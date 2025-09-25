import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class VideoCallState extends ChangeNotifier {
  bool _isLocalCameraMute = false;
  bool _isLocalMicrophoneMute = false;
  bool _isMuteAllRemoteVideo = false;
  bool _isMuteAllRemoteAudio = false;
  String? _localUserId;
  int? _roomId;
  int _localViewId = 0;
  bool _isCallActive = false;
  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  bool _isInitialized = false;
  final Map<String, RemoteUserState> _remoteUsers = {};
  String _statusMessage = 'Preparing...';
  bool _isEnterRoomSuccess = false;

  // Getters
  bool get isLocalCameraMute => _isLocalCameraMute;
  bool get isLocalMicrophoneMute => _isLocalMicrophoneMute;
  bool get isMuteAllRemoteVideo => _isMuteAllRemoteVideo;
  bool get isMuteAllRemoteAudio => _isMuteAllRemoteAudio;
  String? get localUserId => _localUserId;
  int? get roomId => _roomId;
  int get localViewId => _localViewId;
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
    ), TRTCAppScene.videoCall);
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
      onUserVideoAvailable: (userId, available) {
        print("object: $userId, $available");
        updateRemoteUserCameraState(userId, !available);
      },
      onUserAudioAvailable: (userId, available) {
        updateRemoteUserMicrophoneState(userId, !available);
      },
    );
  }

  stopAllRemoteView() {
    _trtcCloud?.stopAllRemoteView();
  }
  
  muteAllRemoteAudio(bool mute) {
    if (_isMuteAllRemoteAudio != mute && _trtcCloud != null) {
      _isMuteAllRemoteAudio = mute;
      _trtcCloud?.muteAllRemoteAudio(mute);
      notifyListeners();
    }
  }
  
  muteAllRemoteVideo(bool mute) {
    if (_isMuteAllRemoteVideo != mute && _trtcCloud != null) {
      _isMuteAllRemoteVideo = mute;
      _trtcCloud?.muteAllRemoteVideoStreams(mute);
      notifyListeners();
    }
  }

  muteLocalVideo(bool mute) {
    if (_isLocalCameraMute != mute && _trtcCloud != null) {
      _isLocalCameraMute = mute;
      _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, mute);
      notifyListeners();
    }
  }

  muteLocalAudio(bool mute) {
    if (_isLocalMicrophoneMute != mute && _trtcCloud != null) {
      _isLocalMicrophoneMute = mute;
      _trtcCloud?.muteLocalAudio(mute);
      notifyListeners();
    }
  }

  void addRemoteUser(String userId) {
    if (!_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId] = RemoteUserState(userId: userId);
      notifyListeners();
    }
  }

  void removeRemoteUser(String userId) {
    if (_remoteUsers.containsKey(userId)) {
      _trtcCloud?.stopRemoteView(userId, TRTCVideoStreamType.big);
      _remoteUsers.remove(userId);
      notifyListeners();
    }
  }

  void updateRemoteUserCameraState(String userId, bool isMuted) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId]!.isCameraMuted = isMuted;
      final viewId = _remoteUsers[userId]?.viewId;
      if (viewId != null) {
        if (isMuted) {
          _trtcCloud?.stopRemoteView(userId, TRTCVideoStreamType.big);
        } else {
          _trtcCloud?.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
        }
      }
      notifyListeners();
    }
  }

  void updateRemoteUserMicrophoneState(String userId, bool isMuted) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId]!.isMicrophoneMuted = isMuted;
      notifyListeners();
    }
  }

  setLocalViewId(int id) {
    _localViewId = id;
    if (_trtcCloud != null) {
      _trtcCloud?.startLocalPreview(true, id);
      _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, _isLocalCameraMute);
    }
  }

  setRemoteViewId(String userId, int id) {
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId]!.viewId = id;
      if (_remoteUsers[userId]!.isCameraMuted)  {
        _trtcCloud?.stopRemoteView(userId, TRTCVideoStreamType.big);
      } else {
        _trtcCloud?.startRemoteView(userId, TRTCVideoStreamType.big, id);
      }
    }
  }

  endCall() {
    _isCallActive = false;
    _remoteUsers.clear();
    if (_trtcCloud != null) {
      _trtcCloud?.exitRoom();
      if (_listener != null) {
        _trtcCloud?.unRegisterListener(_listener!);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    print("object disposed");
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}

class RemoteUserState {
  final String userId;
  int viewId = 0;
  bool isCameraMuted;
  bool isMicrophoneMuted;

  RemoteUserState({
    required this.userId,
    this.isCameraMuted = false,
    this.isMicrophoneMuted = false,
  });
}
