// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;
import 'dart:convert' as convert;
import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/live/play/v2_tx_live_player_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/live/play/v2_tx_live_player_observer_native.dart';
import 'package:tencent_rtc_sdk/bindings/live/live_log.dart';
import 'package:tencent_rtc_sdk/live_config.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_player_observer.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_code.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_def.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_player.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class V2TXLivePlayerImpl extends V2TXLivePlayer {
  late V2TXLivePlayerFFIBindings? _playerFFIBindings;
  late V2TXLivePlayerObserverNative? _observerNative;

  late ffi.Pointer<V2TXLivePlayerNativePointer> _playerNativePointer;

  int _textureId = -1;

  V2TXLivePlayerImpl() {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    _playerFFIBindings =
        V2TXLivePlayerFFIBindings(LiveLoadDynamicLib.getLiteavSDK());
    _playerNativePointer = _playerFFIBindings!.createPlayer();
    setProperty("setFramework", "{\"component\": 1,\"framework\": 23}");
    _observerNative = V2TXLivePlayerObserverNative(_playerNativePointer);
    LiveLog.playerPrint(
      _playerNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePlayerImpl.create, hashCode: $hashCode, flutterSDKVersion: ${LiteavLiveConfig.flutterSDKVersion}",
    );
  }

  V2TXLivePlayerImpl.identifier(String identifier) {
    LiveLoadDynamicLib.getPluginChannel().invokeMethod('initialize');
    _playerFFIBindings =
        V2TXLivePlayerFFIBindings(LiveLoadDynamicLib.getLiteavSDK());

    ffi.Pointer<ffi.Int8> nativeIdentifier =
        identifier.toNativeUtf8().cast<ffi.Int8>();
    _playerNativePointer =
        _playerFFIBindings!.createByIdentifier(nativeIdentifier);
    setProperty("setFramework", "{\"component\": 1,\"framework\": 23}");
    _observerNative = V2TXLivePlayerObserverNative(_playerNativePointer);
    LiveLog.playerPrint(
      _playerNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePlayerImpl.identifier, hashCode: $hashCode, flutterSDKVersion: ${LiteavLiveConfig.flutterSDKVersion}, identifier: $identifier",
    );
    calloc.free(nativeIdentifier);
  }

  static Future<V2TXLivePlayerImpl> create() async {
    return V2TXLivePlayerImpl();
  }

  static Future<V2TXLivePlayerImpl> createByIdentifier(
      String identifier) async {
    return V2TXLivePlayerImpl.identifier(identifier);
  }

  @override
  void destroy() async {
    LiveLog.playerPrint(
      _playerNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePlayerImpl.destroy: $hashCode",
    );
    _unregisterTexture();
    _observerNative?.unRegisterNativeListener();
    _observerNative = null;
    _playerFFIBindings?.releasePlayer(_playerNativePointer);
    _playerFFIBindings = null;
    _playerNativePointer = ffi.nullptr;
  }

  @override
  void addListener(V2TXLivePlayerObserver observer) async {
    _observerNative?.addListener(observer);
  }

  @override
  void removeListener(V2TXLivePlayerObserver observer) async {
    _observerNative?.removeListener(observer);
  }

  @override
  Future<V2TXLiveCode> setRenderViewID(int viewID) async {
    if (TRTCPlatform.isOhos) {
      var json = {"surfaceId": viewID};
      return setProperty("setOHOSSurface", convert.jsonEncode(json));
    }

    ffi.Pointer<ffi.Void> nativeView =
        ffi.Pointer<ffi.Void>.fromAddress(viewID);
    var result =
        _playerFFIBindings?.setRenderViewID(_playerNativePointer, nativeView) ??
            V2TXLIVE_ERROR_REFUSED;
    return result;
  }

  @override
  Future<V2TXLiveCode> setRenderRotation(V2TXLiveRotation rotation) async {
    return _playerFFIBindings?.setRenderRotation(
            _playerNativePointer, rotation.index) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> setRenderFillMode(V2TXLiveFillMode mode) async {
    return _playerFFIBindings?.setRenderFillMode(
            _playerNativePointer, mode.index) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> startLivePlay(String url) async {
    ffi.Pointer<ffi.Int8> nativeURL = url.toNativeUtf8().cast<ffi.Int8>();
    var result =
        _playerFFIBindings?.startPlay(_playerNativePointer, nativeURL) ??
            V2TXLIVE_ERROR_REFUSED;

    calloc.free(nativeURL);

    return result;
  }

  @override
  Future<V2TXLiveCode> stopPlay() async {
    return _playerFFIBindings?.stopPlay(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> switchStream(String url) async {
    ffi.Pointer<ffi.Int8> nativeURL = url.toNativeUtf8().cast<ffi.Int8>();
    var result =
        _playerFFIBindings?.switchStream(_playerNativePointer, nativeURL) ??
            V2TXLIVE_ERROR_REFUSED;

    calloc.free(nativeURL);

    return result;
  }

  @override
  Future<V2TXLiveCode> isPlaying() async {
    return _playerFFIBindings?.isPlaying(_playerNativePointer) ?? 0;
  }

  @override
  Future<V2TXLiveCode> pauseAudio() async {
    return _playerFFIBindings?.pauseAudio(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> resumeAudio() async {
    return _playerFFIBindings?.resumeAudio(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> pauseVideo() async {
    return _playerFFIBindings?.pauseVideo(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> resumeVideo() async {
    return _playerFFIBindings?.resumeVideo(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> setPlayoutVolume(int volume) async {
    return _playerFFIBindings?.setPlayoutVolume(_playerNativePointer, volume) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> setCacheParams(double minTime, double maxTime) async {
    return _playerFFIBindings?.setCacheParams(
            _playerNativePointer, minTime, maxTime) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> enableVolumeEvaluation(int intervalMs) async {
    return _playerFFIBindings?.enableVolumeEvaluation(
            _playerNativePointer, intervalMs) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> snapshot() async {
    return _playerFFIBindings?.snapshot(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<V2TXLiveCode> enableObserveVideoFrame(
      bool enable, int pixelFormat, int bufferType) async {
    var c_pixel_format = _convertPixelFormat(pixelFormat);
    var c_buffer_type = _convertBufferType(bufferType);

    return _playerFFIBindings?.enableObserveVideoFrame(
          _playerNativePointer,
          enable,
          c_pixel_format,
          c_buffer_type,
        ) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  int _convertBufferType(int bufferType) {
    if (bufferType == V2TXLiveBufferType.v2TXLiveBufferTypeByteBuffer.index) {
      return 1;
    } else if (bufferType ==
        V2TXLiveBufferType.v2TXLiveBufferTypeTexture.index) {
      return 2;
    } else {
      return 0;
    }
  }

  int _convertPixelFormat(int pixelFormat) {
    if (pixelFormat == V2TXLivePixelFormat.v2TXLivePixelFormatI420.index) {
      return 1;
    } else if (pixelFormat ==
        V2TXLivePixelFormat.v2TXLivePixelFormatBGRA32.index) {
      return 2;
    } else if (pixelFormat ==
        V2TXLivePixelFormat.v2TXLivePixelFormatTexture2D.index) {
      return 4;
    } else {
      return 0;
    }
  }

  @override
  Future<V2TXLiveCode> enableReceiveSeiMessage(
      bool enable, int payloadType) async {
    return _playerFFIBindings?.enableReceiveSeiMessage(
            _playerNativePointer, enable, payloadType) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<void> showDebugView(bool isShow) async {
    _playerFFIBindings?.showDebugView(_playerNativePointer, isShow);
  }

  @override
  Future<V2TXLiveCode> enablePictureInPicture(bool enable) async {
    if (TRTCPlatform.isIOS) {
      return _playerFFIBindings?.enablePictureInPicture(
              _playerNativePointer, enable) ??
          V2TXLIVE_ERROR_REFUSED;
    }
    return V2TXLIVE_ERROR_NOT_SUPPORTED;
  }

  @override
  Future<V2TXLiveCode> setProperty(String key, Object value) async {
    if (_playerFFIBindings == null) return V2TXLIVE_ERROR_REFUSED;
    var result = V2TXLIVE_OK;
    ffi.Pointer<ffi.Int8> nativeKey = key.toNativeUtf8().cast<ffi.Int8>();

    if (value is bool) {
      var nativeBoolValue = calloc<ffi.Bool>(ffi.sizeOf<ffi.Bool>());
      nativeBoolValue.value = value;

      var nativeVoidValue = nativeBoolValue.cast<ffi.Void>();
      result = _playerFFIBindings?.setProperty(
              _playerNativePointer, nativeKey, nativeVoidValue) ??
          V2TXLIVE_ERROR_REFUSED;
      calloc.free(nativeBoolValue);
    } else if (value is int) {
      var nativeInt32Value = calloc<ffi.Int32>(ffi.sizeOf<ffi.Int32>());
      nativeInt32Value.value = value;

      var nativeVoidValue = nativeInt32Value.cast<ffi.Void>();
      result = _playerFFIBindings?.setProperty(
              _playerNativePointer, nativeKey, nativeVoidValue) ??
          V2TXLIVE_ERROR_REFUSED;
      calloc.free(nativeInt32Value);
    } else if (value is String) {
      var nativeValue = value.toString().toNativeUtf8().cast<ffi.Void>();
      result = _playerFFIBindings?.setProperty(
              _playerNativePointer, nativeKey, nativeValue) ??
          V2TXLIVE_ERROR_REFUSED;
      calloc.free(nativeValue);
    } else if (value == Null) {
      result = _playerFFIBindings?.setProperty(
              _playerNativePointer, nativeKey, ffi.nullptr) ??
          V2TXLIVE_ERROR_REFUSED;
    } else {
      result = V2TXLIVE_ERROR_INVALID_PARAMETER;
    }

    calloc.free(nativeKey);

    return result;
  }

  @override
  Future<V2TXLiveCode> startLocalRecording(
      V2TXLiveLocalRecordingParams params) async {
    ffi.Pointer<ffi.Int8> nativeFilePath =
        params.filePath.toNativeUtf8().cast<ffi.Int8>();
    var result = _playerFFIBindings?.startLocalRecording(
          _playerNativePointer,
          nativeFilePath,
          params.recordType.index,
          params.interval,
        ) ??
        V2TXLIVE_ERROR_REFUSED;

    calloc.free(nativeFilePath);

    return result;
  }

  @override
  Future<V2TXLiveCode> stopLocalRecording() async {
    return _playerFFIBindings?.stopLocalRecording(_playerNativePointer) ??
        V2TXLIVE_ERROR_REFUSED;
  }

  @override
  Future<int> getTextureId(int width, int height) async {
    if (width <= 0 || height <= 0) {
      LiveLog.playerPrint(
        _playerNativePointer,
        V2TXLiveLogLevel.v2TXLiveLogLevelWarning,
        "V2TXLivePlayerImpl.getTextureId: width or height invalid, width: $width, height: $height",
      );
      return V2TXLIVE_ERROR_INVALID_PARAMETER;
    }
    if (_textureId == -1) {
      _textureId = await LiveLoadDynamicLib.getVideoViewChannel()
          .invokeMethod('getTextureId');
    }

    int result = V2TXLIVE_OK;
    if (TRTCPlatform.isMacOS || TRTCPlatform.isWindows) {
      result = await _handleDesktopTexture();
    } else {
      result = await _handleMobileTexture(width, height);
    }

    if (result != V2TXLIVE_OK) {
      return result;
    }
    return _textureId;
  }

  Future<int> _handleMobileTexture(int width, int height) async {
    if (TRTCPlatform.isAndroid) {
      _observerNative?.onSurfaceAddressChanged = (int newSurfaceAddress) async {
        LiveLog.playerPrint(
          _playerNativePointer,
          V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
          "V2TXLivePlayerImpl.onSurfaceAddressChanged: newSurfaceAddress: $newSurfaceAddress",
        );
        await setRenderViewID(newSurfaceAddress);
      };
    }

    var surfaceId = await LiveLoadDynamicLib.getVideoViewChannel()
        .invokeMethod('getSurfaceId', {"textureId": _textureId});
    var newSurfaceId = await LiveLoadDynamicLib.getVideoViewChannel()
        .invokeMethod('setRenderSize', {
      "textureId": _textureId,
      "width": width,
      "height": height,
    });
    if (newSurfaceId != null) {
      surfaceId = newSurfaceId;
    }
    await setRenderViewID(surfaceId);

    LiveLog.playerPrint(
      _playerNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePlayerImpl.getTextureId: $_textureId, surfaceId: $surfaceId, width: $width, height: $height",
    );
    return V2TXLIVE_OK;
  }

  Future<int> _handleDesktopTexture() async {
    try {
      var listener = await LiveLoadDynamicLib.getPluginChannel().invokeMethod(
          'getCustomVideoFrameListener', {'textureId': _textureId});

      if (_playerFFIBindings != null && listener != null && listener != 0) {
        _playerFFIBindings!.registerPlayerVideoRenderListener(
          _playerNativePointer,
          listener,
        );
      } else {
        LiveLog.playerPrint(
          _playerNativePointer,
          V2TXLiveLogLevel.v2TXLiveLogLevelError,
          "V2TXLivePlayerImpl: ERROR - Failed to register video render listener. FFIBindings: ${_playerFFIBindings != null}, listener: $listener",
        );
        return V2TXLIVE_ERROR_REFUSED;
      }
    } catch (e) {
      LiveLog.playerPrint(
        _playerNativePointer,
        V2TXLiveLogLevel.v2TXLiveLogLevelError,
        "V2TXLivePlayerImpl: ERROR - Exception while getting custom video frame listener: $e",
      );
      return V2TXLIVE_ERROR_REFUSED;
    }

    await enableObserveVideoFrame(
      true,
      V2TXLivePixelFormat.v2TXLivePixelFormatBGRA32.index,
      V2TXLiveBufferType.v2TXLiveBufferTypeByteBuffer.index,
    );

    LiveLog.playerPrint(
      _playerNativePointer,
      V2TXLiveLogLevel.v2TXLiveLogLevelInfo,
      "V2TXLivePlayerImpl.getTextureId: $_textureId",
    );
    return V2TXLIVE_OK;
  }

  void _unregisterTexture() async {
    _observerNative?.onSurfaceAddressChanged = null;
    if (_textureId != -1) {
      await LiveLoadDynamicLib.getVideoViewChannel()
          .invokeMethod('unregisterTexture', {
        "textureId": _textureId,
      });
    }

    await enableObserveVideoFrame(
      false,
      V2TXLivePixelFormat.v2TXLivePixelFormatBGRA32.index,
      V2TXLiveBufferType.v2TXLiveBufferTypeByteBuffer.index,
    );

    _playerFFIBindings?.unRegisterPlayerVideoRenderListener(
      _playerNativePointer,
    );

    _textureId = -1;
  }
}
