## 腾讯 tencent_trtc_cloud

该flutter sdk是基于 腾讯云 iOS/Android 平台的 SDK进行封装。

[API 概览](https://github.com/c1avie/trtc_demo/blob/master/API.md)

[API 详细文档](https://pub.dev/documentation/tencent_trtc_cloud/latest/index.html)

DEMO地址 [Github](https://github.com/c1avie/trtc_demo)，任何问题可以通过 Github Issues 提问

注意：demo不支持模拟机运行，请使用真机开发调试。

#### 如何使用

1.flutter安装和环境配置

参考[flutter官方文档](https://flutter.cn/docs/get-started/install)

2.在项目的 `pubspec.yaml`中写如下依赖
```
dependencies:
  tencent_trtc_cloud: 最新版本号
```
该sdk需要`摄像头` `麦克风`权限来开始音视频通话

3.iOS需要再Info.plist中加入对相机和麦克风的权限申请
```
<key>NSCameraUsageDescription</key>
<string>授权摄像头权限才能正常视频通话</string>
<key>NSMicrophoneUsageDescription</key>
<string>授权麦克风权限才能正常语音通话</string>
```
还需要添加字段 io.flutter.embedded_views_preview 值为 YES

4.添加ReplayKit.framework

打开ios/Runner.xcworkspace，在Runner target的Build Phases > Link Binary With Libraries一栏添加

5.Android无需额外配置，已内部打入混淆规则

#### 快速开始

1.登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。

2.单击【立即开始】，输入应用名称，例如TestTRTC，单击【创建应用】。

3.参阅下载[Demo代码](https://github.com/c1avie/trtc_demo)，这是一个简单的多人视频通话示例

4.下载完成后，返回实时音视频控制台，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

5.找到并打开/example/lib/debug/GenerateTestUserSig.dart文件。
设置GenerateTestUserSig.dart文件中的相关参数：

sdkAppId：默认为 0 ，请设置为实际的 sdkAppId。

secretKey：默认为 空 ，请设置为实际的密钥信息。

6.编译运行 flutter run

#### sdk类文件说明

* trtc_cloud-腾讯云视频通话功能的主要接口类
* trtc_cloud_video_view-提供渲染视频TRTCCloudVideoView的widget
* tx_audio_effect_manager-腾讯云视频通话功能音乐和人声设置接口
* tx_beauty_manager-美颜及动效参数管理
* tx_device_manager-设备管理类
* trtc_cloud_def-腾讯云视频通话功能的关键类型定义
* trtc_cloud_listener-腾讯云视频通话功能的事件回调监听接口

#### 调用示例

1.初始化
```
// 创建 TRTCCloud 单例
trtcCloud = await TRTCCloud.sharedInstance();
// 获取设备管理模块
txDeviceManager = trtcCloud.getDeviceManager();
// 获取美颜管理对象
txBeautyManager = trtcCloud.getBeautyManager();
// 获取音效管理类
txAudioManager = trtcCloud.getAudioEffectManager();
```

2.进退房
```
//进房
trtcCloud.enterRoom(
        TRTCParams(
            sdkAppId: sdkAppId, //应用Id
            userId: userId, // 用户Id
            userSig: userSig, // 用户签名
            roomId: roomId), //房间Id
        TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL);
//退房
trtcCloud.exitRoom();
```

3.事件监听
```
//设置事件监听
trtcCloud.registerListener(onRtcListener);
onRtcListener(type, param) {
  //进房回调事件
  if (type == TRTCCloudListenerEnum.onEnterRoom) {
    if (param > 0) {
      showToast('进房成功');
    }
  }
  // 远端用户进房
  if (type == TRTCCloudListenerEnum.onRemoteUserEnterRoom) {
    //param参数为远端用户userId
  }
  //远端用户是否存在可播放的主路画面（一般用于摄像头）
  if (type == TRTCCloudListenerEnum.onUserVideoAvailable) {
    //param['userId']表示远端用户id
    //param['visible']画面是否开启
  }
}
//移除事件监听
trtcCloud.unRegisterListener(onRtcListener);
```

4.显示本地视频
```
// 参数：
// frontCamera	true：前置摄像头；false：后置摄像头
// viewId TRTCCloudVideoView生成的viewId
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startLocalPreview(true, viewId);
});
```

5.显示远端视频

```
// 参数：
// userId 指定远端用户的 userId
// streamType 指定要观看 userId 的视频流类型：
//* 高清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG
//* 低清大画面：TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL
// viewId TRTCCloudVideoView生成的viewId
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL, viewId);
});
```

5.显示远端屏幕分享

```
/// 参数：
/// userId 指定远端用户的 userId
/// streamType 指定要观看 userId 的视频流类型：
///* 辅流（屏幕分享）：TRTCCloudDe.TRTC_VIDEO_STREAM_TYPE_SUB
/// viewId TRTCCloudVideoView生成的viewId
TRTCCloudVideoView(
    onViewCreated: (viewId) {
      trtcCloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB, viewId);
});
```

#### 如何查看 TRTC 日志？
TRTC 的日志默认压缩加密，后缀为 .xlog。
* iOS：sandbox的Documents/log
* Android
  * 6.7及之前的版本：/sdcard/log/tencent/liteav
  * 6.8之后的版本：/sdcard/Android/data/包名/files/log/tencent/liteav/

#### 常见问题

##### iOS无法显示视频（Android是好的）

请确认 io.flutter.embedded_views_preview为`YES`在你的info.plist中

##### Android Manifest merge failed编译失败

请打开/example/android/app/src/main/AndroidManifest.xml文件。

1.将xmlns:tools="http://schemas.android.com/tools" 加入到manifest中

2.将tools:replace="android:label"加入到application中。

![图示](https://main.qcloudimg.com/raw/7a37917112831488423c1744f370c883.png)
