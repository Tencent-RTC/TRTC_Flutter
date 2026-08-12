// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: annotate_overrides
// ignore_for_file: unintended_html_in_doc_comment
part of 'super_player.dart';

class TXVodPlayerController extends ChangeNotifier
    implements ValueListenable<TXPlayerValue?>, TXPlayerController {
  int? _playerId = -1;
  static String kTag = "TXVodPlayerController";

  /// MethodChannel wrapper (replaces the original Pigeon API).
  VodMethodChannel? _mc;
  final Completer<int> _initPlayer;
  bool _isDisposed = false;
  bool _isNeedDisposed = false;
  TXPlayerValue? _value;
  TXPlayerState? _state;
  TXPlayerState? get playState => _state;

  @override
  get value => _value;

  set value(TXPlayerValue? val) {
    if (_value == val) return;
    _value = val;
    notifyListeners();
  }

  double? resizeVideoWidth = 0;
  double? resizeVideoHeight = 0;
  double? videoLeft = 0;
  double? videoTop = 0;
  double? videoRight = 0;
  double? videoBottom = 0;

  final StreamController<TXPlayerState?> _stateStreamController =
      StreamController.broadcast();
  final StreamController<Map<dynamic, dynamic>> _eventStreamController =
      StreamController.broadcast();
  final StreamController<Map<dynamic, dynamic>> _netStatusStreamController =
      StreamController.broadcast();

  /// Playback state listener.
  /// @see TXPlayerState
  Stream<TXPlayerState?> get onPlayerState => _stateStreamController.stream;

  /// Playback event listener.
  /// @see https://cloud.tencent.com/document/product/454/7886
  Stream<Map<dynamic, dynamic>> get onPlayerEventBroadcast =>
      _eventStreamController.stream;

  /// VOD player network status callback.
  /// @see https://cloud.tencent.com/document/product/454/7886
  Stream<Map<dynamic, dynamic>> get onPlayerNetStatusBroadcast =>
      _netStatusStreamController.stream;

  TXVodPlayerController({bool? onlyAudio}) : _initPlayer = Completer() {
    _value = TXPlayerValue.uninitialized();
    _state = _value!.state;
    _create(onlyAudio: onlyAudio);
  }

  Future<void> _create({bool? onlyAudio}) async {
    _playerId = await SuperPlayerPlugin.createVodPlayer(onlyAudio: onlyAudio);
    _mc = VodMethodChannel(_playerId ?? -1);
    // Register event callback; VodEventDispatcher dispatches events by playerId.
    VodEventDispatcher.instance
        .registerPlayer(_playerId ?? -1, _handleNativeEvent);
    _initPlayer.complete(_playerId);
  }

  /// Unified entry for native events, separated by isNetEvent.
  void _handleNativeEvent(Map event, bool isNetEvent) {
    if (isNetEvent) {
      onNetEvent(event);
    } else {
      onPlayerEvent(event);
    }
  }

  _changeState(TXPlayerState playerState) {
    value = _value!.copyWith(state: playerState);
    _state = value!.state;
    _stateStreamController.add(_state);
  }

  void printVersionInfo() async {
    LogUtils.d(kTag, "dart SDK version:${Platform.version}");
    LogUtils.d(
        kTag, "liteAV SDK version:${await SuperPlayerPlugin.platformVersion}");
    LogUtils.d(
        kTag, "superPlayer SDK version:${FPlayerPckInfo.PLAYER_VERSION}");
  }

  /// Starting from version 10.7, the method `startPlay` has been changed to `startVodPlay` for playing videos via a URL.
  /// To play videos successfully, it is necessary to set the license by using the method `SuperPlayerPlugin#setGlobalLicense`.
  /// Failure to set the license will result in video playback failure (a black screen).
  /// Live streaming, short video, and video playback licenses can all be used. If you do not have any of the above licenses,
  /// you can apply for a free trial license to play videos normally[Quickly apply for a free trial version Licence]
  /// (https://cloud.tencent.com/act/event/License).Official licenses can be purchased
  /// (https://cloud.tencent.com/document/product/881/74588).
  ///
  /// @param url video playback address
  /// @return whether the playback starts successfully
  Future<bool> startVodPlay(String url) async {
    if (_isNeedDisposed) return false;
    await _initPlayer.future;
    _changeState(TXPlayerState.buffering);
    printVersionInfo();
    final result = await _mc!.invoke<bool>('startVodPlay', {'value': url});
    return result ?? false;
  }

  /// Starting from version 10.7, the method "startPlayWithParams" has been changed to "startVodPlayWithParams" for playing videos using fileId.
  /// To play the video successfully, you need to set the Licence using "SuperPlayerPlugin#setGlobalLicense" method before playing the video.
  /// If you do not set the Licence, the video will not play (black screen). The Licence for live streaming,
  /// short video, and video playback can all be used. If you have not obtained the Licence, you can apply for a free trial version [here]
  /// (https://cloud.tencent.com/act/event/License) for normal playback. To use the official version, you need to [purchase]
  /// (https://cloud.tencent.com/document/product/881/74588).
  ///
  /// @param params see [TXPlayInfoParams]
  Future<void> startVodPlayWithParams(TXPlayInfoParams params) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    _changeState(TXPlayerState.buffering);
    printVersionInfo();
    await _mc!.invoke<void>('startVodPlayWithParams', params.toMap());
  }

  Future<void> startPlayDrm(TXPlayerDrmBuilder drmBuilder) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    _changeState(TXPlayerState.buffering);
    printVersionInfo();
    await _mc!.invoke<void>('startPlayDrm', drmBuilder.toMap());
  }

  /// Initialize the player, which creates a shared texture and initializes the player.
  /// @param onlyAudio whether to use pure audio mode
  @override
  @Deprecated("this method call will no longer be effective")
  Future<void> initialize({bool? onlyAudio}) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    _changeState(TXPlayerState.paused);
  }

  /// Set autoplay.
  Future<void> setAutoPlay({bool? isAutoPlay}) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setAutoPlay', {'value': isAutoPlay ?? false});
  }

  /// Stop playback.
  /// @return whether the stop succeeded
  @override
  Future<bool> stop({bool isNeedClear = false}) async {
    if (_isNeedDisposed) return false;
    await _initPlayer.future;
    final result = await _mc!.invoke<bool>('stop', {'value': isNeedClear});
    _changeState(TXPlayerState.stopped);
    return result ?? false;
  }

  /// Whether the video is currently playing.
  @override
  Future<bool> isPlaying() async {
    if (_isNeedDisposed) return false;
    await _initPlayer.future;
    final result = await _mc!.invoke<bool>('isPlaying');
    return result ?? false;
  }

  /// Pause playback. Must be called after the player has started playing.
  @override
  Future<void> pause() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('pause');
    _changeState(TXPlayerState.paused);
  }

  /// Resume playback. Should be called when the player is paused.
  @override
  Future<void> resume() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('resume');
  }

  /// Set mute.
  @override
  Future<void> setMute(bool mute) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setMute', {'value': mute});
  }

  /// Set loop playback.
  Future<void> setLoop(bool loop) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setLoop', {'value': loop});
  }

  /// Seek to the specified playback position and start playing.
  /// @param progress target playback time in seconds
  Future<void> seek(double progress) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('seek', {'value': progress});
  }

  /// Only supported by Player_Premium (requires the mobile premium license).
  /// Jump to the specified PDT time point of the video stream, enabling fast forward, fast rewind, and progress bar seeking.
  /// Supported since Player Premium 11.6.
  /// @param pdtTimeMs video stream PDT time point, in milliseconds
  Future<void> seekToPdtTime(int pdtTimeMs) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('seekToPdtTime', {'value': pdtTimeMs});
  }

  /// Set the playback speed. Default is 1.
  Future<void> setRate(double rate) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setRate', {'value': rate});
  }

  /// Get the bitrate information extracted from the playing video.
  /// Each bitrate item contains:
  ///   index:   bitrate index
  ///   width:   video width of this bitrate
  ///   height:  video height of this bitrate
  ///   bitrate: bitrate value
  Future<List?> getSupportedBitrates() async {
    if (_isNeedDisposed) return [];
    await _initPlayer.future;
    final result = await _mc!.invokeList('getSupportedBitrate');
    return result;
  }

  /// Get the index of the current bitrate setting.
  Future<int> getBitrateIndex() async {
    if (_isNeedDisposed) return -1;
    await _initPlayer.future;
    final result = await _mc!.invoke<int>('getBitrateIndex');
    return result ?? -1;
  }

  /// Set the bitrate index.
  Future<void> setBitrateIndex(int index) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setBitrateIndex', {'value': index});
  }

  /// Set the start time of the playback, in seconds.
  Future<void> setStartTime(double startTime) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setStartTime', {'value': startTime});
  }

  /// Set the playback volume. Range: 0-100.
  Future<void> setAudioPlayoutVolume(int volume) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setAudioPlayOutVolume', {'value': volume});
  }

  /// Request audio focus.
  Future<bool> setRequestAudioFocus(bool focus) async {
    if (_isNeedDisposed) return false;
    await _initPlayer.future;
    final result =
        await _mc!.invoke<bool>('setRequestAudioFocus', {'value': focus});
    return result ?? false;
  }

  /// Release player resources.
  Future<void> _release() async {
    await _initPlayer.future;
    await SuperPlayerPlugin.releasePlayer(_playerId);
  }

  /// Set player configuration.
  /// @see [FTXVodPlayConfig]
  Future<void> setConfig(FTXVodPlayConfig config) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setConfig', config.toMap());
  }

  /// Get the current playback time, in seconds.
  Future<double> getCurrentPlaybackTime() async {
    if (_isNeedDisposed) return 0;
    await _initPlayer.future;
    final result = await _mc!.invoke<double>('getCurrentPlaybackTime');
    return result ?? 0;
  }

  /// Get the buffered duration of the current video.
  Future<double> getBufferDuration() async {
    if (_isNeedDisposed) return 0;
    await _initPlayer.future;
    final result = await _mc!.invoke<double>('getBufferDuration');
    return result ?? 0;
  }

  /// Get the playable duration of the current video.
  Future<double> getPlayableDuration() async {
    if (_isNeedDisposed) return 0;
    await _initPlayer.future;
    final result = await _mc!.invoke<double>('getPlayableDuration');
    return result ?? 0;
  }

  /// Get the width of the currently playing video.
  Future<int> getWidth() async {
    if (_isNeedDisposed) return 0;
    await _initPlayer.future;
    final result = await _mc!.invoke<int>('getWidth');
    return result ?? 0;
  }

  /// Get the height of the currently playing video.
  Future<int> getHeight() async {
    if (_isNeedDisposed) return 0;
    await _initPlayer.future;
    final result = await _mc!.invoke<int>('getHeight');
    return result ?? 0;
  }

  /// Set the token used for playing the video.
  Future<void> setToken(String? token) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setToken', {'value': token});
  }

  /// Whether loop playback is enabled.
  Future<bool> isLoop() async {
    if (_isNeedDisposed) return false;
    await _initPlayer.future;
    final result = await _mc!.invoke<bool>('isLoop');
    return result ?? false;
  }

  /// Enable or disable hardware decoding.
  @override
  Future<bool> enableHardwareDecode(bool enable) async {
    if (_isNeedDisposed) return false;
    await _initPlayer.future;
    final result =
        await _mc!.invoke<bool>('enableHardwareDecode', {'value': enable});
    return result ?? false;
  }

  /// To enter Picture-in-Picture mode, you need to adapt the interface for Picture-in-Picture mode.
  /// On Android, this feature is only supported on devices running Android 7.0 or higher.
  /// <h1>
  /// Due to Android system limitations, the size of the icon passed cannot exceed 1MB, otherwise it will not be displayed.
  /// </h1>
  /// @param backIcon playIcon pauseIcon forwardIcon the icons for rewind, play, pause and fast-forward. If not passed the system
  ///     default icons will be used. Only Flutter local resource images are supported, e.g. images/back_icon.png.
  @override
  Future<int> enterPictureInPictureMode(
      {String? backIconForAndroid,
      String? playIconForAndroid,
      String? pauseIconForAndroid,
      String? forwardIconForAndroid}) async {
    if (_isNeedDisposed) return -1;
    await _initPlayer.future;
    final result = await _mc!.invoke<int>('enterPictureInPictureMode', {
      'backIconForAndroid': backIconForAndroid,
      'playIconForAndroid': playIconForAndroid,
      'pauseIconForAndroid': pauseIconForAndroid,
      'forwardIconForAndroid': forwardIconForAndroid,
    });
    return result ?? -1;
  }

  Future<void> initImageSprite(String? vvtUrl, List<String>? imageUrls) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('initImageSprite', {
      'vvtUrl': vvtUrl,
      'imageUrls': imageUrls,
    });
  }

  Future<Uint8List?> getImageSprite(double time) async {
    await _initPlayer.future;
    final result =
        await _mc!.invoke<Uint8List>('getImageSprite', {'value': time});
    return result;
  }

  /// Get the total duration.
  Future<double> getDuration() async {
    if (_isNeedDisposed) return 0;
    await _initPlayer.future;
    final result = await _mc!.invoke<double>('getDuration');
    return result ?? 0;
  }

  /// Exit picture-in-picture mode if the player is currently in it.
  @override
  Future<void> exitPictureInPictureMode() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('exitPictureInPictureMode');
  }

  /// This interface is only supported by the premium version of the player (Player_Premium),
  /// and you need to purchase the premium version of the player mobile license.
  /// Add external subtitles
  /// @param url subtitle address
  /// @param name The name of the subtitle. If you add multiple subtitles, please set the subtitle name to a different name to distinguish it from other added subtitles, otherwise it may lead to incorrect subtitle selection.
  /// @param mimeType subtitle type, only supports VVT and SRT formats [VOD_PLAY_MIMETYPE_TEXT_SRT] [VOD_PLAY_MIMETYPE_TEXT_VTT]
  /// Later, you can get the corresponding name through the name in the result returned by [getSubtitleTrackInfo].
  Future<void> addSubtitleSource(String url, String name,
      {String? mimeType}) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('addSubtitleSource', {
      'url': url,
      'name': name,
      'mimeType': mimeType,
    });
  }

  /// This interface is only supported by the premium version of the player (Player_Premium),
  /// and you need to purchase the premium version of the player mobile license.
  /// Returns the subtitle track information list.
  Future<List<TXTrackInfo>> getSubtitleTrackInfo() async {
    if (_isNeedDisposed) return [];
    await _initPlayer.future;
    final transInfoData = await _mc!.invokeList('getSubtitleTrackInfo');
    if (null != transInfoData) {
      List<TXTrackInfo> trackInfoList = [];
      for (Map<dynamic, dynamic> map in transInfoData) {
        TXTrackInfo trackInfo =
            TXTrackInfo(map["name"], map["trackIndex"], map["trackType"]);
        trackInfo.isSelected = map["isSelected"] ?? false;
        trackInfo.isExclusive = map["isExclusive"] ?? true;
        trackInfo.isInternal = map["isInternal"] ?? true;
        trackInfoList.add(trackInfo);
      }
      return trackInfoList;
    }
    return [];
  }

  /// This interface is only supported by the premium version of the player (Player_Premium),
  /// and you need to purchase the premium version of the player mobile license.
  /// Returns the audio track information list.
  Future<List<TXTrackInfo>> getAudioTrackInfo() async {
    if (_isNeedDisposed) return [];
    await _initPlayer.future;
    final transInfoData = await _mc!.invokeList('getAudioTrackInfo');
    if (null != transInfoData) {
      List<TXTrackInfo> trackInfoList = [];
      for (Map<dynamic, dynamic> map in transInfoData) {
        TXTrackInfo trackInfo =
            TXTrackInfo(map["name"], map["trackIndex"], map["trackType"]);
        trackInfo.isSelected = map["isSelected"] ?? false;
        trackInfo.isExclusive = map["isExclusive"] ?? true;
        trackInfo.isInternal = map["isInternal"] ?? true;
        trackInfoList.add(trackInfo);
      }
      return trackInfoList;
    }
    return [];
  }

  /// This interface is only supported by the premium version of the player (Player_Premium),
  /// and you need to purchase the premium version of the player mobile license.
  /// Select a track.
  /// @param trackIndex track index, obtained from trackIndex of [TXTrackInfo]
  Future<void> selectTrack(int trackIndex) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('selectTrack', {'value': trackIndex});
  }

  /// This interface is only supported by the premium version of the player (Player_Premium),
  /// and you need to purchase the premium version of the player mobile license.
  /// Deselect a track.
  /// @param trackIndex track index, obtained from trackIndex of [TXTrackInfo]
  Future<void> deselectTrack(int trackIndex) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('deselectTrack', {'value': trackIndex});
  }

  /// Set the subtitle render style.
  /// @param model subtitle render parameters, see [TXSubtitleRenderModel]
  Future<void> setSubtitleStyle(TXSubtitleRenderModel model) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setSubtitleStyle', {'style': model.toMap()});
  }

  Future<void> setStringOption(String key, Object value) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setStringOption', {
      'key': key,
      'value': [value],
    });
  }

  Future<void> setPlayerView(int renderViewId) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setPlayerView', {'renderViewId': renderViewId});
  }

  @override
  Future<void> setRenderMode(FTXPlayerRenderMode renderMode) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('setRenderMode', {'renderMode': renderMode.index});
  }

  ///
  /// only valid on Android
  ///
  Future<void> reDraw() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('reDraw');
  }

  Future<void> enableTRTC(bool isEnable) async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('enableTRTC', {'isEnable': isEnable});
  }

  Future<void> publishVideo() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('publishVideo');
  }

  Future<void> unpublishVideo() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('unpublishVideo');
  }

  Future<void> publishAudio() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('publishAudio');
  }

  Future<void> unpublishAudio() async {
    if (_isNeedDisposed) return;
    await _initPlayer.future;
    await _mc!.invoke<void>('unpublishAudio');
  }

  /// Release the controller.
  @override
  Future<void> dispose() async {
    _isNeedDisposed = true;
    if (!_isDisposed) {
      await _release();
      // Unregister from the event dispatcher.
      if (_playerId != null) {
        VodEventDispatcher.instance.unregisterPlayer(_playerId!);
      }
      _changeState(TXPlayerState.disposed);
      _isDisposed = true;
      _stateStreamController.close();
      _eventStreamController.close();
      _netStatusStreamController.close();
    }

    super.dispose();
  }

  @override
  TXPlayerValue? playerValue() {
    return _value;
  }

  /// Network status event (dispatched by VodEventDispatcher).
  void onNetEvent(Map event) {
    final Map<dynamic, dynamic> map = event;
    _netStatusStreamController.add(map);
  }

  /// Event type.
  /// @see https://cloud.tencent.com/document/product/454/7886
  void onPlayerEvent(Map event) {
    final Map<dynamic, dynamic> map = event;
    switch (map["event"]) {
      case TXVodPlayEvent.PLAY_EVT_RTMP_STREAM_BEGIN:
        break;
      case TXVodPlayEvent.PLAY_EVT_RCV_FIRST_I_FRAME:
        if (_isNeedDisposed) return;
        _changeState(TXPlayerState.playing);
        break;
      case TXVodPlayEvent.PLAY_EVT_PLAY_BEGIN:
        if (_isNeedDisposed) return;
        _changeState(TXPlayerState.playing);
        break;
      case TXVodPlayEvent.PLAY_EVT_PLAY_PROGRESS: // Playback progress.
        break;
      case TXVodPlayEvent.PLAY_EVT_PLAY_END:
        _changeState(TXPlayerState.stopped);
        break;
      case TXVodPlayEvent.PLAY_EVT_PLAY_LOADING:
        _changeState(TXPlayerState.buffering);
        break;
      case TXVodPlayEvent
          .PLAY_EVT_CHANGE_RESOLUTION: // Downstream video resolution change.
        if (defaultTargetPlatform == TargetPlatform.android) {
          int? videoWidth = event[TXVodPlayEvent.EVT_VIDEO_WIDTH];
          int? videoHeight = event[TXVodPlayEvent.EVT_VIDEO_HEIGHT];
          videoWidth ??= event[TXVodPlayEvent.EVT_PARAM1];
          videoHeight ??= event[TXVodPlayEvent.EVT_PARAM2];
          if ((videoWidth != null && videoWidth > 0) &&
              (videoHeight != null && videoHeight > 0)) {
            resizeVideoWidth = videoWidth.toDouble();
            resizeVideoHeight = videoHeight.toDouble();
            videoLeft = event["videoLeft"] ?? 0;
            videoTop = event["videoTop"] ?? 0;
            videoRight = event["videoRight"] ?? 0;
            videoBottom = event["videoBottom"] ?? 0;
          }
        }
        int videoDegree = map['EVT_KEY_VIDEO_ROTATION'] ?? 0;
        if (Platform.isIOS && videoDegree == -1) {
          videoDegree = 0;
        }
        value = _value!.copyWith(degree: videoDegree);
        break;
      case TXVodPlayEvent.PLAY_EVT_VOD_PLAY_PREPARED: // VOD loading completed.
        break;
      case TXVodPlayEvent.PLAY_EVT_VOD_LOADING_END: // Loading ended
        break;
      case TXVodPlayEvent.PLAY_ERR_NET_DISCONNECT:
        _changeState(TXPlayerState.failed);
        break;
      case TXVodPlayEvent.PLAY_ERR_FILE_NOT_FOUND:
        _changeState(TXPlayerState.failed);
        break;
      case TXVodPlayEvent.PLAY_ERR_HLS_KEY:
        _changeState(TXPlayerState.failed);
        break;
      case TXVodPlayEvent.PLAY_WARNING_RECONNECT:
        break;
      case TXVodPlayEvent.PLAY_WARNING_DNS_FAIL:
        break;
      case TXVodPlayEvent.PLAY_WARNING_SEVER_CONN_FAIL:
        break;
      case TXVodPlayEvent.PLAY_WARNING_SHAKE_FAIL:
        break;
      case TXVodPlayEvent.EVENT_SUBTITLE_DATA:
        String subtitleDataStr = map[TXVodPlayEvent.EXTRA_SUBTITLE_DATA] ?? "";
        if (subtitleDataStr != "") {
          map[TXVodPlayEvent.EXTRA_SUBTITLE_DATA] =
              subtitleDataStr.trim().replaceAll('\\N', '\n');
        }
        break;
      default:
        break;
    }
    _eventStreamController.add(map);
  }
}
