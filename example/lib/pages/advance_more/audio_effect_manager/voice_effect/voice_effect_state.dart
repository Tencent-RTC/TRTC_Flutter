import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';

class VoiceEffectState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  VoiceEffectState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  TXAudioEffectManager? _audioEffectManager;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  bool earMonitorEnabled = false;
  int earMonitorVolume = 100;
  TXVoiceReverbType reverbType = TXVoiceReverbType.type0;
  TXVoiceChangerType changerType = TXVoiceChangerType.type0;
  int captureVolume = 100;
  double voicePitch = 0.0;

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

  void toggleEarMonitor() {
    earMonitorEnabled = !earMonitorEnabled;
    _audioEffectManager?.enableVoiceEarMonitor(earMonitorEnabled);
    notifyListeners();
  }

  void setEarMonitorVolume(int v) {
    earMonitorVolume = v;
    _audioEffectManager?.setVoiceEarMonitorVolume(v);
    notifyListeners();
  }

  void setReverbType(TXVoiceReverbType type) {
    reverbType = type;
    _audioEffectManager?.setVoiceReverbType(type);
    notifyListeners();
  }

  void setChangerType(TXVoiceChangerType type) {
    changerType = type;
    _audioEffectManager?.setVoiceChangerType(type);
    notifyListeners();
  }

  void setCaptureVolume(int v) {
    captureVolume = v;
    _audioEffectManager?.setVoiceCaptureVolume(v);
    notifyListeners();
  }

  void setVoicePitch(double v) {
    voicePitch = v;
    _audioEffectManager?.setVoicePitch(v);
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
      onError: (code, msg) => debugPrint('VoiceEffect onError: $code, $msg'),
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
