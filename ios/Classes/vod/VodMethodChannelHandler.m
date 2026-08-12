// Copyright (c) 2026 Tencent. All rights reserved.
//
// VodMethodChannelHandler.m — unified MethodChannel dispatcher for the Vod
// module on iOS.
//
// Replaces the former Pigeon-based SuperPlayerPlugin.m:
//   - global methods on the TencentVodPlugin channel;
//   - player instance methods on TencentVodPlayer, routed by playerId to the
//     matching FTXVodPlayer;
//   - download / predownload methods on TencentVodDownload;
//   - events are pushed back via invokeMethod: to Dart (dispatched by
//     VodEventDispatcher).

#import "VodMethodChannelHandler.h"
#import "VodGlobalResource.h"
#import "FTXVodPlayer.h"
#import "FTXBasePlayer.h"
#import "FTXDownloadManager.h"
#import "FTXRenderViewFactory.h"
#import "FTXEvent.h"
#import "FTXPlayerConstants.h"
#import "FTXLog.h"
#import "FTXVodPlayerDelegate.h"
#import "FTXLiteAVSDKHeader.h"
#import <UIKit/UIKit.h>

@interface VodMethodChannelHandler () <FTXVodPlayerDelegate>

    @property (nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;

// The three channels.
@property (nonatomic, strong) FlutterMethodChannel *pluginChannel;
@property (nonatomic, strong) FlutterMethodChannel *playerChannel;
@property (nonatomic, strong) FlutterMethodChannel *downloadChannel;

// Player instance table: playerId(NSNumber) -> FTXBasePlayer.
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, FTXBasePlayer *> *players;

@property (nonatomic, strong) FTXDownloadManager *downloadManager;
@property (nonatomic, strong) FTXRenderViewFactory *renderViewFactory;

@end

@implementation VodMethodChannelHandler

#pragma mark - Lifecycle

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [super init];
    if (self) {
        FTXLOGV(@"VodMethodChannelHandler initWithRegistrar");
        _registrar = registrar;
        _players = [NSMutableDictionary dictionary];

        // 1. Three MethodChannels — names strictly aligned with Android / Dart.
        id<FlutterBinaryMessenger> messenger = [registrar messenger];
        _pluginChannel   = [FlutterMethodChannel methodChannelWithName:@"TencentVodPlugin"   binaryMessenger:messenger];
        _playerChannel   = [FlutterMethodChannel methodChannelWithName:@"TencentVodPlayer"   binaryMessenger:messenger];
        _downloadChannel = [FlutterMethodChannel methodChannelWithName:@"TencentVodDownload" binaryMessenger:messenger];

        __weak typeof(self) wself = self;
        [_pluginChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [wself handlePluginCall:call result:result];
        }];
        [_playerChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [wself handlePlayerCall:call result:result];
        }];
        [_downloadChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
            [wself handleDownloadCall:call result:result];
        }];

        // 2. Register the RenderView factory.
        _renderViewFactory = [[FTXRenderViewFactory alloc] initWithBinaryMessenger:messenger];
        [registrar registerViewFactory:_renderViewFactory withId:VIEW_TYPE_FTX_RENDER_VIEW];

        // 3. Download manager: routes calls via the TencentVodDownload channel and
        //    pushes events back through the channel handler.
        _downloadManager = [[FTXDownloadManager alloc] initWithChannelHandler:self];

        // 4. Register with the process-level resource container. The first handler
        //    performs the real bind (TXLiveBase delegate, orientation notification);
        //    subsequent handlers in multi-engine setups only attach.
        [[VodGlobalResource sharedInstance] acquire:self];
    }
    return self;
}

- (void)dealloc {
    [self destroy];
}

- (void)applicationWillTerminate {
    FTXLOGV(@"VodMethodChannelHandler applicationWillTerminate");
    [self destroy];
}

- (void)destroy {
    @synchronized (self) {
        NSArray *allKeys = [self.players allKeys];
        for (NSNumber *key in allKeys) {
            FTXBasePlayer *player = self.players[key];
            if (player && [player respondsToSelector:@selector(destroy)]) {
                [player destroy];
            }
        }
        [self.players removeAllObjects];
    }
    if (self.downloadManager) {
        [self.downloadManager destroy];
        self.downloadManager = nil;
    }
    // Detach the MethodCallHandler on all three channels. Without this, a reused
    // Flutter Engine could keep a stale handler alive and cause leaks / crosstalk.
    [self.pluginChannel setMethodCallHandler:nil];
    [self.playerChannel setMethodCallHandler:nil];
    [self.downloadChannel setMethodCallHandler:nil];

    // Remove self from the process-level resource container. The last handler
    // being released will unbind the TXLiveBase delegate and the orientation
    // notification.
    [[VodGlobalResource sharedInstance] release:self];
}

#pragma mark - Player registry

- (void)registerPlayer:(FTXBasePlayer *)player forPlayerId:(NSNumber *)playerId {
    if (!player || !playerId) return;
    @synchronized (self) {
        self.players[playerId] = player;
    }
}

