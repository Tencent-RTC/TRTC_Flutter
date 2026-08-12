// Copyright (c) 2022 Tencent. All rights reserved.

#import "FTXVodPlayer.h"
#import "FTXTransformation.h"
#import "FTXLiteAVSDKHeader.h"
#import <stdatomic.h>
#import <libkern/OSAtomic.h>
#import <Flutter/Flutter.h>
#import <AVKit/AVKit.h>
#import "FTXEvent.h"
#import "FTXLog.h"
#import "FTXImgTools.h"
#import "FTXTextureView.h"
#import "FTXPlayerConstants.h"
#import "VodMethodChannelHandler.h"

static const int uninitialized = -1;

@interface FTXVodPlayer ()<TXVodPlayListener, TXVideoCustomProcessDelegate>

@property (nonatomic, assign) BOOL hasEnteredPipMode;
@property (nonatomic, assign) BOOL restoreUI;
@property (atomic, assign) BOOL isStoped;
@property (atomic) BOOL isTerminate;
@property (nonatomic, weak) VodMethodChannelHandler *channelHandler;
@property (nonatomic, strong) FTXRenderViewFactory *renderViewFactory;
@property (nonatomic, strong) FTXRenderView *curRenderView;
@property (nonatomic, assign) NSUInteger renderMode;
@property (nonatomic, assign) float cacheStartTime;

@end
/**
 VOD player TXVodPlayer processing class.
 */
@implementation FTXVodPlayer {
    TXVodPlayer *_txVodPlayer;
    TXImageSprite *_txImageSprite;
    
    id<FlutterPluginRegistrar> _registrar;
    
    float currentPlayTime;
    BOOL volatile isVideoFirstFrameReceived;
    NSNumber *videoWidth;
    NSNumber *videoHeight;
    // Main thread queue, used to ensure that video playback events are executed in order.
    dispatch_queue_t playerMainqueue;
}

- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                   channelHandler:(VodMethodChannelHandler *)channelHandler
                renderViewFactory:(FTXRenderViewFactory*)renderViewFactory
                        onlyAudio:(BOOL)onlyAudio
{
    if (self = [self init]) {
        _registrar = registrar;
        _channelHandler = channelHandler;
        isVideoFirstFrameReceived = false;
        videoWidth = 0;
        videoHeight = 0;
        _isStoped = NO;
        _isTerminate = NO;
        playerMainqueue = dispatch_get_main_queue();
        self.curRenderView = nil;
        self.hasEnteredPipMode = NO;
        self.restoreUI = NO;
        self.renderViewFactory = renderViewFactory;
        self.renderMode = FULL_FILL_CONTAINER;
        self.cacheStartTime = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onApplicationTerminateClick) name:UIApplicationWillTerminateNotification object:nil];
        [self createPlayer:onlyAudio];
    }
    
    return self;
}

- (void)onApplicationTerminateClick {
    _isTerminate = YES;
    [self stopPlay];
    if (nil != _txVodPlayer) {
        [self setRenderView:nil];
        _txVodPlayer = nil;
        _txVodPlayer.videoProcessDelegate = nil;
    }
}

- (void)notifyAppTerminate:(UIApplication *)application {
    if (!_isTerminate) {
        FTXLOGW(@"vodPlayer is called _isTerminate terminate");
        [self notifyPlayerTerminate];
    }
}

