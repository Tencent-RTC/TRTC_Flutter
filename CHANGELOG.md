## 13.4.2
### Bugfix
- Fixed rendering type update timing issue

## 13.4.1
### New Features
- Modify the TRTC native SDK dependency version constraint.

## 13.4.0
### Dependency Notes
- Native SDK update to 13.4.+
### New Features
- TRTC video rendering supports texture rendering.

## 13.2.3
### New Features
- The desktop client supports multi-stream rendering for a single user.
- Added support for super_player capabilities.
- TRTC video-related APIs support passing `null` for `viewId`.

## 13.2.2
### New Features
- Optimized the activation logic of the live-streaming beauty effect.
### Bugfix
- Fixed Xcode compilation issues caused by using an older linker.

## 13.2.1
### New Features
- Optimized the activation logic for Tencent's beauty effects.

## 13.2.0
### Dependency Notes
- Native SDK update to 13.2.+
### New Features
- Supports audio data callbacks.
- Live supports setting up beauty filters for the push stream.

## 13.1.1
### New Features
- Android supports the `startSystemAudioLoopback` interface.

## 13.1.0
### Dependency Notes
- Native SDK update to 13.1.+
### Bugfix
- Fixed an issue where the startPlayMusic interface was ineffective on some devices.

## 13.0.0
### Dependency Notes
- Native SDK update to 13.0.+
### New Features
- Added AI transcription-related manager.
### Bugfix
- Fixed an issue where subsequent attempts to retrieve the instance would fail when `sharedInstance` was called multiple times simultaneously.

## 12.9.1
### New Features
- Optimize some ineffective interfaces.
### Bugfix
- Optimizing Android resource management.
- Fixed an issue with custom audio data errors.

## 12.9.0
### Dependency Notes
- Native SDK update to 12.9.+
### Bugfix
- Optimize TRTC callback dispatch logic
- Fix the issue of incorrect enumeration value mapping

## 12.8.2
### Bugfix
- Modify some Android configurations to be compatible with flutter versions below 3.27.

## 12.8.1
### Bugfix
- Fixed the issue that caused some third-party plug-in channels to be invalid.

## 12.8.0
### Dependency Notes
- Native SDK update to 12.8.+
### Bugfix
- Fixed an issue where the watermark was not being released after submitting a single data instance.
- Fixed an issue where CDN formatting errors were being submitted.

## 12.6.1
### New Features
- Added `setVideoEncoderMirror` interface
### Bugfix
- To avoid NDK version conflicts, use the flutter NDK version by default.
- Fixed the issue that `stopRemoteView` on desktop is invalid.

## 12.6.0
### Dependency Notes
- Android SDK update to 12.6.+
- iOS SDK update to 12.6.18894
- macOS SDK update to 12.6.18866
- Windows SDK update to 12.6.0.16559

## 12.5.4
### Bugfix
- Fixed the issue that the `startScreenCapture` interface does not work on iOS platform
### New Features
- iOS: Added `startScreenCaptureByReplaykit` interface

## 12.5.3
### Bugfix
- Fix the occasional null pointer error when exiting the background on Android

## 12.5.2
### Bugfix
- Fixed crash caused by conflict with other plugin dart_api related C code
- Screen sharing supports local preview without preview

## 12.5.1
### Bugfix
- Fixed the issue that sendCustomCmdMsg caused data truncation when sending Chinese characters

## 12.5.0
### Dependency Notes
- Android SDK update to 12.5.0.17568
- iOS SDK update to 12.5.18359
- macOS SDK update to 12.5.18359
- Windows SDK update to 12.5.0.16383

## 12.3.7
### Bugfix
- Fix the issue that videos cannot be played on Windows & macOS
### New Features
- Android&iOS: Added `snapshotVideo`, `setVideoMuteImage`, and `setWatermark` interfaces

## 12.3.6
### Bugfix
- Fix persistent memory leak after setting callback

## 12.3.5
### Bugfix
- Fixed an issue that could cause conflicts with other ffi plugins

## 12.3.4
### Bugfix
- Windows：Fixed the issue that Windows compilation failed due to incorrect text encoding format settings
- Android&iOS: Added an experimental API for beauty adaptation

## 12.3.2
### Bugfix
- Complete the required symbols in iOS/MacOS SymbolDummy

## 12.3.1
### Bugfix
- Fixed the crash caused by checking out after setting the music interface callback

## 12.3.0
### Dependency Notes
- Android: Android SDK update to 12.3.0.17115
- iOS: iOS SDK update to 12.3.16995
- MacOS: MacOS SDK update to 12.3.16995
- Windows: Windows SDK update to 12.3.0.15893

## 12.2.6
### Bugfix
- Android: Adapt to gradle 8.0 and above

## 12.2.5
### New Features
- Added `setBeautyStyle` interface
### Bugfix
- Fixed an issue with compiling Android on Linux

## 12.2.4
### Bugfix
- iOS: Fix the problem that symbols cannot be found under release.

## 12.2.3
### New Features
- Android: Supports Gradle versions below 7.5

## 12.2.2
### Dependency Notes
- Android SDK update to 12.2.0.15072

## 12.2.1
### Optimize
- Optimize documentation and examples.

## 12.2.0
### New Features
- The new version of Tencent RTC Flutter SDK based on FFI supports Android, iOS, macOS, Windows, and also supports OHOS ([please fill out the application form if you want to use OHOS](https://cloud.tencent.com/apply/p/2fvwc8qu2x5)).

