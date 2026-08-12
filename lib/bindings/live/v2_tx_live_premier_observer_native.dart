import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_premier.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/live/v2_tx_live_premier_ffi_bindings.dart'
    as native;

class V2TXLivePremierObserverNative {
  V2TXLivePremierObserver? _observer;

  late native.V2TXLivePremierFFIBindings _observerFFIBindings;

  late ReceivePort _receivePort;

  V2TXLivePremierObserverNative() {
    _receivePort = ReceivePort();

    _observerFFIBindings =
        native.V2TXLivePremierFFIBindings(LiveLoadDynamicLib.getLiteavSDK());
    _observerFFIBindings.InitDartApiDL(ffi.NativeApi.initializeApiDLData);
  }

  void setObserver(V2TXLivePremierObserver? observer) {
    _observer = observer;
    if (observer != null) {
      _receivePort.listen(_receiveNativePortData);
      _observerFFIBindings
          .registerPremierListener(_receivePort.sendPort.nativePort);
    } else {
      _observerFFIBindings.unRegisterPremierListener();
    }
  }

  _receiveNativePortData(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];

    V2TXLivePremierObserverType? type;

    for (var item in V2TXLivePremierObserverType.values) {
      if (item.toString().replaceFirst("V2TXLivePremierObserverType.", "") ==
          typeStr) {
        type = item;
        break;
      }
    }
    if (type == null) {
      throw MissingPluginException();
    }

    _observer?.call(type, params);
  }
}