- (void)dealloc
{
    if (!_isTerminate) {
        FTXLOGW(@"vodPlayer is called delloc terminate");
        [self notifyPlayerTerminate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notifyPlayerTerminate {
    FTXLOGW(@"vodPlayer notifyPlayerTerminate");
    if (nil != _txVodPlayer) {
        [_txVodPlayer removeVideoWidget];
        [self setRenderView:nil];
        _txVodPlayer.vodDelegate = nil;
    }
    self.curRenderView = nil;
    _isTerminate = YES;
    [self stopPlay];
    _txVodPlayer = nil;
}

- (void)destroy
{
    FTXLOGV(@"vodPlayer start called destroy");
    [self stopPlay];
    if (nil != _txVodPlayer) {
        [self setRenderView:nil];
        [_txVodPlayer removeVideoWidget];
        _txVodPlayer = nil;
    }

    self.curRenderView = nil;
    self.cacheStartTime = 0;
    
    _hasEnteredPipMode = NO;
    _restoreUI = NO;
    [self releaseImageSprite];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupPlayerWithBool:(BOOL)onlyAudio
{
    if (!onlyAudio) {
        if (_txVodPlayer != nil) {
            if (nil != self.curRenderView) {
                [self.curRenderView setPlayer:self];
            }
            [_txVodPlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        }
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:@(0xFFFFFFFF) forKey:@"fontColor"];
        [dic setObject:@(0) forKey:@"bondFont"];
        [dic setObject:@(1) forKey:@"outlineWidth"];
        [dic setObject:@(0xFF000000) forKey:@"outlineColor"];
        [self setSubtitleStyleWithDict:dic];
    }
}

- (void)setSubtitleStyleWithDict:(NSDictionary *)dic {
    TXPlayerSubtitleRenderModel *model = [[TXPlayerSubtitleRenderModel alloc] init];
    model.canvasWidth = 1920;
    model.canvasHeight = 1080;
    model.isBondFontStyle = [dic[@"bondFont"] boolValue];
    model.fontColor = [(NSNumber *)dic[@"fontColor"] unsignedIntValue];
    model.outlineWidth = [(NSNumber *)dic[@"outlineWidth"] floatValue];
    model.outlineColor = [(NSNumber *)dic[@"outlineColor"] unsignedIntValue];
    [_txVodPlayer setSubtitleStyle:model];
}

#pragma mark - 内部 API

- (NSNumber*)createPlayer:(BOOL)onlyAudio
{
    if (_txVodPlayer == nil) {
        _txVodPlayer = [TXVodPlayer new];
        _txVodPlayer.vodDelegate = self;
        TXVodPlayConfig *vodConfig = [[TXVodPlayConfig alloc] init];
        NSMutableDictionary<NSString *, id> *newExtInfoMap = [NSMutableDictionary dictionary];
        [newExtInfoMap setObject:@(0) forKey:@"450"];
        [vodConfig setExtInfoMap:newExtInfoMap];
        [_txVodPlayer setConfig:vodConfig];
        [self setupPlayerWithBool:onlyAudio];
    }
    return [NSNumber numberWithLongLong:NO_ERROR];
}

- (void)setIsAutoPlay:(BOOL)b
{
    if (_txVodPlayer != nil) {
        _txVodPlayer.isAutoPlay = b;
    }
}

- (int)startVodPlay:(NSString *)url
{
    if (_txVodPlayer != nil) {
        _isStoped = NO;
        return [_txVodPlayer startVodPlay:url];
    }
    return uninitialized;
}

- (int)startVodPlayWithParams:(int)appId fileId:(NSString *)fileId sign:(NSString *)sign
{
    if (_txVodPlayer != nil) {
        TXPlayerAuthParams *p = [TXPlayerAuthParams new];
        p.appId = appId;
        p.fileId = fileId;
        p.https = YES;
        if (sign.length > 0) {
            p.sign = sign;
        }
        _isStoped = NO;
        return [_txVodPlayer startVodPlayWithParams:p];
    }
    return uninitialized;
}

- (BOOL)stopPlay
{
    if (_txVodPlayer != nil) {
        _isStoped = YES;
        BOOL result = [_txVodPlayer stopPlay];
        if (self.cacheStartTime > 0) {
            [self setStartTimeInner:self.cacheStartTime];
        }
        return result;
    }
    [self releaseImageSprite];
    return NO;
}

- (BOOL)isPlaying
{
    if (_txVodPlayer != nil) {
        return [_txVodPlayer isPlaying];
    }
    return NO;
}

- (void)pause
{
    if (_txVodPlayer != nil) {
        return [_txVodPlayer pause];
    }
}

- (void)resume
{
    if (_txVodPlayer != nil) {
        return [_txVodPlayer resume];
    }
}

- (void)setMute:(BOOL)bEnable
{
    if (_txVodPlayer != nil) {
        return [_txVodPlayer setMute:bEnable];
    }
}

- (void)setLoop:(BOOL)bLoop
{
    if (_txVodPlayer != nil) {
        _txVodPlayer.loop = bLoop;
    }
}

- (void)seek:(float)progress
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer seek:progress];
    }
}

- (void)seekToPdtTimeMs:(long long)pdtTimeMs
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer seekToPdtTime:pdtTimeMs];
    }
}

- (void)setRate:(float)rate
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer setRate:rate];
    }
}

- (NSArray *)supportedBitrates
{
    if (_txVodPlayer != nil) {
        NSArray *itemList = [_txVodPlayer supportedBitrates];
        NSMutableArray *bitrates = @[].mutableCopy;
        for (TXBitrateItem *item in itemList) {
            [bitrates addObject:@{@"index": @(item.index), @"width": @(item.width), @"height": @(item.height), @"bitrate": @(item.bitrate)}];
        }
        return bitrates;
    }
    return @[];
}

- (void)setBitrateIndex:(int)index
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer setBitrateIndex:index];
    }
}

