// ignore_for_file: empty_constructor_bodies
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: unintended_html_in_doc_comment
// ignore_for_file: comment_references
import 'dart:typed_data';

import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/impl/live/push/v2_tx_live_pusher_impl.dart';

import 'v2_tx_live_code.dart';
import 'v2_tx_live_def.dart';
import 'v2_tx_live_pusher_observer.dart';

/// Live stream pusher
abstract class V2TXLivePusher {
  V2TXLivePusher() {}

  /// Create an instance
  static Future<V2TXLivePusher> create(V2TXLiveMode liveMode) async {
    return V2TXLivePusherImpl.create(liveMode);
  }

  /// Add a pusher callback
  ///
  /// By setting callbacks, you can listen to some callback events of the V2TXLivePusher streamer,
  /// including the streamer status, volume callback, statistics, warnings, and error messages.
  ///
  /// **Parameter:**
  ///
  /// `observer` the target object of the pusher's callback, For more information, please see [V2TXLivePusherObserver]
  void addListener(V2TXLivePusherObserver observer);

  /// Remove a pusher callback
  ///
  /// **Parameter:**
  ///
  /// `observer` the target object of the pusher's callback, For more information, please see [V2TXLivePusherObserver]
  void removeListener(V2TXLivePusherObserver observer);

  /// Destroy the instance
  void destroy();

  /// Set the ID of the local camera preview
  ///
  /// The image captured by the local camera will be displayed on the incoming View after being superimposed with various effects such as beautification, face shape adjustment, and filters.
  ///
  /// **Parameter:**
  ///
  /// `identifier` Local camera preview ID
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderViewID(int viewID);

  /// Set the camera mirror type
  ///
  /// **Parameter:**
  ///
  /// `mirrorType` [V2TXLiveMirrorType]
  /// - [V2TXLiveMirrorType.v2TXLiveMirrorTypeAuto]  Default value: The default image type. In this case, the front camera is mirrored, and the rear camera is not
  /// - [V2TXLiveMirrorType.v2TXLiveMirrorTypeEnable]  Both the front camera and the rear camera are switched to mirror mode
  /// - [V2TXLiveMirrorType.v2TXLiveMirrorTypeDisable] Both the front camera and the rear camera are switched to non-mirror mode
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderMirror(V2TXLiveMirrorType mirrorType);

  ///
  /// Set the video encoding image
  ///
  /// Encoding mirroring only affects the video effect that viewers see.
  ///
  /// **Parameter:**
  ///
  /// `mirror` Whether it is mirrored
  /// - false Default value: The player sees a non-mirror image
  /// - true: What the player sees is a mirror image
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setEncoderMirror(bool mirror);

  ///
  /// Set the rotation angle of the local camera preview screen
  ///
  /// Only the local preview screen is rotated, and the pushed image is not affected.
  ///
  /// **Parameter:**
  ///
  /// `rotation` Rotation angle [V2TXLiveRotation]
  /// - [V2TXLiveRotation.v2TXLiveRotation0] Default value: 0 degrees, no rotation
  /// - [V2TXLiveRotation.v2TXLiveRotation90]  Rotate 90 degrees clockwise
  /// - [V2TXLiveRotation.v2TXLiveRotation180] Rotate 180 degrees clockwise
  /// - [V2TXLiveRotation.v2TXLiveRotation270] Rotate 270 degrees clockwise
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderRotation(V2TXLiveRotation rotation);

  /// Set the fill mode of the picture
  ///
  /// **Parameter:**
  /// `mode` Picture fill mode [V2TXLiveFillMode]
  /// - [V2TXLiveFillMode.v2TXLiveFillModeFill] Default: The image covers the screen without black bars, and if the aspect ratio of the image is different from the aspect ratio of the screen, part of the image content will be cropped
  /// - [V2TXLiveFillMode.v2TXLiveFillModeFit] The image adapts to the screen and keeps the picture intact, but if the image aspect ratio is different from the screen aspect ratio, there will be black bars
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setRenderFillMode(V2TXLiveFillMode mode);

  /// Turn on your local camera
  ///
  /// Note: startVirtualCamera, startCamera, startScreenCapture, only one of them can be uplink under the same Pusher instance, and the three are overlay relationships. For example, startCamera is called first, and then startVirtualCamera is called. In this case, the camera is paused and the image stream is started
  ///
  /// **Parameter:**
  ///
  /// frontCamera Specifies whether the camera orientation is front-facing
  /// - true Default: Switch to the front-facing camera
  /// - false: Switch to the rear camera
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startCamera(bool frontCamera);

