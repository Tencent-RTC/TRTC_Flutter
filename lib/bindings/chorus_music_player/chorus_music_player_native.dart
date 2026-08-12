import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/bindings/chorus_music_player/chorus_music_player_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/chorus_music_player/chorus_music_player_struct.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_struct.dart';
import 'package:tencent_rtc_sdk/chorus_music_player.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class ChorusMusicPlayerNative {
  final ChorusMusicPlayerFFIBindings _ffiBindings;
  final chorus_music_player _playerPointer;

  ChorusMusicPlayerNative._(this._ffiBindings, this._playerPointer);

  /// Create a native chorus music player instance.
  static ChorusMusicPlayerNative create(trtc_cloud cloud, String roomId) {
    final ffiBindings =
        ChorusMusicPlayerFFIBindings(LoadDynamicLib().loadTRTCSDK());
    final roomIdPtr = roomId.toNativeUtf8().cast<ffi.Char>();
    final player = ffiBindings.create(cloud, roomIdPtr);
    calloc.free(roomIdPtr);
    return ChorusMusicPlayerNative._(ffiBindings, player);
  }

  /// Get the native pointer for observer registration.
  chorus_music_player get nativePointer => _playerPointer;

  void destroy() {
    _ffiBindings.destroy(_playerPointer);
  }

  void setChorusRole(int role, TRTCParams? trtcParams) {
    if (trtcParams != null) {
      ffi.Pointer<trtc_params_t> paramsPtr =
          trtc_params_t.fromParams(trtcParams);
      _ffiBindings.setChorusRole(_playerPointer, role, paramsPtr);
      trtc_params_t.freeStruct(paramsPtr);
    } else {
      _ffiBindings.setChorusRole(_playerPointer, role, ffi.nullptr);
    }
  }

  void loadExternalMusic(ChorusExternalMusicParams params) {
    ffi.Pointer<chorus_external_music_params_t> paramsPtr =
        chorus_external_music_params_t.fromParams(params);
    _ffiBindings.loadExternalMusic(_playerPointer, paramsPtr.ref);
    chorus_external_music_params_t.freeStruct(paramsPtr);
  }

  void start() {
    _ffiBindings.start(_playerPointer);
  }

  void stop() {
    _ffiBindings.stop(_playerPointer);
  }

  void pause() {
    _ffiBindings.pause(_playerPointer);
  }

  void resume() {
    _ffiBindings.resume(_playerPointer);
  }

  void seek(int timestampMs) {
    _ffiBindings.seek(_playerPointer, timestampMs);
  }

  void switchMusicTrack(int track) {
    _ffiBindings.switchMusicTrack(_playerPointer, track);
  }

  void setPlayoutVolume(int volume) {
    _ffiBindings.setPlayoutVolume(_playerPointer, volume);
  }

  void setPublishVolume(int volume) {
    _ffiBindings.setPublishVolume(_playerPointer, volume);
  }

  void setMusicPitch(double pitch) {
    _ffiBindings.setMusicPitch(_playerPointer, pitch);
  }

  void callExperimentalAPI(String jsonStr) {
    final jsonStrPtr = jsonStr.toNativeUtf8().cast<ffi.Char>();
    _ffiBindings.callExperimentalAPI(_playerPointer, jsonStrPtr);
    calloc.free(jsonStrPtr);
  }
}