- (void)setStartTimeInner:(float)startTime
{
    if (_txVodPlayer != nil) {
        self.cacheStartTime = startTime;
        [_txVodPlayer setStartTime:startTime];
    }
}

- (void)setAudioPlayoutVolume:(int)volume
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer setAudioPlayoutVolume:volume];
    }
}

- (void)setRenderRotation:(int)rotation
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer setRenderRotation:rotation];
    }
}

- (void)setMirror:(BOOL)isMirror
{
    if (_txVodPlayer != nil) {
        [_txVodPlayer setMirror:isMirror];
    }
}

- (void)releaseImageSprite
{
    if(_txImageSprite) {
        _txImageSprite = nil;
    }
}

- (void)setPlayerImageSprite:(NSString*)urlStr withImgArray:(NSArray*)imgStrArray {
    [self releaseImageSprite];
    _txImageSprite = [[TXImageSprite alloc] init];
    NSMutableArray *imageUrls = @[].mutableCopy;
    NSURL *vvtUrl = nil;
    if(imgStrArray && [NSNull null] != (NSNull *)imgStrArray) {
        for(NSString *url in imgStrArray) {
            NSURL *nsurl = [NSURL URLWithString:url];
            if (nsurl) {
                [imageUrls addObject:nsurl];
            }
        }
    }
    if(urlStr && urlStr.length > 0) {
        vvtUrl =  [NSURL URLWithString:urlStr];
    }
    if (vvtUrl && imageUrls.count > 0) {
        [_txImageSprite setVTTUrl:vvtUrl imageUrls:imageUrls];
    }
}

- (NSData*)getPlayerImageSprite:(NSNumber*)time {
    if(_txImageSprite && [NSNull null] != (NSNull*)time) {
        UIImage *imageSprite = [_txImageSprite getThumbnail:time.floatValue];
        if(nil != imageSprite) {
            NSData *data = UIImagePNGRepresentation(imageSprite);
            return data;
        }
    } else {
        FTXLOGE(@"getImageSprite failed, time is null or initImageSprite not invoke");
    }
    return nil;
}

- (void)setPlayerConfigWithDict:(NSDictionary *)dict {
    if (_txVodPlayer == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    TXVodPlayConfig *vodConfig = [FTXTransformation transformToVodConfigFromDict:dict];
    NSMutableDictionary<NSString *, id> *newExtInfoMap = [NSMutableDictionary dictionary];
    NSDictionary *extInfoMap = vodConfig.extInfoMap;
    if (extInfoMap != nil && [extInfoMap count] > 0) {
        [newExtInfoMap addEntriesFromDictionary:extInfoMap];
    }
    [newExtInfoMap setObject:@(0) forKey:@"450"];
    [vodConfig setExtInfoMap:newExtInfoMap];
    _txVodPlayer.config = vodConfig;
}

- (float)getCurrentPlaybackTime
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.currentPlaybackTime;
    }
    return 0;
}

- (float)getDuration
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.duration;
    }
    return 0;
}

- (float)getPlayableDuration
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.playableDuration;
    }
    return 0;
}

- (int)getWidth
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.width;
    }
    return 0;
}

- (int)getHeight
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.height;
    }
    return 0;
}

- (void)setToken:(NSString *)token
{
    if(_txVodPlayer != nil) {
        if(token && token.length > 0) {
            _txVodPlayer.token = token;
        } else {
            _txVodPlayer.token = nil;
        }
    }
}

- (BOOL)isLoop
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.loop;
    }
    return false;
}

- (BOOL)enableHardwareDecode:(BOOL)enable
{
    if(_txVodPlayer != nil) {
        _txVodPlayer.enableHWAcceleration = enable;
        return true;
    }
    return false;
}

- (void)snapShot:(void (^)(UIImage *))listener
{
    if(_txVodPlayer != nil) {
        [_txVodPlayer snapshot:listener];
    }
}

- (void)setRenderMode:(NSUInteger)renderMode
{
    self->_renderMode = renderMode;
    if(_txVodPlayer != nil) {
        if (renderMode == ADJUST_RESOLUTION) {
            [_txVodPlayer setRenderMode:RENDER_MODE_FILL_EDGE];
        } else if (renderMode == FULL_FILL_CONTAINER) {
            [_txVodPlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        }
    } else {
        FTXLOGW(@"miss player when setRenderMode");
    }
}

- (long)getBitrateIndex
{
    if(_txVodPlayer != nil) {
        return _txVodPlayer.bitrateIndex;
    }
    return -1;
}

- (int)enterPictureInPictureMode {
    if (_hasEnteredPipMode) {
        return ERROR_IOS_PIP_IS_RUNNING;
    }
    
    if (![TXVodPlayer isSupportPictureInPicture]) {
        return ERROR_IOS_PIP_DEVICE_NOT_SUPPORT;
    }
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerPipRequestStart)]) {
        [self.delegate onPlayerPipRequestStart];
    }
    
    [_txVodPlayer enterPictureInPicture];
    
    return NO_ERROR;
}

