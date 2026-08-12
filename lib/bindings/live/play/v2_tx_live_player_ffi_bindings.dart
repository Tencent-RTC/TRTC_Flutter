// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;

class V2TXLivePlayerFFIBindings {
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;
  V2TXLivePlayerFFIBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;
  V2TXLivePlayerFFIBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ///***********************************************************************************************
  ///                                          V2TXLivePlayer
  /// **********************************************************************************************
  ffi.Pointer<V2TXLivePlayerNativePointer> createPlayer() {
    return _createPlayer();
  }

  late final _createPlayerPtr = _lookup<
          ffi
          .NativeFunction<ffi.Pointer<V2TXLivePlayerNativePointer> Function()>>(
      'create_v2tx_live_player');
  late final _createPlayer = _createPlayerPtr
      .asFunction<ffi.Pointer<V2TXLivePlayerNativePointer> Function()>();

  ffi.Pointer<V2TXLivePlayerNativePointer> createByIdentifier(
      ffi.Pointer<ffi.Int8> identifier) {
    return _createByIdentifier(identifier);
  }

  late final _createByIdentifierPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<V2TXLivePlayerNativePointer> Function(
              ffi.Pointer<ffi.Int8>)>>('create_v2tx_live_player_by_identifier');
  late final _createByIdentifier = _createByIdentifierPtr.asFunction<
      ffi.Pointer<V2TXLivePlayerNativePointer> Function(
          ffi.Pointer<ffi.Int8>)>();

  int releasePlayer(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _releasePlayer(player);
  }

