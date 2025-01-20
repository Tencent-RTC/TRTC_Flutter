import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'trtc_cloud_def.dart';

/// Music and voice settings APIs for the TRTC video call feature
class TXAudioEffectManager {
  static late MethodChannel _channel;

  TRTCCloudListenerWrapper? _listener;

  TXAudioEffectManager(channel, listener) {
    _channel = channel;
    _listener = listener;
  }

  /// Enable in-ear monitoring
  ///
  /// After in-ear monitoring is enabled, the local user can hear their own voice.
  ///
  /// **Note:** this API takes effect only if the user wears headphones. Currently, only some models with a short voice capturing delay are supported
  ///
  /// **Parameters:**
  ///
  /// `enable` `true`: enabled; `false`: disabled
  ///
  /// **Platform not supported:**
  /// - web
  /// - Windows
  Future<void> enableVoiceEarMonitor(bool enable) {
    return _channel.invokeMethod('enableVoiceEarMonitor', {"enable": enable});
  }

  /// Set the in-ear monitoring volume
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. Value range: `0`–`100`. Default value: `100`
  ///
  /// **Platform not supported:**
  /// - web
  /// - Windows
  Future<void> setVoiceEarMonitorVolume(int volume) {
    return _channel
        .invokeMethod('setVoiceEarMonitorVolume', {"volume": volume});
  }

  /// Set the voice reverb effect (karaoke room, small room, big hall, deep, resonant, and other effects)
  ///
  /// **Parameters:**
  ///
  /// Default value: [TXVoiceReverbType.TXLiveVoiceReverbType_0]. For more information, please see the definition of the [TXVoiceReverbType] parameter in `trtc_cloud_def`
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setVoiceReverbType(int type) {
    return _channel.invokeMethod('setVoiceReverbType', {"type": type});
  }

  /// Set the voice changing effect (young girl, middle-aged man, heavy metal, punk, and other effects)
  ///
  /// **Parameters:**
  ///
  /// Default value: [TXVoiceChangerType.TXLiveVoiceChangerType_0]. For more information, please see the definition of the [TXVoiceChangerType] parameter in `trtc_cloud_def`
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setVoiceChangerType(int type) {
    return _channel.invokeMethod('setVoiceChangerType', {"type": type});
  }

  /// Set the mic voice volume
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. `1` is the normal volume. Value range: floating point number between `[0,100]`
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setVoiceCaptureVolume(int volume) {
    return _channel.invokeMethod('setVoiceCaptureVolume', {"volume": volume});
  }

  /// Start background music
  ///
  /// You must assign an ID to each music track, through which you can start, stop, or set the volume of the music track.
  ///
  /// **Note:** to play back multiple music tracks at the same time, assign different IDs to them. If you use the same ID for different music tracks, the SDK cannot play them back at the same time. Instead, it stops playing back the old music track and then starts playing back the new one.
  ///
  /// **Parameters:**
  ///
  /// `musicParam` Music parameter. For more information, please see the definition of the [AudioMusicParam] parameter in `trtc_cloud_def`
  ///
  /// **Returned value**:
  ///
  /// `true`: success; `false`: failure
  ///
  /// **Platform not supported:**
  /// - web
  Future<bool?> startPlayMusic(AudioMusicParam musicParam) {
    return _channel
        .invokeMethod('startPlayMusic', {"musicParam": jsonEncode(musicParam)});
  }

  /// Stop background music
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> stopPlayMusic(int id) {
    return _channel.invokeMethod('stopPlayMusic', {"id": id});
  }

  /// Pause background music
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> pausePlayMusic(int id) {
    return _channel.invokeMethod('pausePlayMusic', {"id": id});
  }

  /// Resume background music
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> resumePlayMusic(int id) {
    return _channel.invokeMethod('resumePlayMusic', {"id": id});
  }

