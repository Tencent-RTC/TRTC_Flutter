简体中文 | [English](https://github.com/Tencent-RTC/TRTC_Flutter/blob/master/SDK/README.md)

# **腾讯 RTC Flutter SDK**

凭借腾讯在网络和音视频技术领域21年的经验，腾讯实时通信（TRTC）提供了群组音视频通话和低延迟互动直播的解决方案。使用 TRTC，您可以快速开发具有成本效益、低延迟和高质量的互动音视频服务。

## **SDK 概述**

[tencent_rtc_sdk](https://pub.dev/packages/tencent_rtc_sdk)：`tencent_rtc_sdk` 是 `tencent_trtc_cloud` 插件的升级版。在 `tencent_rtc_sdk` 中，我们针对 `tencent_trtc_cloud` 中的一些使用痛点进行了优化，主要包括但不限于以下方面：
- 改进了 `TRTCCloudListener` 的使用方式
- 规范化了枚举的定义

## **Demo 快速开始**

请参见 [Demo 快速开始（Flutter）](https://cloud.tencent.com/document/product/647/51601)

## **SDK 快速集成**

请参见 [快速集成（Flutter）](https://cloud.tencent.com/document/product/647/51602)

## **SDK 类文件**

* trtc_cloud - 腾讯云 TRTC 核心功能接口。
* trtc_cloud_video_view - 提供用于渲染视频的 `TRTCCloudVideoView` 小部件。
* tx_audio_effect_manager - 腾讯云音效管理模块。
* tx_device_manager - 腾讯云设备管理模块。
* trtc_cloud_def - TRTC 关键类定义描述：接口和常量值的定义，如分辨率和质量等级。
* trtc_cloud_listener - 腾讯云 TRTC 事件通知接口。

## **示例调用**

1. **初始化**
```
// 创建 TRTCCloud 单例
trtcCloud = await TRTCCloud.sharedInstance();
// 腾讯云音效管理模块
txDeviceManager = trtcCloud.getDeviceManager();
// 腾讯云音效管理模块
txAudioManager = trtcCloud.getAudioEffectManager();
```

2.**进退房**
```
// 进房
trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: sdkAppId,
            userId: userId,
            userSig: userSig,
            roomId: roomId),
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
// 退房
trtcCloud.exitRoom();
```

3.**事件监听**
```
// 设置事件监听
TRTCCloudListener listener = TRTCCloudListener(
    onError: (errorCode, errorMessage) {
      debugPrint("TRTCCloudListener onError errCode:$errCode errMsg: $errMsg");
    }
    ……
)
trtcCloud.registerListener(listener);
// 移除事件监听
trtcCloud.unRegisterListener(listener);
```

4.**显示本地视频**
```
// 参数:
// frontCamera: `true`: 前置摄像头; `false`: 后置摄像头
// viewId: `TRTCCloudVideoView` 生成的 viewId
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startLocalPreview(true, viewId);
});
```

5.**显示远端视频**

```
// 参数:
/// userId 指定远端用户的 userId
/// streamType 指定要观看 userId 的视频流类型：
//* 高清大画面：TRTCVideoStreamType.big
//* 低清小画面：TRTCVideoStreamType.small
/// viewId TRTCCloudVideoView生成的viewId
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
});
```

### 如何查看 TRTC 日志 ？
TRTC 日志默认是压缩和加密的，扩展名为 xlog/clog。您可以设置 setLogCompressEnabled 来指定是否加密日志。如果日志文件名包含 C（压缩），则日志是压缩和加密的；如果包含 R（原始），则日志是明文的。

* iOS：Documents/log of the application sandbox
* Android
  * 6.7 或更低: /sdcard/log/tencent/liteav
  * 6.8 或更高: /sdcard/Android/data/package name/files/log/tencent/liteav/

