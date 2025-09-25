import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

class VoiceEffectState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  UserListState? userListState;

  String? _userId;
  int? _roomId;
  bool _isEnterRoom = false;
  bool _isInit = false;

  bool get isInit => _isInit;
  bool get isEntered => _isEnterRoom;
  String? get userId => _userId;
  int? get roomId => _roomId;

  bool earMonitorEnabled = false;
  int earMonitorVolume = 100;
  int reverbType = 0;
  int changerType = 0;
  int captureVolume = 100;
  double voicePitch = 0.0;
  List<String> logs = [];

  final reverbTypes = List.generate(12, (i) => i);
  final changerTypes = List.generate(12, (i) => i);

  TXAudioEffectManager? _audioEffectManager;

  Future<void> enterRoom(String userId, int roomId) async {
    _userId = userId;
    _roomId = roomId;
    _trtcCloud = await TRTCCloud.sharedInstance();
    _audioEffectManager = _trtcCloud?.getAudioEffectManager();
    _listener ??= _getTRTCCloudListener();
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

  void setEarMonitorEnabled(bool v) {
    earMonitorEnabled = v;
    _audioEffectManager?.enableVoiceEarMonitor(v);
    _addLog('Ear monitor: $v');
    notifyListeners();
  }
  void setEarMonitorVolume(int v) {
    earMonitorVolume = v;
    _audioEffectManager?.setVoiceEarMonitorVolume(v);
    _addLog('Ear monitor volume: $v');
    notifyListeners();
  }
  void setReverbType(int v) {
    reverbType = v;
    _audioEffectManager?.setVoiceReverbType(TXVoiceReverbType.values[v]);
    _addLog('Reverb type: $v');
    notifyListeners();
  }
  void setChangerType(int v) {
    changerType = v;
    _audioEffectManager?.setVoiceChangerType(TXVoiceChangerType.values[v]);
    _addLog('Changer type: $v');
    notifyListeners();
  }
  void setCaptureVolume(int v) {
    captureVolume = v;
    _audioEffectManager?.setVoiceCaptureVolume(v);
    _addLog('Capture volume: $v');
    notifyListeners();
  }
  void setVoicePitch(double v) {
    voicePitch = v;
    _audioEffectManager?.setVoicePitch(v);
    _addLog('Voice pitch: $v');
    notifyListeners();
  }

  void _addLog(String msg) {
    logs.insert(0, msg);
    if (logs.length > 50) logs.removeLast();
    notifyListeners();
  }

  @override
  void dispose() {
    userListState?.dispose();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
} 