// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;

import 'package:tencent_rtc_sdk/bindings/manager/tx_audio_effect_manager_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/manager/tx_device_manager_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/impl/live/v2_tx_live_struct.dart';

class V2TXLivePusherFFIBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;
  V2TXLivePusherFFIBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;
  V2TXLivePusherFFIBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ///***********************************************************************************************
  ///                                          V2TXLivePusher
  /// **********************************************************************************************

  ffi.Pointer<V2TXLivePusherNativePointer> createPusher(int mode) {
    return _createPusher(mode);
  }

  late final _createPusherPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<V2TXLivePusherNativePointer> Function(ffi.Int32)>>(
    'create_v2tx_live_pusher',
  );
  late final _createPusher = _createPusherPtr
      .asFunction<ffi.Pointer<V2TXLivePusherNativePointer> Function(int)>();

  int releasePusher(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _releasePusher(pusher);
  }

  late final _releasePusherPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'release_v2tx_live_pusher',
  );
  late final _releasePusher = _releasePusherPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int setRenderViewID(ffi.Pointer<V2TXLivePusherNativePointer> pusher,
      ffi.Pointer<ffi.Void> viewPointer) {
    return _setRenderView(pusher, viewPointer);
  }

  late final _setRenderViewPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Pointer<ffi.Void>)>>(
    'v2tx_live_pusher_set_render_view',
  );
  late final _setRenderView = _setRenderViewPtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Pointer<ffi.Void>)>();

  int setRenderMirror(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, int mirrorType) {
    return _setRenderMirror(pusher, mirrorType);
  }

  late final _setRenderMirrorPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Int32)>>(
    'v2tx_live_pusher_set_render_mirror',
  );
  late final _setRenderMirror = _setRenderMirrorPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();

  int setEncoderMirror(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, bool mirror) {
    return _setEncoderMirror(pusher, mirror);
  }

  late final _setEncoderMirrorPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool)>>(
    'v2tx_live_pusher_set_encoder_mirror',
  );
  late final _setEncoderMirror = _setEncoderMirrorPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, bool)>();

  int setRenderRotation(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, int rotation) {
    return _setRenderRotation(pusher, rotation);
  }

  late final _setRenderRotationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Int32)>>(
    'v2tx_live_pusher_set_render_rotation',
  );
  late final _setRenderRotation = _setRenderRotationPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();

  int setRenderFillMode(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, int mode) {
    return _setRenderFillMode(pusher, mode);
  }

  late final _setRenderFillModePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Int32)>>(
    'v2tx_live_pusher_set_render_fill_mode',
  );
  late final _setRenderFillMode = _setRenderFillModePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();

  int startCamera(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, bool frontCamera) {
    return _startCamera(pusher, frontCamera);
  }

  late final _startCameraPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool)>>(
    'v2tx_live_pusher_start_camera',
  );
  late final _startCamera = _startCameraPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, bool)>();

  int stopCamera(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _stopCamera(pusher);
  }

  late final _stopCameraPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_stop_camera',
  );
  late final _stopCamera = _stopCameraPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int startMicrophone(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _startMicrophone(pusher);
  }

  late final _startMicrophonePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_start_microphone',
  );
  late final _startMicrophone = _startMicrophonePtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int stopMicrophone(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _stopMicrophone(pusher);
  }

  late final _stopMicrophonePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_stop_microphone',
  );
  late final _stopMicrophone = _stopMicrophonePtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int startScreenCapture(ffi.Pointer<V2TXLivePusherNativePointer> pusher,
      ffi.Pointer<ffi.Int8> appGroup) {
    return _startScreenCapture(pusher);
  }

  late final _startScreenCapturePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_start_screen_capture',
  );
  late final _startScreenCapture = _startScreenCapturePtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int stopScreenCapture(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _stopScreenCapture(pusher);
  }

  late final _stopScreenCapturePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_stop_screen_capture',
  );
  late final _stopScreenCapture = _stopScreenCapturePtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int pauseAudio(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _pauseAudio(pusher);
  }

  late final _pauseAudioPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_pause_audio',
  );
  late final _pauseAudio = _pauseAudioPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int resumeAudio(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _resumeAudio(pusher);
  }

  late final _resumeAudioPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_resume_audio',
  );
  late final _resumeAudio = _resumeAudioPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int pauseVideo(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _pauseVideo(pusher);
  }

  late final _pauseVideoPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_pause_video',
  );
  late final _pauseVideo = _pauseVideoPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int resumeVideo(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _resumeVideo(pusher);
  }

  late final _resumeVideoPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_resume_video',
  );
  late final _resumeVideo = _resumeVideoPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int startPush(ffi.Pointer<V2TXLivePusherNativePointer> pusher,
      ffi.Pointer<ffi.Int8> url) {
    return _startPush(pusher, url);
  }

  late final _startPushPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Pointer<ffi.Int8>)>>(
    'v2tx_live_pusher_start_push',
  );
  late final _startPush = _startPushPtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Pointer<ffi.Int8>)>();

  int stopPush(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _stopPush(pusher);
  }

  late final _stopPushPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_stop_push',
  );
  late final _stopPush = _stopPushPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int isPushing(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _isPushing(pusher);
  }

  late final _isPushingPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_is_pushing',
  );
  late final _isPushing = _isPushingPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int setAudioQuality(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, int quality) {
    return _setAudioQuality(pusher, quality);
  }

  late final _setAudioQualityPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Int32)>>(
    'v2tx_live_pusher_set_audio_quality',
  );
  late final _setAudioQuality = _setAudioQualityPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();

  int setVideoQuality(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    ffi.Pointer<V2TXLiveVideoEncoderParamStruct> struct,
  ) {
    return _setVideoQuality(pusher, struct);
  }

  late final _setVideoQualityPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
                  ffi.Pointer<V2TXLiveVideoEncoderParamStruct>)>>(
      'v2tx_live_pusher_set_video_quality');
  late final _setVideoQuality = _setVideoQualityPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>,
          ffi.Pointer<V2TXLiveVideoEncoderParamStruct>)>();

  int setProperty(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    ffi.Pointer<ffi.Int8> key,
    ffi.Pointer<ffi.Void> value,
  ) {
    return _setProperty(pusher, key, value);
  }

  late final _setPropertyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Pointer<ffi.Int8>,
              ffi.Pointer<ffi.Void>)>>('v2tx_live_pusher_set_property');
  late final _setProperty = _setPropertyPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>,
          ffi.Pointer<ffi.Int8>, ffi.Pointer<ffi.Void>)>();

  TXAudioEffectManagerNativePointer getAudioEffectManager(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
  ) {
    return _getAudioEffectManager(pusher);
  }

  late final _getAudioEffectManagerPtr = _lookup<
          ffi.NativeFunction<
              TXAudioEffectManagerNativePointer Function(
                  ffi.Pointer<V2TXLivePusherNativePointer>)>>(
      'v2tx_live_pusher_get_audio_effect_manager');
  late final _getAudioEffectManager = _getAudioEffectManagerPtr.asFunction<
      TXAudioEffectManagerNativePointer Function(
          ffi.Pointer<V2TXLivePusherNativePointer>)>();

  TXDeviceManagerNativePointer getDeviceManager(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _getDeviceManager(pusher);
  }

  late final _getDeviceManagerPtr = _lookup<
          ffi.NativeFunction<
              TXDeviceManagerNativePointer Function(
                  ffi.Pointer<V2TXLivePusherNativePointer>)>>(
      'v2tx_live_pusher_get_device_manager');
  late final _getDeviceManager = _getDeviceManagerPtr.asFunction<
      TXDeviceManagerNativePointer Function(
          ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int snapshot(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _snapshot(pusher);
  }

  late final _snapshotPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'v2tx_live_pusher_snapshot',
  );
  late final _snapshot = _snapshotPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int enableVolumeEvaluation(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, int intervalMs) {
    return _enableVolumeEvaluation(pusher, intervalMs);
  }

  late final _enableVolumeEvaluationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Int32)>>(
    'v2tx_live_pusher_enable_volume_evaluation',
  );
  late final _enableVolumeEvaluation = _enableVolumeEvaluationPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();

  int enableCustomVideoProcess(ffi.Pointer<V2TXLivePusherNativePointer> pusher,
      bool enable, int pixelFormat, int bufferType) {
    return _enableCustomVideoProcess(pusher, enable, pixelFormat, bufferType);
  }

  late final _enableCustomVideoProcessPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool,
              ffi.Int32, ffi.Int32)>>(
    'v2tx_live_pusher_enable_custom_video_process',
  );
  late final _enableCustomVideoProcess =
      _enableCustomVideoProcessPtr.asFunction<
          int Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, bool, int, int)>();

  int showDebugView(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, bool isShow) {
    return _showDebugView(pusher, isShow);
  }

  late final _showDebugViewPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool)>>(
    'v2tx_live_pusher_show_debug_view',
  );
  late final _showDebugView = _showDebugViewPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, bool)>();

  int enableCustomVideoCapture(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, bool enable) {
    return _enableCustomVideoCapture(pusher, enable);
  }

  late final _enableCustomVideoCapturePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool)>>(
    'v2tx_live_pusher_enable_custom_video_capture',
  );
  late final _enableCustomVideoCapture =
      _enableCustomVideoCapturePtr.asFunction<
          int Function(ffi.Pointer<V2TXLivePusherNativePointer>, bool)>();

  int enableCustomAudioCapture(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, bool enable) {
    return _enableCustomAudioCapture(pusher, enable);
  }

  late final _enableCustomAudioCapturePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool)>>(
    'v2tx_live_pusher_enable_custom_audio_capture',
  );
  late final _enableCustomAudioCapture =
      _enableCustomAudioCapturePtr.asFunction<
          int Function(ffi.Pointer<V2TXLivePusherNativePointer>, bool)>();

  int sendCustomVideoFrame(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    ffi.Pointer<V2TXLiveVideoFrameStruct> struct,
  ) {
    return _sendCustomVideoFrame(pusher, struct);
  }

  late final _sendCustomVideoFramePtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
                  ffi.Pointer<V2TXLiveVideoFrameStruct>)>>(
      'v2tx_live_pusher_send_custom_video_frame');
  late final _sendCustomVideoFrame = _sendCustomVideoFramePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>,
          ffi.Pointer<V2TXLiveVideoFrameStruct>)>();

  int sendCustomAudioFrame(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    ffi.Pointer<V2TXLiveAudioFrameStruct> struct,
  ) {
    return _sendCustomAudioFrame(pusher, struct);
  }

  late final _sendCustomAudioFramePtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
                  ffi.Pointer<V2TXLiveAudioFrameStruct>)>>(
      'v2tx_live_pusher_send_custom_audio_frame');
  late final _sendCustomAudioFrame = _sendCustomAudioFramePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>,
          ffi.Pointer<V2TXLiveAudioFrameStruct>)>();

  int sendSeiMessage(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    int payloadType,
    ffi.Pointer<ffi.Uint8> data,
    int length,
  ) {
    return _sendSeiMessage(pusher, payloadType, data, length);
  }

  late final _sendSeiMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Int32,
              ffi.Pointer<ffi.Uint8>,
              ffi.Int32)>>('v2tx_live_pusher_send_sei_message');
  late final _sendSeiMessage = _sendSeiMessagePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int,
          ffi.Pointer<ffi.Uint8>, int)>();

  int startSystemAudioLoopback(ffi.Pointer<V2TXLivePusherNativePointer> pusher,
      ffi.Pointer<ffi.Int8> deviceName) {
    return _startSystemAudioLoopback(pusher, deviceName);
  }

  late final _startSystemAudioLoopbackPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
                  ffi.Pointer<ffi.Int8>)>>(
      'v2tx_live_pusher_start_system_audio_loopback');
  late final _startSystemAudioLoopback =
      _startSystemAudioLoopbackPtr.asFunction<
          int Function(ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Pointer<ffi.Int8>)>();

  int stopSystemAudioLoopback(ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    return _stopSystemAudioLoopback(pusher);
  }

  late final _stopSystemAudioLoopbackPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
      'v2tx_live_pusher_stop_system_audio_loopback');
  late final _stopSystemAudioLoopback = _stopSystemAudioLoopbackPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  int setSystemAudioLoopbackVolume(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    int volume,
  ) {
    return _setSystemAudioLoopbackVolume(pusher, volume);
  }

  late final _setSystemAudioLoopbackVolumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Int)>>('v2tx_live_pusher_set_system_audio_loopback_volume');
  late final _setSystemAudioLoopbackVolume =
      _setSystemAudioLoopbackVolumePtr.asFunction<
          int Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();

  int setMixTranscodingConfig(
    ffi.Pointer<V2TXLivePusherNativePointer> pusher,
    ffi.Pointer<V2TXLiveTranscodingConfigStruct> config,
  ) {
    return _setMixTranscodingConfig(pusher, config);
  }

  late final _setMixTranscodingConfigPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
                  ffi.Pointer<V2TXLiveTranscodingConfigStruct>)>>(
      'v2tx_live_pusher_set_mix_transcoding_config');
  late final _setMixTranscodingConfig = _setMixTranscodingConfigPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePusherNativePointer>,
          ffi.Pointer<V2TXLiveTranscodingConfigStruct>)>();

  int setBeautyStyle(ffi.Pointer<V2TXLivePusherNativePointer> pusher, int style,
      int beautyLevel, int whitenessLevel, int ruddinessLevel) {
    return _setBeautyStyle(
        pusher, style, beautyLevel, whitenessLevel, ruddinessLevel);
  }

  late final _setBeautyStylePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32)>>(
    'v2tx_live_pusher_set_beauty_style',
  );
  late final _setBeautyStyle = _setBeautyStylePtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePusherNativePointer>, int, int, int, int)>();

  int enableSharpnessEnhancement(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, bool enable) {
    return _enableSharpnessEnhancement(pusher, enable);
  }

  late final _enableSharpnessEnhancementPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Bool)>>(
    'v2tx_live_pusher_enable_sharpness_enhancement',
  );
  late final _enableSharpnessEnhancement =
      _enableSharpnessEnhancementPtr.asFunction<
          int Function(ffi.Pointer<V2TXLivePusherNativePointer>, bool)>();

  int setLUTColorFilter(ffi.Pointer<V2TXLivePusherNativePointer> pusher,
      ffi.Pointer<ffi.Int8> file_path) {
    return _setLUTColorFilter(pusher, file_path);
  }

  late final _setLUTColorFilterPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePusherNativePointer>,
              ffi.Pointer<ffi.Int8>)>>(
    'v2tx_live_pusher_set_lut_color_filter',
  );
  late final _setLUTColorFilter = _setLUTColorFilterPtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Pointer<ffi.Int8>)>();

  int setLUTColorFilterStrength(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, double strength) {
    return _setLUTColorFilterStrength(pusher, strength);
  }

  late final _setLUTColorFilterStrengthPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Float)>>(
    'v2tx_live_pusher_set_lut_color_filter_strength',
  );
  late final _setLUTColorFilterStrength =
      _setLUTColorFilterStrengthPtr.asFunction<
          int Function(ffi.Pointer<V2TXLivePusherNativePointer>, double)>();

  void registerPusherListener(
      int sender_port, ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    _registerPusherListener(sender_port, pusher);
  }

  late final _registerPusherListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Int64, ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'LiteavFFIRegisterPusherListener',
  );
  late final _registerPusherListener = _registerPusherListenerPtr.asFunction<
      void Function(int, ffi.Pointer<V2TXLivePusherNativePointer>)>();

  void unRegisterPusherListener(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    _unRegisterPusherListener(pusher);
  }

  late final _unRegisterPusherListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'LiteavFFIUnRegisterPusherListener',
  );
  late final _unRegisterPusherListener = _unRegisterPusherListenerPtr
      .asFunction<void Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  void registerPusherPreprocessListener(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher, int listener) {
    _registerPusherPreprocessListener(pusher, listener);
  }

  late final _registerPusherPreprocessListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<V2TXLivePusherNativePointer>, ffi.Int64)>>(
    'LiteavFFIRegisterPusherPreprocessListener',
  );
  late final _registerPusherPreprocessListener =
      _registerPusherPreprocessListenerPtr.asFunction<
          void Function(ffi.Pointer<V2TXLivePusherNativePointer>, int)>();
  void unRegisterPusherPreprocessListener(
      ffi.Pointer<V2TXLivePusherNativePointer> pusher) {
    _unRegisterPusherPreprocessListener(pusher);
  }

  late final _unRegisterPusherPreprocessListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<V2TXLivePusherNativePointer>)>>(
    'LiteavFFIUnRegisterPusherPreprocessListener',
  );
  late final _unRegisterPusherPreprocessListener =
      _unRegisterPusherPreprocessListenerPtr.asFunction<
          void Function(ffi.Pointer<V2TXLivePusherNativePointer>)>();

  ///***********************************************************************************************
  ///                                          InitDartApiDL
  /// **********************************************************************************************

  int InitDartApiDL(ffi.Pointer<ffi.Void> data) {
    return _InitDartApiDL(data);
  }

  late final _InitDartApiDLPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
    'LiteavFFIInitApiDL',
  );
  late final _InitDartApiDL =
      _InitDartApiDLPtr.asFunction<int Function(ffi.Pointer<ffi.Void>)>();
}

/// INitDartApiDl
typedef Native_Dart_InitializeApiDL = ffi.Int32 Function(
    ffi.Pointer<ffi.Void> data);
typedef FFI_Dart_InitializeApiDL = int Function(ffi.Pointer<ffi.Void> data);

/// A port is used to send or receive inter-isolate messages
typedef V2TXLivePusherNativePointer = ffi.Pointer<ffi.Void>;
