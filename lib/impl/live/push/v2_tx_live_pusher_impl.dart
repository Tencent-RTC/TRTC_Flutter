// ignore_for_file: annotate_overrides
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: prefer_final_fields
import 'dart:ffi' as ffi;
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/live/push/v2_tx_live_pusher_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/live/push/v2_tx_live_pusher_observer_native.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_log.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_pusher_observer.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_code.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_def.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_pusher.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/impl/live/v2_tx_live_struct.dart';
import 'package:tencent_rtc_sdk/impl/manager/tx_audio_effect_manager_impl.dart';
import 'package:tencent_rtc_sdk/impl/manager/tx_device_manager_impl.dart';
import 'package:tencent_rtc_sdk/live_config.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class V2TXLivePusherImpl extends V2TXLivePusher {
  late V2TXLivePusherFFIBindings _pusherFFIBindings;
  late V2TXLivePusherObserverNative? _observerNative;
  late TXDeviceManagerImpl _deviceManager;
  late TXAudioEffectManagerImpl _audioEffectManager;

  late ffi.Pointer<V2TXLivePusherNativePointer> _pusherNativePointer;

  bool _system_audio_loopback_support =
      Platform.isAndroid || Platform.isWindows || Platform.isMacOS;

  V2TXLivePusherImpl(V2TXLiveMode liveMode) {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    _pusherFFIBindings =
        V2TXLivePusherFFIBindings(LiveLoadDynamicLib.getLiteavSDK());
    _pusherNativePointer = _pusherFFIBindings.createPusher(liveMode.index);
    setProperty("setFramework", "{\"component\": 1,\"framework\": 23}");
    _observerNative = V2TXLivePusherObserverNative(_pusherNativePointer);
    _audioEffectManager = TXAudioEffectManagerImpl(
        _pusherFFIBindings.getAudioEffectManager(_pusherNativePointer));
    _deviceManager = TXDeviceManagerImpl(
        _pusherFFIBindings.getDeviceManager(_pusherNativePointer));
    LiveLog.pusherPrint(
      _pusherNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePusherImpl.create: $hashCode, flutterSDKVersion: ${LiteavLiveConfig.flutterSDKVersion}",
    );
  }

  static Future<V2TXLivePusherImpl> create(V2TXLiveMode liveMode) async {
    return V2TXLivePusherImpl(liveMode);
  }

  void destroy() async {
    LiveLog.pusherPrint(
      _pusherNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePusherImpl.destroy: $hashCode",
    );
    _deviceManager.destroy();
    _audioEffectManager.destroy();
    _observerNative?.unRegisterNativeObserver();
    _observerNative = null;
    _pusherFFIBindings.releasePusher(_pusherNativePointer);
  }

  void addListener(V2TXLivePusherObserver observer) async {
    _observerNative?.addObserver(observer);
  }

  void removeListener(V2TXLivePusherObserver observer) async {
    _observerNative?.removeObserver(observer);
  }

  Future<V2TXLiveCode> setRenderViewID(int viewId) async {
    if (TRTCPlatform.isOhos) {
      var json = {"surfaceId": viewId};
      return setProperty("setOHOSSurface", convert.jsonEncode(json));
    }

    ffi.Pointer<ffi.Void> nativeView =
        ffi.Pointer<ffi.Void>.fromAddress(viewId);
    var result =
        _pusherFFIBindings.setRenderViewID(_pusherNativePointer, nativeView);
    return result;
  }

  Future<V2TXLiveCode> setRenderMirror(V2TXLiveMirrorType mirrorType) async {
    return _pusherFFIBindings.setRenderMirror(
        _pusherNativePointer, mirrorType.index);
  }

  Future<V2TXLiveCode> setEncoderMirror(bool mirror) async {
    return _pusherFFIBindings.setEncoderMirror(_pusherNativePointer, mirror);
  }

  Future<V2TXLiveCode> setRenderRotation(V2TXLiveRotation rotation) async {
    return _pusherFFIBindings.setRenderRotation(
        _pusherNativePointer, rotation.index);
  }

  Future<V2TXLiveCode> setRenderFillMode(V2TXLiveFillMode mode) async {
    return _pusherFFIBindings.setRenderFillMode(
        _pusherNativePointer, mode.index);
  }

  Future<V2TXLiveCode> startCamera(bool frontCamera) async {
    return _pusherFFIBindings.startCamera(_pusherNativePointer, frontCamera);
  }

  Future<V2TXLiveCode> stopCamera() async {
    return _pusherFFIBindings.stopCamera(_pusherNativePointer);
  }

  Future<V2TXLiveCode> startMicrophone() async {
    return _pusherFFIBindings.startMicrophone(_pusherNativePointer);
  }

  Future<V2TXLiveCode> stopMicrophone() async {
    return _pusherFFIBindings.stopMicrophone(_pusherNativePointer);
  }

  Future<V2TXLiveCode> startScreenCapture(String appGroup) async {
    ffi.Pointer<ffi.Int8> native_group =
        appGroup.toNativeUtf8().cast<ffi.Int8>();
    var result = _pusherFFIBindings.startScreenCapture(
        _pusherNativePointer, native_group);
    calloc.free(native_group);
    return result;
  }

  Future<V2TXLiveCode> stopScreenCapture() async {
    return _pusherFFIBindings.stopScreenCapture(_pusherNativePointer);
  }

  Future<V2TXLiveCode> pauseAudio() async {
    return _pusherFFIBindings.pauseAudio(_pusherNativePointer);
  }

  Future<V2TXLiveCode> resumeAudio() async {
    return _pusherFFIBindings.resumeAudio(_pusherNativePointer);
  }

  Future<V2TXLiveCode> pauseVideo() async {
    return _pusherFFIBindings.pauseVideo(_pusherNativePointer);
  }

  Future<V2TXLiveCode> resumeVideo() async {
    return _pusherFFIBindings.resumeVideo(_pusherNativePointer);
  }

  Future<V2TXLiveCode> startPush(String url) async {
    ffi.Pointer<ffi.Int8> nativeUrl = url.toNativeUtf8().cast<ffi.Int8>();
    var result = _pusherFFIBindings.startPush(_pusherNativePointer, nativeUrl);
    calloc.free(nativeUrl);
    return result;
  }

  Future<V2TXLiveCode> stopPush() async {
    return _pusherFFIBindings.stopPush(_pusherNativePointer);
  }

  Future<V2TXLiveCode> isPushing() async {
    return _pusherFFIBindings.isPushing(_pusherNativePointer);
  }

  Future<V2TXLiveCode> setAudioQuality(V2TXLiveAudioQuality quality) async {
    return _pusherFFIBindings.setAudioQuality(
        _pusherNativePointer, quality.index);
  }

  Future<V2TXLiveCode> setVideoQuality(V2TXLiveVideoEncoderParam param) async {
    var result = V2TXLIVE_OK;
    ffi.Pointer<V2TXLiveVideoEncoderParamStruct> paramPointer =
        V2TXLiveVideoEncoderParamStruct.convert(param);
    result =
        _pusherFFIBindings.setVideoQuality(_pusherNativePointer, paramPointer);
    calloc.free(paramPointer);
    return result;
  }

  TXAudioEffectManager getAudioEffectManager() {
    return _audioEffectManager;
  }

  TXDeviceManager getDeviceManager() {
    return _deviceManager;
  }

  Future<V2TXLiveCode> snapshot() async {
    return _pusherFFIBindings.snapshot(_pusherNativePointer);
  }

  Future<V2TXLiveCode> enableVolumeEvaluation(int intervalMs) async {
    return _pusherFFIBindings.enableVolumeEvaluation(
        _pusherNativePointer, intervalMs);
  }

  Future<V2TXLiveCode> enableCustomVideoProcess(bool enable,
      V2TXLivePixelFormat pixelFormat, V2TXLiveBufferType bufferType) async {
    if (enable) {
      var listener = await LiveLoadDynamicLib.getPluginChannel()
          .invokeMethod('getCustomVideoProcessListener');
      if (listener == 0) {
        LiveLog.pusherPrint(
          _pusherNativePointer,
          V2TXLiveLogLevel.v2TXLiveLogLevelError,
          "enableCustomVideoProcess: invalid listener pointer: $listener",
        );
        return V2TXLIVE_ERROR_NOT_SUPPORTED;
      }
      _pusherFFIBindings.registerPusherPreprocessListener(
          _pusherNativePointer, listener);
    } else {
      _pusherFFIBindings
          .unRegisterPusherPreprocessListener(_pusherNativePointer);
    }
    int nativePixelFormat = 0;
    int nativeBufferType = 0;
    switch (pixelFormat) {
      case V2TXLivePixelFormat.v2TXLivePixelFormatI420:
        nativePixelFormat = 1;
        break;
      case V2TXLivePixelFormat.v2TXLivePixelFormatBGRA32:
        nativePixelFormat = 2;
        break;
      case V2TXLivePixelFormat.v2TXLivePixelFormatTexture2D:
        nativePixelFormat = 4;
        break;
      default:
        break;
    }
    switch (bufferType) {
      case V2TXLiveBufferType.v2TXLiveBufferTypeByteBuffer:
        nativeBufferType = 1;
        break;
      case V2TXLiveBufferType.v2TXLiveBufferTypeTexture:
        nativeBufferType = 2;
        break;
      default:
        break;
    }
    return _pusherFFIBindings.enableCustomVideoProcess(
        _pusherNativePointer, enable, nativePixelFormat, nativeBufferType);
  }

  Future<V2TXLiveCode> enableCustomVideoCapture(bool enable) async {
    return _pusherFFIBindings.enableCustomVideoCapture(
        _pusherNativePointer, enable);
  }

  Future<V2TXLiveCode> enableCustomAudioCapture(bool enable) async {
    return _pusherFFIBindings.enableCustomAudioCapture(
        _pusherNativePointer, enable);
  }

  Future<V2TXLiveCode> sendCustomVideoFrame(
      V2TXLiveVideoFrame videoFrame) async {
    var result = V2TXLIVE_OK;
    ffi.Pointer<V2TXLiveVideoFrameStruct> framePointer =
        V2TXLiveVideoFrameStruct.convert(videoFrame);
    result = _pusherFFIBindings.sendCustomVideoFrame(
        _pusherNativePointer, framePointer);
    V2TXLiveVideoFrameStruct.freeStruct(framePointer);
    return result;
  }

  Future<V2TXLiveCode> sendCustomAudioFrame(
      V2TXLiveAudioFrame audioFrame) async {
    var result = V2TXLIVE_OK;
    ffi.Pointer<V2TXLiveAudioFrameStruct> framePointer =
        V2TXLiveAudioFrameStruct.convert(audioFrame);
    result = _pusherFFIBindings.sendCustomAudioFrame(
        _pusherNativePointer, framePointer);
    V2TXLiveAudioFrameStruct.freeStruct(framePointer);
    return result;
  }

  Future<V2TXLiveCode> sendSeiMessage(int payloadType, Uint8List data) async {
    ffi.Pointer<ffi.Uint8> native_data = calloc<ffi.Uint8>(data.length);
    native_data.asTypedList(data.length).setAll(0, data);
    var result = _pusherFFIBindings.sendSeiMessage(
        _pusherNativePointer, payloadType, native_data, data.length);
    calloc.free(native_data);
    return result;
  }

  Future<V2TXLiveCode> startSystemAudioLoopback(String? deviceName) async {
    if (!_system_audio_loopback_support) {
      debugPrint("startSystemAudioLoopback not support");
      return V2TXLIVE_ERROR_NOT_SUPPORTED;
    }
    var result = V2TXLIVE_OK;
    if (deviceName != null) {
      ffi.Pointer<ffi.Int8> nativeDeviceName =
          deviceName.toNativeUtf8().cast<ffi.Int8>();
      result = _pusherFFIBindings.startSystemAudioLoopback(
          _pusherNativePointer, nativeDeviceName);
      calloc.free(nativeDeviceName);
    } else {
      result = _pusherFFIBindings.startSystemAudioLoopback(
          _pusherNativePointer, ffi.nullptr);
    }
    return result;
  }

  Future<V2TXLiveCode> stopSystemAudioLoopback() async {
    if (!_system_audio_loopback_support) {
      debugPrint("stopSystemAudioLoopback not support");
      return V2TXLIVE_ERROR_NOT_SUPPORTED;
    }
    return _pusherFFIBindings.stopSystemAudioLoopback(_pusherNativePointer);
  }

  Future<V2TXLiveCode> setSystemAudioLoopbackVolume(int volume) async {
    if (!_system_audio_loopback_support) {
      debugPrint("setSystemAudioLoopbackVolume not support");
      return V2TXLIVE_ERROR_NOT_SUPPORTED;
    }
    return _pusherFFIBindings.setSystemAudioLoopbackVolume(
        _pusherNativePointer, volume);
  }

  Future<V2TXLiveCode> showDebugView(bool isShow) async {
    return _pusherFFIBindings.showDebugView(_pusherNativePointer, isShow);
  }

  Future<V2TXLiveCode> setProperty(String key, Object value) async {
    var result = V2TXLIVE_OK;
    ffi.Pointer<ffi.Int8> native_key = key.toNativeUtf8().cast<ffi.Int8>();

    if (value is bool) {
      var native_bool_value = calloc<ffi.Bool>(ffi.sizeOf<ffi.Bool>());
      native_bool_value.value = value;

      var native_void_value = native_bool_value.cast<ffi.Void>();
      result = _pusherFFIBindings.setProperty(
          _pusherNativePointer, native_key, native_void_value);
      calloc.free(native_bool_value);
    } else if (value is int) {
      var native_int32_value = calloc<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
      native_int32_value.value = value;

      var native_void_value = native_int32_value.cast<ffi.Void>();
      result = _pusherFFIBindings.setProperty(
          _pusherNativePointer, native_key, native_void_value);
      calloc.free(native_int32_value);
    } else if (value is String) {
      var native_value = value.toString().toNativeUtf8().cast<ffi.Void>();
      result = _pusherFFIBindings.setProperty(
          _pusherNativePointer, native_key, native_value);
      calloc.free(native_value);
    } else {
      result = V2TXLIVE_ERROR_INVALID_PARAMETER;
    }

    calloc.free(native_key);

    return result;
  }

  Future<V2TXLiveCode> setMixTranscodingConfig(
      V2TXLiveTranscodingConfig? config) async {
    if (config == null) {
      return _pusherFFIBindings.setMixTranscodingConfig(
          _pusherNativePointer, ffi.nullptr);
    } else {
      var result = V2TXLIVE_OK;
      ffi.Pointer<V2TXLiveTranscodingConfigStruct> paramPointer =
          V2TXLiveTranscodingConfigStruct.convert(config);
      result = _pusherFFIBindings.setMixTranscodingConfig(
          _pusherNativePointer, paramPointer);
      V2TXLiveTranscodingConfigStruct.freeStruct(paramPointer);
      return result;
    }
  }

  Future<V2TXLiveCode> enableSharpnessEnhancement(bool enable) async {
    return _pusherFFIBindings.enableSharpnessEnhancement(
        _pusherNativePointer, enable);
  }

  Future<V2TXLiveCode> setBeautyStyle(int style, int beautyLevel,
      int whitenessLevel, int ruddinessLevel) async {
    return _pusherFFIBindings.setBeautyStyle(_pusherNativePointer, style,
        beautyLevel, whitenessLevel, ruddinessLevel);
  }

  Future<V2TXLiveCode> setLUTColorFilter(String? file_path) async {
    if (file_path == null) {
      return _pusherFFIBindings.setLUTColorFilter(
          _pusherNativePointer, ffi.nullptr);
    }
    ffi.Pointer<ffi.Int8> nativeFilePath =
        file_path.toNativeUtf8().cast<ffi.Int8>();
    var result = _pusherFFIBindings.setLUTColorFilter(
        _pusherNativePointer, nativeFilePath);
    calloc.free(nativeFilePath);
    return result;
  }

  Future<V2TXLiveCode> setLUTColorFilterStrength(double strength) async {
    return _pusherFFIBindings.setLUTColorFilterStrength(
        _pusherNativePointer, strength);
  }
}
