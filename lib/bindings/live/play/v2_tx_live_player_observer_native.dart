import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_player_observer.dart';

import 'v2_tx_live_player_ffi_bindings.dart' as native;

typedef OnSurfaceAddressChanged = void Function(int newSurfaceAddress);

class V2TXLivePlayerObserverNative {
  final Set<V2TXLivePlayerObserver> _observers = {};

  late native.V2TXLivePlayerFFIBindings _observerFFIBindings;
  late Pointer<native.V2TXLivePlayerNativePointer> _playerNativePointer;

  OnSurfaceAddressChanged? onSurfaceAddressChanged;

  late ReceivePort _receivePort;

  V2TXLivePlayerObserverNative(
      Pointer<native.V2TXLivePlayerNativePointer> playerNativePointer) {
    _playerNativePointer = playerNativePointer;

    _receivePort = ReceivePort();
    _receivePort.listen(_receiveNativePortData);

    _observerFFIBindings =
        native.V2TXLivePlayerFFIBindings(LiveLoadDynamicLib.getLiteavSDK());
    _observerFFIBindings.InitDartApiDL(NativeApi.initializeApiDLData);
    _observerFFIBindings.registerPlayerListener(
        _receivePort.sendPort.nativePort, _playerNativePointer);
  }

  void addListener(V2TXLivePlayerObserver observer) {
    _observers.add(observer);
  }

  void removeListener(V2TXLivePlayerObserver observer) {
    _observers.remove(observer);
  }

  void unRegisterNativeListener() {
    _observers.clear();
    _observerFFIBindings.unRegisterPlayerListener(_playerNativePointer);
    _receivePort.close();
  }

  _receiveNativePortData(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];

    V2TXLivePlayerListenerType? type;

    for (var item in V2TXLivePlayerListenerType.values) {
      if (item.toString().replaceFirst("V2TXLivePlayerListenerType.", "") ==
          typeStr) {
        type = item;

        if (type == V2TXLivePlayerListenerType.onReceiveSeiMessage) {
          Uint8List decodedBytes = base64Decode(params['data']);
          params['data'] = decodedBytes;
        }

        if (type == V2TXLivePlayerListenerType.onSnapshotComplete) {
          final imageData = params.remove('image');
          if (imageData is String && imageData.isNotEmpty) {
            params['image'] = base64Decode(imageData);
          }
        }
        break;
      }
    }
    if (type == null) {
      throw MissingPluginException();
    }
    for (var item in _observers) {
      item(type, params);
    }
  }
}
