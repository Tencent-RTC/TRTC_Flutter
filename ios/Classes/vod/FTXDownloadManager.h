// Copyright (c) 2022 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@class VodMethodChannelHandler;

/// Vod download / predownload manager.
///
/// After the migration into the TRTC v3 plugin, this class no longer relies
/// on Pigeon-generated protocols. Instead, VodMethodChannelHandler receives
/// calls on the TencentVodDownload channel and forwards them to
/// handleMethodCall:result: for unified routing.
///
/// Event push-back (onDownloadEvent / onPreDownloadEvent) is delivered via
/// the held VodMethodChannelHandler through invokeDownloadEvent: /
/// invokePreDownloadEvent:.
@interface FTXDownloadManager : NSObject

/// channelHandler: used for event push-back. The outer side holds it strongly;
/// this class keeps a weak reference to avoid a retain cycle.
- (instancetype)initWithChannelHandler:(VodMethodChannelHandler *)channelHandler;

/// Method dispatch entry for the TencentVodDownload channel.
- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

/// Release the download observer and other resources.
- (void)destroy;

@end

NS_ASSUME_NONNULL_END