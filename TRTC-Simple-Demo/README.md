[简体中文](./README-zh_CN.md) | English

# Demo(Flutter)

This document describes how to quickly run the TRTC demo for Flutter.

Note: The international version only supports Android and IOS.

## Environment Requirements
- Flutter 2.0 or above
- **Developing for Android:**
  - Android Studio 3.5 or above
  - Devices with Android 4.1 or above
- **Developing for iOS:**
  - Xcode 11.0 or above
  - OS X 10.11 or above
  - A valid developer signature for your project

## Prerequisites
You have [signed up](https://intl.cloud.tencent.com) for a Tencent Cloud account and completed identity verification.

## Directions
[](id:step1)
### Step 1. Create an application
1. Log in to the TRTC console and select **Development Assistance** > **[Demo Quick Run](https://console.intl.cloud.tencent.com/trtc/quickstart)**.
2. Click **Create Application** and enter the application name such as `TestTRTC`. If you have already created an application, click **Select Existing Application**.
3. Add or edit tags according to your actual business needs and click **Create**.
![](https://main.qcloudimg.com/raw/8dc52b5fa66ec4a5a4317719f9d442b9.png)
>?
>- An application name can contain up to 15 characters. Only digits, letters, Chinese characters, and underscores are allowed.
>- Tags are used to identify and organize your Tencent Cloud resources. For example, an enterprise may have multiple business units, each of which has one or more TRTC applications. In this case, the enterprise can tag TRTC applications to mark out the unit information. Tags are optional and can be added or edited according to your actual business needs.

[](id:step2)
### Step 2. Download the SDK and demo source code
1. Download the SDK and [demo source code](https://github.com/LiteAVSDK/TRTC_Flutter/tree/master/TRTC-Simple-Demo) for your platform.
2. Click **Next**.
![](https://main.qcloudimg.com/raw/9f4c878c0a150d496786574cae2e89f9.png)


[](id:step3)
### Step 3. Configure demo project files
1. In the **Modify Configuration** step, select the development platform in line with the source package downloaded.
2. Find and open `/example/lib/debug/GenerateTestUserSig.dart`.
3. Set parameters in `GenerateTestUserSig.dart` as follows.
<ul><li/>SDKAPPID: a placeholder by default. Set it to the actual `SDKAppID`.
	<li/>`SECRETKEY`: a placeholder by default. Set it to the actual key.</ul>
<img src="https://main.qcloudimg.com/raw/87dc814a675692e76145d76aab91b414.png">

4. Click **Next** to complete the creation.
5. After compilation, click **Return to Overview Page**.

>?
>- The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is leaked, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for the local execution and debugging of the demo**.
>- The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://intl.cloud.tencent.com/document/product/647/35166).

[](id:step4)
### Step 4. Compile and run
1. Run `flutter pub get`.
2. Compile, run, and debug the project.

####  Android
1. Run `flutter run`.
2. Open the demo project with Android Studio (3.5 or above), and click **Run**.

#### iOS
Open the `/ios` demo project in the source code directory with Xcode (11.0 or above) and compile and run the demo project.

## FAQs
### How do I view TRTC logs?
TRTC logs are compressed and encrypted by default with the `.xlog` extension at the following address:
- **iOS**: `Documents/log` in the sandbox.
- **Android**:
	- 6.7 or below: `/sdcard/log/tencent/liteav`.
	- 6.8 or above: `/sdcard/Android/data/package name/files/log/tencent/liteav/`.

### What should I do if videos do not show on iOS but do on Android?
Please check whether `io.flutter.embedded_views_preview` is `YES` in your `info.plist`. 

### What should I do if Android Studio fails to build my project with the error "Manifest merge failed"?
Open `/example/android/app/src/main/AndroidManifest.xml`.
    1. Add `xmlns:tools="http://schemas.android.com/tools"` to `manifest`.
    2. Add `tools:replace="android:label"` to `application`.
![Illustration](https://main.qcloudimg.com/raw/7a37917112831488423c1744f370c883.png)

>? For more FAQs, please see [Flutter](https://intl.cloud.tencent.com/document/product/647/39242).