  /// Set the remote volume of background music. The anchor can use this API to set the volume of background music heard by the remote audience.
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// `volume` Volume. `100` is the normal volume. Value range: `0`–`100`. Default value: `100`
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setMusicPublishVolume(int id, int volume) {
    return _channel
        .invokeMethod('setMusicPublishVolume', {"id": id, "volume": volume});
  }

  /// Set the local volume of background music. The anchor can use this API to set the volume of local background music.
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// `volume` Volume. `100` is the normal volume. Value range: `0`–`100`. Default value: `100`
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setMusicPlayoutVolume(int id, int volume) {
    return _channel
        .invokeMethod('setMusicPlayoutVolume', {"id": id, "volume": volume});
  }

  /// Set the local and remote volumes of global background music
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. `100` is the normal volume. Value range: `0`–`100`. Default value: `100`
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setAllMusicVolume(int volume) {
    return _channel.invokeMethod('setAllMusicVolume', {"volume": volume});
  }

  /// Adjust the pitch of background music
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// `pitch` Pitch. Default value: `0.0f`. Value range: floating point number between `[-1,1]`;
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setMusicPitch(int id, double pitch) {
    return _channel
        .invokeMethod('setMusicPitch', {"id": id, "pitch": pitch.toString()});
  }

  /// Adjust the speed of background music
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// `speedRate` Speed. Default value: `1.0f`. Value range: floating point between `[0.5,2]`;
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> setMusicSpeedRate(int id, double speedRate) {
    return _channel.invokeMethod(
        'setMusicSpeedRate', {"id": id, "speedRate": speedRate.toString()});
  }

  /// Get the current playback progress of background music in milliseconds
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// **Returned value**: the current playback time in milliseconds will be returned if this API is successfully called; otherwise, `-1` will be returned
  ///
  /// **Platform not supported:**
  /// - web
  Future<int?> getMusicCurrentPosInMS(int id) {
    return _channel.invokeMethod('getMusicCurrentPosInMS', {"id": id});
  }

  /// Set the playback progress of background music in milliseconds
  ///
  /// **Note:** do not call this API frequently, as this API may repeatedly read and write the music file, which is time-consuming. When this API is used together with the progress bar, call this API in the callback triggered after the progress bar is dragged. Do not call this API when the progress bar is being dragged.
  ///
  /// **Parameters:**
  ///
  /// `id` Music track ID
  ///
  /// `pts`	Unit: ms
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> seekMusicToPosInMS(int id, int pts) {
    return _channel.invokeMethod('seekMusicToPosInMS', {"id": id, "pts": pts});
  }

  /// Get the total duration of the background music file in milliseconds
  ///
  /// **Parameters:**
  ///
  /// path Path of the music file. If the `path` parameter is empty, the duration of the music file being played back will be returned.
  ///
  /// **Returned value**: the music duration will be returned if this API is successfully called; otherwise, `-1` will be returned
  ///
  /// **Platform not supported:**
  /// - web
  Future<int?> getMusicDurationInMS(String path) {
    return _channel.invokeMethod('getMusicDurationInMS', {"path": path});
  }

  /// Set the pitch of the voice
  ///
  /// **Parameters:**
  ///
  /// `pitch` Pitch. Default value: `0.0f`. Value range: floating point between `[-1.0,1.0]`;
  ///
  /// **Platform not supported:**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> setVoicePitch(double pitch) {
    return _channel.invokeMethod('setVoicePitch', {"pitch": pitch});
  }

  /// Preload background music
  ///
  /// You must assign an ID to each music track so that you can start, stop, or set the volume of music tracks by ID.
  ///
  /// **Parameters:**
  ///
  /// `preloadParam` Preload parameter
  ///
  /// 'observer' For more information, please see the APIs defined in  TXMusicPreloadObserver .
  ///
  /// **Platform not supported:**
  /// - web
  Future<void> preloadMusic(AudioMusicParam preloadParam, TXMusicPreloadObserver? observer) {
    _listener!.setPreloadObserver(observer);
    return _channel.invokeMethod('preloadMusic', { "preloadParam": jsonEncode(preloadParam), });
  }
}
