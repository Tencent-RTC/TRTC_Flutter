//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<path_provider_ios/FLTPathProviderPlugin.h>)
#import <path_provider_ios/FLTPathProviderPlugin.h>
#else
@import path_provider_ios;
#endif

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<replay_kit_launcher/ReplayKitLauncherPlugin.h>)
#import <replay_kit_launcher/ReplayKitLauncherPlugin.h>
#else
@import replay_kit_launcher;
#endif

#if __has_include(<tencent_trtc_cloud/TencentTRTCCloud.h>)
#import <tencent_trtc_cloud/TencentTRTCCloud.h>
#else
@import tencent_trtc_cloud;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FLTPathProviderPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTPathProviderPlugin"]];
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [ReplayKitLauncherPlugin registerWithRegistrar:[registry registrarForPlugin:@"ReplayKitLauncherPlugin"]];
  [TencentTRTCCloud registerWithRegistrar:[registry registrarForPlugin:@"TencentTRTCCloud"]];
}

@end
