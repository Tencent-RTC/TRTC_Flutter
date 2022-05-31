# TRTC Flutter API-Example 
## Collect audio and video after switching to background

### iOS
If you want the SDK to run in the background, select your project, under the Capabilities tab, toggle on Background Modes, and select Audio, AirPlay, and Picture in Picture.

![](https://main.qcloudimg.com/raw/d960dfec88388936abce2d4cb77ac766.jpg)

### Android
If you need to use an Android 9 device to capture audio or video after the device locks its screen, you can start a foreground service before the screen locks, and stop the service before exiting the screen lock. On how to start a service, see [https://developer.android.com/reference/android/app/Service](https://developer.android.com/reference/android/app/Service)

Here is a brief reference code:

1. Add the following configuration to AndroidManifest.xml
`<service
   android:name=".TUICallService"
   android:enabled="true"
   android:exported="false" />`

2. Implement TUICallService.java，detailed code can be [reference](https://github.com/LiteAVSDK/TRTC_Flutter/blob/master/TRTC-API-Example/android/app/src/main/java/com/example/trtc_api_example/TUICallService.java)

3. It can be enabled when the application background is switched `TUICallService.start(this)`，disabled when switch to front `TUICallService.stop(this)`
detailed code can be reference [MainActivity.java](https://github.com/LiteAVSDK/TRTC_Flutter/blob/master/TRTC-API-Example/android/app/src/main/java/com/example/trtc_api_example/MainActivity.java)