- (void)enableTRTC:(BOOL)isEnabled {
#if SDK_IS_PRO
    if (nil != _txVodPlayer) {
        if (isEnabled) {
            NSObject *trtcCloud = [TRTCCloud sharedInstance];
            [_txVodPlayer attachTRTC:trtcCloud];
        } else {
            [_txVodPlayer detachTRTC];
        }
    }
#else
    FTXLOGE(@"enableTRTC must use professional or professional_premium sdk");
#endif
}

- (void)setPlayerViewWithRenderViewId:(NSInteger)renderViewId {
    FTXLOGI(@"setPlayerView, renderViewId:%ld", (long)renderViewId);
    FTXRenderView *renderView = [self.renderViewFactory findViewById:(NSUInteger)renderViewId];
    if (nil != renderView) {
        self.curRenderView = renderView;
        [renderView setPlayer:self];
    } else {
        self.curRenderView = nil;
        [self setRenderView:nil];
        FTXLOGE(@"setPlayerView can not find renderView by id: %ld, release player's renderView", (long)renderViewId);
    }
}

- (void)setRenderView:(FTXTextureView*)renderView {
    if (nil != _txVodPlayer) {
        if (renderView != nil) {
            [_txVodPlayer setupVideoWidget:renderView insertIndex:0];
        } else {
            self.renderControl = nil;
        }
    }
}

#pragma mark - TXVodPlayListener

- (void)onPlayEvent:(TXVodPlayer *)player event:(int)evtID withParam:(NSDictionary*)param
{
    // Hand over the first frame event timing to Flutter for shared texture processing.
    if (evtID == PLAY_EVT_RCV_FIRST_I_FRAME) {
        currentPlayTime = 0;
        NSMutableDictionary *mutableDic = param.mutableCopy;
        self->videoWidth = param[@"EVT_WIDTH"];
        self->videoHeight = param[@"EVT_HEIGHT"];
        mutableDic[@"EVT_PARAM1"] = self->videoWidth;
        mutableDic[@"EVT_PARAM2"] = self->videoHeight;
        param = mutableDic;
    } else if(evtID == PLAY_EVT_CHANGE_RESOLUTION) {
        dispatch_async(playerMainqueue, ^{
            self->videoWidth = param[@"EVT_PARAM1"];
            self->videoHeight = param[@"EVT_PARAM2"];
        });
    } else if(evtID == PLAY_EVT_PLAY_PROGRESS) {
        float progressSec = [param[EVT_PLAY_PROGRESS] floatValue];
        float durationSec = [param[EVT_PLAY_DURATION] floatValue];
        float playableDurationSec = [param[EVT_PLAYABLE_DURATION] floatValue];
        NSMutableDictionary *dic = param.mutableCopy;
        NSInteger playableDurationMillisec = (NSInteger)(playableDurationSec * 1000);
        NSInteger durationMillisec = (NSInteger)(durationSec * 1000);
        NSInteger progressMillisec = (NSInteger)(progressSec * 1000);
        dic[EVT_FLUTTER_PLAYABLE_DURATION] = @(playableDurationSec);
        dic[EVT_FLUTTER_PLAYABLE_DURATION_MS] = @(playableDurationMillisec);
        dic[EVT_FLUTTER_DURATION_MS] = @(durationMillisec);
        dic[EVT_FLUTTER_PROGRESS_MS] = @(progressMillisec);
        currentPlayTime = progressSec;
        param = dic;
    } else if(evtID == PLAY_EVT_PLAY_BEGIN) {
        currentPlayTime = 0;
    } else if(evtID == PLAY_EVT_START_VIDEO_DECODER) {
        dispatch_async(playerMainqueue, ^{
            self->isVideoFirstFrameReceived = false;
        });
    }
    if (evtID != PLAY_EVT_PLAY_PROGRESS) {
        FTXLOGI(@"onPlayEvent:%i,%@", evtID, param[EVT_PLAY_DESCRIPTION]);
    }
    // Flatten the event params into the top-level map (aligned with Android:
    // {event: evtID, ...param}), so that the Dart side can read EVT_WIDTH /
    // EVT_PARAM1 etc. without an extra "params" wrapping layer.
    NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
    if ([param isKindOfClass:[NSDictionary class]]) {
        [eventDict addEntriesFromDictionary:param];
    }
    eventDict[@"event"] = @(evtID);
    [self.channelHandler invokePlayerEventWithPlayerId:self.playerId event:eventDict];
}

