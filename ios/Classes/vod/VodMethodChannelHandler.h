// Copyright (c) 2026 Tencent. All rights reserved.
//
// VodMethodChannelHandler
// ------------------------------------------------------------
// Unified MethodChannel dispatcher added after the Vod module was migrated
// into the TRTC v3 plugin. Replaces the former Pigeon-based SuperPlayerPlugin
// by routing calls through three native MethodChannels.
//
// MethodChannels (strictly aligned with Android / Dart):
//   - TencentVodPlugin    — global methods: license / cache folder / log / createVodPlayer / env / userId
//   - TencentVodPlayer    — player instance methods + player events + PiP events (routed by playerId)
//   - TencentVodDownload  — download / predownload methods + download events
//
// Event direction: native -> Dart via invokeMethod:arguments:, dispatched on
// the Dart side by VodEventDispatcher (see Dart: vod_method_channel.dart).

#ifndef TRTC_FLUTTER_IOS_CLASSES_VOD_VODMETHODCHANNELHANDLER_H_
#define TRTC_FLUTTER_IOS_CLASSES_VOD_VODMETHODCHANNELHANDLER_H_

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@class FTXBasePlayer;
@class FTXRenderViewFactory;

@interface VodMethodChannelHandler : NSObject

/// Registers every Vod-related MethodChannel, PlatformView and lifecycle observer.
/// Invoked by TencentRTCCloud.register(with:).
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;

/// Forwarded from TencentRTCCloud.applicationWillTerminate.
- (void)applicationWillTerminate;

/// Event-invocation entry points used by FTXVodPlayer / FTXDownloadManager.
/// Each method picks the matching MethodChannel and calls invokeMethod:arguments:.

/// Player event: onPlayerEvent(playerId, event)
- (void)invokePlayerEventWithPlayerId:(NSNumber *)playerId event:(NSDictionary *)event;

/// Player network event: onPlayerNetEvent(playerId, event)
- (void)invokePlayerNetEventWithPlayerId:(NSNumber *)playerId event:(NSDictionary *)event;

/// Picture-in-Picture event: onPipEvent(event)
- (void)invokePipEvent:(NSDictionary *)event;

/// Download event: onDownloadEvent(event)
- (void)invokeDownloadEvent:(NSDictionary *)event;

/// Predownload event: onPreDownloadEvent(event)
- (void)invokePreDownloadEvent:(NSDictionary *)event;

/// SDK-global event (onLicenceLoaded etc.): onSDKListener(event)
- (void)invokeSDKListenerEvent:(NSDictionary *)event;

/// Native generic event (brightness / volume / orientation): onNativeEvent(event)
- (void)invokeNativeEvent:(NSDictionary *)event;

/// Called by VodGlobalResource to fan out the process-level license callback
/// to this engine's Dart side.
- (void)dispatchLicenceLoadedWithResult:(int)result reason:(nullable NSString *)reason;

/// Called by VodGlobalResource to fan out the process-level orientation change
/// to this engine's Dart side.
- (void)dispatchOrientationChanged:(int)orientation;

/// Invoked by the player itself to (un)register in the global player map so
/// that releasePlayer / releaseAllPlayer can work.
- (void)registerPlayer:(FTXBasePlayer *)player forPlayerId:(NSNumber *)playerId;
- (void)unregisterPlayerId:(NSNumber *)playerId;

@end

NS_ASSUME_NONNULL_END

#endif  // TRTC_FLUTTER_IOS_CLASSES_VOD_VODMETHODCHANNELHANDLER_H_