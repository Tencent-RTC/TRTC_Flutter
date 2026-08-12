// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:isolate';
import 'dart:typed_data';

import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_struct.dart';
import 'package:tencent_rtc_sdk/impl/trtc/trtc_cloud_listener_prase.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'ffi_bindings.dart' as native;
import 'load_dynamic_lib.dart';

abstract class ListenerNative<T> {
  static bool _isInit = false;

  final ListenerParse<T> _listeners;
  final ffi.Pointer<ffi.Void> _instanceNativePointer;

  late native.FFIBindings _listenerFFIBindings;
  late ReceivePort _receivePort;

  ListenerNative(
    this._listeners,
    this._instanceNativePointer,
  ) {
    _listenerFFIBindings = native.FFIBindings(LoadDynamicLib().loadTRTCSDK());

    if (!ListenerNative._isInit) {
      try {
        _listenerFFIBindings.InitDartApiDL(ffi.NativeApi.initializeApiDLData);
        ListenerNative._isInit = true;
      } catch (e) {
        print(e);
      }
    }

    _receivePort = ReceivePort();
    _receivePort.listen(_receiveNativePortData);
  }

  void addListener(T listener) {
    _listeners.addListener(listener);
  }

  void removeListener(T listener) {
    _listeners.removeListener(listener);
  }

  void clearListeners() {
    _listeners.clearListeners();
  }

  void unRegisterNativeListener() {
    _listeners.clearListeners();
    _receivePort.close();
  }

  _receiveNativePortData(var message);
}

class TRTCCloudListenerNative extends ListenerNative<TRTCCloudListener> {
  TRTCCloudListenerNative(trtc_cloud instanceNativePointer)
      : super(TRTCCloudListenerParse(), instanceNativePointer) {
    _listenerFFIBindings.registerListener(
        _receivePort.sendPort.nativePort, _instanceNativePointer);
  }

  @override
  void _receiveNativePortData(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];
    params ??= <String, dynamic>{};

    _listeners.handleListener(typeStr, params);
  }

  @override
  void unRegisterNativeListener() {
    _listenerFFIBindings.unRegisterListener(_instanceNativePointer);
    super.unRegisterNativeListener();
  }
}

class TRTCAudioFrameCallbackNative
    extends ListenerNative<TRTCAudioFrameCallback> {
  TRTCAudioFrameCallbackNative(trtc_cloud instanceNativePointer)
      : super(TRTCAudioFrameCallbackParse(), instanceNativePointer) {
    _listenerFFIBindings.registerAudioFrameObserver(
        _receivePort.sendPort.nativePort, _instanceNativePointer);
  }

  @override
  _receiveNativePortData(message) {
    final audioFrameParse = _listeners as TRTCAudioFrameCallbackParse;

    if (message is List && message.length == 2) {
      // 新格式: [Uint8List audioData, String jsonMetadata]
      final Uint8List audioData = message[0] as Uint8List;
      final String jsonStr = message[1] as String;
      final arguments = jsonDecode(jsonStr);
      final String typeStr = arguments['type'];
      final params = arguments['params'] as Map<String, dynamic>;

      audioFrameParse.handleListenerWithData(typeStr, params, audioData);
    } else if (message is String) {
      // 旧格式兼容: 纯 JSON 字符串
      final arguments = jsonDecode(message);
      final String typeStr = arguments['type'];
      final params = arguments['params'] as Map<String, dynamic>;

      audioFrameParse.handleListener(typeStr, params);
    }
  }

  @override
  void unRegisterNativeListener() {
    _listenerFFIBindings.unRegisterAudioFrameObserver(
        _receivePort.sendPort.nativePort, _instanceNativePointer);
    super.unRegisterNativeListener();
  }
}

class TRTCLogCallbackNative extends ListenerNative<TRTCLogCallback> {
  TRTCLogCallbackNative(trtc_cloud instanceNativePointer)
      : super(TRTCLogCallbackParse(), instanceNativePointer) {
    _listenerFFIBindings.registerLogObserver(
        _receivePort.sendPort.nativePort, _instanceNativePointer);
  }

  @override
  _receiveNativePortData(message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];

    _listeners.handleListener(typeStr, params);
  }

  @override
  void unRegisterNativeListener() {
    _listenerFFIBindings.unRegisterLogObserver(
        _receivePort.sendPort.nativePort, _instanceNativePointer);
    super.unRegisterNativeListener();
  }
}
