// ignore_for_file: annotate_overrides
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: prefer_final_fields
// ignore_for_file: unnecessary_new
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/cupertino.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/manager/tx_device_manager_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/manager/manager_observer_native.dart';
import 'package:tencent_rtc_sdk/bindings/manager/manager_struct.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_struct.dart';
import 'package:tencent_rtc_sdk/bridge/trtc/trtc_method_channel.dart';
import 'package:tencent_rtc_sdk/impl/trtc/trtc_cloud_impl.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class TXDeviceManagerImpl extends TXDeviceManager {
  late TXDeviceManagerFFIBindings _deviceFFIBindings;
  late TXDeviceObserverNative? _deviceObserverNative;

  late TXDeviceManagerNativePointer _nativePointer;

  bool _only_support_mobile =
      Platform.isAndroid || Platform.isIOS || TRTCPlatform.isOhos;
  bool _only_support_desktop = Platform.isWindows || Platform.isMacOS;
  bool _only_support_windows = Platform.isWindows;

  TXDeviceManagerImpl(TXDeviceManagerNativePointer nativePointer) {
    _nativePointer = nativePointer;
    _deviceFFIBindings =
        TXDeviceManagerFFIBindings(LoadDynamicLib().loadTRTCSDK());
    _deviceObserverNative = TXDeviceObserverNative(_nativePointer);
  }

  void destroy() {
    _deviceObserverNative?.unRegisterNativeObserver();
    _deviceObserverNative = null;
  }

  bool isFrontCamera() {
    if (_only_support_mobile) {
      return _deviceFFIBindings.is_front_camera(_nativePointer) == 1;
    } else {
      debugPrint("device-manager-api not support");
      return false;
    }
  }

  int setAudioRoute(TXAudioRoute route) {
    if (_only_support_mobile) {
      return _deviceFFIBindings.set_audio_route(_nativePointer, route.value());
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int switchCamera(bool frontCamera) {
    if (_only_support_mobile) {
      return _deviceFFIBindings.switch_camera(_nativePointer, frontCamera);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int enableCameraAutoFocus(bool enabled) {
    if (_only_support_mobile) {
      return _deviceFFIBindings.enable_camera_auto_focus(
          _nativePointer, enabled);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int enableCameraTorch(bool enabled) {
    if (_only_support_mobile) {
      return _deviceFFIBindings.enable_camera_torch(_nativePointer, enabled);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int enableFollowingDefaultAudioDevice(TXMediaDeviceType type, bool enable) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.enable_following_default_audio_device(
          _nativePointer, type.value(), enable);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int setApplicationMuteState(bool mute) {
    if (_only_support_windows) {
      return _deviceFFIBindings.set_application_mute_state(
          _nativePointer, mute);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int getApplicationMuteState() {
    if (_only_support_windows) {
      return _deviceFFIBindings.get_application_mute_state(_nativePointer);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  double getCameraZoomMaxRatio() {
    if (_only_support_mobile) {
      return _deviceFFIBindings.get_camera_zoom_max_ratio(_nativePointer);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  TXDeviceInfo getCurrentDevice(TXMediaDeviceType type) {
    if (_only_support_desktop) {
      TXDeviceInfo deviceInfo = new TXDeviceInfo();
      ffi.Pointer<TXDeviceInfoStruct> deviceInfoPointer =
          TXDeviceInfoStruct.create();
      _deviceFFIBindings.get_current_device(
          _nativePointer, type.value(), deviceInfoPointer);
      if (deviceInfoPointer != ffi.nullptr) {
        deviceInfo.devicePid =
            FFIConverter.getStringFromChar(deviceInfoPointer.ref.device_pid);
        deviceInfo.deviceName =
            FFIConverter.getStringFromChar(deviceInfoPointer.ref.device_name);
        deviceInfo.deviceProperties = FFIConverter.getStringFromChar(
            deviceInfoPointer.ref.device_properties);
      }
      return deviceInfo;
    } else {
      debugPrint("device-manager-api not support");
      return TXDeviceInfo();
    }
  }

  bool getCurrentDeviceMute(TXMediaDeviceType type) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.get_current_device_mute(
              _nativePointer, type.value()) !=
          0;
    } else {
      debugPrint("device-manager-api not support");
      return false;
    }
  }

  int getCurrentDeviceVolume(TXMediaDeviceType type) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.get_current_device_volume(
          _nativePointer, type.value());
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  List<TXDeviceInfo> getDevicesList(TXMediaDeviceType type) {
    if (_only_support_desktop) {
      List<TXDeviceInfo> devices = <TXDeviceInfo>[];
      var count =
          _deviceFFIBindings.get_device_count(_nativePointer, type.value());
      for (int index = 0; index < count; index++) {
        TXDeviceInfo deviceInfo = new TXDeviceInfo();
        ffi.Pointer<TXDeviceInfoStruct> deviceInfoPointer =
            TXDeviceInfoStruct.create();
        _deviceFFIBindings.get_device_info(
            _nativePointer, type.value(), index, deviceInfoPointer);
        deviceInfo.devicePid =
            FFIConverter.getStringFromChar(deviceInfoPointer.ref.device_pid);
        deviceInfo.deviceName =
            FFIConverter.getStringFromChar(deviceInfoPointer.ref.device_name);
        deviceInfo.deviceProperties = FFIConverter.getStringFromChar(
            deviceInfoPointer.ref.device_properties);
        devices.add(deviceInfo);
        TXDeviceInfoStruct.freeStruct(deviceInfoPointer);
      }
      return devices;
    } else {
      debugPrint("device-manager-api not support");
      return [];
    }
  }

  bool isAutoFocusEnabled() {
    if (_only_support_mobile) {
      return _deviceFFIBindings.is_audio_focus_enabled(_nativePointer) != 0;
    } else {
      debugPrint("device-manager-api not support");
      return false;
    }
  }

  int setApplicationPlayVolume(int volume) {
    if (_only_support_windows) {
      return _deviceFFIBindings.set_application_play_volume(
          _nativePointer, volume);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int getApplicationPlayVolume() {
    if (_only_support_windows) {
      return _deviceFFIBindings.get_application_play_volume(_nativePointer);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  void setCameraCaptureParam(TXCameraCaptureParam params) {
    ffi.Pointer<TXCameraCaptureParamStruct> paramsPointer =
        TXCameraCaptureParamStruct.fromParams(params);
    _deviceFFIBindings.set_camera_capture_param(_nativePointer, paramsPointer);
    calloc.free(paramsPointer);
  }

  int setCameraFocusPosition(double x, double y) {
    if (_only_support_mobile) {
      return _deviceFFIBindings.set_camera_focus_position(_nativePointer, x, y);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int setCameraZoomRatio(double ratio) {
    if (_only_support_mobile) {
      return _deviceFFIBindings.set_camera_zoom_ratio(_nativePointer, ratio);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int setCurrentDevice(TXMediaDeviceType type, String deviceId) {
    if (_only_support_desktop) {
      ffi.Pointer<ffi.Char> deviceIdPointer =
          deviceId.toNativeUtf8().cast<ffi.Char>();
      int result = _deviceFFIBindings.set_current_device(
          _nativePointer, type.value(), deviceIdPointer);
      calloc.free(deviceIdPointer);
      return result;
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int setCurrentDeviceMute(TXMediaDeviceType type, bool mute) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.set_current_device_mute(
          _nativePointer, type.value(), mute);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int setCurrentDeviceVolume(TXMediaDeviceType type, int volume) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.set_current_device_volume(
          _nativePointer, type.value(), volume);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int setDeviceObserver(TXDeviceObserver? observer) {
    if (observer != null) {
      _deviceObserverNative?.setObserver(observer);
    } else {
      _deviceObserverNative?.removeObserver();
    }
    return 0;
  }

  int startCameraDeviceTest(int viewId) {
    if (!_only_support_desktop) {
      debugPrint("device-manager-api not support");
      return -1;
    }
    if (TRTCCloudImpl.useTextureRender) {
      TRTCMethodChannel().startCameraDeviceTest(viewId);
      return 0;
    }
    tx_view txView = tx_view.fromAddress(viewId);
    return _deviceFFIBindings.start_camera_device_test(_nativePointer, txView);
  }

  int startMicDeviceTest(int interval) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.start_mic_device_test(_nativePointer, interval);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int startMicDeviceTestAndPlayback(int interval, bool playback) {
    if (_only_support_desktop) {
      return _deviceFFIBindings.start_mic_device_test_and_playback(
          _nativePointer, interval, playback);
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  int startSpeakerDeviceTest(String filePath) {
    if (_only_support_desktop) {
      ffi.Pointer<ffi.Char> filePathPointer =
          filePath.toNativeUtf8().cast<ffi.Char>();
      int result = _deviceFFIBindings.start_speaker_device_test(
          _nativePointer, filePathPointer);
      calloc.free(filePathPointer);
      return result;
    } else {
      debugPrint("device-manager-api not support");
      return -1;
    }
  }

  void stopCameraDeviceTest() {
    if (!_only_support_desktop) {
      debugPrint("device-manager-api not support");
      return;
    }
    if (TRTCCloudImpl.useTextureRender) {
      TRTCMethodChannel().stopCameraDeviceTest();
      return;
    }
    _deviceFFIBindings.stop_camera_device_test(_nativePointer);
  }

  void stopMicDeviceTest() {
    if (_only_support_desktop) {
      _deviceFFIBindings.stop_mic_device_test(_nativePointer);
    } else {
      debugPrint("device-manager-api not support");
      return;
    }
  }

  void stopSpeakerDeviceTest() {
    if (_only_support_desktop) {
      _deviceFFIBindings.stop_speaker_device_test(_nativePointer);
    } else {
      debugPrint("device-manager-api not support");
      return;
    }
  }
}
