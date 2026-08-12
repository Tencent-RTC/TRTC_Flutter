// Copyright (c) 2022 Tencent. All rights reserved.
#import <Foundation/Foundation.h>
#import "FTXTransformation.h"

// Read an NSNumber for a key (returns nil when missing or NSNull).
static inline NSNumber *FTX_NumberOrNil(NSDictionary *dict, NSString *key) {
    id v = dict[key];
    if (!v || v == [NSNull null]) return nil;
    if ([v isKindOfClass:[NSNumber class]]) return v;
    if ([v isKindOfClass:[NSString class]]) {
        // Tolerate numeric values sent as strings from the Dart side.
        return @([(NSString *)v doubleValue]);
    }
    return nil;
}

static inline NSString *FTX_StringOrNil(NSDictionary *dict, NSString *key) {
    id v = dict[key];
    if (!v || v == [NSNull null]) return nil;
    if ([v isKindOfClass:[NSString class]]) return v;
    return nil;
}

static inline NSDictionary *FTX_DictOrNil(NSDictionary *dict, NSString *key) {
    id v = dict[key];
    if (!v || v == [NSNull null]) return nil;
    if ([v isKindOfClass:[NSDictionary class]]) return v;
    return nil;
}

@implementation FTXTransformation

+ (TXVodPlayConfig *)transformToVodConfigFromDict:(NSDictionary *)dict {
    TXVodPlayConfig *config = [[TXVodPlayConfig alloc] init];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return config;
    }

    NSNumber *connectRetryCount       = FTX_NumberOrNil(dict, @"connectRetryCount");
    NSNumber *connectRetryInterval    = FTX_NumberOrNil(dict, @"connectRetryInterval");
    NSNumber *timeout                 = FTX_NumberOrNil(dict, @"timeout");
    NSNumber *playerType              = FTX_NumberOrNil(dict, @"playerType");
    NSNumber *enableAccurateSeek      = FTX_NumberOrNil(dict, @"enableAccurateSeek");
    NSNumber *autoRotate              = FTX_NumberOrNil(dict, @"autoRotate");
    NSNumber *smoothSwitchBitrate     = FTX_NumberOrNil(dict, @"smoothSwitchBitrate");
    NSNumber *maxBufferSize           = FTX_NumberOrNil(dict, @"maxBufferSize");
    NSNumber *maxPreloadSize          = FTX_NumberOrNil(dict, @"maxPreloadSize");
    NSNumber *firstStartPlayBufferTime= FTX_NumberOrNil(dict, @"firstStartPlayBufferTime");
    NSNumber *nextStartPlayBufferTime = FTX_NumberOrNil(dict, @"nextStartPlayBufferTime");
    NSNumber *enableRenderProcess     = FTX_NumberOrNil(dict, @"enableRenderProcess");
    NSNumber *preferredResolution     = FTX_NumberOrNil(dict, @"preferredResolution");
    NSNumber *mediaType               = FTX_NumberOrNil(dict, @"mediaType");
    NSNumber *encryptedMp4Level       = FTX_NumberOrNil(dict, @"encryptedMp4Level");
    NSNumber *progressInterval        = FTX_NumberOrNil(dict, @"progressInterval");
    NSNumber *preferAudioTrack        = FTX_NumberOrNil(dict, @"preferAudioTrack");

    if (connectRetryCount)        config.connectRetryCount        = connectRetryCount.intValue;
    if (connectRetryInterval)     config.connectRetryInterval     = connectRetryInterval.intValue;
    if (timeout)                  config.timeout                  = timeout.intValue;
    if (playerType)               config.playerType               = playerType.intValue;
    if (enableAccurateSeek)       config.enableAccurateSeek       = enableAccurateSeek.boolValue;
    if (autoRotate)               config.autoRotate               = autoRotate.boolValue;
    if (smoothSwitchBitrate)      config.smoothSwitchBitrate      = smoothSwitchBitrate.boolValue;
    if (maxBufferSize)            config.maxBufferSize            = maxBufferSize.floatValue;
    if (maxPreloadSize)           config.maxPreloadSize           = maxPreloadSize.floatValue;
    if (firstStartPlayBufferTime) config.firstStartPlayBufferTime = firstStartPlayBufferTime.intValue;
    if (nextStartPlayBufferTime)  config.nextStartPlayBufferTime  = nextStartPlayBufferTime.intValue;
    if (enableRenderProcess)      config.enableRenderProcess      = enableRenderProcess.boolValue;
    if (preferredResolution)      config.preferredResolution      = preferredResolution.longValue;
    if (mediaType)                config.mediaType                = mediaType.intValue;
    if (encryptedMp4Level)        config.encryptedMp4Level        = encryptedMp4Level.intValue;

    // progressInterval is in milliseconds on the Dart side while the SDK expects seconds.
    if (progressInterval) {
        NSTimeInterval sec = progressInterval.intValue / 1000.0;
        if (sec > 0) {
            config.progressInterval = sec;
        }
    }

    NSString *overlayKey = FTX_StringOrNil(dict, @"overlayKey");
    NSString *overlayIv  = FTX_StringOrNil(dict, @"overlayIv");
    if (overlayKey) config.overlayKey = overlayKey;
    if (overlayIv)  config.overlayIv  = overlayIv;

    NSDictionary *headers    = FTX_DictOrNil(dict, @"headers");
    NSDictionary *extInfoMap = FTX_DictOrNil(dict, @"extInfoMap");
    if (headers)    config.headers    = headers;
    if (extInfoMap) config.extInfoMap = extInfoMap;

    if (preferAudioTrack) config.preferAudioTrack = preferAudioTrack;
    return config;
}

