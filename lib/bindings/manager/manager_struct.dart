// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

typedef tx_beauty_manager = Pointer<Void>;
typedef tx_device_manager = Pointer<Void>;
typedef tx_audio_effect_manager = Pointer<Void>;

class AudioMusicParamStruct extends Struct {
  @Int32()
  external int id;

  external Pointer<Char> path;

  @Int32()
  external int loop_count;

  @Int32()
  external int publish;

  @Int32()
  external int is_short_file;

  @Int32()
  external int start_time_ms;

  @Int32()
  external int end_time_ms;

  static Pointer<AudioMusicParamStruct> fromParams(AudioMusicParam param) {
    final paramsPointer = calloc<AudioMusicParamStruct>();
    paramsPointer.ref
      ..id = param.id
      ..path = param.path.toNativeUtf8().cast<Char>()
      ..loop_count = param.loopCount
      ..publish = param.publish ? 1 : 0
      ..is_short_file = param.isShortFile ? 1 : 0
      ..start_time_ms = param.startTimeMS
      ..end_time_ms = param.endTimeMS;
    return paramsPointer;
  }

  static void freeStruct(Pointer<AudioMusicParamStruct> paramsPointer) {
    if (paramsPointer.ref.path != nullptr) {
      calloc.free(paramsPointer.ref.path);
    }
    calloc.free(paramsPointer);
  }
}

class TXCameraCaptureParamStruct extends Struct {
  @Int32()
  external int mode;

  @Int32()
  external int width;

  @Int32()
  external int height;

  static Pointer<TXCameraCaptureParamStruct> fromParams(
      TXCameraCaptureParam params) {
    final paramsPointer = calloc<TXCameraCaptureParamStruct>();
    paramsPointer.ref
      ..mode = params.mode.value()
      ..width = params.width
      ..height = params.height;
    return paramsPointer;
  }
}

class TXDeviceInfoStruct extends Struct {
  external Pointer<Char> device_pid;

  external Pointer<Char> device_name;

  external Pointer<Char> device_properties;

  @Uint32()
  external int device_pid_len;

  @Uint32()
  external int device_name_len;

  @Uint32()
  external int device_properties_len;

  static Pointer<TXDeviceInfoStruct> create() {
    final deviceInfoPointer = calloc<TXDeviceInfoStruct>();
    deviceInfoPointer.ref
      ..device_pid = calloc<Char>(1024)
      ..device_name = calloc<Char>(1024)
      ..device_properties = calloc<Char>(1024)
      ..device_pid_len = 1024
      ..device_name_len = 1024
      ..device_properties_len = 1024;
    return deviceInfoPointer;
  }

  static Pointer<TXDeviceInfoStruct> fromParams(TXDeviceInfo deviceInfo) {
    final deviceInfoPointer = calloc<TXDeviceInfoStruct>();
    deviceInfoPointer.ref
      ..device_pid = deviceInfo.devicePid.toNativeUtf8().cast<Char>()
      ..device_name = deviceInfo.deviceName.toNativeUtf8().cast<Char>()
      ..device_properties =
          deviceInfo.deviceProperties.toNativeUtf8().cast<Char>()
      ..device_pid_len = deviceInfo.devicePid.length
      ..device_name_len = deviceInfo.deviceName.length
      ..device_properties_len = deviceInfo.deviceProperties.length;
    return deviceInfoPointer;
  }

  static freeStruct(Pointer<TXDeviceInfoStruct> deviceInfoPointer) {
    if (deviceInfoPointer.ref.device_properties != nullptr) {
      calloc.free(deviceInfoPointer.ref.device_properties);
    }
    if (deviceInfoPointer.ref.device_name != nullptr) {
      calloc.free(deviceInfoPointer.ref.device_name);
    }
    if (deviceInfoPointer.ref.device_pid != nullptr) {
      calloc.free(deviceInfoPointer.ref.device_pid);
    }

    calloc.free(deviceInfoPointer);
  }
}
