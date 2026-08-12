import 'package:api_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

class MusicEffectState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  UserListState? userListState;

  String? _userId;
  int? _roomId;
  bool _isEnterRoom = false;
  bool _isInit = false;

  // 控件
  final TextEditingController musicPathController = TextEditingController(text: 'assets/music/daoxiang.mp3');
  final TextEditingController musicIdController = TextEditingController(text: '1');
  final TextEditingController loopCountController = TextEditingController(text: '0');
  final TextEditingController seekPosController = TextEditingController();
  final TextEditingController trackIndexController = TextEditingController();

  bool publish = false;
  bool isShortFile = false;
  int allMusicVolume = 100;
  double musicPitch = 0.0;
  double musicSpeedRate = 1.0;
  List<String> logs = [];

  TXAudioEffectManager? _audioEffectManager;

  bool get isInit => _isInit;
  bool get isEntered => _isEnterRoom;
  String? get userId => _userId;
  int? get roomId => _roomId;

  MusicEffectState(String userId, int roomId) {
    _userId = userId;
    _roomId = roomId;
  }

  Future<void> enterRoom(String userId, int roomId) async {
    _userId = userId;
    _roomId = roomId;
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener ??= _getTRTCCloudListener();
    _audioEffectManager = _trtcCloud?.getAudioEffectManager();
    _trtcCloud?.registerListener(_listener!);
    userListState = UserListState(_trtcCloud!);
    userListState?.setLocalUser(userId);
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomId,
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.live,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
    _isInit = true;
    notifyListeners();
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    notifyListeners();
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
      onEnterRoom: (result) {
        if (result > 0) {
          _isEnterRoom = true;
          if (_userId != null) {
            userListState?.setLocalUser(_userId!);
            userListState?.refreshUserListWidget();
          }
        } else {
          _isEnterRoom = false;
        }
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onError: (code, msg) {
        notifyListeners();
      },
    );
  }

  void setPublish(bool v) {
    publish = v;
    notifyListeners();
  }
  void setShortFile(bool v) {
    isShortFile = v;
    notifyListeners();
  }
  void setAllMusicVolume(int v) {
    allMusicVolume = v;
    _audioEffectManager?.setAllMusicVolume(v);
    notifyListeners();
  }
  void setMusicPitch(double v) {
    musicPitch = v;
    if (_musicId != null) {
      _audioEffectManager?.setMusicPitch(_musicId!, v);
    }
    notifyListeners();
  }
  void setMusicSpeedRate(double v) {
    musicSpeedRate = v;
    if (_musicId != null) {
      _audioEffectManager?.setMusicSpeedRate(_musicId!, v);
    }
    notifyListeners();
  }

  int? get _musicId => int.tryParse(musicIdController.text);
  String get _musicPath => musicPathController.text;
  int get _loopCount => int.tryParse(loopCountController.text) ?? 0;

  void startPlayMusic() async {
    if (_musicId == null || _musicPath.isEmpty) return;
    final param = AudioMusicParam(
      id: _musicId!,
      path: await Utils.getAssetsFilePath(_musicPath),
      loopCount: _loopCount,
      publish: publish,
      isShortFile: isShortFile,
    );
    _audioEffectManager?.startPlayMusic(param);
    _addLog('Start music: id=$_musicId, path=$_musicPath');
  }
  void pauseMusic() {
    if (_musicId == null) return;
    _audioEffectManager?.pausePlayMusic(_musicId!);
    _addLog('Pause music: id=$_musicId');
  }
  void resumeMusic() {
    if (_musicId == null) return;
    _audioEffectManager?.resumePlayMusic(_musicId!);
    _addLog('Resume music: id=$_musicId');
  }
  void stopMusic() {
    if (_musicId == null) return;
    _audioEffectManager?.stopPlayMusic(_musicId!);
    _addLog('Stop music: id=$_musicId');
  }
  void getMusicCurrentPos() {
    if (_musicId == null) return;
    final pos = _audioEffectManager?.getMusicCurrentPosInMS(_musicId!) ?? -1;
    _addLog('Current Pos: $pos ms');
  }
  void getMusicDuration() {
    final duration = _audioEffectManager?.getMusicDurationInMS(_musicPath) ?? -1;
    _addLog('Duration: $duration ms');
  }
  void seekMusicToPos() {
    if (_musicId == null) return;
    final pts = int.tryParse(seekPosController.text) ?? 0;
    _audioEffectManager?.seekMusicToPosInTime(_musicId!, pts);
    _addLog('Seek music: id=$_musicId, pos=$pts');
  }
  void getMusicTrackCount() {
    if (_musicId == null) return;
    final count = _audioEffectManager?.getMusicTrackCount(_musicId!) ?? 0;
    _addLog('Track count: $count');
  }
  void setMusicTrack() {
    if (_musicId == null) return;
    final idx = int.tryParse(trackIndexController.text) ?? 0;
    _audioEffectManager?.setMusicTrack(_musicId!, idx);
    _addLog('Set music track: id=$_musicId, idx=$idx');
  }
  void preloadMusic() {
    if (_musicId == null || _musicPath.isEmpty) return;
    final param = AudioMusicParam(
      id: _musicId!,
      path: _musicPath,
      loopCount: _loopCount,
      publish: publish,
      isShortFile: isShortFile,
    );
    _audioEffectManager?.preloadMusic(param);
    _addLog('Preload music: id=$_musicId, path=$_musicPath');
  }
  void setPreloadObserver() {
    _audioEffectManager?.setPreloadObserver(TXMusicPreloadObserver(
      onLoadProgress: (id, progress) {
        _addLog('Preload progress: id=$id, progress=$progress');
      },
      onLoadError: (id, errorCode) {
        _addLog('Preload error: id=$id, code=$errorCode');
      },
    ));
    _addLog('Set preload observer');
  }
  void setMusicObserver() {
    if (_musicId == null) return;
    _audioEffectManager?.setMusicObserver(_musicId!, TXMusicPlayObserver(
      onStart: (id, errorCode) {
        _addLog('Music start: id=$id, code=$errorCode');
      },
      onPlayProgress: (id, curPts, duration) {
        _addLog('Music progress: id=$id, $curPts/$duration');
      },
      onComplete: (id, errorCode) {
        _addLog('Music complete: id=$id, code=$errorCode');
      },
    ));
    _addLog('Set music observer: id=$_musicId');
  }

  void _addLog(String msg) {
    logs.insert(0, msg);
    if (logs.length > 50) logs.removeLast();
    notifyListeners();
  }

  @override
  void dispose() {
    musicPathController.dispose();
    musicIdController.dispose();
    loopCountController.dispose();
    seekPosController.dispose();
    trackIndexController.dispose();
    userListState?.dispose();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
} 