  late final _releasePlayerPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'release_v2tx_live_player');
  late final _releasePlayer = _releasePlayerPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int startPlay(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      ffi.Pointer<ffi.Int8> url) {
    return _startPlay(player, url);
  }

  late final _startPlayPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Pointer<ffi.Int8>)>>('v2tx_live_player_start_play');
  late final _startPlay = _startPlayPtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePlayerNativePointer>, ffi.Pointer<ffi.Int8>)>();

  int stopPlay(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _stopPlay(player);
  }

  late final _stopPlayPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_stop_play');
  late final _stopPlay = _stopPlayPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int isPlaying(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _isPlaying(player);
  }

  late final _isPlayingPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_is_playing');
  late final _isPlaying = _isPlayingPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int pauseAudio(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _pauseAudio(player);
  }

  late final _pauseAudioPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_pause_audio');
  late final _pauseAudio = _pauseAudioPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int resumeAudio(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _resumeAudio(player);
  }

  late final _resumeAudioPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_resume_audio');
  late final _resumeAudio = _resumeAudioPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int pauseVideo(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _pauseVideo(player);
  }

  late final _pauseVideoPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_pause_video');
  late final _pauseVideo = _pauseVideoPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int resumeVideo(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _resumeVideo(player);
  }

  late final _resumeVideoPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_resume_video');
  late final _resumeVideo = _resumeVideoPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int switchStream(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      ffi.Pointer<ffi.Int8> url) {
    return _switchStream(player, url);
  }

  late final _switchStreamPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Pointer<ffi.Int8>)>>('v2tx_live_player_switch_stream');
  late final _switchStream = _switchStreamPtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePlayerNativePointer>, ffi.Pointer<ffi.Int8>)>();

  int setRenderViewID(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      ffi.Pointer<ffi.Void> viewPointer) {
    return _setRenderView(player, viewPointer);
  }

  late final _setRenderViewPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Pointer<ffi.Void>)>>('v2tx_live_player_set_render_view');
  late final _setRenderView = _setRenderViewPtr.asFunction<
      int Function(
          ffi.Pointer<V2TXLivePlayerNativePointer>, ffi.Pointer<ffi.Void>)>();

  int setPlayoutVolume(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, int volume) {
    return _setPlayoutVolume(player, volume);
  }

  late final _setPlayoutVolumePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Int32)>>('v2tx_live_player_set_playout_volume');
  late final _setPlayoutVolume = _setPlayoutVolumePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, int)>();

  int setCacheParams(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      double minTime, double maxTime) {
    return _setCacheParams(player, minTime, maxTime);
  }

  late final _setCacheParamsPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Float, ffi.Float)>>('v2tx_live_player_set_cache_params');
  late final _setCacheParams = _setCacheParamsPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, double, double)>();

  int setRenderRotation(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, int rotation) {
    return _setRenderRotation(player, rotation);
  }

  late final _setRenderRotationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Int32)>>('v2tx_live_player_set_render_rotation');
  late final _setRenderRotation = _setRenderRotationPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, int)>();

  int setRenderFillMode(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, int mode) {
    return _setRenderFillMode(player, mode);
  }

  late final _setRenderFillModePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Int32)>>('v2tx_live_player_set_render_fill_mode');
  late final _setRenderFillMode = _setRenderFillModePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, int)>();

  int setProperty(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      ffi.Pointer<ffi.Int8> key, ffi.Pointer<ffi.Void> value) {
    return _setProperty(player, key, value);
  }

  late final _setPropertyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Pointer<ffi.Int8>,
              ffi.Pointer<ffi.Void>)>>('v2tx_live_player_set_property');
  late final _setProperty = _setPropertyPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
          ffi.Pointer<ffi.Int8>, ffi.Pointer<ffi.Void>)>();

  int enableReceiveSeiMessage(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      bool enable, int payloadType) {
    return _enableReceiveSeiMessage(player, enable, payloadType);
  }

  late final _enableReceiveSeiMessagePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>, ffi.Bool,
              ffi.Int32)>>('v2tx_live_player_enable_receive_sei_message');
  late final _enableReceiveSeiMessage = _enableReceiveSeiMessagePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, bool, int)>();

  int enableVolumeEvaluation(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, int intervalMs) {
    return _enableVolumeEvaluation(player, intervalMs);
  }

  late final _enableVolumeEvaluationPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Int32)>>('v2tx_live_player_enable_volume_evaluation');
  late final _enableVolumeEvaluation = _enableVolumeEvaluationPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, int)>();

  int enableObserveVideoFrame(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      bool enable, int pixelFormat, int bufferType) {
    return _enableObserveVideoFrame(player, enable, pixelFormat, bufferType);
  }

  late final _enableObserveVideoFramePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Bool,
              ffi.Int32,
              ffi.Int32)>>('v2tx_live_player_enable_observer_video_frame');
  late final _enableObserveVideoFrame = _enableObserveVideoFramePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, bool, int, int)>();

  int showDebugView(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, bool isShow) {
    return _showDebugView(player, isShow);
  }

  late final _showDebugViewPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Bool)>>('v2tx_live_player_show_debug_view');
  late final _showDebugView = _showDebugViewPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, bool)>();

  int snapshot(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _snapshot(player);
  }

  late final _snapshotPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_snapshot');
  late final _snapshot = _snapshotPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  int enablePictureInPicture(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, bool enable) {
    return _enablePictureInPicture(player, enable);
  }

  late final _enablePictureInPicturePtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Bool)>>('v2tx_live_player_enable_picture_in_picture');
  late final _enablePictureInPicture = _enablePictureInPicturePtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>, bool)>();

  int startLocalRecording(ffi.Pointer<V2TXLivePlayerNativePointer> player,
      ffi.Pointer<ffi.Int8> filePath, int recordType, int interval) {
    return _startLocalRecording(player, filePath, recordType, interval);
  }

  late final _startLocalRecordingPtr = _lookup<
      ffi.NativeFunction<
          ffi.Int32 Function(
              ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Pointer<ffi.Int8>,
              ffi.Int32,
              ffi.Int32)>>('v2tx_live_player_start_local_recording');
  late final _startLocalRecording = _startLocalRecordingPtr.asFunction<
      int Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
          ffi.Pointer<ffi.Int8>, int, int)>();

  int stopLocalRecording(ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    return _stopLocalRecording(player);
  }

  late final _stopLocalRecordingPtr = _lookup<
          ffi.NativeFunction<
              ffi.Int32 Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'v2tx_live_player_stop_local_recording');
  late final _stopLocalRecording = _stopLocalRecordingPtr
      .asFunction<int Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  void registerPlayerListener(
      int sender_port, ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    _registerPlayerListener(sender_port, player);
  }

  late final _registerPlayerListenerPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(
                  ffi.Int64, ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'LiteavFFIRegisterPlayerListener');
  late final _registerPlayerListener = _registerPlayerListenerPtr.asFunction<
      void Function(int, ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  void unRegisterPlayerListener(
      ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    _unRegisterPlayerListener(player);
  }

  late final _unRegisterPlayerListenerPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'LiteavFFIUnRegisterPlayerListener');
  late final _unRegisterPlayerListener = _unRegisterPlayerListenerPtr
      .asFunction<void Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  void registerPlayerVideoRenderListener(
      ffi.Pointer<V2TXLivePlayerNativePointer> player, int sender_port) {
    _registerPlayerVideoRenderListener(player, sender_port);
  }

  late final _registerPlayerVideoRenderListenerPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(ffi.Pointer<V2TXLivePlayerNativePointer>,
              ffi.Int64)>>('LiteavFFIRegisterPlayerVideoRenderCallback');
  late final _registerPlayerVideoRenderListener =
      _registerPlayerVideoRenderListenerPtr.asFunction<
          void Function(ffi.Pointer<V2TXLivePlayerNativePointer>, int)>();

  void unRegisterPlayerVideoRenderListener(
      ffi.Pointer<V2TXLivePlayerNativePointer> player) {
    _unRegisterPlayerVideoRenderListener(player);
  }

  late final _unRegisterPlayerVideoRenderListenerPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>>(
      'LiteavFFIUnRegisterPlayerVideoRenderCallback');
  late final _unRegisterPlayerVideoRenderListener =
      _unRegisterPlayerVideoRenderListenerPtr.asFunction<
          void Function(ffi.Pointer<V2TXLivePlayerNativePointer>)>();

  ///***********************************************************************************************
  ///                                          InitDartApiDL
  /// **********************************************************************************************

  int InitDartApiDL(
    ffi.Pointer<ffi.Void> data,
  ) {
    return _InitDartApiDL(
      data,
    );
  }

  late final _InitDartApiDLPtr =
      _lookup<ffi.NativeFunction<ffi.IntPtr Function(ffi.Pointer<ffi.Void>)>>(
          'LiteavFFIInitApiDL');
  late final _InitDartApiDL =
      _InitDartApiDLPtr.asFunction<int Function(ffi.Pointer<ffi.Void>)>();
}

/// A port is used to send or receive inter-isolate messages
typedef V2TXLivePlayerNativePointer = ffi.Pointer<ffi.Void>;
