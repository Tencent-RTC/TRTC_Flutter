import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:isolate';

import 'package:tencent_rtc_sdk/bindings/chorus_music_player/chorus_music_player_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/chorus_music_player.dart';
import 'package:tencent_rtc_sdk/impl/chorus_music_player/chorus_music_player_listener_parse.dart';

class ChorusPlayerListenerNative {
  final ChorusPlayerListenerParse _listeners;
  final ffi.Pointer<ffi.Void> _playerNativePointer;

  late ChorusMusicPlayerFFIBindings _ffiBindings;
  late ReceivePort _receivePort;

  ChorusPlayerListenerNative(this._playerNativePointer)
      : _listeners = ChorusPlayerListenerParse() {
    _ffiBindings = ChorusMusicPlayerFFIBindings(LoadDynamicLib().loadTRTCSDK());

    _receivePort = ReceivePort();
    _receivePort.listen(_receiveNativePortData);

    _ffiBindings.registerChorusPlayerObserver(
        _receivePort.sendPort.nativePort, _playerNativePointer);
  }

  void addListener(ChorusPlayerEventListener listener) {
    _listeners.addListener(listener);
  }

  void removeListener(ChorusPlayerEventListener listener) {
    _listeners.removeListener(listener);
  }

  void unRegisterNativeListener() {
    _listeners.clearListeners();
    _ffiBindings.unRegisterChorusPlayerObserver(
        _receivePort.sendPort.nativePort, _playerNativePointer);
    _receivePort.close();
  }

  void _receiveNativePortData(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];
    params ??= <String, dynamic>{};

    _listeners.handleListener(typeStr, params);
  }
}
