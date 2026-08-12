import 'package:json_annotation/json_annotation.dart';
part 'tx_device_manager.g.dart';

/// Audio route (the route via which audio is played)
@JsonEnum(alwaysCreate: true)
enum TXAudioRoute {
  /// - Speakerphone: the speaker at the bottom is used for playback (hands-free). With relatively high volume, it is used to play music out loud.
  @JsonValue(0)
  speakerPhone,

  /// - Earpiece: the receiver at the top is used for playback. With relatively low volume, it is suitable for call scenarios that require privacy.
  @JsonValue(1)
  earpiece,

  /// - WiredHeadset.
  @JsonValue(2)
  wiredHeadset,

  /// - BluetoothHeadset.
  @JsonValue(3)
  bluetoothHeadset,

  /// - SoundCard.
  @JsonValue(4)
  soundCard,
}

extension TXAudioRouteExt on TXAudioRoute {
  /// @nodoc
  static TXAudioRoute fromValue(int value) {
    return $enumDecode(_$TXAudioRouteEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TXAudioRouteEnumMap[this]!;
  }
}

/// Device Type (for Desktop OS)
///
/// This enumerated type defines three types of audio/video devices:
/// - Camera
/// - Microphone (Mic)
/// - Speaker
///
/// This allows you to use the same device management API to manage
/// all three types of devices.
@JsonEnum(alwaysCreate: true)
enum TXMediaDeviceType {
  /// - undefined device type
  @JsonValue(-1)
  unknown,

  /// - microphone
  @JsonValue(0)
  mic,

  /// - speaker or earpiece
  @JsonValue(1)
  speaker,

  /// - camera
  @JsonValue(2)
  camera,
}

/// @nodoc
extension TXMediaDeviceTypeExt on TXMediaDeviceType {
  /// @nodoc
  static TXMediaDeviceType fromValue(int value) {
    return $enumDecode(_$TXMediaDeviceTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TXMediaDeviceTypeEnumMap[this]!;
  }
}

/// Device operation
///
/// This enumerated value is used to notify the status change of the local device onDeviceChanged.
@JsonEnum(alwaysCreate: true)
enum TXMediaDeviceState {
  /// - The device has been plugged in
  @JsonValue(0)
  add,

  /// - The device has been removed
  @JsonValue(1)
  remove,

  /// - The device has been enabled
  @JsonValue(2)
  active,

  /// - system default device changed
  @JsonValue(3)
  defaultDeviceChanged,
}

/// @nodoc
extension TXMediaDeviceStateExt on TXMediaDeviceState {
  /// @nodoc
  static TXMediaDeviceState fromValue(int value) {
    return $enumDecode(_$TXMediaDeviceStateEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TXMediaDeviceStateEnumMap[this]!;
  }
}

/// Camera acquisition preferences
///
/// This enum is used to set camera acquisition parameters.
@JsonEnum(alwaysCreate: true)
enum TXCameraCaptureMode {
  /// - Auto adjustment of camera capture parameters.
  /// - SDK selects the appropriate camera output parameters according to the actual acquisition device performance and network situation,
  /// and maintains a balance between device performance and video preview quality.
  @JsonValue(0)
  auto,

  /// - Give priority to equipment performance.
  /// - SDK selects the closest camera output parameters according to the user's encoder resolution and frame rate, so as to ensure the performance of the device.
  @JsonValue(1)
  performance,

  /// - Give priority to the quality of video preview.
  /// - SDK selects higher camera output parameters to improve the quality of preview video. In this case, it will consume more CPU and memory to do video preprocessing.
  @JsonValue(2)
  highQuality,

  /// - Allows the user to set the width and height of the video captured by the local camera.
  @JsonValue(3)
  manual,
}

/// @nodoc
extension TXCameraCaptureModeExt on TXCameraCaptureMode {
  /// @nodoc
  static TXCameraCaptureMode fromValue(int value) {
    return $enumDecode(_$TXCameraCaptureModeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TXCameraCaptureModeEnumMap[this]!;
  }
}

/// Camera acquisition parameters
///
/// This setting determines the quality of the local preview image.
class TXCameraCaptureParam {
  /// - Field description: camera acquisition preferences,please see [TXCameraCaptureMode]
  TXCameraCaptureMode mode;

  /// - Field description: width of acquired image
  int width;

  /// - Field description:  height of acquired image
  int height;

  TXCameraCaptureParam({
    this.mode = TXCameraCaptureMode.auto,
    this.width = 640,
    this.height = 360,
  });
}

class TXDeviceInfo {
  /// - device name
  String deviceName;

  /// - device id
  String devicePid;

  /// - device properties
  String deviceProperties;

