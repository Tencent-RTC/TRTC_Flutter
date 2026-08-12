// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;

import 'package:tencent_rtc_sdk/impl/live/v2_tx_live_struct.dart';

class V2TXLivePremierFFIBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;
  V2TXLivePremierFFIBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;
  V2TXLivePremierFFIBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ///***********************************************************************************************
  ///                                          V2TXLivePremier
  /// **********************************************************************************************
  void setUserId(ffi.Pointer<ffi.Int8> userId) {
    _setUserId(userId);
  }

  late final _setUserIdPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Int8>)>>(
          'v2tx_live_premier_set_user_id');
  late final _setUserId =
      _setUserIdPtr.asFunction<void Function(ffi.Pointer<ffi.Int8>)>();

  int setEnvironment(ffi.Pointer<ffi.Int8> env) {
    return _setEnvironment(env);
  }

  late final _setEnvironmentPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<ffi.Int8>)>>(
          'v2tx_live_premier_set_environment');
  late final _setEnvironment =
      _setEnvironmentPtr.asFunction<int Function(ffi.Pointer<ffi.Int8>)>();

  ffi.Pointer<ffi.Int8> getSDKVersion() {
    return _getSDKVersion();
  }

  late final _getSDKVersionPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int8> Function()>>(
          'v2tx_live_premier_get_sdk_version');
  late final _getSDKVersion =
      _getSDKVersionPtr.asFunction<ffi.Pointer<ffi.Int8> Function()>();

  void setLicence(ffi.Pointer<ffi.Int8> url, ffi.Pointer<ffi.Int8> key) {
    _setLicence(url, key);
  }

  late final _setLicencePtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<ffi.Int8>,
              ffi.Pointer<ffi.Int8>)>>('v2tx_live_premier_set_license');
  late final _setLicence = _setLicencePtr.asFunction<
      void Function(ffi.Pointer<ffi.Int8>, ffi.Pointer<ffi.Int8>)>();

  void setLogConfig(ffi.Pointer<V2TXLiveLogConfigStruct> struct) {
    _setLogConfig(struct);
  }

  late final _setLogConfigPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<V2TXLiveLogConfigStruct>)>>(
      'v2tx_live_premier_set_log_config');
  late final _setLogConfig = _setLogConfigPtr
      .asFunction<void Function(ffi.Pointer<V2TXLiveLogConfigStruct>)>();

  void setLogLevel(ffi.Pointer<V2TXLiveLogConfigStruct> struct) {
    _setLogLevel(struct);
  }

  late final _setLogLevelPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<V2TXLiveLogConfigStruct>)>>(
      'v2tx_live_premier_set_log_level');
  late final _setLogLevel = _setLogLevelPtr
      .asFunction<void Function(ffi.Pointer<V2TXLiveLogConfigStruct>)>();

  int callExperimentalAPI(ffi.Pointer<ffi.Int8> jsonStr) {
    return _callExperimentalAPI(jsonStr);
  }

  late final _callExperimentalAPIPtr =
      _lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Pointer<ffi.Int8>)>>(
          'v2tx_live_premier_call_experimental_api');
  late final _callExperimentalAPI =
      _callExperimentalAPIPtr.asFunction<int Function(ffi.Pointer<ffi.Int8>)>();

  void registerPremierListener(int sendPort) {
    _registerPremierListener(sendPort);
  }

  late final _registerPremierListenerPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int64)>>(
          'LiteavFFIRegisterPremierListener');
  late final _registerPremierListener =
      _registerPremierListenerPtr.asFunction<void Function(int)>();

  void unRegisterPremierListener() {
    _unRegisterPremierListener();
  }

  late final _unRegisterPremierListenerPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>(
          'LiteavFFIUnRegisterPremierListener');
  late final _unRegisterPremierListener =
      _unRegisterPremierListenerPtr.asFunction<void Function()>();

  ///***********************************************************************************************
  ///                                          InitDartApiDL
  /// **********************************************************************************************

  int InitDartApiDL(
    ffi.Pointer<ffi.Void> data,
  ) {
    return _InitDartApiDL(
      data,
    );
  }

  late final _InitDartApiDLPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
          'LiteavFFIInitApiDL');
  late final _InitDartApiDL =
      _InitDartApiDLPtr.asFunction<int Function(ffi.Pointer<ffi.Void>)>();
}

/// A port is used to send or receive inter-isolate messages
typedef V2TXLivePremierNativePointer = ffi.Pointer<ffi.Void>;
