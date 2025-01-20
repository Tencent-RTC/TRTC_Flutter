import 'dart:async';
import 'package:flutter/services.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';

/// Device management
class TXDeviceManager {
  static late MethodChannel _channel;
  TXDeviceManager(channel) {
    _channel = channel;
  }

  /// Set whether to use the front camera (supports only the Android and iOS platforms)
  Future<bool?> isFrontCamera() {
    return _channel.invokeMethod('isFrontCamera');
  }

  /// Switch camera (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `isFrontCamera`: `true`: front camera; `false`: rear camera
  Future<int?> switchCamera(bool isFrontCamera) {
    return _channel.invokeMethod('switchCamera', {"isFrontCamera": isFrontCamera});
  }

  /// Get the camera zoom factor (supports only the Android and iOS platforms)
  Future<double?> getCameraZoomMaxRatio() {
    return _channel.invokeMethod('getCameraZoomMaxRatio');
  }

  /// Set the zoom factor (focal length) of camera (supports only the Android and iOS platforms)
  ///
  /// The value range is `1`–`5`. `1` indicates the furthest view (normal lens), and `5` indicates the nearest view (enlarging lens). We recommend you set the maximum value to `5`. If the maximum value is greater than `5`, the video will become blurry.
  ///
  /// **Parameters:**
  ///
  /// `value` Value range: `1`–`5`. The greater the value, the further the focal length
  ///
  /// Returned value. `0`: success; negative number: failure
  Future<int?> setCameraZoomRatio(
      double value // Value range: 1–5. The greater the value, the further the focal length
      ) {
    return _channel.invokeMethod('setCameraZoomRatio', {
      "value": value,
    });
  }

  /// Set the audio device used by the SDK to follow the system default device (Support for macOS and Windows platforms)
  ///
  /// Only supports setting microphone and speaker types. Camera does not currently support following the system default device.
  ///
  /// **Parameters:**
  ///
  /// `type` Device type. For more information, please see the definition of `TXMediaDeviceType`.
  ///
  /// `enable` `true`: enabled; `false`: disabled.
  Future<int?> enableFollowingDefaultAudioDevice(int type, bool enable) {
    return _channel.invokeMethod('enableFollowingDefaultAudioDevice', {
      "type": type,
      "enable": enable,
    });
  }

  /// Set whether to enable the automatic recognition of face position (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `enable`   `true`: enabled; `false`: disabled. Default value: `true`
  ///
  /// **Returned value**: `0`: success; negative number: failure
  Future<int?> enableCameraAutoFocus(bool enable) {
    return _channel.invokeMethod('enableCameraAutoFocus', {
      "enable": enable,
    });
  }

  /// Query whether the device supports automatic recognition of face position (supports only the Android and iOS platforms)
  ///
  /// **Returned value**: `true`: supported; `false`: not supported
  Future<bool?> isAutoFocusEnabled() {
    return _channel.invokeMethod('isAutoFocusEnabled');
  }

  /// Set camera focus (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `x` X coordinate of focus position
  ///
  /// `y` Y coordinate of focus position
  Future<void> setCameraFocusPosition(int x, int y) {
    return _channel.invokeMethod('setCameraFocusPosition', {
      "x": x,
      "y": y,
    });
  }

  /// Enable/Disable flash (supports only the Android and iOS platforms)
  ///
  /// **Parameters:**
  ///
  /// `enable` `true`: enabled; `false`: disabled. Default value: `false`
  Future<bool?> enableCameraTorch(
      bool enable // true: enabled; false: disabled. Default value: false
      ) {
    return _channel.invokeMethod('enableCameraTorch', {
      "enable": enable,
    });
  }

