# 跑通Demo(Flutter)
本文主要介绍如何快速运行腾讯云 TRTC Demo（Flutter）。
## 环境要求
- Flutter 版本 1.12及以上
- Android开发 
	-  Android Studio 3.5及以上版本
	-  App 要求 Android 4.1及以上设备
- iOS 开发
	- Xcode 11.0及以上版本
	- 请确保您的项目已设置有效的开发者签名

## 前提条件
您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。

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
3. 设置`GenerateTestUserSig.java`文件中的相关参数：
  <ul><li>SDKAPPID：默认为 PLACEHOLDER ，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为 PLACEHOLDER ，请设置为实际的密钥信息。</li></ul> 
<img src="https://imgcache.qq.com/operation/dianshi/other/flutterSercet.abb0c77a30a50a27bb36058bdabe1f051484c058.png" height="400" /> 
4. 返回实时音视频控制台，单击【粘贴完成，下一步】。
5. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 步骤4：编译运行
1.执行`flutter pub get`
2.Android调试：
（1）可以执行`flutter run`
（2）可以使用 Android Studio（3.5及以上的版本）打开源码工程，单击【运行】即可。
3.iOS调试：使用 XCode（11.0及以上的版本）打开源码目录下的 /ios工程，编译并运行 Demo 工程即可。

## 常见问题
### 1. 两台手机同时运行 Demo，为什么看不到彼此的画面？
请确保两台手机在运行 Demo 时使用的是不同的 UserID，TRTC 不支持同一个 UserID （除非 SDKAppID 不同）在两个终端同时使用。
![](https://main.qcloudimg.com/raw/c7b1589e1a637cf502c6728f3c3c4f99.png)

### 2. 防火墙有什么限制？
由于 SDK 使用 UDP 协议进行音视频传输，所以在对 UDP 有拦截的办公网络下无法使用。如遇到类似问题，请参考 [应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399) 排查并解决。

### 3.iOS打包运行crash
排查是否IOS14以上的debug模式问题，[官方说明](https://flutter.cn/docs/development/ios-14#launching-debug-flutter-without-a-host-computer)
### 4.iOS无法显示视频（Android是好的）
请确认 io.flutter.embedded_views_preview为YES在你的info.plist中
### 5.更新sdk版本后，iOS CocoaPods 运行报错
* 删除ios目录下Podfile.lock文件
* 执行`pod repo update`
* 执行`pod install`
* 重新运行
### 6.Android Manifest merge failed编译失败
![img](https://main.qcloudimg.com/raw/7a37917112831488423c1744f370c883.png)

请打开/example/android/app/src/main/AndroidManifest.xml文件。
1.将xmlns:tools="http://schemas.android.com/tools" 加入到manifest中
2.将tools:replace="android:label"加入到application中。
### 7.真机调试报错，因为没有签名，如图
![图片](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/9.png)
解决方案：购买苹果证书，配置，签名，就可以在真机上调试，已购买证书，在target > signing & capabilities配置
### 8.对插件内的swift文件做了增删，可能存在build时查找不到对应文件
解决方案：在主工程目录的/ios文件路径下`pod install`即可
### 9.Run报错，Info.plit, error: No value at that key path or invalid key path: NSBonjourServices
解决方案：`flutter clean`再重新运行
### 10.Pod install报错
![img](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/3.png)
报错信息里面提示 pod install 的时候没有 generated.xconfig 文件，因此运行报错，您根据提示需要执行 flutter pub get 解决。

说明：该问题是 flutter 编译后的问题，新项目或者执行了 flutter clean 后，都不存在这个问题。
### 11.Run的时候iOS版本依赖报错
![img](https://flutter-im-trtc-1256635546.cos.ap-guangzhou.myqcloud.com/8.png)
分析：如果pods的target版本，无法满足所依赖的插件，会报错，原因可能是修改了pods的target导致
解决方案：修改报错的target到对应的版本