+ (TXPlayerSubtitleRenderModel *)transformToTitleRenderModelFromDict:(NSDictionary *)dict {
    TXPlayerSubtitleRenderModel *model = [[TXPlayerSubtitleRenderModel alloc] init];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return model;
    }

    NSNumber *canvasWidth     = FTX_NumberOrNil(dict, @"canvasWidth");
    NSNumber *canvasHeight    = FTX_NumberOrNil(dict, @"canvasHeight");
    NSNumber *fontSize        = FTX_NumberOrNil(dict, @"fontSize");
    NSNumber *fontScale       = FTX_NumberOrNil(dict, @"fontScale");
    NSNumber *fontColor       = FTX_NumberOrNil(dict, @"fontColor");
    NSNumber *isBondFontStyle = FTX_NumberOrNil(dict, @"isBondFontStyle");
    NSNumber *outlineWidth    = FTX_NumberOrNil(dict, @"outlineWidth");
    NSNumber *outlineColor    = FTX_NumberOrNil(dict, @"outlineColor");
    NSNumber *lineSpace       = FTX_NumberOrNil(dict, @"lineSpace");
    NSNumber *startMargin     = FTX_NumberOrNil(dict, @"startMargin");
    NSNumber *endMargin       = FTX_NumberOrNil(dict, @"endMargin");
    NSNumber *verticalMargin  = FTX_NumberOrNil(dict, @"verticalMargin");
    NSString *familyName      = FTX_StringOrNil(dict, @"familyName");

    if (canvasWidth)     model.canvasWidth     = canvasWidth.intValue;
    if (canvasHeight)    model.canvasHeight    = canvasHeight.intValue;
    if (familyName)      model.familyName      = familyName;
    if (fontSize)        model.fontSize        = fontSize.floatValue;
    if (fontScale)       model.fontScale       = fontScale.floatValue;
    if (fontColor)       model.fontColor       = fontColor.unsignedIntValue;
    if (isBondFontStyle) model.isBondFontStyle = isBondFontStyle.boolValue;
    if (outlineWidth)    model.outlineWidth    = outlineWidth.floatValue;
    if (outlineColor)    model.outlineColor    = outlineColor.unsignedIntValue;
    if (lineSpace)       model.lineSpace       = lineSpace.floatValue;
    if (startMargin)     model.startMargin     = startMargin.floatValue;
    if (endMargin)       model.endMargin       = endMargin.floatValue;
    if (verticalMargin)  model.verticalMargin  = verticalMargin.floatValue;
    return model;
}

@end