- (void)unregisterPlayerId:(NSNumber *)playerId {
    if (!playerId) return;
    @synchronized (self) {
        [self.players removeObjectForKey:playerId];
    }
}

- (void)releasePlayerInner:(NSNumber *)playerId {
    if (!playerId) return;
    FTXLOGI(@"releasePlayer :%@", playerId);
    FTXBasePlayer *player = nil;
    @synchronized (self) {
        player = self.players[playerId];
        [self.players removeObjectForKey:playerId];
    }
    if (player && [player respondsToSelector:@selector(destroy)]) {
        [player destroy];
    }
}

#pragma mark - Plugin channel dispatch (global methods)

- (void)handlePluginCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSDictionary *args = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : @{};

    if ([@"getLiteAVSDKVersion" isEqualToString:method] ||
        [@"getPlatformVersion"  isEqualToString:method]) {
        result([TXLiveBase getSDKVersionStr] ?: @"");
        return;
    }

    if ([@"createVodPlayer" isEqualToString:method]) {
        NSNumber *onlyAudioNum = args[@"onlyAudio"];
        BOOL onlyAudio = onlyAudioNum ? [onlyAudioNum boolValue] : NO;
        FTXVodPlayer *player = [[FTXVodPlayer alloc] initWithRegistrar:self.registrar
                                                        channelHandler:self
                                                     renderViewFactory:self.renderViewFactory
                                                             onlyAudio:onlyAudio];
        player.delegate = self;
        NSNumber *playerId = player.playerId;
        [self registerPlayer:player forPlayerId:playerId];
        FTXLOGI(@"createVodPlayer :%@", playerId);
        result(playerId);
        return;
    }

    if ([@"releasePlayer" isEqualToString:method]) {
        NSNumber *playerId = args[@"playerId"];
        [self releasePlayerInner:playerId];
        result(nil);
        return;
    }

    if ([@"setConsoleEnabled" isEqualToString:method]) {
        NSNumber *v = args[@"value"];
        [TXLiveBase setConsoleEnabled:[v boolValue]];
        result(nil);
        return;
    }

    if ([@"setGlobalMaxCacheSize" isEqualToString:method]) {
        NSNumber *v = args[@"value"];
        if (v && [v intValue] > 0) {
            [TXPlayerGlobalSetting setMaxCacheSize:[v intValue]];
        }
        result(nil);
        return;
    }

    if ([@"setGlobalCacheFolderPath" isEqualToString:method]) {
        NSString *postfix = args[@"postfixPath"];
        if (postfix.length > 0) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDirectory = [[paths firstObject] stringByAppendingString:@"/"];
            NSString *preloadDataPath = [documentDirectory stringByAppendingPathComponent:postfix];
            NSError *err = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:preloadDataPath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&err];
            FTXLOGV(@"setGlobalCacheFolderPath:%@", preloadDataPath);
            [TXPlayerGlobalSetting setCacheFolderPath:preloadDataPath];
            result(@YES);
        } else {
            result(@NO);
        }
        return;
    }

    if ([@"setGlobalCacheFolderCustomPath" isEqualToString:method]) {
        // Dart-side key is "iOSAbsolutePath"; it must match exactly.
        NSString *cachePath = args[@"iOSAbsolutePath"];
        if (cachePath.length > 0) {
            NSError *err = nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath
                                      withIntermediateDirectories:NO
                                                       attributes:nil
                                                            error:&err];
            FTXLOGV(@"setGlobalCacheFolderCustomPath:%@", cachePath);
            [TXPlayerGlobalSetting setCacheFolderPath:cachePath];
            result(@YES);
        } else {
            result(@NO);
        }
        return;
    }

    if ([@"setGlobalLicense" isEqualToString:method]) {
        NSString *licenseUrl = args[@"licenseUrl"];
        NSString *licenseKey = args[@"licenseKey"];
        [TXLiveBase setLicenceURL:licenseUrl ?: @"" key:licenseKey ?: @""];
        result(nil);
        return;
    }

    if ([@"setLogLevel" isEqualToString:method]) {
        NSNumber *v = args[@"value"];
        if (v) {
            [TXLiveBase setLogLevel:[v intValue]];
            [FTXLog setLogLevel:[v intValue]];
        }
        result(nil);
        return;
    }

    if ([@"setGlobalEnv" isEqualToString:method]) {
        NSString *envConfig = args[@"value"];
        int code = [TXLiveBase setGlobalEnv:[envConfig UTF8String]];
        result(@(code));
        return;
    }

    if ([@"startVideoOrientationService" isEqualToString:method]) {
        // iOS does not need a dedicated orientation service (the observer is
        // installed at init time). Return true directly.
        result(@YES);
        return;
    }

    if ([@"setUserId" isEqualToString:method]) {
        NSString *v = args[@"value"];
        [TXLiveBase setUserId:v ?: @""];
        result(nil);
        return;
    }

    if ([@"setLicenseFlexibleValid" isEqualToString:method]) {
        NSNumber *v = args[@"value"];
        [TXPlayerGlobalSetting setLicenseFlexibleValid:[v boolValue]];
        result(nil);
        return;
    }

    if ([@"setDrmProvisionEnv" isEqualToString:method]) {
        // Android-only; a no-op on iOS to keep the interface aligned.
        result(nil);
        return;
    }

    if ([@"isDeviceSupportPip" isEqualToString:method]) {
        BOOL isSupport = [TXVodPlayer isSupportPictureInPicture];
        int supportResult = isSupport ? 0 : ERROR_IOS_PIP_DEVICE_NOT_SUPPORT;
        result(@(supportResult));
        return;
    }

    result(FlutterMethodNotImplemented);
}

