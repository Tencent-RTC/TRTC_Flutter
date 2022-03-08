# TRTC Flutter API-Example 
[中文](README.md) | English

## Background
This open-source demo shows how to use some APIs of the [TRTC Flutter SDK](https://cloud.tencent.com/document/product/647/32689) to help you better understand the APIs and use them to implement some basic TRTC features. 

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
You have [signed up for a Tencent Cloud account](https://intl.cloud.tencent.com/document/product/378/17985) and completed [identity verification](https://intl.cloud.tencent.com/document/product/378/3629).


### Obtaining `SDKAPPID` and `SECRETKEY`
1. Log in to the TRTC console and select **Development Assistance** > **[Demo Quick Run](https://console.cloud.tencent.com/trtc/quickstart)**.
2. Enter an application name such as `TestTRTC`, and click **Create**.

![ #900px](https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png)
3. Click **Next** to view your `SDKAppID` and key.


### Configuring demo project files
1. Open the [GenerateTestUserSig.dart](debug/GenerateTestUserSig.dart) file in the Debug directory.
2. Configure two parameters in the `GenerateTestUserSig.dart` file:
  - `SDKAPPID`: `PLACEHOLDER` by default. Set it to the actual `SDKAppID`.
  - `SECRETKEY`: left empty by default. Set it to the actual key.
 ![ #900px](https://main.qcloudimg.com/raw/fba60aa9a44a94455fe31b809433cfa4.png)

3. Return to the TRTC console and click **Next**.
4. Click **Return to Overview Page**.

>!The method for generating `UserSig` described in this document involves configuring `SECRETKEY` in client code. In this method, `SECRETKEY` may be easily decompiled and reversed, and if your key is disclosed, attackers can steal your Tencent Cloud traffic. Therefore, **this method is suitable only for the local execution and debugging of the demo**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your application can make a request to the business server for dynamic `UserSig`. For more information, please see [How to Calculate UserSig](https://cloud.tencent.com/document/product/647/17275#Server).


### Compiling and running the project
- Run `flutter pub get`。
- Compile, run, and debug the project `flutter run`
# Contact Us
- [FAQs](https://cloud.tencent.com/document/product/647/34399)
- [Documentation](https://cloud.tencent.com/document/product/647/16788)(Cloud+ Community)
- [API document](https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloud__ios.html)
- [Template for issue reporting](https://github.com/tencentyun/TRTCSDK/issues/53)

> If the above does not solve your problem, [report](https://wj.qq.com/s2/8393513/f442/) it to our **engineer**.
