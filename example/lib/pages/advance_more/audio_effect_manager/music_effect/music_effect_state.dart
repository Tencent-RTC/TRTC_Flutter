import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';

class MusicEffectState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  MusicEffectState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  TXAudioEffectManager? _audioEffectManager;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;
  TXAudioEffectManager? get audioEffectManager => _audioEffectManager;

  // Music params
  String musicPath = 'assets/music/daoxiang.mp3';
  int musicId = 1;
  int loopCount = 0;
  bool publish = false;
  bool isShortFile = false;

  // Audio adjustments
  int allMusicVolume = 100;
  int musicPlayoutVolume = 100;
  int musicPublishVolume = 100;
  double musicPitch = 0.0;
  double musicSpeedRate = 1.0;

  // Playback state
  ValueNotifier<bool> isPlaying = ValueNotifier(false);
  ValueNotifier<bool> isPaused = ValueNotifier(false);

  // Log
  final List<String> _logs = [];
  List<String> get logs => List.unmodifiable(_logs);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _audioEffectManager = _trtcCloud?.getAudioEffectManager();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    _enterRoom();
    notifyListeners();
  }

  void _enterRoom() {
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomIdSpec.effectiveRoomId,
        strRoomId: roomIdSpec.effectiveStrRoomId,
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.live,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void setLocalViewId(int viewId) {
    if (_localViewId == viewId) return;
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    _localViewId = viewId;
    _trtcCloud?.startLocalPreview(true, viewId);
  }

  void setMusicPath(String path) { musicPath = path; notifyListeners(); }
  void setMusicId(int id) { musicId = id; notifyListeners(); }
  void setLoopCount(int count) { loopCount = count; notifyListeners(); }
  void togglePublish() { publish = !publish; notifyListeners(); }
  void toggleShortFile() { isShortFile = !isShortFile; notifyListeners(); }

  void setAllMusicVolume(int v) {
    allMusicVolume = v;
    _audioEffectManager?.setAllMusicVolume(v);
    notifyListeners();
  }

  void setMusicPlayoutVolume(int v) {
    musicPlayoutVolume = v;
    _audioEffectManager?.setMusicPlayoutVolume(musicId, v);
    notifyListeners();
  }

  void setMusicPublishVolume(int v) {
    musicPublishVolume = v;
    _audioEffectManager?.setMusicPublishVolume(musicId, v);
    notifyListeners();
  }

  void setMusicPitch(double v) {
    musicPitch = v;
    _audioEffectManager?.setMusicPitch(musicId, v);
    notifyListeners();
  }

  void setMusicSpeedRate(double v) {
    musicSpeedRate = v;
    _audioEffectManager?.setMusicSpeedRate(musicId, v);
    notifyListeners();
  }

  Future<void> startPlayMusic() async {
    if (musicPath.isEmpty) return;
    final param = AudioMusicParam(
      id: musicId,
      path: await Utils.getAssetsFilePath(musicPath),
      loopCount: loopCount,
      publish: publish,
      isShortFile: isShortFile,
    );
    _audioEffectManager?.startPlayMusic(param);
    isPlaying.value = true;
    isPaused.value = false;
  }

  void pauseMusic() {
    _audioEffectManager?.pausePlayMusic(musicId);
    isPaused.value = true;
  }

  void resumeMusic() {
    _audioEffectManager?.resumePlayMusic(musicId);
    isPaused.value = false;
  }

  void stopMusic() {
    _audioEffectManager?.stopPlayMusic(musicId);
    isPlaying.value = false;
    isPaused.value = false;
  }

  void getMusicCurrentPos() {
    final pos = _audioEffectManager?.getMusicCurrentPosInMS(musicId) ?? -1;
    _addLog('pos:$pos');
  }

  void getMusicDuration() {
    final duration = _audioEffectManager?.getMusicDurationInMS(musicPath) ?? -1;
    _addLog('duration:$duration');
  }

  void seekMusicToPos(int pts) {
    _audioEffectManager?.seekMusicToPosInTime(musicId, pts);
  }

  void getMusicTrackCount() {
    final count = _audioEffectManager?.getMusicTrackCount(musicId) ?? 0;
    _addLog('track_count:$count');
  }

  void setMusicTrack(int idx) {
    _audioEffectManager?.setMusicTrack(musicId, idx);
  }

  void preloadMusic() {
    final param = AudioMusicParam(
      id: musicId, path: musicPath,
      loopCount: loopCount, publish: publish, isShortFile: isShortFile,
    );
    _audioEffectManager?.preloadMusic(param);
  }

  void setPreloadObserver() {
    _audioEffectManager?.setPreloadObserver(TXMusicPreloadObserver(
      onLoadProgress: (id, progress) => _addLog('preload_progress:$id:$progress'),
      onLoadError: (id, code) => _addLog('preload_error:$id:$code'),
    ));
  }

  void setMusicObserver() {
    _audioEffectManager?.setMusicObserver(musicId, TXMusicPlayObserver(
      onStart: (id, code) => _addLog('music_start:$id:$code'),
      onPlayProgress: (id, cur, dur) => _addLog('music_progress:$id:$cur:$dur'),
      onComplete: (id, code) => _addLog('music_complete:$id:$code'),
    ));
  }

  void clearLogs() { _logs.clear(); notifyListeners(); }

  void _addLog(String msg) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    _logs.insert(0, '[$time] $msg');
    if (_logs.length > 50) _logs.removeLast();
    notifyListeners();
  }

  void exitRoom() {
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('MusicEffect onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}
