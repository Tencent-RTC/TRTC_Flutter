import 'dart:ffi' as ffi;

import 'package:tencent_rtc_sdk/bindings/chorus_music_player/chorus_music_player_struct.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_struct.dart';

/// FFI bindings for chorus_music_player C API.
class ChorusMusicPlayerFFIBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  ChorusMusicPlayerFFIBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  // --- Create / Destroy ---

  chorus_music_player create(trtc_cloud cloud, ffi.Pointer<ffi.Char> roomId) {
    return _create(cloud, roomId);
  }

  late final _createPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Void> Function(trtc_cloud,
              ffi.Pointer<ffi.Char>)>>('chorus_music_player_create');
  late final _create = _createPtr.asFunction<
      ffi.Pointer<ffi.Void> Function(trtc_cloud, ffi.Pointer<ffi.Char>)>();

  void destroy(chorus_music_player player) {
    _destroy(player);
  }

  late final _destroyPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'chorus_music_player_destroy');
  late final _destroy =
      _destroyPtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  // --- Set Chorus Role ---

  void setChorusRole(chorus_music_player player, int role,
      ffi.Pointer<trtc_params_t> trtcParams) {
    _setChorusRole(player, role, trtcParams);
  }

  late final _setChorusRolePtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<ffi.Void>, ffi.Int, ffi.Pointer<trtc_params_t>)>>(
      'chorus_music_player_set_chorus_role');
  late final _setChorusRole = _setChorusRolePtr.asFunction<
      void Function(ffi.Pointer<ffi.Void>, int, ffi.Pointer<trtc_params_t>)>();

  // --- Load External Music ---

  void loadExternalMusic(
      chorus_music_player player, chorus_external_music_params_t params) {
    _loadExternalMusic(player, params);
  }

  late final _loadExternalMusicPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Pointer<ffi.Void>, chorus_external_music_params_t)>>(
      'chorus_music_player_load_external_music');
  late final _loadExternalMusic = _loadExternalMusicPtr.asFunction<
      void Function(ffi.Pointer<ffi.Void>, chorus_external_music_params_t)>();

  // --- Playback Controls ---

  void start(chorus_music_player player) {
    _start(player);
  }

  late final _startPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'chorus_music_player_start');
  late final _start =
      _startPtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  void stop(chorus_music_player player) {
    _stop(player);
  }

  late final _stopPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'chorus_music_player_stop');
  late final _stop =
      _stopPtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  void pause(chorus_music_player player) {
    _pause(player);
  }

  late final _pausePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'chorus_music_player_pause');
  late final _pause =
      _pausePtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  void resume(chorus_music_player player) {
    _resume(player);
  }

  late final _resumePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
          'chorus_music_player_resume');
  late final _resume =
      _resumePtr.asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  // --- Seek ---

  void seek(chorus_music_player player, int timestampMs) {
    _seek(player, timestampMs);
  }

  late final _seekPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int64)>>(
      'chorus_music_player_seek');
  late final _seek =
      _seekPtr.asFunction<void Function(ffi.Pointer<ffi.Void>, int)>();

  // --- Switch Music Track ---

  void switchMusicTrack(chorus_music_player player, int track) {
    _switchMusicTrack(player, track);
  }

  late final _switchMusicTrackPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int)>>(
      'chorus_music_player_switch_music_track');
  late final _switchMusicTrack = _switchMusicTrackPtr
      .asFunction<void Function(ffi.Pointer<ffi.Void>, int)>();

  // --- Volume Controls ---

  void setPlayoutVolume(chorus_music_player player, int volume) {
    _setPlayoutVolume(player, volume);
  }

  late final _setPlayoutVolumePtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int32)>>(
      'chorus_music_player_set_playout_volume');
  late final _setPlayoutVolume = _setPlayoutVolumePtr
      .asFunction<void Function(ffi.Pointer<ffi.Void>, int)>();

  void setPublishVolume(chorus_music_player player, int volume) {
    _setPublishVolume(player, volume);
  }

  late final _setPublishVolumePtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Int32)>>(
      'chorus_music_player_set_publish_volume');
  late final _setPublishVolume = _setPublishVolumePtr
      .asFunction<void Function(ffi.Pointer<ffi.Void>, int)>();

  // --- Music Pitch ---

  void setMusicPitch(chorus_music_player player, double pitch) {
    _setMusicPitch(player, pitch);
  }

  late final _setMusicPitchPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Float)>>(
      'chorus_music_player_set_music_pitch');
  late final _setMusicPitch = _setMusicPitchPtr
      .asFunction<void Function(ffi.Pointer<ffi.Void>, double)>();

  // --- Experimental API ---

  void callExperimentalAPI(
      chorus_music_player player, ffi.Pointer<ffi.Char> jsonStr) {
    _callExperimentalAPI(player, jsonStr);
  }

  late final _callExperimentalAPIPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>)>>(
      'chorus_music_player_call_experimental_api');
  late final _callExperimentalAPI = _callExperimentalAPIPtr.asFunction<
      void Function(ffi.Pointer<ffi.Void>, ffi.Pointer<ffi.Char>)>();

  // --- Observer Registration ---

  int registerChorusPlayerObserver(int sendPort, ffi.Pointer<ffi.Void> player) {
    return _registerChorusPlayerObserver(sendPort, player);
  }

  late final _registerChorusPlayerObserverPtr = _lookup<
          ffi
          .NativeFunction<ffi.Int Function(ffi.Int64, ffi.Pointer<ffi.Void>)>>(
      'LiteavFFIRegisterChorusPlayerObserver');
  late final _registerChorusPlayerObserver = _registerChorusPlayerObserverPtr
      .asFunction<int Function(int, ffi.Pointer<ffi.Void>)>();

  int unRegisterChorusPlayerObserver(
      int sendPort, ffi.Pointer<ffi.Void> player) {
    return _unRegisterChorusPlayerObserver(sendPort, player);
  }

  late final _unRegisterChorusPlayerObserverPtr = _lookup<
          ffi
          .NativeFunction<ffi.Int Function(ffi.Int64, ffi.Pointer<ffi.Void>)>>(
      'LiteavFFIUnRegisterChorusPlayerObserver');
  late final _unRegisterChorusPlayerObserver =
      _unRegisterChorusPlayerObserverPtr
          .asFunction<int Function(int, ffi.Pointer<ffi.Void>)>();
}
