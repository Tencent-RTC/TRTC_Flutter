// ignore_for_file: prefer_final_fields
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/bindings/manager/tx_audio_effect_manager_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/manager/tx_device_manager_ffi_bindings.dart';

class TXMusicPreloadObserverNative {
  TXMusicPreloadObserver? _observer;
  late TXAudioEffectManagerFFIBindings _ffiBindings;
  late TXAudioEffectManagerNativePointer _nativePointer;
  late ReceivePort _receivePort;

  TXMusicPreloadObserverNative(TXAudioEffectManagerNativePointer pointer) {
    _nativePointer = pointer;
    _receivePort = ReceivePort();
    _receivePort.listen(_handleMessage);

    _ffiBindings =
        TXAudioEffectManagerFFIBindings(LoadDynamicLib().loadTRTCSDK());
    _ffiBindings.InitDartApiDL(NativeApi.initializeApiDLData);
    _ffiBindings.registerMusicPreloadObserver(
        _receivePort.sendPort.nativePort, _nativePointer);
  }

  void setObserver(TXMusicPreloadObserver observer) {
    _observer = observer;
  }

  void removeObserver() {
    _observer = null;
  }

  void unRegisterNativeObserver() {
    _observer = null;
    _ffiBindings.unRegisterMusicPreloadObserver(_nativePointer);
    _receivePort.close();
  }

  void _handleMessage(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];
    int musicId = params['musicId'];

    switch (typeStr) {
      case 'onLoadProgress':
        int progress = params['progress'];
        _observer?.onLoadProgress(musicId, progress);
        break;
      case 'onLoadError':
        int errCode = params['errCode'];
        _observer?.onLoadError(musicId, errCode);
        break;
      default:
        break;
    }
  }
}

class TXMusicPlayObserverNative {
  static bool _isInit = false;

  final Map<int, TXMusicPlayObserver> _observers = {};
  late TXAudioEffectManagerFFIBindings _ffiBindings;
  late TXAudioEffectManagerNativePointer _nativePointer;
  late ReceivePort _receivePort;

  TXMusicPlayObserverNative(this._nativePointer) {
    _ffiBindings =
        TXAudioEffectManagerFFIBindings(LoadDynamicLib().loadTRTCSDK());

    if (!TXMusicPlayObserverNative._isInit) {
      _ffiBindings.InitDartApiDL(NativeApi.initializeApiDLData);
      TXMusicPlayObserverNative._isInit = true;
    }
    _receivePort = ReceivePort();
    _receivePort.listen(_handleMessage);
  }

  void addObserver(int musicId, TXMusicPlayObserver observer) {
    _observers[musicId] = observer;
    _setObserverNative(musicId, true);
  }

  void removeObserver(int musicId) {
    TXMusicPlayObserver? observer = _observers[musicId];
    _observers.remove(musicId);

    if (observer != null) {
      _setObserverNative(musicId, false);
    }
  }

  void unRegisterNativeObserver() {
    _observers.forEach((musicId, observer) {
      _setObserverNative(musicId, false);
    });
    _observers.clear();
    _receivePort.close();
  }

  void _setObserverNative(int musicId, bool enable) {
    Map<String, dynamic> params = {'musicId': musicId};
    String jsonString = jsonEncode(params);
    Pointer<Char> nativeJsonString = jsonString.toNativeUtf8().cast<Char>();

    if (enable) {
      _ffiBindings.registerMusicPlayObserver(
        _receivePort.sendPort.nativePort,
        _nativePointer,
        nativeJsonString,
      );
    } else {
      _ffiBindings.unRegisterMusicPlayObserver(
        _nativePointer,
        nativeJsonString,
      );
    }
    calloc.free(nativeJsonString);
  }

  void _handleMessage(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];
    int musicId = params['musicId'];
    TXMusicPlayObserver? observer = _observers[musicId];

    switch (typeStr) {
      case 'onStart':
        int errCode = params['errCode'];
        observer?.onStart(musicId, errCode);
        break;
      case 'onPlayProgress':
        int curPtsMs = params['curPtsMs'];
        int durationMs = params['durationMs'];
        observer?.onPlayProgress(musicId, curPtsMs, durationMs);
        break;
      case 'onComplete':
        int errCode = params['errCode'];
        observer?.onComplete(musicId, errCode);
        break;
      default:
        break;
    }
  }
}

class TXDeviceObserverNative {
  TXDeviceObserver? _observer;
  late TXDeviceManagerFFIBindings _ffiBindings;
  late TXDeviceManagerNativePointer _nativePointer;
  late ReceivePort _receivePort;

  TXDeviceObserverNative(TXDeviceManagerNativePointer pointer) {
    _nativePointer = pointer;
    _receivePort = ReceivePort();
    _receivePort.listen(_handleMessage);

    _ffiBindings = TXDeviceManagerFFIBindings(LoadDynamicLib().loadTRTCSDK());
    _ffiBindings.InitDartApiDL(NativeApi.initializeApiDLData);
    _ffiBindings.registerDeviceObserver(
        _receivePort.sendPort.nativePort, _nativePointer);
  }

  void setObserver(TXDeviceObserver observer) {
    _observer = observer;
  }

  void removeObserver() {
    _observer = null;
  }

  void unRegisterNativeObserver() {
    _observer = null;
    _ffiBindings.unRegisterDeviceObserver(_nativePointer);
    _receivePort.close();
  }

  void _handleMessage(var message) {
    var arguments = jsonDecode(message);
    String typeStr = arguments['type'];
    var params = arguments['params'];

    switch (typeStr) {
      case 'onDeviceChanged':
        String deviceId = params['deviceId'];
        int type = params['type'];
        int state = params['state'];
        _observer?.onDeviceChanged(
            deviceId,
            TXMediaDeviceTypeExt.fromValue(type),
            TXMediaDeviceStateExt.fromValue(state));
        break;
      default:
        break;
    }
  }
}