  /// Turn off your local camera
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<void> stopCamera();

  ///
  /// Turn on the microphone
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startMicrophone();

  ///
  /// Turn off the microphone
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopMicrophone();

  ///
  /// Turn on screen capture
  ///
  /// Note: startVirtualCamera, startCamera, startScreenCapture, only one of them can be uplink under the same Pusher instance, and the three are overlay relationships. For example, startCamera is called first, and then startVirtualCamera is called. In this case, the camera is paused and the image stream is started
  ///
  /// **Parameter:**
  ///
  /// `appGroup`  This parameter is only valid for iOS and can be ignored for Android. It is the Application Group Identifier that is shared by the main application and the broadcast process
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> startScreenCapture(String appGroup);

  ///
  /// Turn off screen capture
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopScreenCapture();

  ///
  /// Pause the audio stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> pauseAudio();

  ///
  /// Resume the audio stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> resumeAudio();

  ///
  /// Pause the video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> pauseVideo();

  ///
  /// Resume the video stream
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> resumeVideo();

  ///
  /// Starts ingesting audio and video data
  ///
  /// **Parameter:**
  ///
  /// `url` The destination address of the stream ingest server can be used at any streaming server
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: The operation succeeds and the destination endpoint is connected
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: The operation failed and the URL was invalid
  /// - V2TXLIVE_ERROR_INVALID_LICENSE: The operation fails, the license is invalid, and the authentication fails
  /// - V2TXLIVE_ERROR_REFUSED: If the operation fails, RTC does not support pushing and pulling the same StreamId on the same device at the same time
  Future<V2TXLiveCode> startPush(String url);

  ///
  /// Stop pushing audio and video data
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> stopPush();

  ///
  /// Whether the stream ingest is pushing
  ///
  /// **Return:**
  /// - 1: Ingesting is in progress
  /// - 0: Ingest has been stopped
  Future<V2TXLiveCode> isPushing();

  ///
  /// Set the ingest audio quality
  ///
  /// **Parameter:**
  ///
  /// `quality` Audio quality [V2TXLiveAudioQuality]
  /// - [V2TXLiveAudioQuality.v2TXLiveAudioQualityDefault] Default value: General
  /// - [V2TXLiveAudioQuality.v2TXLiveAudioQualitySpeech] Voice
  /// - [V2TXLiveAudioQuality.v2TXLiveAudioQualityMusic]  Music
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: During the ingest process, the sound quality cannot be adjusted
  Future<V2TXLiveCode> setAudioQuality(V2TXLiveAudioQuality quality);

  ///
  /// Set the encoding parameters for streaming video
  ///
  /// **Parameter:**
  ///
  /// `param` Video encoding parameters [V2TXLiveVideoEncoderParam]
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setVideoQuality(V2TXLiveVideoEncoderParam param);

  /// Get sound effect management class ([TXAudioEffectManager])
  ///
  /// [TXAudioEffectManager] is a sound effect management API, through
  /// which you can implement the following features:
  /// - **Background music**: Both online music and local music can be
  ///   played back with various features such as speed adjustment, pitch
  ///   adjustment, original voice, accompaniment, and loop.
  /// - **In-ear monitoring**: The sound captured by the mic is played
  ///   back in the headphones in real time, which is generally used for
  ///   music live streaming.
  /// - **Reverb effect**: Karaoke room, small room, big hall, deep,
  ///   resonant, and other effects.
  /// - **Voice changing effect**: Young girl, middle-aged man, heavy
  ///   metal, and other effects.
  /// - **Short sound effect**: Short sound effect files such as applause
  ///   and laughter are supported (for files less than 10 seconds in
  ///   length, please set the `isShortFile` parameter to `true`).
  TXAudioEffectManager getAudioEffectManager();

  /// Get device management class ([TXDeviceManager])
  TXDeviceManager getDeviceManager();

  ///
  /// Capture the local image during stream ingest
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: Stream ingest has been stopped, and screenshot operations are not allowed
  Future<V2TXLiveCode> snapshot();

  ///
  /// Enables the capture volume prompt
  ///
  /// After this is enabled, you can get the SDK's evaluation of the volume value in the [V2TXLivePusherListenerType.onMicrophoneVolumeUpdate] callback.
  ///
  /// **Parameter:**
  ///
  /// `intervalMs` determines the trigger interval of the [V2TXLivePusherListenerType.onMicrophoneVolumeUpdate] callback, the unit is ms, the minimum interval is 100ms, if it is less than or equal to 0, the callback will be disabled, it is recommended to set it to 300ms; Default value: 0, not enabled
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableVolumeEvaluation(int intervalMs);

