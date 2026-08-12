import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_code.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_def.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_premier.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/live/v2_tx_live_premier_observer_native.dart';
import 'package:tencent_rtc_sdk/impl/live/v2_tx_live_struct.dart';
import 'package:tencent_rtc_sdk/bindings/live/v2_tx_live_premier_ffi_bindings.dart'
    as native;

class V2TXLivePremierImpl {
  static final _premierFFIBindings =
      native.V2TXLivePremierFFIBindings(LiveLoadDynamicLib.getLiteavSDK());

  static V2TXLivePremierObserverNative? _observerNative;

  static Future<void> setLicence(String url, String key) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    ffi.Pointer<ffi.Int8> nativeURL = url.toNativeUtf8().cast<ffi.Int8>();
    ffi.Pointer<ffi.Int8> nativeKey = key.toNativeUtf8().cast<ffi.Int8>();
    _premierFFIBindings.setLicence(nativeURL, nativeKey);

    calloc.free(nativeURL);
    calloc.free(nativeKey);
  }

  static Future<String> getSDKVersionStr() async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    ffi.Pointer<ffi.Int8> version = _premierFFIBindings.getSDKVersion();
    return version.cast<Utf8>().toDartString();
  }

  static Future<void> setObserver(V2TXLivePremierObserver? observer) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    _observerNative ??= V2TXLivePremierObserverNative();
    _observerNative?.setObserver(observer);
  }

  static Future<V2TXLiveCode> setLogConfig(V2TXLiveLogConfig config) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');

    ffi.Pointer<V2TXLiveLogConfigStruct> configPointer =
        V2TXLiveLogConfigStruct.convert(config);
    _premierFFIBindings.setLogConfig(configPointer);

    V2TXLiveLogConfigStruct.freeStruct(configPointer);
    return V2TXLIVE_OK;
  }

  static Future<V2TXLiveCode> setEnvironment(String env) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    ffi.Pointer<ffi.Int8> nativeEnv = env.toNativeUtf8().cast<ffi.Int8>();
    var result = _premierFFIBindings.setEnvironment(nativeEnv);

    calloc.free(nativeEnv);
    return result;
  }

  static Future<V2TXLiveCode> setSocks5Proxy(
      String host,
      int port,
      String username,
      String password,
      V2TXLiveSocks5ProxyConfig config) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    return V2TXLIVE_OK;
  }

  static Future<V2TXLiveCode> setUserId(String userId) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    ffi.Pointer<ffi.Int8> nativeUserId = userId.toNativeUtf8().cast<ffi.Int8>();
    _premierFFIBindings.setUserId(nativeUserId);

    calloc.free(nativeUserId);
    return V2TXLIVE_OK;
  }

  static Future<V2TXLiveCode> callExperimentalAPI(String jsonStr) async {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    ffi.Pointer<ffi.Int8> nativeJsonStr =
        jsonStr.toNativeUtf8().cast<ffi.Int8>();
    var result = _premierFFIBindings.callExperimentalAPI(nativeJsonStr);

    calloc.free(nativeJsonStr);
    return result;
  }
}
