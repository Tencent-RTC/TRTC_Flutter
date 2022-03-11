[English](./README.md) | 简体中文

# 跑通Demo(Flutter)

本文主要介绍如何快速运行腾讯云 TRTC Demo（Flutter）。

注意：目前Windows/MacOs端仅支持音频，视频接口暂不支持；安卓/iOS端支持视频通话

## 环境要求
- Flutter 版本 2.0及以上
- Android开发 
	-  Android Studio 3.5及以上版本
	-  App 要求 Android 4.1及以上设备
- iOS & macOS 开发
	- Xcode 11.0及以上版本
	- macOS 系统版本要求 10.11 及以上
	- 请确保您的项目已设置有效的开发者签名
- Windows 开发
	- 操作系统：Windows 7 SP1 或更高的版本（基于 x86-64 的 64 位操作系统）。
    - 磁盘空间：除安装 IDE 和一些工具之外还应有至少 1.64 GB 的空间。
	- 安装 Visual Studio 2019[https://visualstudio.microsoft.com/zh-hans/downloads/]
- Flutter Web 开发
	- Chrome72及以上版本
	- Safari13及以上版本
	- flutter 2.0及以上版本

## 前提条件

您已[注册腾讯云](https://cloud.tencent.com)账号，并完成实名认证。

## 操作步骤
<span id="step1"></span>
### 步骤1：创建新的应用
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入应用名称，例如`TestTRTC`，单击【创建应用】。

<span id="step2"></span>
### 步骤2：下载 SDK 和 Demo 源码
1. 鼠标移动至对应卡片，单击【[Github](https://github.com/c1avie/trtc_demo)】跳转至 Github，下载相关 SDK 及配套的 Demo 源码。
<img src="https://imgcache.qq.com/operation/dianshi/other/flutterCard.e9d6e205d0e0a8903aa437602acafecb3958e0cb.png" height="400" />

2. 下载完成后，返回实时音视频控制台，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。
<span id="step3"></span>
### 步骤3：配置 Demo 工程文件
1. 解压 [步骤2](#step2) 中下载的源码包。
2. 找到并打开`/lib/debug/GenerateTestUserSig.dart`文件。
3. 设置`GenerateTestUserSig.dart`文件中的相关参数：
  <ul><li>SDKAPPID：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为 PLACEHOLDER ，请设置为实际的密钥信息。</li></ul> 
<img src="https://imgcache.qq.com/operation/dianshi/other/flutterSercet.abb0c77a30a50a27bb36058bdabe1f051484c058.png" height="400" /> 
4. 返回实时音视频控制台，单击【粘贴完成，下一步】。

5. 单击【关闭指引，进入控制台管理应用】。

>本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见[服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤4：编译运行
1.执行`flutter pub get`

2.Android调试：
* （1）可以执行`flutter run`
* （2）可以使用 Android Studio（3.5及以上的版本）打开源码工程，单击【运行】即可。
  
3.iOS调试：使用 XCode（11.0及以上的版本）打开源码目录下的 /ios工程，编译并运行 Demo 工程即可。

4.windows调试：
* （1）启用windows支持：flutter config --enable-windows-desktop
* （2）flutter run -d windows

4.macOS调试
* （1）启用macOS支持：flutter config --enable-macos-desktop
* （2）执行`flutter run -d macos`

4.web调试
* （1）启用web支持：flutter config --enable-web
* （2）执行`flutter run -d chrome`

#### 如何查看 TRTC 日志？
TRTC 的日志默认压缩加密，后缀为 .xlog。
* iOS：sandbox的Documents/log
* Android
  * 6.7及之前的版本：/sdcard/log/tencent/liteav
  * 6.8之后的版本：/sdcard/Android/data/包名/files/log/tencent/liteav/

#### 常见问题

更多常见问题参考[文档](https://cloud.tencent.com/document/product/647/51623)

##### iOS无法显示视频（Android是好的）

请确认 io.flutter.embedded_views_preview为`YES`在你的info.plist中

##### Android Manifest merge failed编译失败

请打开/example/android/app/src/main/AndroidManifest.xml文件。

1.将xmlns:tools="http://schemas.android.com/tools" 加入到manifest中

2.将tools:replace="android:label"加入到application中。

![图示](https://main.qcloudimg.com/raw/7a37917112831488423c1744f370c883.png)