  ///
  /// Enable/disable custom video processing
  ///
  /// **Parameter:**
  ///
  /// `enable` true: Enabled; false: Disabled. Default: false
  ///
  /// `pixelFormat` Pixel format of the video called back for custom pre-processing[V2TXLivePixelFormat]
  ///
  /// `bufferType` Data format of the video called back for custom pre-processing[V2TXLiveBufferType]
  ///
  /// @note Supported format combinations:
  ///   V2TXLivePixelFormatTexture2D+V2TXLiveBufferTypeTexture
  ///   V2TXLivePixelFormatI420+V2TXLiveBufferTypeByteBuffer
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_NOT_SUPPORTED: Unsupported formats
  Future<V2TXLiveCode> enableCustomVideoProcess(bool enable,
      V2TXLivePixelFormat pixelFormat, V2TXLiveBufferType bufferType);

  ///
  /// Turn on/off custom video capture
  ///
  /// Note:
  /// - In this mode, the SDK no longer captures images from the camera, only retaining the encoding and sending capabilities.
  /// - It needs to be called before [startPush] for it to take effect.
  ///
  /// **Parameter:**
  ///
  /// `enable` true: enables custom collection. false: disables custom collection. Default: false
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableCustomVideoCapture(bool enable);

  ///
  /// Turn on/off custom audio capture
  ///
  /// Note:
  /// - In this mode, the SDK no longer captures sound from the microphone, only retaining the encoding and sending capabilities.
  /// - It needs to be called before [startPush] for it to take effect.
  ///
  /// **Parameter:**
  ///
  /// `enable` true: Enable custom collection; false: Disables custom collection. Default: false
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableCustomAudioCapture(bool enable);

  ///
  /// In the custom video capture mode, the collected video data is sent to the SDK
  ///
  /// Note:
  /// - In this mode, the SDK no longer collects camera data, and only retains the encoding and sending functions.
  /// - You need to call [enableCustomVideoCapture] before [startPush] to enable custom capture.
  ///
  /// **Parameter:**
  ///
  /// `videoFrame` Video frame data sent to the SDK [V2TXLiveVideoFrame]
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: The sending failed and the video frame data is invalid
  /// - V2TXLIVE_ERROR_REFUSED: If the sending fails, you must call [enableCustomVideoCapture] to enable custom video capture.
  Future<V2TXLiveCode> sendCustomVideoFrame(V2TXLiveVideoFrame videoFrame);

  ///
  /// In the custom audio collection mode, the collected audio data is sent to the SDK
  ///
  /// Note:
  /// - In this mode, the SDK no longer collects microphone data, and only retains the encoding and sending functions.
  /// - You need to call [enableCustomAudioCapture] before [startPush] to enable custom capture.
  ///
  /// **Parameter:**
  ///
  /// `audioFrame` Audio frame data sent to the SDK [V2TXLiveAudioFrame]
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: If the sending fails, you must first call [enableCustomAudioCapture] to enable custom audio capture
  Future<V2TXLiveCode> sendCustomAudioFrame(V2TXLiveAudioFrame audioFrame);

  ///
  /// Send an SEI message
  ///
  /// The player receives the message via the [V2TXLivePlayerListenerType.onReceiveSeiMessage] callback.
  ///
  /// **Parameter:**
  ///
  /// `payloadType`  Data type, 5, 242 supported. Recommended: 242
  ///
  /// `data`        Data to be sent
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> sendSeiMessage(int payloadType, Uint8List data);

  /// **Note:**
  /// - On the Windows platform, you can also specify `deviceName` as
  ///   the process ID of a certain process (in the format of
  ///   "process_xxx", where xxx is the process ID), and then the SDK
  ///   will capture the sound of that process (requires Windows version
  ///   10.0.19042 or higher).
  /// - You can also specify `deviceName` as the name of a certain
  ///   speaker device to capture specific speaker sound (you can use
  ///   the getDevicesList interface in TXDeviceManager to obtain the
  ///   speaker devices of type [TXMediaDeviceType.speaker]).
  Future<V2TXLiveCode> startSystemAudioLoopback(String? deviceName);

  /// Stop system audio capturing
  Future<V2TXLiveCode> stopSystemAudioLoopback();

  /// Set the volume of system audio capturing
  ///
  /// **Parameters:**
  /// - **volume(int)**:
  ///   - Set volume. Value range: [0, 150].
  ///   - Default value: 100.
  Future<V2TXLiveCode> setSystemAudioLoopbackVolume(int volume);

