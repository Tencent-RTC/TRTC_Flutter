# TRTC Flutter API-Example 
## 切后台后继续采集音视频

### iOS端
如需要进入后台仍然运行相关功能，可选中当前工程项目，在 Capabilities 下的设置 Background Modes 打开为 ON，并勾选 Audio，AirPlay and Picture in Picture ，如下图所示：

![](https://main.qcloudimg.com/raw/d960dfec88388936abce2d4cb77ac766.jpg)

### Android端
如果 Android 9 设备用户有锁屏后采集音频或视频的需求，可以在锁屏或退至后台前起一个 Service，并在退出锁屏或返回前台前终止 Service。
关于如何起 Service，请参考 [https://developer.android.com/reference/android/app/Service](https://developer.android.com/reference/android/app/Service) 。

下面简单提供一个参考代码：

1. 在AndroidManifest.xml中添加以下配置
`<service
   android:name=".TUICallService"
   android:enabled="true"
   android:exported="false" />`

2. 实现TUICallService.java，详细代码可[参考](https://github.com/LiteAVSDK/TRTC_Flutter/blob/master/TRTC-API-Example/android/app/src/main/java/com/example/trtc_api_example/TUICallService.java)

3. 可在切应用程序后台的时候开启保活`TUICallService.start(this)`，切前台的时候关闭保活`TUICallService.stop(this)`
详细代码可见[MainActivity.java](https://github.com/LiteAVSDK/TRTC_Flutter/blob/master/TRTC-API-Example/android/app/src/main/java/com/example/trtc_api_example/MainActivity.java)