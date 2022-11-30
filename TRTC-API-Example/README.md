# TRTC Flutter API-Example

[中文](README_zh-CN.md) | English

## Background

This open-source demo shows how to use some APIs of the [TRTC Flutter SDK](https://intl.cloud.tencent.com/products/trtc) to help you better understand the APIs and use them to implement some basic TRTC features.

## Contents

This demo covers the following features (click to view the details of a feature):

- Basic Features
  - [Audio Call](./lib/Basic/AudioCall)
  - [Video Call](./lib/Basic/VideoCall)
  - [Interactive Live Video Streaming](./lib/Basic/Live)
  - [Interactive Live Audio Streaming](./lib/Basic/VoiceChatRoom)
  - [Screen Sharing Live Streaming](./lib/Basic/ScreenShare)
- Advanced Features
  - [String-type Room IDs](./lib/Advanced/StringRoomId)
  - [Video Quality Setting](./lib/Advanced/SetVideoQuality)
  - [Audio Quality Setting](./lib/Advanced/SetAudioQuality)
  - [Rendering Control](./lib/Advanced/SetRenderParams)
  - [Network Speed Testing](./lib/Advanced/SpeedTest)
  - [Audio Effect Setting](./lib/Advanced/SetAudioEffect)
  - [Background Music Setting](./lib/Advanced/SetBackgroundMusic)
  - [Local Video Recording](./lib/Advanced/LocalRecord)
  - [SEI Message Receiving/Sending](./lib/Advanced/SEIMessage)
  - [Room Switching](./lib/Advanced/SwitchRoom)
  - [Cross-Room Competition](./lib/Advanced/RoomPk)

## Environment Requirements

- Flutter 2.0or above
- **Developing for Android:**
  - Android Studio 3.5 or above
  - Devices with Android 4.1 or above
- **Developing for iOS:**
  - Xcode 11.0 or above
  - Your project has a valid developer signature.

## Demo Run Example

#### Prerequisites

You have [signed up](https://www.tencentcloud.com/) for a Tencent Cloud account and completed identity verification.

### Obtaining `SDKAPPID` and `SECRETKEY`

1. Log in to the TRTC console and select **Application Management** > **[Create application](https://console.tencentcloud.com/trtc/app/create)**.
2. Click **Create Application** and enter the application name such as `APIExample`. If you have already created an application, click **Select Existing Application**.
   ![#900px](https://qcloudimg.tencent-cloud.cn/raw/30fddb57f90491c7c94fd1cdfdde9a81.png)
3. Click **Next** to view your `SDKAppID` and key.

### Configuring demo project files

1. Find and open `/lib/Debug/GenerateTestUserSig.dart`.
2. Set parameters in `GenerateTestUserSig.dart` as follows.

> - SDKAPPID: a placeholder by default. Set it to the actual `SDKAppID`.
> - SECRETKEY: a placeholder by default. Set it to the actual key.
>   ![#900px](https://imgcache.qq.com/operation/dianshi/other/flutter_sig.237b3ce20dde2fa6cac972f49169e7e539d691fd.png)

3. Click **Next** to complete the creation.
4. After compilation, click **Return to Overview Page**.

> !The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging of the demo**.

> The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can make a request to the business server for dynamic `UserSig`. For more information, please see [How to Calculate UserSig](https://intl.cloud.tencent.com/document/product/647/35166).

### Compiling and running the project

1. Run `flutter pub get`.
2. Compile, run, and debug the project.

#### Android

1. Run `flutter run`.
2. Open the demo project with Android Studio (3.5 or above), and click **Run**.

#### iOS

1. Run `pod install`.
2. Open the `/ios` demo project in the source code directory with Xcode (11.0 or above) and compile and run the demo project.
