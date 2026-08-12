// Copyright (c) 2022 Tencent. All rights reserved.

#ifndef TRTC_FLUTTER_V3_IOS_CLASSES_VOD_TOOLS_TXCOMMONUTIL_H_
#define TRTC_FLUTTER_V3_IOS_CLASSES_VOD_TOOLS_TXCOMMONUTIL_H_

#import <Foundation/Foundation.h>
#import "FTXEvent.h"

/**
 * Common utility class for the VOD module.
 *
 * Migration note: the original SuperPlayer version also exposed a set of
 * Pigeon-generated wrapper factory methods (`PlayerMsg` / `StringMsg` /
 * `BoolMsg` / `IntMsg` / `DoubleMsg` / `UInt8ListMsg` / `ListMsg`). After
 * the Pigeon -> MethodChannel migration in the V3 plugin, those wrapper
 * types are gone; MethodChannel carries primitive types (NSNumber / NSString
 * / NSDictionary ...) directly, so this utility class now keeps only the
 * event / download helpers that are unrelated to Pigeon.
 */
@interface TXCommonUtil : NSObject

/// Convert a TXVodDownloadManager download state code into the event code
/// defined by FTXEvent.
+ (NSNumber *)getDownloadEventByState:(int)downloadState;

/// Build the payload of a player / SDK / native event: start from params and
/// fill in `EVT_KEY_PLAYER_EVENT`.
+ (NSMutableDictionary *)getParamsWithEvent:(int)EvtID withParams:(NSDictionary *)params;

@end

#endif  // TRTC_FLUTTER_V3_IOS_CLASSES_VOD_TOOLS_TXCOMMONUTIL_H_
