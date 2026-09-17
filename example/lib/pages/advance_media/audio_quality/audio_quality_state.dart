import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class AudioQualityState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  AudioQualityState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;

  bool get isEnterRoom => _isEnterRoom;

  TRTCAudioQuality _selectedQuality = TRTCAudioQuality.defaultMode;
  TRTCAudioQuality get selectedQuality => _selectedQuality;

  int _captureVolume = 50;
  int get captureVolume => _captureVolume;
  int _playbackVolume = 50;
  int get playbackVolume => _playbackVolume;

  /// Queried values from SDK
  ValueNotifier<int?> queriedCaptureVolume = ValueNotifier(null);
  ValueNotifier<int?> queriedPlayoutVolume = ValueNotifier(null);

  bool _micEnabled = true;
  bool get micEnabled => _micEnabled;
  bool _speakerEnabled = true;
  bool get speakerEnabled => _speakerEnabled;

  final Map<String, AudioUser> _users = {};
  List<AudioUser> get users => _users.values.toList();

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _deviceManager = _trtcCloud?.getDeviceManager();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);

    _users[userId] = AudioUser(userId: userId, isLocalUser: true);

    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomIdSpec.effectiveRoomId,
        strRoomId: roomIdSpec.effectiveStrRoomId,
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.voiceChatRoom,
    );
    _trtcCloud?.startLocalAudio(_selectedQuality);
    _trtcCloud?.enableAudioVolumeEvaluation(true, TRTCAudioVolumeEvaluateParams(interval: 300));
    notifyListeners();
  }

  void setQuality(TRTCAudioQuality quality) {
    if (_selectedQuality == quality) return;
    _selectedQuality = quality;
    _trtcCloud?.startLocalAudio(quality);
    notifyListeners();
  }

  void setCaptureVolume(int volume) {
    _captureVolume = volume;
    _trtcCloud?.setAudioCaptureVolume(volume);
    notifyListeners();
  }

  void setPlaybackVolume(int volume) {
    _playbackVolume = volume;
    _trtcCloud?.setAudioPlayoutVolume(volume);
    notifyListeners();
  }

  void queryCaptureVolume() {
    queriedCaptureVolume.value = _trtcCloud?.getAudioCaptureVolume();
  }

  void queryPlayoutVolume() {
    queriedPlayoutVolume.value = _trtcCloud?.getAudioPlayoutVolume();
  }

  void toggleMic() {
    _micEnabled = !_micEnabled;
    if (_micEnabled) {
      _trtcCloud?.startLocalAudio(_selectedQuality);
    } else {
      _trtcCloud?.stopLocalAudio();
    }
    notifyListeners();
  }

  void toggleSpeaker() {
    _speakerEnabled = !_speakerEnabled;
    _deviceManager?.setAudioRoute(
      _speakerEnabled ? TXAudioRoute.speakerPhone : TXAudioRoute.earpiece,
    );
    notifyListeners();
  }

  void toggleUserMute(String targetUserId) {
    final user = _users[targetUserId];
    if (user == null) return;
    user.isMuted = !user.isMuted;
    if (targetUserId == userId) {
      _trtcCloud?.muteLocalAudio(user.isMuted);
    } else {
      _trtcCloud?.muteRemoteAudio(targetUserId, user.isMuted);
    }
    notifyListeners();
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _users.clear();
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('AudioQuality onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _users[remoteUserId] = AudioUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _users.remove(remoteUserId);
        notifyListeners();
      },
      onUserAudioAvailable: (remoteUserId, available) {
        final user = _users[remoteUserId];
        if (user != null) {
          user.hasStream = available;
          notifyListeners();
        }
      },
      onUserVoiceVolume: (userVolumes, totalVolume) {
        for (final uv in userVolumes) {
          final uid = uv.userId.isEmpty ? userId : uv.userId;
          final user = _users[uid];
          if (user != null) {
            user.isSpeaking = uv.volume > 10;
          }
        }
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}

class AudioUser {
  final String userId;
  final bool isLocalUser;
  bool isSpeaking = false;
  bool isMuted = false;
  bool hasStream = false;

  AudioUser({required this.userId, this.isLocalUser = false});
}
