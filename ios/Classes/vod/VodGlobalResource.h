// Copyright (c) 2026 Tencent. All rights reserved.
//
// VodGlobalResource
// ------------------------------------------------------------
// Process-wide shared resources for the Vod module on iOS.
//
// The handler itself stays per-engine (aligned with the official Flutter plugin model), but
// process-level hooks must only be attached once for the whole app:
//   - [TXLiveBase sharedInstance].delegate (License callback is a single assign, not multicast)
//   - UIDeviceOrientationDidChangeNotification (multicast, but keeping one source avoids
//     duplicated delivery across engines)
//
// This class keeps a weak set of attached handlers and toggles the hooks based on whether the
// set is empty. When the first handler acquires, the hooks are wired up; when the last handler
// releases, they are torn down. SDK events (License / orientation) are fanned out to every
// attached handler.

#ifndef TRTC_FLUTTER_IOS_CLASSES_VOD_VODGLOBALRESOURCE_H_
#define TRTC_FLUTTER_IOS_CLASSES_VOD_VODGLOBALRESOURCE_H_

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class VodMethodChannelHandler;

@interface VodGlobalResource : NSObject

+ (instancetype)sharedInstance;

/// Register a handler with the global resource. Safe to call across multiple engines.
/// The first acquire installs the process-level hooks.
- (void)acquire:(VodMethodChannelHandler *)handler;

/// Unregister a handler. The last release tears down the process-level hooks.
- (void)release:(VodMethodChannelHandler *)handler;

@end

NS_ASSUME_NONNULL_END

#endif  // TRTC_FLUTTER_IOS_CLASSES_VOD_VODGLOBALRESOURCE_H_
