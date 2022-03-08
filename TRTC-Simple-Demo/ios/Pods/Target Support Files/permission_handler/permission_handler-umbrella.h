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

#import "PermissionHandlerEnums.h"
#import "PermissionHandlerPlugin.h"
#import "PermissionManager.h"
#import "AudioVideoPermissionStrategy.h"
#import "BluetoothPermissionStrategy.h"
#import "ContactPermissionStrategy.h"
#import "EventPermissionStrategy.h"
#import "LocationPermissionStrategy.h"
#import "MediaLibraryPermissionStrategy.h"
#import "NotificationPermissionStrategy.h"
#import "PermissionStrategy.h"
#import "PhonePermissionStrategy.h"
#import "PhotoPermissionStrategy.h"
#import "SensorPermissionStrategy.h"
#import "SpeechPermissionStrategy.h"
#import "StoragePermissionStrategy.h"
#import "UnknownPermissionStrategy.h"
#import "Codec.h"

FOUNDATION_EXPORT double permission_handlerVersionNumber;
FOUNDATION_EXPORT const unsigned char permission_handlerVersionString[];

