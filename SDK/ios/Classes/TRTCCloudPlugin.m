// TencentRtcPlugin.m
// Created by lexuslin on 2020/11/19
// Copyright (c) 2020年 Tencent. All rights reserved.
#import "TRTCCloudPlugin.h"
#if __has_include(<tencent_trtc_cloud/tencent_trtc_cloud-Swift.h>)
#import <tencent_trtc_cloud/tencent_trtc_cloud-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tencent_trtc_cloud-Swift.h"
#endif

// 接口定义
@implementation TRTCCloudPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [TencentTRTCCloud registerWithRegistrar:registrar];
}
@end