  /// Set the system volume type used in call (supports only the Android and iOS platforms)
  ///
  /// Smartphones usually have two system volume types, i.e., call volume and media volume.
  ///
  /// Currently, the SDK provides three control modes of system volume types, including:
  ///
  ///* [TRTCCloudDef.TRTCSystemVolumeTypeAuto] : "call volume with mic and media volume without mic", i.e., the call volume mode will be used when the anchor mics on, while the media volume mode will be used when the audience user mics off. This is suitable for live streaming scenarios. If the scenario you select during `enterRoom` is [TRTCCloudDef.TRTC_APP_SCENE_LIVE] or [TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM], the SDK will automatically select this mode.
  ///
  ///* [TRTCCloudDef.TRTCSystemVolumeTypeVOIP] : the call volume mode will be used throughout the call, which is suitable for conferencing scenarios. If the scenario you select during `enterRoom` is [TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL] or [TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL], the SDK will automatically select this mode.
  ///
  ///* [TRTCCloudDef.TRTCSystemVolumeTypeMedia] : the media volume mode is used throughout the call. This is not common and is suitable for scenarios with special requirements (for example, the anchor has an external sound card).
  ///
  /// **Note:**
  ///
  ///* This API must be called before [TRTCCloud.startLocalAudio] is called.
  ///
  ///* If you have no special requirements, we recommend you not set it by yourself. You just need to set your scenario through [TRTCCloud.enterRoom], and the SDK will automatically select the matching volume type internally.
  ///
  /// **Parameters:**
  ///
  /// `type` System volume type. If you have no special requirements, we recommend you not set it by yourself.
  Future<void> setSystemVolumeType(
      int type // System volume type. For more information, please see `TRTCSystemVolumeType`. Default value: TRTCSystemVolumeTypeAuto
      ) {
    return _channel.invokeMethod('setSystemVolumeType', {
      "type": type,
    });
  }

  /// Set audio route, i.e., earpiece at the top or speaker at the bottom (supports only the Android and iOS platforms)
  ///
  /// The hands-free mode of video call features in WeChat and Mobile QQ is implemented based on audio routing. Generally, a mobile phone has two speakers: one is the receiver at the top with low volume, and the other is the stereo speaker at the bottom with high volume. The purpose of setting audio routing is to determine which speaker will be used.
  ///
  /// **Parameters:**
  ///
  /// route Audio route, i.e., whether the audio is output by speaker or receiver. For more information, please see [TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER]. Default value: [TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER]
  Future<void> setAudioRoute(
      int route // Audio route, i.e., whether the audio is output by speaker or receiver
      ) {
    return _channel.invokeMethod('setAudioRoute', {
      "route": route,
    });
  }

  /// Get the list of devices (Support for macOS, Windows and web platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic]、[TRTCCloudDef.TXMediaDeviceTypeSpeaker], or [TRTCCloudDef.TXMediaDeviceTypeCamera].
  Future<Map?> getDevicesList(int type) {
    return _channel.invokeMethod('getDevicesList', {
      "type": type,
    });
  }

  /// Specify the current device (Support for macOS, Windows and web platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic]、[TRTCCloudDef.TXMediaDeviceTypeSpeaker], or [TRTCCloudDef.TXMediaDeviceTypeCamera].
  ///
  /// `deviceId` Device ID obtained from [getDevicesList]
  ///
  /// **Returned value**:
  ///
  /// `0`: success; negative number: failure
  Future<int?> setCurrentDevice(int type, String deviceId) {
    return _channel.invokeMethod('setCurrentDevice', {"type": type, "deviceId": deviceId});
  }

  /// Get the currently used device (Support for macOS, Windows and web platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic]、[TRTCCloudDef.TXMediaDeviceTypeSpeaker], or [TRTCCloudDef.TXMediaDeviceTypeCamera].
  ///
  /// `deviceId` Device ID obtained from `getDevicesList`
  ///
  /// **Returned value**:
  ///
  /// `ITRTCDeviceInfo` device information, from which the device ID and device name can be obtained
  Future<Map?> getCurrentDevice(int type) {
    return _channel.invokeMethod('getCurrentDevice', {"type": type});
  }

