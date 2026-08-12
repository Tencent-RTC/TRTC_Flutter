// ignore_for_file: annotate_overrides
// ignore_for_file: avoid_init_to_null
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/load_dynamic_lib.dart';
import 'package:tencent_rtc_sdk/bindings/manager/tx_audio_effect_manager_ffi_bindings.dart';
import 'package:tencent_rtc_sdk/bindings/manager/manager_observer_native.dart';
import 'package:tencent_rtc_sdk/bindings/manager/manager_struct.dart';

class TXAudioEffectManagerImpl extends TXAudioEffectManager {
  late TXAudioEffectManagerFFIBindings _audioEffectFFIBindings;
  late TXMusicPreloadObserverNative? _preloadObserverNative = null;
  late TXMusicPlayObserverNative? _playObserverNative = null;

  late TXAudioEffectManagerNativePointer _nativePointer;

  TXAudioEffectManagerImpl(TXAudioEffectManagerNativePointer nativePointer) {
    _nativePointer = nativePointer;
    _audioEffectFFIBindings =
        TXAudioEffectManagerFFIBindings(LoadDynamicLib().loadTRTCSDK());
    _preloadObserverNative = TXMusicPreloadObserverNative(_nativePointer);
    _playObserverNative = TXMusicPlayObserverNative(_nativePointer);
  }

  void destroy() {
    _preloadObserverNative?.unRegisterNativeObserver();
    _preloadObserverNative = null;
    _playObserverNative?.unRegisterNativeObserver();
    _playObserverNative = null;
  }

  void enableVoiceEarMonitor(bool enable) {
    _audioEffectFFIBindings.enable_voice_ear_monitor(_nativePointer, enable);
  }

  int getMusicCurrentPosInMS(int id) {
    return _audioEffectFFIBindings.get_current_pos_in_ms(_nativePointer, id);
  }

  int getMusicDurationInMS(String path) {
    ffi.Pointer<ffi.Char> pathPointer = path.toNativeUtf8().cast<ffi.Char>();
    int result = _audioEffectFFIBindings.get_music_duration_in_ms(
        _nativePointer, pathPointer);
    calloc.free(pathPointer);
    return result;
  }

  int getMusicTrackCount(int id) {
    return _audioEffectFFIBindings.get_music_track_count(_nativePointer, id);
  }

  void pausePlayMusic(int id) {
    _audioEffectFFIBindings.pause_play_music(_nativePointer, id);
  }

  void preloadMusic(AudioMusicParam musicParam) {
    final musicParamPointer = AudioMusicParamStruct.fromParams(musicParam);
    _audioEffectFFIBindings.preload_music(
        _nativePointer, musicParamPointer.ref);
    AudioMusicParamStruct.freeStruct(musicParamPointer);
  }

  void resumePlayMusic(int id) {
    _audioEffectFFIBindings.resume_play_music(_nativePointer, id);
  }

  void seekMusicToPosInTime(int id, int pts) {
    _audioEffectFFIBindings.seek_music_to_pos_in_time(_nativePointer, id, pts);
  }

  void setAllMusicVolume(int volume) {
    _audioEffectFFIBindings.set_all_music_volume(_nativePointer, volume);
  }

  void setMusicObserver(int musicId, TXMusicPlayObserver? observer) {
    if (observer != null) {
      _playObserverNative?.addObserver(musicId, observer);
    } else {
      _playObserverNative?.removeObserver(musicId);
    }
  }

  void setMusicPitch(int id, double pitch) {
    _audioEffectFFIBindings.set_music_pitch(_nativePointer, id, pitch);
  }

  void setMusicPlayoutVolume(int id, int volume) {
    _audioEffectFFIBindings.set_music_playout_volume(
        _nativePointer, id, volume);
  }

  void setMusicPublishVolume(int id, int volume) {
    _audioEffectFFIBindings.set_music_publish_volume(
        _nativePointer, id, volume);
  }

  void setMusicScratchSpeedRate(int id, double scratchSpeedRate) {
    _audioEffectFFIBindings.set_music_scratch_speed_rate(
        _nativePointer, id, scratchSpeedRate);
  }

  void setMusicSpeedRate(int id, double rate) {
    _audioEffectFFIBindings.set_music_speed_rate(_nativePointer, id, rate);
  }

  void setMusicTrack(int id, int trackIndex) {
    _audioEffectFFIBindings.set_music_track(_nativePointer, id, trackIndex);
  }

  void setPreloadObserver(TXMusicPreloadObserver? observer) {
    if (observer != null) {
      _preloadObserverNative?.setObserver(observer);
    } else {
      _preloadObserverNative?.removeObserver();
    }
  }

  void setVoiceCaptureVolume(int volume) {
    _audioEffectFFIBindings.set_voice_capture_volume(_nativePointer, volume);
  }

  void setVoiceChangerType(TXVoiceChangerType type) {
    _audioEffectFFIBindings.set_voice_changer_type(
        _nativePointer, type.value());
  }

  void setVoiceEarMonitorVolume(int volume) {
    _audioEffectFFIBindings.set_voice_ear_monitor_volume(
        _nativePointer, volume);
  }

  void setVoicePitch(double pitch) {
    _audioEffectFFIBindings.set_voice_pitch(_nativePointer, pitch);
  }

  void setVoiceReverbType(TXVoiceReverbType type) {
    _audioEffectFFIBindings.set_voice_reverb_type(_nativePointer, type.value());
  }

  void startPlayMusic(AudioMusicParam musicParam) {
    final musicParamPointer = AudioMusicParamStruct.fromParams(musicParam);
    _audioEffectFFIBindings.start_play_music(
        _nativePointer, musicParamPointer.ref);
    AudioMusicParamStruct.freeStruct(musicParamPointer);
  }

  void stopPlayMusic(int id) {
    _audioEffectFFIBindings.stop_play_music(_nativePointer, id);
  }
}
