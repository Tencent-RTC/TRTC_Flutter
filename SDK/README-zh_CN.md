[English](https://github.com/Tencent-RTC/TRTC_Flutter/blob/master/README.md) | 简体中文

# **腾讯 RTC Flutter SDK**

依托腾讯 21 年来在网络与音视频技术领域积累的深厚经验，腾讯实时音视频（TRTC）提供群组音视频通话和低延时互动直播等解决方案。借助 TRTC，您可以快速开发出成本效益高、延时低、品质优良的互动音视频服务。

## **Demo 快速开始**

请参见 [Demo 快速开始（Flutter）](https://trtc.io/zh/document/39243?product=rtcengine&menulabel=core%20sdk&platform=flutter)

## **SDK 快速集成**

请参见 [快速集成（Flutter）](https://trtc.io/zh/document/64203?product=rtcengine&menulabel=core%20sdk&platform=flutter)

## **SDK 类文件**

* trtc_cloud - 腾讯云 TRTC 核心功能接口。
* trtc_cloud_video_view - 提供用于渲染视频的 Widget `TRTCCloudVideoView`。
* tx_audio_effect_manager - 腾讯云音效管理模块。
* tx_device_manager - 腾讯云设备管理模块。
* trtc_cloud_def - TRTC 关键类定义说明：分辨率、质量等级等接口枚举及常量值的定义。
* trtc_cloud_listener - 腾讯云 TRTC 事件通知接口。

## **调用示例**

1. **初始化**
```
// 创建 TRTCCloud 单例
trtcCloud = await TRTCCloud.sharedInstance();
// 腾讯云设备管理模块
txDeviceManager = trtcCloud.getDeviceManager();
// 腾讯云音效管理模块
txAudioManager = trtcCloud.getAudioEffectManager();
```

2. **进房/退房**
```
// 进房/退房
trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: sdkAppId,
            userId: userId,
            userSig: userSig,
            roomId: roomId),
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
// 离开房间
trtcCloud.exitRoom();
```

3. **注册监听器**
```
// 注册监听器
TRTCCloudListener listener = TRTCCloudListener(
    onError: (errorCode, errorMessage) {
      debugPrint("TRTCCloudListener onError errCode:$errCode errMsg: $errMsg");
    }
    ……
)
trtcCloud.registerListener(listener);
// 移除监听器
trtcCloud.unRegisterListener(listener);
```

4. **播放本地视频**
```
// 参数说明：
// frontCamera：`true`：前置摄像头；`false`：后置摄像头
// viewId：由 `TRTCCloudVideoView` 生成的视图 ID
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startLocalPreview(true, viewId);
});
```

5. **显示远端视频**

```
// 参数说明：
// userId：指定远端用户的 userid
// streamType：指定要观看的视频流类型：
//* 高清大图：TRTCVideoStreamType.big
//* 低清大图：TRTCVideoStreamType.small
// viewId：由 `TRTCCloudVideoView` 生成的视图 ID
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
});
```

6. **显示远端屏幕分享**

```
/// 参数说明：
/// userId：指定远端用户的 userid
/// streamType：要播放的远端用户视频流类型：
///* 辅流（屏幕分享）：TRTCVideoStreamType.sub
/// viewId：由 `TRTCCloudVideoView` 生成的视图 ID
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startRemoteView(userId, TRTCVideoStreamType.sub, viewId);
});
```

### 如何查看 TRTC 日志？
TRTC 日志默认以 XLOG 扩展名进行压缩和加密。您可以通过 setLogCompressEnabled 来设置是否加密日志。如果日志文件名中包含 C（compressed），则表示该日志已压缩加密；如果包含 R（raw），则表示该日志为明文。
* iOS：应用沙盒的 Documents/log 目录
* Android
  * 6.7 及以下版本：/sdcard/log/tencent/liteav
  * 6.8 及以上版本：/sdcard/Android/data/包名/files/log/tencent/liteav/