  /// Set the volume of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// `volume` Volume
  ///
  /// **Returned value**:
  ///
  /// `ITRTCDeviceInfo` device information, from which the device ID and device name can be obtained
  Future<int?> setCurrentDeviceVolume(int type, int volume) {
    return _channel.invokeMethod('setCurrentDeviceVolume', {"type": type, "volume": volume});
  }

  /// Get the volume of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// **Returned value**:
  ///
  /// Volume
  Future<int?> getCurrentDeviceVolume(int type) {
    return _channel.invokeMethod('getCurrentDeviceVolume', {"type": type});
  }

  /// Set the mute status of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// `mute` Whether to mute/freeze
  ///
  /// **Returned value**:
  ///
  /// `0`: success; negative number: failure
  Future<int?> setCurrentDeviceMute(int type, bool mute) {
    return _channel.invokeMethod('setCurrentDeviceMute', {"type": type, "mute": mute});
  }

  /// Query the mute status of the current device (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `type` Device type, which specifies the type of devices to be obtained. For more information, please see the definition of `TXMediaDeviceType`. `type` can only be [TRTCCloudDef.TXMediaDeviceTypeMic] or [TRTCCloudDef.TXMediaDeviceTypeSpeaker].
  ///
  /// **Returned value**:
  ///
  /// `true`: the current device is muted; `false`: the current device is not muted
  Future<bool?> getCurrentDeviceMute(int type) {
    return _channel.invokeMethod('getCurrentDeviceMute', {"type": type});
  }

  /// Start mic test (Support for macOS and Windows platforms)
  ///
  /// **Parameters:**
  ///
  /// `interval` Volume callback interval in ms
  ///
  /// **Returned value**:
  ///
  /// `0`: success; negative number: failure
  Future<int?> startMicDeviceTest(int interval) {
    return _channel.invokeMethod('startMicDeviceTest', {"interval": interval});
  }

  /// Stop mic test (Support for macOS and Windows platforms)
  ///
  /// **Returned value**:
  ///
  /// `0`: success; negative number: failure
  Future<int?> stopMicDeviceTest() {
    return _channel.invokeMethod('stopMicDeviceTest');
  }

  /// Start speaker test (Support for macOS and Windows platforms)
  ///
  /// This method plays back the specified audio data to test whether the speaker can function properly. If sound can be heard, the speaker is normal.
  ///
  /// **Parameters:**
  ///
  /// `filePath` Audio file path
  ///
  /// **Returned value**:
  ///
  /// `0`: success; negative number: failure
  Future<int?> startSpeakerDeviceTest(String filePath) {
    return _channel.invokeMethod('startSpeakerDeviceTest', {"filePath": filePath});
  }

  /// Stop speaker test (Support for macOS and Windows platforms)
  ///
  /// **Returned value**:
  ///
  /// `0`: success; negative number: failure
  Future<int?> stopSpeakerDeviceTest() {
    return _channel.invokeMethod('stopSpeakerDeviceTest');
  }

  /// Set the volume of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. Value range: `[0,100]`
  ///
  /// **Returned value**:
  ///
  /// `0`: success
  Future<int?> setApplicationPlayVolume(int volume) {
    return _channel.invokeMethod('setApplicationPlayVolume', {"volume": volume});
  }

  /// Get the volume of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Returned value**:
  ///
  /// Returned volume value. Value range: `[0,100]`
  Future<int?> getApplicationPlayVolume() {
    return _channel.invokeMethod('getApplicationPlayVolume');
  }

  /// Set the mute status of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Parameters:**
  ///
  /// `bMute` Whether to mute
  ///
  /// **Returned value**:
  ///
  /// `0`: success
  Future<int?> setApplicationMuteState(bool bMute) {
    return _channel.invokeMethod('setApplicationMuteState', {"bMute": bMute});
  }

  /// Get the mute status of the current process in the Windows system volume mixer (supports only the Windows platform)
  ///
  /// **Returned value**:
  ///
  /// Returned mute status
  Future<bool?> getApplicationMuteState() {
    return _channel.invokeMethod('getApplicationMuteState');
  }
}
