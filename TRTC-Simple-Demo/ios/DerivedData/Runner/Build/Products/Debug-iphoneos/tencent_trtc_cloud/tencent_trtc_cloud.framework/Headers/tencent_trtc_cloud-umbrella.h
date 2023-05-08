#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "TRTCCloudPlugin.h"
#import "txg_log.h"

FOUNDATION_EXPORT double tencent_trtc_cloudVersionNumber;
FOUNDATION_EXPORT const unsigned char tencent_trtc_cloudVersionString[];