/**
 * Network status notification.
 */
- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary*)param
{
    // Aligned with Android: network status params are flattened to the top-level map.
    NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
    if ([param isKindOfClass:[NSDictionary class]]) {
        [eventDict addEntriesFromDictionary:param];
    }
    [self.channelHandler invokePlayerNetEventWithPlayerId:self.playerId event:eventDict];
}

- (BOOL)onPlayerPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    return NO;
}

/**
 * 字幕数据回调
 */
- (void)onPlayer:(TXVodPlayer *)player subtitleData:(TXVodSubtitleData *)subtitleData
{
    // Aligned with Android: subtitle fields are flattened into the event map.
    NSMutableDictionary *eventDict = [[NSMutableDictionary alloc] init];
    eventDict[EXTRA_SUBTITLE_DATA] = subtitleData.subtitleData;
    eventDict[EXTRA_SUBTITLE_START_POSITION_MS] = @(subtitleData.startPositionMs);
    eventDict[EXTRA_SUBTITLE_DURATION_MS] = @(subtitleData.durationMs);
    eventDict[EXTRA_SUBTITLE_TRACK_INDEX] = @(subtitleData.trackIndex);
    eventDict[@"event"] = @(EVENT_SUBTITLE_DATA);
    [self.channelHandler invokePlayerEventWithPlayerId:self.playerId event:eventDict];
}

#pragma mark - Private Method

- (BOOL)isCurrentLanguageHans
{
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages objectAtIndex:0];
    if ([currentLanguage isEqualToString:@"zh-Hans-CN"])
    {
        return YES;
    }
    return NO;
}

- (CVPixelBufferRef)getPipImagePixelBuffer
{
    NSString *imagePath;
    if ([self isCurrentLanguageHans]) {
        imagePath = [[NSBundle mainBundle] pathForResource:@"pictureInpicture_zh" ofType:@"jpg"];
    } else {
        imagePath = [[NSBundle mainBundle] pathForResource:@"pictureInpicture_en" ofType:@"jpg"];
    }

    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return [FTXImgTools CVPixelBufferRefFromUiImage:image];
}

#pragma mark - PIP delegate
- (void)onPlayer:(TXVodPlayer *)player pictureInPictureStateDidChange:(TX_VOD_PLAYER_PIP_STATE)pipState withParam:(NSDictionary *)param {
    if (pipState == TX_VOD_PLAYER_PIP_STATE_DID_START) {
        self.hasEnteredPipMode = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerPipStateDidStart)]) {
            [self.delegate onPlayerPipStateDidStart];
        }
    }
    
    if (pipState == TX_VOD_PLAYER_PIP_STATE_WILL_STOP) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerPipStateWillStop)]) {
            [self.delegate onPlayerPipStateWillStop];
        }
    }
    
    if (pipState == TX_VOD_PLAYER_PIP_STATE_DID_STOP) {
        self.hasEnteredPipMode = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [player exitPictureInPicture];
            }

            if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerPipStateDidStop)]) {
                [self.delegate onPlayerPipStateDidStop];
            }
        });
    }
    
    if (pipState == TX_VOD_PLAYER_PIP_STATE_RESTORE_UI) {
        self.restoreUI = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [player exitPictureInPicture];
            [self->_txVodPlayer resume];
        });
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerPipStateRestoreUI:)]) {
            [self.delegate onPlayerPipStateRestoreUI:currentPlayTime];
        }
    }
}

- (void)onPlayer:(TXVodPlayer *)player pictureInPictureErrorDidOccur:(TX_VOD_PLAYER_PIP_ERROR_TYPE)errorType withParam:(NSDictionary *)param {
    NSInteger type = errorType;
    switch (errorType) {
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_NONE:
            type = NO_ERROR;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_DEVICE_NOT_SUPPORT:
            type = ERROR_IOS_PIP_DEVICE_NOT_SUPPORT;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_PLAYER_NOT_SUPPORT:
            type = ERROR_IOS_PIP_PLAYER_NOT_SUPPORT;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_VIDEO_NOT_SUPPORT:
            type = ERROR_IOS_PIP_VIDEO_NOT_SUPPORT;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_IS_NOT_POSSIBLE:
            type = ERROR_IOS_PIP_IS_NOT_POSSIBLE;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_ERROR_FROM_SYSTEM:
            type = ERROR_IOS_PIP_FROM_SYSTEM;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_PLAYER_NOT_EXIST:
            type = ERROR_IOS_PIP_PLAYER_NOT_EXIST;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_IS_RUNNING:
            type = ERROR_IOS_PIP_IS_RUNNING;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_NOT_RUNNING:
            type = ERROR_IOS_PIP_NOT_RUNNING;
            break;
        case TX_VOD_PLAYER_PIP_ERROR_TYPE_PIP_START_TIMEOUT:
            type = ERROR_IOS_PIP_START_TIME_OUT;
            break;
        default:
            type = errorType;
            break;
    }
    self.hasEnteredPipMode = NO;
    FTXLOGE(@"[onPlayer], pictureInPictureErrorDidOccur errorType= %ld", (long)type);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPlayerPipStateError:)]) {
        [self.delegate onPlayerPipStateError:type];
    }
}