  /// Display the dashboard
  ///
  /// **Parameter:**
  ///
  /// `isShow` Whether it is displayed or not. Default: false
  Future<V2TXLiveCode> showDebugView(bool isShow);

  /// Call the high-level API interface of V2TXLivePusher
  ///
  /// **Parameter:**
  ///
  /// `key`   The key corresponding to the high-level API
  ///
  /// `value` When calling the high-level API corresponding to the key, the parameter required is a base type or jsonString
  ///
  /// **Return:**
  ///
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_INVALID_PARAMETER: If the operation fails, the key is not allowed to be null
  Future<V2TXLiveCode> setProperty(String key, Object value);

  ///
  /// Set the parameters for MixTranscoding in the cloud
  ///
  /// If you enable Enable Bypass Streaming on the Feature Configuration page in the real-time audio and video [Console](https://console.cloud.tencent.com/trtc/),
  /// Each screen in the room will have a default live stream [CDN address](https://cloud.tencent.com/document/product/647/16826)
  ///
  /// There may be more than one streamer in a live stream, and each streamer has their own picture and sound, but for CDN viewers, they only need to live stream all the way
  /// Therefore, you need to mix multiple audio and video streams into a standard live stream, which requires transcoding
  ///
  /// When you call this API, the SDK sends a command to Tencent Cloud's transcoding server to mix multiple audio and video streams in the room into one.
  /// You can use the mixStreams parameter to adjust the position of each image and whether to mix only sound, and you can also use parameters such as videoWidth, videoHeight, and videoBitrate to control the encoding parameters of the mixed audio and video streams
  ///
  /// <pre>
  /// 【Video1】=> Decode ====> \
  ///                         \
  /// 【Video2】=> Decode =>  video mixing => Encode => 【Mixed Video】
  ///                         /
  /// 【Video3】=> Decode ====> /
  ///
  /// 【Audio1】=> Decode ====> \
  ///                         \
  /// 【Audio2】=> Decode =>  audio mixing => Encode => 【Mixed Audio】
  ///                         /
  /// 【Audio3】=> Decode ====> /
  /// </pre>
  ///
  /// Reference: [Cloud Mixtranscoding](https://cloud.tencent.com/document/product/647/16827)
  ///
  /// Note:
  /// - Only RTC mode is supported
  /// - Cloud transcoding will introduce a certain CDN viewing delay, which will increase by about 1-2 seconds
  /// - The user who calls this function will mix the multi-channel image in the microphone connection to the current screen or the streamId specified in the config
  /// - Please note that if you are still in the room and no longer need to mix streams, be sure to pass null to cancel, because after you initiate stream mixing, the cloud stream mixing module will start working, and failure to cancel the mix in time may cause unnecessary billing losses
  /// - Rest assured, the mix-in status will be automatically canceled when you check out
  ///
  /// **Parameter:**
  ///
  /// `config` Please refer to [V2TXLiveTranscodingConfig]. If null is passed, the cloud blending transcoding is canceled
  ///
  /// **Return:**
  /// - V2TXLIVE_OK: Succeed
  /// - V2TXLIVE_ERROR_REFUSED: If stream ingest is not enabled, you are not allowed to set the MixTranscoding parameter
  Future<V2TXLiveCode> setMixTranscodingConfig(
      V2TXLiveTranscodingConfig? config);

  /// Enable/disable sharpness enhancement
  ///
  /// **Parameter:**
  ///
  /// `enable` true: Enable; false: Disable. Default: false
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> enableSharpnessEnhancement(bool enable);

  /// Set beauty style
  ///
  /// **Parameter:**
  ///
  /// `style` Beauty style
  ///
  /// `beautyLevel` Beauty level, value range: 0-9
  ///
  /// `whitenessLevel` Whiteness level, value range: 0-9
  ///
  /// `ruddinessLevel` Ruddiness level, value range: 0-9
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setBeautyStyle(
      int style, int beautyLevel, int whitenessLevel, int ruddinessLevel);

  /// Set LUT color filter
  ///
  /// **Parameter:**
  ///
  /// `file_path` LUT image file path. Pass null or empty string to disable filter
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setLUTColorFilter(String? file_path);

  /// Set LUT color filter strength
  ///
  /// **Parameter:**
  ///
  /// `strength` Filter strength, value range: 0.0-1.0
  ///
  /// **Return:**
  ///
  /// '0' success, more information please see [V2TXLiveCode]
  Future<V2TXLiveCode> setLUTColorFilterStrength(double strength);
}