#pragma mark - Player channel dispatch

- (void)handlePlayerCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *args = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : @{};
    NSNumber *playerId = args[@"playerId"];

    FTXBasePlayer *player = nil;
    @synchronized (self) {
        player = playerId ? self.players[playerId] : nil;
    }
    if (!player) {
        FTXLOGE(@"player not found for method:%@ playerId:%@", call.method, playerId);
        result([FlutterError errorWithCode:@"PLAYER_NOT_FOUND"
                                   message:[NSString stringWithFormat:@"playerId %@ not registered", playerId]
                                   details:nil]);
        return;
    }

    // FTXVodPlayer implements -onMethodCall:result:; forward the call to it.
    if ([player respondsToSelector:@selector(onMethodCall:result:)]) {
        [(id)player onMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Download channel dispatch

- (void)handleDownloadCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    // FTXDownloadManager implements -handleMethodCall:result:; forward the call to it.
    if (self.downloadManager) {
        [self.downloadManager handleMethodCall:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

#pragma mark - Event push-back (used by FTXVodPlayer / FTXDownloadManager)

- (void)invokePlayerEventWithPlayerId:(NSNumber *)playerId event:(NSDictionary *)event {
    if (!playerId || !event) return;
    [self.playerChannel invokeMethod:@"onPlayerEvent"
                           arguments:@{@"playerId": playerId, @"event": event}];
}

- (void)invokePlayerNetEventWithPlayerId:(NSNumber *)playerId event:(NSDictionary *)event {
    if (!playerId || !event) return;
    [self.playerChannel invokeMethod:@"onPlayerNetEvent"
                           arguments:@{@"playerId": playerId, @"event": event}];
}

- (void)invokePipEvent:(NSDictionary *)event {
    if (!event) return;
    [self.playerChannel invokeMethod:@"onPipEvent" arguments:event];
}

- (void)invokeDownloadEvent:(NSDictionary *)event {
    if (!event) return;
    [self.downloadChannel invokeMethod:@"onDownloadEvent" arguments:event];
}

- (void)invokePreDownloadEvent:(NSDictionary *)event {
    if (!event) return;
    [self.downloadChannel invokeMethod:@"onPreDownloadEvent" arguments:event];
}

- (void)invokeSDKListenerEvent:(NSDictionary *)event {
    if (!event) return;
    [self.pluginChannel invokeMethod:@"onSDKListener" arguments:event];
}

- (void)invokeNativeEvent:(NSDictionary *)event {
    if (!event) return;
    [self.pluginChannel invokeMethod:@"onNativeEvent" arguments:event];
}

#pragma mark - Global event fan-out (called by VodGlobalResource)

- (void)dispatchLicenceLoadedWithResult:(int)result reason:(NSString *)reason {
    // Aligned with Android: EVENT_RESULT / EVENT_REASON are flattened at the top level.
    [self invokeSDKListenerEvent:@{
        @"event": @(EVENT_ON_LICENCE_LOADED),
        @(EVENT_RESULT): @(result),
        @(EVENT_REASON): reason ?: @"",
    }];
}

- (void)dispatchOrientationChanged:(int)orientation {
    [self invokeNativeEvent:@{
        @"event": @(EVENT_ORIENTATION_CHANGED),
        EXTRA_NAME_ORIENTATION: @(orientation)
    }];
}

#pragma mark - FTXVodPlayerDelegate (PiP callbacks -> onPipEvent)

- (void)onPlayerPipRequestStart {
    [self invokePipEvent:@{@"event": @(EVENT_PIP_MODE_REQUEST_START)}];
}

- (void)onPlayerPipStateDidStart {
    [self invokePipEvent:@{@"event": @(EVENT_PIP_MODE_ALREADY_ENTER)}];
}

- (void)onPlayerPipStateWillStop {
    [self invokePipEvent:@{@"event": @(EVENT_PIP_MODE_WILL_EXIT)}];
}

- (void)onPlayerPipStateDidStop {
    [self invokePipEvent:@{@"event": @(EVENT_PIP_MODE_ALREADY_EXIT)}];
}

- (void)onPlayerPipStateError:(NSInteger)errorId {
    [self invokePipEvent:@{@"event": @(errorId)}];
}

- (void)onPlayerPipStateRestoreUI:(double)playTime {
    [self invokePipEvent:@{@"event": @(EVENT_PIP_MODE_RESTORE_UI),
                           EVENT_PIP_PLAY_TIME: @(playTime)}];
}

@end