  TXDeviceInfo({
    this.deviceName = '',
    this.devicePid = '',
    this.deviceProperties = '',
  });
}

class TXDeviceObserver {
  /// The Status of a Local Device Changed (for Desktop OS Only)
  ///
  /// The SDK returns this callback when a local device (camera, mic, or speaker)
  /// is connected or disconnected.
  ///
  /// - **Parameters:**
  ///   - **deviceId**:
  ///     - Device ID.
  ///   - **deviceType**:
  ///     - Device type.
  ///       - `0`: Microphone
  ///       - `1`: Speaker
  ///       - `2`: Camera
  ///   - **state**:
  ///     - Device status.
  ///       - `0`: Connected
  ///       - `1`: Disconnected
  ///       - `2`: Started
  final void Function(
          String deviceId, TXMediaDeviceType type, TXMediaDeviceState state)
      onDeviceChanged;

  TXDeviceObserver({
    required this.onDeviceChanged,
  });
}

abstract class TXDeviceManager {
  /// Querying whether the front camera is being used
  bool isFrontCamera();

  /// Switching to the front/rear camera (for mobile OS)
  ///
  /// - **Parameters:**
  ///   - **frontCamera(bool)**:
  ///      - `true` front camera;
  ///      - `false` rear camera.
  int switchCamera(bool frontCamera);

  /// Getting the maximum zoom ratio of the camera (for mobile OS)
  double getCameraZoomMaxRatio();

  /// Setting the Camera Zoom Ratio (for Mobile OS)
  ///
  /// - **Parameters:**
  ///   - **zoomRatio(double)**:
  ///     - Value range: 1-5.
  ///       - `1` indicates the widest angle of view (original).
  ///       - `5` indicates the narrowest angle of view (zoomed in).
  ///     - The maximum value is recommended to be `5`.
  ///       If the value exceeds `5`, the video will become blurred.
  int setCameraZoomRatio(double ratio);

  /// Querying whether automatic face detection is supported (for mobile OS)
  bool isAutoFocusEnabled();

  /// Enabling auto focus (for mobile OS)
  ///
  /// After auto focus is enabled, the camera will automatically detect and always focus on faces.
  int enableCameraAutoFocus(bool enabled);

  /// Adjusting the Focus (for Mobile OS)
  ///
  /// This API can be used to achieve the following:
  ///
  /// 1. A user can tap on the camera preview.
  /// 2. A rectangle will appear where the user taps, indicating the spot the camera will focus on.
  /// 3. The user passes the coordinates of the spot to the SDK using this API,
  ///    and the SDK will instruct the camera to focus as required.
  ///
  /// - **Parameters:**
  ///   - **x(double)**:
  ///     - The x-coordinate value of the desired focus point
  ///   - **y(double)**:
  ///     - The y-coordinate value of the desired focus point
  ///
  /// > **Note**
  /// > Before using this API, you must first disable auto focus using [enableCameraAutoFocus].
  ///
  /// Return Description:
  /// - `0`: Operation successful;
  /// - Negative number: Operation failed.
  int setCameraFocusPosition(double x, double y);

  /// Enabling/Disabling flash, i.e., the torch mode (for mobile OS)
  ///
  /// - **Parameters:**
  ///   - **enabled(bool)**
  int enableCameraTorch(bool enabled);

  /// Setting the Audio Route (for Mobile OS)
  ///
  /// A mobile phone has two audio playback devices:
  /// - The receiver at the top
  /// - The speaker at the bottom
  ///
  /// If the audio route is set to the receiver:
  /// - The volume is relatively low, and audio can be heard only when the phone is put near the ear.
  /// - This mode has a high level of privacy and is suitable for answering calls.
  ///
  /// If the audio route is set to the speaker:
  /// - The volume is relatively high, and there is no need to put the phone near the ear.
  /// - This mode enables the "hands-free" feature.
  ///
  /// - **Parameters:**
  ///   - **route([TXAudioRoute])**
  int setAudioRoute(TXAudioRoute route);

  /// Getting the Device List (for Desktop OS)
  ///
  /// - **Parameters:**
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type. Set it to the type of device you want to get.
  List<TXDeviceInfo> getDevicesList(TXMediaDeviceType type);

  /// Setting the Device to Use (for Desktop OS)
  ///
  /// - **Parameters:**
  ///   - **deviceId(String)**:
  ///     - Device ID. You can get the ID of a device using the [getDevicesList] API.
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  ///
  /// Return Description:
  /// - `0`: Operation successful;
  /// - Negative number: Operation failed.
  int setCurrentDevice(TXMediaDeviceType type, String deviceId);

  /// Getting the device currently in use (for desktop OS)
  ///
  /// - **Parameters:**
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  TXDeviceInfo getCurrentDevice(TXMediaDeviceType type);

