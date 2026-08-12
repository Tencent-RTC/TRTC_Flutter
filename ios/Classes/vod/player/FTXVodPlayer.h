// Copyright (c) 2022 Tencent. All rights reserved.
#ifndef SUPERPLAYER_FLUTTER_IOS_CLASSES_PLAYER_FTXVODPLAYER_H_
#define SUPERPLAYER_FLUTTER_IOS_CLASSES_PLAYER_FTXVODPLAYER_H_

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "FTXBasePlayer.h"
#import "FTXVodPlayerDelegate.h"
#import "FTXRenderViewFactory.h"

@protocol FlutterPluginRegistrar;
@class VodMethodChannelHandler;

NS_ASSUME_NONNULL_BEGIN

@interface FTXVodPlayer : FTXBasePlayer

@property(nonatomic, weak) id<FTXVodPlayerDelegate> delegate;

/// New initializer after the C6 migration. VodMethodChannelHandler injects itself
/// so that this player can push playerEvent / netEvent / pipEvent back to Dart.
- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                   channelHandler:(VodMethodChannelHandler *)channelHandler
                renderViewFactory:(FTXRenderViewFactory*)renderViewFactory
                        onlyAudio:(BOOL)onlyAudio;

- (void)notifyAppTerminate:(UIApplication *)application;

/// Method dispatch entry for the TencentVodPlayer MethodChannel. VodMethodChannelHandler
/// routes calls here based on playerId.
- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result;

@end

NS_ASSUME_NONNULL_END

#endif  // SUPERPLAYER_FLUTTER_IOS_CLASSES_PLAYER_FTXVODPLAYER_H_
