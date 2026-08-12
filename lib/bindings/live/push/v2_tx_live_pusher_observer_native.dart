// ignore_for_file: prefer_collection_literals
// ignore_for_file: unnecessary_import
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_pusher_observer.dart';

import 'v2_tx_live_pusher_ffi_bindings.dart' as native;

class V2TXLivePusherObserverNative {
  final Set<V2TXLivePusherObserver> _observers = Set();
  late native.V2TXLivePusherFFIBindings _ffiBindings;
  late Pointer<native.V2TXLivePusherNativePointer> _nativePointer;
  late ReceivePort _receivePort;

  V2TXLivePusherObserverNative(
      Pointer<native.V2TXLivePusherNativePointer> pointer) {
    _nativePointer = pointer;
    _receivePort = ReceivePort();
    _receivePort.listen(_handleMessage);

    _ffiBindings =
        native.V2TXLivePusherFFIBindings(LiveLoadDynamicLib.getLiteavSDK());
    _ffiBindings.InitDartApiDL(NativeApi.initializeApiDLData);
    _ffiBindings.registerPusherListener(
        _receivePort.sendPort.nativePort, _nativePointer);
  }

  void addObserver(V2TXLivePusherObserver observer) {
    _observers.add(observer);
  }

  void removeObserver(V2TXLivePusherObserver observer) {
    _observers.remove(observer);
  }

  void unRegisterNativeObserver() {
    _observers.clear();
    _ffiBindings.unRegisterPusherListener(_nativePointer);
    _receivePort.close();
  }

  void _handleMessage(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];

    V2TXLivePusherListenerType? type;
    for (var item in V2TXLivePusherListenerType.values) {
      if (item.toString().replaceFirst("V2TXLivePusherListenerType.", "") ==
          typeStr) {
        type = item;

        if (type == V2TXLivePusherListenerType.onSnapshotComplete) {
          final imageData = params['image'];
          if (imageData is String && imageData.isNotEmpty) {
            Uint8List decodedBytes = base64Decode(imageData);
            params['image'] = decodedBytes;
          }
        }

        break;
      }
    }

    if (type == null) {
      throw MissingPluginException(
          'Unknown V2TXLivePusherListenerType: $typeStr');
    }

    for (var observer in _observers) {
      observer(type, params);
    }
  }
}
