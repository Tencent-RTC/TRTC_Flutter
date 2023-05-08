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

#import "ReplayKitLauncherPlugin.h"

FOUNDATION_EXPORT double replay_kit_launcherVersionNumber;
FOUNDATION_EXPORT const unsigned char replay_kit_launcherVersionString[];

