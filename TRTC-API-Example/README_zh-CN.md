# TRTC Flutter API-Example

中文 | [English](README.md)

## 前言

这个开源示例 Demo 主要演示了 [TRTC 实时音视频 Flutter SDK](https://cloud.tencent.com/document/product/647/32689) 部分 API 的使用示例，帮助开发者可以更好的理解 TRTC 实时音视频 Flutter SDK 的 API，从而快速实现一些音视频场景的基本功能。

## 结构说明

在这个示例项目中包含了以下场景:（带上对应的跳转目录，方便用户快速浏览感兴趣的功能）

- 基础功能
  - [语音通话](./lib/Basic/AudioCall)
  - [视频通话](./lib/Basic/VideoCall)
  - [视频互动直播](./lib/Basic/Live)
  - [语音互动直播](./lib/Basic/VoiceChatRoom)
  - [录屏直播](./lib/Basic/ScreenShare)
- 进阶功能
  - [字符串房间号](./lib/Advanced/StringRoomId)
  - [画质设定](./lib/Advanced/SetVideoQuality)
  - [音质设定](./lib/Advanced/SetAudioQuality)
  - [渲染控制](./lib/Advanced/SetRenderParams)
  - [网络测速](./lib/Advanced/SpeedTest)
  - [CDN 发布](./lib/Advanced/PushCDN)
  - [设置音效](./lib/Advanced/SetAudioEffect)
  - [设置背景音乐](./lib/Advanced/SetBackgroundMusic)
  - [本地视频录制](./lib/Advanced/LocalRecord)
  - [收发 SEI 消息](./lib/Advanced/SEIMessage)
  - [快速切换房间](./lib/Advanced/SwitchRoom)
  - [跨房 PK](./lib/Advanced/RoomPk)

## 环境准备

- Flutter 2.0 及以上版本。
- **Android 端开发：**
  - Android Studio 3.5 及以上版本。
  - App 要求 Android 4.1 及以上版本设备。
- **iOS & macOS 端开发：**
  - Xcode 11.0 及以上版本。
  - osx 系统版本要求 10.11 及以上版本
  - 请确保您的项目已设置有效的开发者签名。

## 运行示例

### 前提条件

您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

### 申请 SDKAPPID 和 SECRETKEY

1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通 Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 输入应用名称，例如`APIExample`；若您已创建过应用，可以勾选【选择已有应用】，然后单击【创建】。
   ![#900px](https://qcloudimg.tencent-cloud.cn/raw/899626ba2c8f9b32921bda193c9ab9a9.png)
3. 创建应用完成后，单击【已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 配置 Demo 工程文件

1. 找到并打开`/lib/debug/GenerateTestUserSig.dart`文件。
2. 设置`GenerateTestUserSig.dart`文件中的相关参数：

> - SDKAPPID：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID。
> - SECRETKEY：默认为 PLACEHOLDER ，请设置为实际的密钥信息。
>   ![#900px](https://qcloudimg.tencent-cloud.cn/raw/c8a787f11cb3f52a49ffd04ad0197d4b.png)

3. 返回实时音视频控制台，单击【已复制粘贴，下一步】。
4. 单击【关闭指引，进入控制台管理应用】。

> !本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。

> 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 编译运行

1. 执行`flutter pub get`
2. 编译、运行或调试项目工程。

#### Android 调试：

1. 可以执行`flutter run`
2. 可以使用 Android Studio（3.5 及以上的版本）打开源码工程，单击【运行】即可。

#### iOS 调试：

1. 执行`cd ios`
2. 执行`pod install`
3. 使用 XCode（11.0 及以上的版本）打开源码目录下的 `/ios` 工程，编译并运行 Demo 工程即可。

### 常见问题

更多常见问题参考[文档](https://cloud.tencent.com/document/product/647/51623)

##### iOS 无法显示视频（Android 是好的）

请确认 io.flutter.embedded_views_preview 为`YES`在你的 info.plist 中

##### Android Manifest merge failed 编译失败

请打开/example/android/app/src/main/AndroidManifest.xml 文件。

1. 将 xmlns:tools="http://schemas.android.com/tools" 加入到 manifest 中
2. 将 tools:replace="android:label"加入到 application 中。
   ![图示](https://main.qcloudimg.com/raw/7a37917112831488423c1744f370c883.png)

##### 更新 SDK 版本后，iOS CocoaPods 运行报错？

1. 删除 iOS 目录下 `Podfile.lock` 文件。
2. 执行 `pod repo update`。
3. 执行 `pod install`。
4. 重新运行。
