// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;
import 'package:tencent_rtc_sdk/bindings/manager/manager_struct.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_struct.dart';

class TXDeviceManagerFFIBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;
  TXDeviceManagerFFIBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;
  TXDeviceManagerFFIBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int is_front_camera(TXDeviceManagerNativePointer? instance) {
    return _is_front_camera(instance);
  }

  late final _is_front_cameraPtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_is_front_camera',
  );
  late final _is_front_camera = _is_front_cameraPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  int set_audio_route(TXDeviceManagerNativePointer? instance, int route) {
    return _set_audio_route(instance, route);
  }

  late final _set_audio_routePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32)>>(
    'tx_device_manager_set_audio_route',
  );
  late final _set_audio_route = _set_audio_routePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int)>();

  int switch_camera(TXDeviceManagerNativePointer? instance, bool front_camera) {
    return _switch_camera(instance, front_camera);
  }

  late final _switch_cameraPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Bool)>>(
    'tx_device_manager_switch_camera',
  );
  late final _switch_camera = _switch_cameraPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, bool)>();

  int enable_camera_auto_focus(
      TXDeviceManagerNativePointer? instance, bool enabled) {
    return _enable_camera_auto_focus(instance, enabled);
  }

  late final _enable_camera_auto_focusPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Bool)>>(
    'tx_device_manager_enable_camera_auto_focus',
  );
  late final _enable_camera_auto_focus = _enable_camera_auto_focusPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, bool)>();

  int enable_camera_torch(
      TXDeviceManagerNativePointer? instance, bool enabled) {
    return _enable_camera_torch(instance, enabled);
  }

  late final _enable_camera_torchPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Bool)>>(
    'tx_device_manager_enable_camera_torch',
  );
  late final _enable_camera_torch = _enable_camera_torchPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, bool)>();

  int enable_following_default_audio_device(
    TXDeviceManagerNativePointer? instance,
    int type,
    bool enable,
  ) {
    return _enable_following_default_audio_device(instance, type, enable);
  }

  late final _enable_following_default_audio_devicePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXDeviceManagerNativePointer?, ffi.Int32, ffi.Bool)>>(
    'tx_device_manager_enable_following_default_audio_device',
  );
  late final _enable_following_default_audio_device =
      _enable_following_default_audio_devicePtr
          .asFunction<int Function(TXDeviceManagerNativePointer?, int, bool)>();

  int get_application_mute_state(TXDeviceManagerNativePointer? instance) {
    return _get_application_mute_state(instance);
  }

  late final _get_application_mute_statePtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_get_application_mute_state',
  );
  late final _get_application_mute_state = _get_application_mute_statePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  int get_application_play_volume(TXDeviceManagerNativePointer? instance) {
    return _get_application_play_volume(instance);
  }

  late final _get_application_play_volumePtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_get_application_play_volume',
  );
  late final _get_application_play_volume = _get_application_play_volumePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  double get_camera_zoom_max_ratio(TXDeviceManagerNativePointer? instance) {
    return _get_camera_zoom_max_ratio(instance);
  }

  late final _get_camera_zoom_max_ratioPtr = _lookup<
      ffi.NativeFunction<ffi.Float Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_get_camera_zoom_max_ratio',
  );
  late final _get_camera_zoom_max_ratio = _get_camera_zoom_max_ratioPtr
      .asFunction<double Function(TXDeviceManagerNativePointer?)>();

  int get_current_device(
    TXDeviceManagerNativePointer? instance,
    int type,
    ffi.Pointer<TXDeviceInfoStruct> device_info,
  ) {
    return _get_current_device(instance, type, device_info);
  }

  late final _get_current_devicePtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32,
                  ffi.Pointer<TXDeviceInfoStruct>)>>(
      'tx_device_manager_get_current_device');
  late final _get_current_device = _get_current_devicePtr.asFunction<
      int Function(TXDeviceManagerNativePointer?, int,
          ffi.Pointer<TXDeviceInfoStruct>)>();

  int get_current_device_mute(
      TXDeviceManagerNativePointer? instance, int type) {
    return _get_current_device_mute(instance, type);
  }

  late final _get_current_device_mutePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32)>>(
    'tx_device_manager_get_current_device_mute',
  );
  late final _get_current_device_mute = _get_current_device_mutePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int)>();

  int get_current_device_volume(
      TXDeviceManagerNativePointer? instance, int type) {
    return _get_current_device_volume(instance, type);
  }

  late final _get_current_device_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32)>>(
    'tx_device_manager_get_current_device_volume',
  );
  late final _get_current_device_volume = _get_current_device_volumePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int)>();

  int get_device_count(TXDeviceManagerNativePointer? instance, int type) {
    return _get_device_count(instance, type);
  }

  late final _get_device_countPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32)>>(
    'tx_device_manager_get_device_count',
  );
  late final _get_device_count = _get_device_countPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int)>();

  int get_device_info(
    TXDeviceManagerNativePointer? instance,
    int type,
    int index,
    ffi.Pointer<TXDeviceInfoStruct> device_info,
  ) {
    return _get_device_info(instance, type, index, device_info);
  }

  late final _get_device_infoPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32,
                  ffi.Int, ffi.Pointer<TXDeviceInfoStruct>)>>(
      'tx_device_manager_get_device_info');
  late final _get_device_info = _get_device_infoPtr.asFunction<
      int Function(TXDeviceManagerNativePointer?, int, int,
          ffi.Pointer<TXDeviceInfoStruct>)>();

  int is_audio_focus_enabled(TXDeviceManagerNativePointer? instance) {
    return _is_audio_focus_enabled(instance);
  }

  late final _is_audio_focus_enabledPtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_is_audio_focus_enabled',
  );
  late final _is_audio_focus_enabled = _is_audio_focus_enabledPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  int set_application_mute_state(
      TXDeviceManagerNativePointer? instance, bool mute) {
    return _set_application_mute_state(instance, mute);
  }

  late final _set_application_mute_statePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Bool)>>(
    'tx_device_manager_set_application_mute_state',
  );
  late final _set_application_mute_state = _set_application_mute_statePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, bool)>();

  int set_application_play_volume(
      TXDeviceManagerNativePointer? instance, int volume) {
    return _set_application_play_volume(instance, volume);
  }

  late final _set_application_play_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int)>>(
    'tx_device_manager_set_application_play_volume',
  );
  late final _set_application_play_volume = _set_application_play_volumePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int)>();

  int set_camera_capture_param(
    TXDeviceManagerNativePointer? instance,
    ffi.Pointer<TXCameraCaptureParamStruct> params,
  ) {
    return _set_camera_capture_param(instance, params);
  }

  late final _set_camera_capture_paramPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(TXDeviceManagerNativePointer?,
                  ffi.Pointer<TXCameraCaptureParamStruct>)>>(
      'tx_device_manager_set_camera_capture_param');
  late final _set_camera_capture_param =
      _set_camera_capture_paramPtr.asFunction<
          int Function(TXDeviceManagerNativePointer?,
              ffi.Pointer<TXCameraCaptureParamStruct>)>();

  int set_camera_focus_position(
      TXDeviceManagerNativePointer? instance, double x, double y) {
    return _set_camera_focus_position(instance, x, y);
  }

  late final _set_camera_focus_positionPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXDeviceManagerNativePointer?, ffi.Float, ffi.Float)>>(
    'tx_device_manager_set_camera_focus_position',
  );
  late final _set_camera_focus_position =
      _set_camera_focus_positionPtr.asFunction<
          int Function(TXDeviceManagerNativePointer?, double, double)>();

  int set_camera_zoom_ratio(
      TXDeviceManagerNativePointer? instance, double zoom_ratio) {
    return _set_camera_zoom_ratio(instance, zoom_ratio);
  }

  late final _set_camera_zoom_ratioPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Float)>>(
    'tx_device_manager_set_camera_zoom_ratio',
  );
  late final _set_camera_zoom_ratio = _set_camera_zoom_ratioPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, double)>();

  int set_current_device(
    TXDeviceManagerNativePointer? instance,
    int type,
    ffi.Pointer<ffi.Char> device_id,
  ) {
    return _set_current_device(instance, type, device_id);
  }

  late final _set_current_devicePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Int32,
              ffi.Pointer<ffi.Char>)>>('tx_device_manager_set_current_device');
  late final _set_current_device = _set_current_devicePtr.asFunction<
      int Function(
          TXDeviceManagerNativePointer?, int, ffi.Pointer<ffi.Char>)>();

  int set_current_device_mute(
      TXDeviceManagerNativePointer? instance, int type, bool mute) {
    return _set_current_device_mute(instance, type, mute);
  }

  late final _set_current_device_mutePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXDeviceManagerNativePointer?, ffi.Int32, ffi.Bool)>>(
    'tx_device_manager_set_current_device_mute',
  );
  late final _set_current_device_mute = _set_current_device_mutePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int, bool)>();

  int set_current_device_volume(
      TXDeviceManagerNativePointer? instance, int type, int volume) {
    return _set_current_device_volume(instance, type, volume);
  }

  late final _set_current_device_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXDeviceManagerNativePointer?, ffi.Int32, ffi.Uint32)>>(
    'tx_device_manager_set_current_device_volume',
  );
  late final _set_current_device_volume = _set_current_device_volumePtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int, int)>();

  int start_camera_device_test(
      TXDeviceManagerNativePointer? instance, tx_view view) {
    return _start_camera_device_test(instance, view);
  }

  late final _start_camera_device_testPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, tx_view)>>(
    'tx_device_manager_start_camera_device_test',
  );
  late final _start_camera_device_test = _start_camera_device_testPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, tx_view)>();

  int start_mic_device_test(
      TXDeviceManagerNativePointer? instance, int interval) {
    return _start_mic_device_test(instance, interval);
  }

  late final _start_mic_device_testPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXDeviceManagerNativePointer?, ffi.Uint32)>>(
    'tx_device_manager_start_mic_device_test',
  );
  late final _start_mic_device_test = _start_mic_device_testPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?, int)>();

  int start_mic_device_test_and_playback(
    TXDeviceManagerNativePointer? instance,
    int interval,
    bool playback,
  ) {
    return _start_mic_device_test_and_playback(instance, interval, playback);
  }

  late final _start_mic_device_test_and_playbackPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXDeviceManagerNativePointer?, ffi.Uint32, ffi.Bool)>>(
    'tx_device_manager_start_mic_device_test_and_playback',
  );
  late final _start_mic_device_test_and_playback =
      _start_mic_device_test_and_playbackPtr
          .asFunction<int Function(TXDeviceManagerNativePointer?, int, bool)>();

  int start_speaker_device_test(
      TXDeviceManagerNativePointer? instance, ffi.Pointer<ffi.Char> file_path) {
    return _start_speaker_device_test(instance, file_path);
  }

  late final _start_speaker_device_testPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXDeviceManagerNativePointer?, ffi.Pointer<ffi.Char>)>>(
    'tx_device_manager_start_speaker_device_test',
  );
  late final _start_speaker_device_test =
      _start_speaker_device_testPtr.asFunction<
          int Function(TXDeviceManagerNativePointer?, ffi.Pointer<ffi.Char>)>();

  int stop_camera_device_test(TXDeviceManagerNativePointer? instance) {
    return _stop_camera_device_test(instance);
  }

  late final _stop_camera_device_testPtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_stop_camera_device_test',
  );
  late final _stop_camera_device_test = _stop_camera_device_testPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  int stop_mic_device_test(TXDeviceManagerNativePointer? instance) {
    return _stop_mic_device_test(instance);
  }

  late final _stop_mic_device_testPtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_stop_mic_device_test',
  );
  late final _stop_mic_device_test = _stop_mic_device_testPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  int stop_speaker_device_test(TXDeviceManagerNativePointer? instance) {
    return _stop_speaker_device_test(instance);
  }

  late final _stop_speaker_device_testPtr = _lookup<
      ffi.NativeFunction<ffi.Int Function(TXDeviceManagerNativePointer?)>>(
    'tx_device_manager_stop_speaker_device_test',
  );
  late final _stop_speaker_device_test = _stop_speaker_device_testPtr
      .asFunction<int Function(TXDeviceManagerNativePointer?)>();

  void registerDeviceObserver(
      int sender_port, TXDeviceManagerNativePointer? instance) {
    _registerDeviceObserver(sender_port, instance);
  }

  late final _registerDeviceObserverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, TXDeviceManagerNativePointer?)>>(
    'LiteavFFIRegisterDeviceChangeObserver',
  );
  late final _registerDeviceObserver = _registerDeviceObserverPtr
      .asFunction<void Function(int, TXDeviceManagerNativePointer?)>();

  void unRegisterDeviceObserver(TXDeviceManagerNativePointer? instance) {
    _unRegisterDeviceObserver(0, instance);
  }

  late final _unRegisterDeviceObserverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, TXDeviceManagerNativePointer?)>>(
    'LiteavFFIUnRegisterDeviceChangeObserver',
  );
  late final _unRegisterDeviceObserver = _unRegisterDeviceObserverPtr
      .asFunction<void Function(int, TXDeviceManagerNativePointer?)>();

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

/// A port is used to send or receive inter-isolate messages
typedef TXDeviceManagerNativePointer = ffi.Pointer<ffi.Void>;