- (void)onPlayer:(TXVodPlayer *)player airPlayErrorDidOccur:(TX_VOD_PLAYER_AIRPLAY_ERROR_TYPE)errorType withParam:(NSDictionary *)param {
}

- (void)onPlayer:(TXVodPlayer *)player airPlayStateDidChange:(TX_VOD_PLAYER_AIRPLAY_STATE)airPlayState withParam:(NSDictionary *)param {
}

#pragma mark - MethodChannel dispatch

/**
 TencentVodPlayer MethodChannel entry point.
 Every Dart -> Native player instance method is dispatched here by method name.
 Arguments are read from call.arguments (NSDictionary) by their agreed keys.
 "playerId" has already been matched by VodMethodChannelHandler before routing
 (a miss would have returned PLAYER_NOT_FOUND), so no extra check is needed here.
 */
- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    NSDictionary *args = [call.arguments isKindOfClass:[NSDictionary class]] ? call.arguments : @{};

    // ======================== Playback control ========================
    if ([@"initialize" isEqualToString:method]) {
        BOOL onlyAudio = [args[@"onlyAudio"] boolValue];
        NSNumber *textureId = [self createPlayer:onlyAudio];
        result(textureId);
        return;
    }
    if ([@"startVodPlay" isEqualToString:method]) {
        // Dart-side key is "value", matching startVodPlay(String url).
        NSString *url = args[@"value"];
        int r = [self startVodPlay:url ?: @""];
        // Return NSNumber(BOOL) explicitly so Flutter does not decode it as int.
        result(r == 0 ? @YES : @NO);
        return;
    }
    if ([@"startVodPlayWithParams" isEqualToString:method]) {
        NSNumber *appId = args[@"appId"];
        NSString *fileId = args[@"fileId"];
        NSString *psign = args[@"psign"];
        [self startVodPlayWithParams:(appId ? appId.intValue : 0) fileId:fileId sign:psign];
        result(nil);
        return;
    }
    if ([@"stop" isEqualToString:method]) {
        // Dart-side key is always "value".
        BOOL isNeedClear = [args[@"value"] boolValue];
        if (_txVodPlayer) {
            TXVodPlayConfig *config = _txVodPlayer.config;
            config.keepLastFrameWhenStop = !isNeedClear;
            [_txVodPlayer setConfig:config];
        }
        BOOL r = [self stopPlay];
        // Return NSNumber(BOOL) explicitly so Flutter does not decode it as int.
        result(r ? @YES : @NO);
        return;
    }
    if ([@"isPlaying" isEqualToString:method]) {
        result([self isPlaying] ? @YES : @NO);
        return;
    }
    if ([@"pause" isEqualToString:method]) {
        [self pause];
        result(nil);
        return;
    }
    if ([@"resume" isEqualToString:method]) {
        [self resume];
        result(nil);
        return;
    }
    if ([@"setMute" isEqualToString:method]) {
        [self setMute:[args[@"value"] boolValue]];
        result(nil);
        return;
    }
    if ([@"setLoop" isEqualToString:method]) {
        [self setLoop:[args[@"value"] boolValue]];
        result(nil);
        return;
    }
    if ([@"isLoop" isEqualToString:method]) {
        result([self isLoop] ? @YES : @NO);
        return;
    }
    if ([@"seek" isEqualToString:method]) {
        [self seek:[args[@"value"] floatValue]];
        result(nil);
        return;
    }
    if ([@"seekToPdtTime" isEqualToString:method]) {
        [self seekToPdtTimeMs:[args[@"value"] longLongValue]];
        result(nil);
        return;
    }
    if ([@"setRate" isEqualToString:method]) {
        [self setRate:[args[@"value"] floatValue]];
        result(nil);
        return;
    }
    if ([@"setAutoPlay" isEqualToString:method]) {
        [self setIsAutoPlay:[args[@"value"] boolValue]];
        result(nil);
        return;
    }
    if ([@"setStartTime" isEqualToString:method]) {
        [self setStartTimeInner:[args[@"value"] floatValue]];
        result(nil);
        return;
    }
    if ([@"setAudioPlayOutVolume" isEqualToString:method]) {
        [self setAudioPlayoutVolume:[args[@"value"] intValue]];
        result(nil);
        return;
    }
    if ([@"setRequestAudioFocus" isEqualToString:method]) {
        // iOS has no equivalent; keep the interface aligned with a no-op.
        result(@YES);
        return;
    }
    if ([@"setConfig" isEqualToString:method]) {
        // Dart side passes config.toMap() flattened (no "config" wrapping key),
        // so just use args directly.
        [self setPlayerConfigWithDict:args];
        result(nil);
        return;
    }
    if ([@"setToken" isEqualToString:method]) {
        [self setToken:args[@"value"] ?: @""];
        result(nil);
        return;
    }
    if ([@"enableHardwareDecode" isEqualToString:method]) {
        BOOL r = [self enableHardwareDecode:[args[@"value"] boolValue]];
        result(r ? @YES : @NO);
        return;
    }

    // ======================== Rendering ========================
    if ([@"setPlayerView" isEqualToString:method]) {
        NSInteger renderViewId = [args[@"renderViewId"] integerValue];
        [self setPlayerViewWithRenderViewId:renderViewId];
        result(nil);
        return;
    }
    if ([@"setRenderMode" isEqualToString:method]) {
        NSInteger renderMode = [args[@"renderMode"] integerValue];
        if (self.renderMode != (NSUInteger)renderMode) {
            [self setRenderMode:renderMode];
        }
        result(nil);
        return;
    }
    if ([@"reDraw" isEqualToString:method]) {
        result(nil);
        return;
    }

    // ======================== Bitrate / Resolution ========================
    if ([@"getSupportedBitrate" isEqualToString:method]) {
        result([self supportedBitrates]);
        return;
    }
    if ([@"getBitrateIndex" isEqualToString:method]) {
        result(@([self getBitrateIndex]));
        return;
    }
    if ([@"setBitrateIndex" isEqualToString:method]) {
        [self setBitrateIndex:[args[@"value"] intValue]];
        result(nil);
        return;
    }

    // ======================== Duration / Size ========================
    if ([@"getCurrentPlaybackTime" isEqualToString:method]) {
        result(@([self getCurrentPlaybackTime]));
        return;
    }
    if ([@"getDuration" isEqualToString:method]) {
        result(@([self getDuration]));
        return;
    }
    if ([@"getPlayableDuration" isEqualToString:method]) {
        result(@([self getPlayableDuration]));
        return;
    }
    if ([@"getWidth" isEqualToString:method]) {
        result(@([self getWidth]));
        return;
    }
    if ([@"getHeight" isEqualToString:method]) {
        result(@([self getHeight]));
        return;
    }
    if ([@"getBufferDuration" isEqualToString:method]) {
        // iOS has no standalone implementation; return 0 to keep the interface aligned.
        result(@0);
        return;
    }

    // ======================== Image sprite ========================
    if ([@"initImageSprite" isEqualToString:method]) {
        NSString *vvtUrl = args[@"vvtUrl"];
        NSArray *imageUrls = args[@"imageUrls"];
        [self setPlayerImageSprite:vvtUrl withImgArray:imageUrls];
        result(nil);
        return;
    }
    if ([@"getImageSprite" isEqualToString:method]) {
        NSNumber *time = args[@"value"];
        NSData *data = [self getPlayerImageSprite:time];
        result(data ?: [NSNull null]);
        return;
    }

    // ======================== DRM ========================
    if ([@"startPlayDrm" isEqualToString:method]) {
        if (nil == _txVodPlayer) {
            result(@(uninitialized));
            return;
        }
        TXPlayerDrmBuilder *builder = [[TXPlayerDrmBuilder alloc] init];
        builder.playUrl = args[@"playUrl"] ?: @"";
        builder.keyLicenseUrl = args[@"licenseUrl"] ?: @"";
        NSString *deviceCertificateUrl = args[@"deviceCertificateUrl"];
        if (deviceCertificateUrl) {
            builder.deviceCertificateUrl = deviceCertificateUrl;
        }
        int r = [_txVodPlayer startPlayDrm:builder];
        result(@(r));
        return;
    }

    // ======================== Subtitle / Audio track ========================
    if ([@"addSubtitleSource" isEqualToString:method]) {
        if (nil != _txVodPlayer) {
            NSString *url = args[@"url"];
            NSString *name = args[@"name"];
            NSString *mimeStr = args[@"mimeType"];
            TX_VOD_PLAYER_SUBTITLE_MIME_TYPE mimeType = TX_VOD_PLAYER_MIMETYPE_TEXT_SRT;
            if ([@"text/vtt" isEqualToString:mimeStr]) {
                mimeType = TX_VOD_PLAYER_MIMETYPE_TEXT_VTT;
            }
            [_txVodPlayer addSubtitleSource:url name:name mimeType:mimeType];
        }
        result(nil);
        return;
    }
    if ([@"selectTrack" isEqualToString:method]) {
        if (nil != _txVodPlayer && args[@"value"]) {
            [_txVodPlayer selectTrack:[args[@"value"] intValue]];
        }
        result(nil);
        return;
    }
    if ([@"deselectTrack" isEqualToString:method]) {
        if (nil != _txVodPlayer && args[@"value"]) {
            [_txVodPlayer deselectTrack:[args[@"value"] intValue]];
        }
        result(nil);
        return;
    }
    if ([@"getAudioTrackInfo" isEqualToString:method]) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        if (nil != _txVodPlayer) {
            for (TXTrackInfo *info in [_txVodPlayer getAudioTrackInfo]) {
                [list addObject:@{
                    @"trackType":   @(info.trackType),
                    @"trackIndex":  @(info.trackIndex),
                    @"name":        info.name ?: @"",
                    @"isSelected":  @(info.isSelected),
                    @"isExclusive": @(info.isExclusive),
                    @"isInternal":  @(info.isInternal),
                }];
            }
        }
        result(list);
        return;
    }
    if ([@"getSubtitleTrackInfo" isEqualToString:method]) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        if (nil != _txVodPlayer) {
            for (TXTrackInfo *info in [_txVodPlayer getSubtitleTrackInfo]) {
                [list addObject:@{
                    @"trackType":   @(info.trackType),
                    @"trackIndex":  @(info.trackIndex),
                    @"name":        info.name ?: @"",
                    @"isSelected":  @(info.isSelected),
                    @"isExclusive": @(info.isExclusive),
                    @"isInternal":  @(info.isInternal),
                }];
            }
        }
        result(list);
        return;
    }
    if ([@"setSubtitleStyle" isEqualToString:method]) {
        if (nil != _txVodPlayer) {
            NSDictionary *styleDict = args[@"style"];
            if (![styleDict isKindOfClass:[NSDictionary class]]) styleDict = args;
            [_txVodPlayer setSubtitleStyle:[FTXTransformation transformToTitleRenderModelFromDict:styleDict]];
        }
        result(nil);
        return;
    }

    // ======================== Extra parameters ========================
    if ([@"setStringOption" isEqualToString:method]) {
        if (nil == _txVodPlayer) { result(nil); return; }
        NSString *key = args[@"key"];
        NSArray *values = args[@"value"];
        if (key.length > 0 && values.count > 0) {
            id value = values[0];
            if ([key isEqualToString:VOD_KEY_VIDEO_CODEC_TYPE] && [value isKindOfClass:[NSString class]]) {
                if ([(NSString *)value isEqualToString:@"video/hevc"]) {
                    [_txVodPlayer setExtentOptionInfo:@{VOD_KEY_VIDEO_CODEC_TYPE: @(kCMVideoCodecType_HEVC)}];
                }
            } else {
                [_txVodPlayer setExtentOptionInfo:@{key: value}];
            }
        }
        result(nil);
        return;
    }

    // ======================== TRTC ========================
    if ([@"enableTRTC" isEqualToString:method]) {
        [self enableTRTC:[args[@"isEnabled"] boolValue]];
        result(nil);
        return;
    }
    if ([@"publishVideo" isEqualToString:method]) {
        if (nil != _txVodPlayer) { [_txVodPlayer publishVideo]; }
        result(nil);
        return;
    }
    if ([@"publishAudio" isEqualToString:method]) {
        if (nil != _txVodPlayer) { [_txVodPlayer publishAudio]; }
        result(nil);
        return;
    }
    if ([@"unpublishVideo" isEqualToString:method]) {
        if (nil != _txVodPlayer) { [_txVodPlayer unpublishVideo]; }
        result(nil);
        return;
    }
    if ([@"unpublishAudio" isEqualToString:method]) {
        if (nil != _txVodPlayer) { [_txVodPlayer unpublishAudio]; }
        result(nil);
        return;
    }

    // ======================== PIP ========================
    if ([@"enterPictureInPictureMode" isEqualToString:method]) {
        int r = [self enterPictureInPictureMode];
        result(@(r));
        return;
    }
    if ([@"exitPictureInPictureMode" isEqualToString:method]) {
        if (nil != _txVodPlayer) { [_txVodPlayer exitPictureInPicture]; }
        result(nil);
        return;
    }

    result(FlutterMethodNotImplemented);
}

@end