  /// Setting the Volume of the Current Device (for Desktop OS)
  ///
  /// This API is used to set the capturing volume of the mic or
  /// playback volume of the speaker, but not the volume of the camera.
  ///
  /// - **Parameters:**
  ///   - **volume(int)**:
  ///     - Volume. Value range: 0-100; default: 100.
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  int setCurrentDeviceVolume(TXMediaDeviceType type, int volume);

  /// Getting the Volume of the Current Device (for Desktop OS)
  ///
  /// This API is used to get the capturing volume of the mic or
  /// playback volume of the speaker, but not the volume of the camera.
  ///
  /// - **Parameters:**
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  int getCurrentDeviceVolume(TXMediaDeviceType type);

  /// Muting the current device (for desktop OS)
  ///
  /// This API is used to mute the mic or speaker, but not the camera.
  ///
  /// - **Parameters:**
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  ///   - **mute(bool)**:
  int setCurrentDeviceMute(TXMediaDeviceType type, bool mute);

  /// Querying whether the current device is muted (for desktop OS)
  ///
  /// This API is used to query whether the mic or speaker is muted. Camera muting is not supported.
  ///
  /// - **Parameters:**
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  bool getCurrentDeviceMute(TXMediaDeviceType type);

  /// Set the Audio Device Used by SDK to Follow the System Default Device (for Desktop OS)
  ///
  /// This API is used to set the microphone and speaker types.
  /// Camera following the system default device is not supported.
  ///
  /// - **Parameters:**
  ///   - **enable(bool)**:
  ///     - Whether to follow the system default audio device.
  ///       - `true`: Following. When the default audio device of the system is changed or a new audio device is plugged in, the SDK immediately switches the audio device.
  ///       - `false`: Not following. When the default audio device of the system is changed or a new audio device is plugged in, the SDK doesn't switch the audio device.
  ///   - **type([TXMediaDeviceType])**:
  ///     - Device type.
  int enableFollowingDefaultAudioDevice(TXMediaDeviceType type, bool enable);

  /// Starting Camera Testing (for Desktop OS)
  ///
  /// - **Parameters:**
  ///   - **viewId(int)**
  ///     - Controls for rendering camera test images.
  ///
  /// > **Note**
  /// > You can use the [setCurrentDevice] API to switch between cameras during testing.
  int startCameraDeviceTest(int viewId);

  /// Ending camera testing (for desktop OS)
  void stopCameraDeviceTest();

  /// Starting Mic Testing (for Desktop OS)
  ///
  /// This API is used to test whether the mic functions properly.
  /// The mic volume detected (value range: 0-100) is returned via a callback.
  ///
  /// - **Parameters:**
  ///   - **interval(int)**:
  ///     - Interval of volume callbacks.
  ///
  /// > **Note**
  /// > When this interface is called, the sound recorded by the microphone will be played back to the speakers by default.
  int startMicDeviceTest(int interval);

  /// Starting Mic Testing (for Desktop OS)
  ///
  /// This API is used to test whether the mic functions properly.
  /// The mic volume detected (value range: 0-100) is returned via a callback.
  ///
  /// - **Parameters:**
  ///   - **interval(int)**:
  ///     - Interval of volume callbacks.
  ///   - **playback(bool)**:
  ///     - Whether to play back the microphone sound.
  ///     - The user will hear his own sound when testing the microphone if `playback` is true.
  int startMicDeviceTestAndPlayback(int interval, bool playback);

  /// Ending mic testing (for desktop OS)
  void stopMicDeviceTest();

  /// Starting Speaker Testing (for Desktop OS)
  ///
  /// This API is used to test whether the audio playback device functions properly
  /// by playing a specified audio file. If users can hear audio during testing,
  /// the device functions properly.
  ///
  /// - **Parameters:**
  ///   - **filePath(String)**:
  ///     - Path of the audio file.
  int startSpeakerDeviceTest(String filePath);

  /// Ending speaker testing (for desktop OS)
  void stopSpeakerDeviceTest();

  /// Setting the volume of the current process in the volume mixer (for Windows)
  ///
  /// - **Parameters:**
  ///   - **volume(int)**
  int setApplicationPlayVolume(int volume);

  /// Getting the volume of the current process in the volume mixer (for Windows)
  int getApplicationPlayVolume();

  /// Muting the current process in the volume mixer (for Windows)
  ///
  /// - **Parameters:**
  ///   - **volume(int)**
  int setApplicationMuteState(bool mute);

  /// Querying whether the current process is muted in the volume mixer (for Windows)
  int getApplicationMuteState();

  /// Set camera acquisition preferences
  ///
  /// - **Parameters:**
  ///   - **params([TXCameraCaptureParam])**
  ///     - Camera acquisition parameters
  void setCameraCaptureParam(TXCameraCaptureParam params);

  /// set onDeviceChanged callback
  int setDeviceObserver(TXDeviceObserver? observer);
}
