// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;

import 'package:tencent_rtc_sdk/bindings/manager/manager_struct.dart';

class TXAudioEffectManagerFFIBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;
  TXAudioEffectManagerFFIBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;
  TXAudioEffectManagerFFIBindings.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName) lookup,
  ) : _lookup = lookup;

  int enable_voice_ear_monitor(
      TXAudioEffectManagerNativePointer? instance, bool enable) {
    return _enable_voice_ear_monitor(instance, enable);
  }

  late final _enable_voice_ear_monitorPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Bool)>>(
    'tx_audio_effect_manager_enable_voice_ear_monitor',
  );
  late final _enable_voice_ear_monitor = _enable_voice_ear_monitorPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, bool)>();

  int get_current_pos_in_ms(
      TXAudioEffectManagerNativePointer? instance, int music_id) {
    return _get_current_pos_in_ms(instance, music_id);
  }

  late final _get_current_pos_in_msPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int64 Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_get_current_pos_in_ms',
  );
  late final _get_current_pos_in_ms = _get_current_pos_in_msPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int get_music_duration_in_ms(
      TXAudioEffectManagerNativePointer? instance, ffi.Pointer<ffi.Char> path) {
    return _get_music_duration_in_ms(instance, path);
  }

  late final _get_music_duration_in_msPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int64 Function(
                  TXAudioEffectManagerNativePointer?, ffi.Pointer<ffi.Char>)>>(
      'tx_audio_effect_manager_get_music_duration_in_ms');
  late final _get_music_duration_in_ms =
      _get_music_duration_in_msPtr.asFunction<
          int Function(
              TXAudioEffectManagerNativePointer?, ffi.Pointer<ffi.Char>)>();

  int get_music_track_count(
      TXAudioEffectManagerNativePointer? instance, int music_id) {
    return _get_music_track_count(instance, music_id);
  }

  late final _get_music_track_countPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int64 Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_get_music_track_count',
  );
  late final _get_music_track_count = _get_music_track_countPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int pause_play_music(
      TXAudioEffectManagerNativePointer? instance, int music_id) {
    return _pause_play_music(instance, music_id);
  }

  late final _pause_play_musicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_pause_play_music',
  );
  late final _pause_play_music = _pause_play_musicPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int preload_music(
    TXAudioEffectManagerNativePointer? instance,
    AudioMusicParamStruct param,
  ) {
    return _preload_music(instance, param);
  }

  late final _preload_musicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?,
              AudioMusicParamStruct)>>('tx_audio_effect_manager_preload_music');
  late final _preload_music = _preload_musicPtr.asFunction<
      int Function(
          TXAudioEffectManagerNativePointer?, AudioMusicParamStruct)>();

  int resume_play_music(
      TXAudioEffectManagerNativePointer? instance, int music_id) {
    return _resume_play_music(instance, music_id);
  }

  late final _resume_play_musicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_resume_play_music',
  );
  late final _resume_play_music = _resume_play_musicPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int seek_music_to_pos_in_time(
      TXAudioEffectManagerNativePointer? instance, int music_id, int pts) {
    return _seek_music_to_pos_in_time(instance, music_id, pts);
  }

  late final _seek_music_to_pos_in_timePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXAudioEffectManagerNativePointer?, ffi.Int, ffi.Int)>>(
    'tx_audio_effect_manager_seek_music_to_pos_in_time',
  );
  late final _seek_music_to_pos_in_time = _seek_music_to_pos_in_timePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int, int)>();

  int set_all_music_volume(
      TXAudioEffectManagerNativePointer? instance, int volume) {
    return _set_all_music_volume(instance, volume);
  }

  late final _set_all_music_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_set_all_music_volume',
  );
  late final _set_all_music_volume = _set_all_music_volumePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int set_music_pitch(
      TXAudioEffectManagerNativePointer? instance, int music_id, double pitch) {
    return _set_music_pitch(instance, music_id, pitch);
  }

  late final _set_music_pitchPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int,
              ffi.Float)>>('tx_audio_effect_manager_set_music_pitch');
  late final _set_music_pitch = _set_music_pitchPtr.asFunction<
      int Function(TXAudioEffectManagerNativePointer?, int, double)>();

  int set_music_playout_volume(
      TXAudioEffectManagerNativePointer? instance, int music_id, int volume) {
    return _set_music_playout_volume(instance, music_id, volume);
  }

  late final _set_music_playout_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXAudioEffectManagerNativePointer?, ffi.Int, ffi.Int)>>(
    'tx_audio_effect_manager_set_music_playout_volume',
  );
  late final _set_music_playout_volume = _set_music_playout_volumePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int, int)>();

  int set_music_publish_volume(
      TXAudioEffectManagerNativePointer? instance, int music_id, int volume) {
    return _set_music_publish_volume(instance, music_id, volume);
  }

  late final _set_music_publish_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXAudioEffectManagerNativePointer?, ffi.Int, ffi.Int)>>(
    'tx_audio_effect_manager_set_music_publish_volume',
  );
  late final _set_music_publish_volume = _set_music_publish_volumePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int, int)>();

  int set_music_scratch_speed_rate(
    TXAudioEffectManagerNativePointer? instance,
    int music_id,
    double scratch_speed_rate,
  ) {
    return _set_music_scratch_speed_rate(
        instance, music_id, scratch_speed_rate);
  }

  late final _set_music_scratch_speed_ratePtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(
                  TXAudioEffectManagerNativePointer?, ffi.Int, ffi.Float)>>(
      'tx_audio_effect_manager_set_music_scratch_speed_rate');
  late final _set_music_scratch_speed_rate =
      _set_music_scratch_speed_ratePtr.asFunction<
          int Function(TXAudioEffectManagerNativePointer?, int, double)>();

  int set_music_speed_rate(TXAudioEffectManagerNativePointer? instance,
      int music_id, double speed_rate) {
    return _set_music_speed_rate(instance, music_id, speed_rate);
  }

  late final _set_music_speed_ratePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int,
              ffi.Float)>>('tx_audio_effect_manager_set_music_speed_rate');
  late final _set_music_speed_rate = _set_music_speed_ratePtr.asFunction<
      int Function(TXAudioEffectManagerNativePointer?, int, double)>();

  int set_music_track(TXAudioEffectManagerNativePointer? instance, int music_id,
      int track_index) {
    return _set_music_track(instance, music_id, track_index);
  }

  late final _set_music_trackPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(
              TXAudioEffectManagerNativePointer?, ffi.Int, ffi.Int)>>(
    'tx_audio_effect_manager_set_music_track',
  );
  late final _set_music_track = _set_music_trackPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int, int)>();

  int set_voice_capture_volume(
      TXAudioEffectManagerNativePointer? instance, int volume) {
    return _set_voice_capture_volume(instance, volume);
  }

  late final _set_voice_capture_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_set_voice_capture_volume',
  );
  late final _set_voice_capture_volume = _set_voice_capture_volumePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int set_voice_changer_type(
      TXAudioEffectManagerNativePointer? instance, int type) {
    return _set_voice_changer_type(instance, type);
  }

  late final _set_voice_changer_typePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int32)>>(
    'tx_audio_effect_manager_set_voice_changer_type',
  );
  late final _set_voice_changer_type = _set_voice_changer_typePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int set_voice_ear_monitor_volume(
      TXAudioEffectManagerNativePointer? instance, int volume) {
    return _set_voice_ear_monitor_volume(instance, volume);
  }

  late final _set_voice_ear_monitor_volumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_set_voice_ear_monitor_volume',
  );
  late final _set_voice_ear_monitor_volume = _set_voice_ear_monitor_volumePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int set_voice_pitch(
      TXAudioEffectManagerNativePointer? instance, double pitch) {
    return _set_voice_pitch(instance, pitch);
  }

  late final _set_voice_pitchPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Double)>>(
    'tx_audio_effect_manager_set_voice_pitch',
  );
  late final _set_voice_pitch = _set_voice_pitchPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, double)>();

  int set_voice_reverb_type(
      TXAudioEffectManagerNativePointer? instance, int type) {
    return _set_voice_reverb_type(instance, type);
  }

  late final _set_voice_reverb_typePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int32)>>(
    'tx_audio_effect_manager_set_voice_reverb_type',
  );
  late final _set_voice_reverb_type = _set_voice_reverb_typePtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  int start_play_music(
    TXAudioEffectManagerNativePointer? instance,
    AudioMusicParamStruct param,
  ) {
    return _start_play_music(instance, param);
  }

  late final _start_play_musicPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int Function(
                  TXAudioEffectManagerNativePointer?, AudioMusicParamStruct)>>(
      'tx_audio_effect_manager_start_play_music');
  late final _start_play_music = _start_play_musicPtr.asFunction<
      int Function(
          TXAudioEffectManagerNativePointer?, AudioMusicParamStruct)>();

  int stop_play_music(
      TXAudioEffectManagerNativePointer? instance, int music_id) {
    return _stop_play_music(instance, music_id);
  }

  late final _stop_play_musicPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int Function(TXAudioEffectManagerNativePointer?, ffi.Int)>>(
    'tx_audio_effect_manager_stop_play_music',
  );
  late final _stop_play_music = _stop_play_musicPtr
      .asFunction<int Function(TXAudioEffectManagerNativePointer?, int)>();

  void registerMusicPreloadObserver(
      int sender_port, TXAudioEffectManagerNativePointer? instance) {
    _registerMusicPreloadObserver(sender_port, instance);
  }

  late final _registerMusicPreloadObserverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, TXAudioEffectManagerNativePointer?)>>(
    'LiteavFFIRegisterMusicPreloadObserver',
  );
  late final _registerMusicPreloadObserver = _registerMusicPreloadObserverPtr
      .asFunction<void Function(int, TXAudioEffectManagerNativePointer?)>();

  void unRegisterMusicPreloadObserver(
      TXAudioEffectManagerNativePointer? instance) {
    _unRegisterMusicPreloadObserver(0, instance);
  }

  late final _unRegisterMusicPreloadObserverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, TXAudioEffectManagerNativePointer?)>>(
    'LiteavFFIUnRegisterMusicPreloadObserver',
  );
  late final _unRegisterMusicPreloadObserver =
      _unRegisterMusicPreloadObserverPtr
          .asFunction<void Function(int, TXAudioEffectManagerNativePointer?)>();

  void registerMusicPlayObserver(
    int sender_port,
    TXAudioEffectManagerNativePointer? instance,
    ffi.Pointer<ffi.Char> param,
  ) {
    _registerMusicPlayObserver(sender_port, instance, param);
  }

  late final _registerMusicPlayObserverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, TXAudioEffectManagerNativePointer?,
              ffi.Pointer<ffi.Char>)>>('LiteavFFIRegisterMusicPlayObserver');
  late final _registerMusicPlayObserver =
      _registerMusicPlayObserverPtr.asFunction<
          void Function(int, TXAudioEffectManagerNativePointer?,
              ffi.Pointer<ffi.Char>)>();

  void unRegisterMusicPlayObserver(
    TXAudioEffectManagerNativePointer? instance,
    ffi.Pointer<ffi.Char> param,
  ) {
    _unRegisterMusicPlayObserver(0, instance, param);
  }

  late final _unRegisterMusicPlayObserverPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Int64, TXAudioEffectManagerNativePointer?,
              ffi.Pointer<ffi.Char>)>>('LiteavFFIUnRegisterMusicPlayObserver');
  late final _unRegisterMusicPlayObserver =
      _unRegisterMusicPlayObserverPtr.asFunction<
          void Function(int, TXAudioEffectManagerNativePointer?,
              ffi.Pointer<ffi.Char>)>();

  ///***********************************************************************************************
  ///                                          InitDartApiDL
  /// **********************************************************************************************

  int InitDartApiDL(ffi.Pointer<ffi.Void> data) {
    return _InitDartApiDL(data);
  }

  late final _InitDartApiDLPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
    'LiteavFFIInitApiDL',
  );
  late final _InitDartApiDL =
      _InitDartApiDLPtr.asFunction<int Function(ffi.Pointer<ffi.Void>)>();
}

/// A port is used to send or receive inter-isolate messages
typedef TXAudioEffectManagerNativePointer = ffi.Pointer<ffi.Void>;
