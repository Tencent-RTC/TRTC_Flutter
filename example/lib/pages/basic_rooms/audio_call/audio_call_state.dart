import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class AudioCallState extends ChangeNotifier {
  bool _isLocalMicrophoneEnabled = true;
  bool _isLocalSpeakerEnabled = true;
  String? _localUserId;
  int? _roomId;
  bool _isCallActive = false;
  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  bool _isInitialized = false;
  final Map<String, RemoteUserState> _remoteUsers = {};
  String _statusMessage = 'Preparing...';
  bool _isEnterRoomSuccess = false;

  // Getters
  bool get isLocalMicrophoneEnabled => _isLocalMicrophoneEnabled;
  bool get isLocalSpeakerEnabled => _isLocalSpeakerEnabled;
  String? get localUserId => _localUserId;
  int? get roomId => _roomId;
  bool get isCallActive => _isCallActive;
  List<RemoteUserState> get remoteUsers => _remoteUsers.values.toList();
  bool get isInitialized => _isInitialized;
  String get statusMessage => _statusMessage;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;

  TRTCCloudListener? _listener;

  Future<void> initializeCall({
    required String userId,
    required int roomId,
  }) async {
    _localUserId = userId;
    _roomId = roomId;
    _isCallActive = true;
    _statusMessage = 'Initializing...';

    await _initializeTRTC();
    notifyListeners();
  }

  Future<void> _initializeTRTC() async {
    if (_trtcCloud == null) {
      _trtcCloud = await TRTCCloud.sharedInstance();
      _deviceManager = _trtcCloud?.getDeviceManager();
      _isInitialized = true;
    }
    _listener ??= _getTRTCCloudListener();
    if (_listener != null) {
      _trtcCloud?.registerListener(_listener!);
    }

    _statusMessage = 'Entering room...';
    _trtcCloud?.enterRoom(TRTCParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: _localUserId ?? "",
      roomId: roomId ?? 123456,
      role: TRTCRoleType.anchor,
      userSig: GenerateTestUserSig.genTestSig(_localUserId!)
    ), TRTCAppScene.audioCall);
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
  }

  _getTRTCCloudListener() {
    return _listener ??= TRTCCloudListener(
      onError: (errorCode, errorMsg) {
        _statusMessage = 'Error: $errorMsg';
        notifyListeners();
      },
      onEnterRoom: (result) {
        if (result > 0) {
          _statusMessage = 'Room entered successfully';
          _isEnterRoomSuccess = true;
        } else {
          _statusMessage = 'Failed to enter room: $result';
          _isEnterRoomSuccess = false;
        }
        notifyListeners();
      },
      onRemoteUserEnterRoom: (userId) {
        addRemoteUser(userId);
        _statusMessage = 'User $userId joined the room';
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        removeRemoteUser(userId);
        _statusMessage = 'User $userId left the room';
        notifyListeners();
      },
      onUserAudioAvailable: (userId, available) {
        updateRemoteUserMicrophoneState(userId, !available);
      },
    );
  }

  Future<void> exitRoom() async {
    if (_trtcCloud != null) {
      _trtcCloud?.exitRoom();
    }
  }

  Future<void> updateLocalMicrophoneState(bool enabled) async {
    if (_isLocalMicrophoneEnabled != enabled && _trtcCloud != null) {
      _isLocalMicrophoneEnabled = enabled;
      _trtcCloud?.muteLocalAudio(!enabled);
      notifyListeners();
    }
  }

  Future<void> updateLocalSpeakerState(bool enabled) async {
    if (_isLocalSpeakerEnabled != enabled && _trtcCloud != null) {
      _isLocalSpeakerEnabled = enabled;
      _deviceManager?.setAudioRoute(
        enabled ? TXAudioRoute.speakerPhone : TXAudioRoute.earpiece,
      );
      notifyListeners();
    }
  }

  void addRemoteUser(String userId) {
    if (!_remoteUsers.containsKey(userId) && userId != _localUserId) {
      _remoteUsers[userId] = RemoteUserState(userId: userId);
      notifyListeners();
    }
  }

  void removeRemoteUser(String userId) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers.remove(userId);
      notifyListeners();
    }
  }

  void updateRemoteUserMicrophoneState(String userId, bool isMuted) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId]!.updateMuteState(isMuted);
      notifyListeners();
    }
  }

  endCall() {
    _isCallActive = false;
    _remoteUsers.clear();
    if (_trtcCloud != null) {
      _trtcCloud?.exitRoom();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}

class RemoteUserState {
  final String userId;
  bool isMuted;

  RemoteUserState({
    required this.userId,
    this.isMuted = false,
  });

  void updateMuteState(bool isMuted) {
    this.isMuted = isMuted;
  }
}