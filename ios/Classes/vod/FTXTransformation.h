// Copyright (c) 2022 Tencent. All rights reserved.
#ifndef SUPERPLAYER_FLUTTER_IOS_CLASSES_FTXTRANSFORMATION_H_
#define SUPERPLAYER_FLUTTER_IOS_CLASSES_FTXTRANSFORMATION_H_

#import <Foundation/Foundation.h>
#import "FTXLiteAVSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

/// Parameter conversion utilities for the VOD module.
/// After migrating from Pigeon to MethodChannel, the Dart side delivers
/// parameters as Map<String, Object?>, so all inputs here are NSDictionary.
@interface FTXTransformation : NSObject

/// Convert the config map from Dart into a TXVodPlayConfig.
+ (TXVodPlayConfig *)transformToVodConfigFromDict:(NSDictionary *)dict;

/// Convert the subtitle render model map from Dart into TXPlayerSubtitleRenderModel.
+ (TXPlayerSubtitleRenderModel *)transformToTitleRenderModelFromDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END

#endif  // SUPERPLAYER_FLUTTER_IOS_CLASSES_FTXTRANSFORMATION_H_
