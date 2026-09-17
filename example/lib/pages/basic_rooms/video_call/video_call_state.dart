import 'package:api_example/common/call_status.dart';
import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class VideoCallState extends ChangeNotifier {
  bool _isLocalCameraMute = false;
  bool _isLocalMicrophoneMute = false;
  bool _isMuteAllRemoteVideo = false;
  bool _isMuteAllRemoteAudio = false;
  String? _localUserId;
  RoomIdSpec _roomIdSpec = const RoomIdSpec();
  int _localViewId = 0;
  bool _isCallActive = false;
  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  bool _isInitialized = false;
  final Map<String, RemoteUserState> _remoteUsers = {};
  CallStatus _status = CallStatus.preparing;
  bool _isEnterRoomSuccess = false;

  // Connection / quality monitoring state
  String _connectionState = 'normal'; // normal | reconnecting | lost | recovered
  String? _lastWarning;
  int? _rtt;
  int? _upLoss;
  int? _downLoss;
  int? _appCpu;
  final List<FrameEvent> _frameEvents = [];

  // Getters
  bool get isLocalCameraMute => _isLocalCameraMute;
  bool get isLocalMicrophoneMute => _isLocalMicrophoneMute;
  bool get isMuteAllRemoteVideo => _isMuteAllRemoteVideo;
  bool get isMuteAllRemoteAudio => _isMuteAllRemoteAudio;
  String? get localUserId => _localUserId;
  String? get roomId => _roomIdSpec.display;
  int get localViewId => _localViewId;
  bool get isCallActive => _isCallActive;
  List<RemoteUserState> get remoteUsers => _remoteUsers.values.toList();
  bool get isInitialized => _isInitialized;
  CallStatus get status => _status;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;
  String get connectionState => _connectionState;
  String? get lastWarning => _lastWarning;
  int? get rtt => _rtt;
  int? get upLoss => _upLoss;
  int? get downLoss => _downLoss;
  int? get appCpu => _appCpu;
  List<FrameEvent> get frameEvents => List.unmodifiable(_frameEvents);

  void _addFrameEvent(FrameEvent event) {
    _frameEvents.insert(0, event);
    if (_frameEvents.length > 10) _frameEvents.removeLast();
  }

  TRTCCloudListener? _listener;

  Future<void> initializeCall({
    required String userId,
    required RoomIdSpec roomIdSpec,
  }) async {
    _localUserId = userId;
    _roomIdSpec = roomIdSpec;
    _isCallActive = true;
    _status = CallStatus.initializing;
    notifyListeners();

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

    _status = CallStatus.enteringRoom;
    _trtcCloud?.enterRoom(TRTCParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: _localUserId ?? "",
      roomId: _roomIdSpec.effectiveRoomId,
      strRoomId: _roomIdSpec.effectiveStrRoomId,
      role: TRTCRoleType.anchor,
      userSig: GenerateTestUserSig.genTestSig(_localUserId!)
    ), TRTCAppScene.videoCall);
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
  }

  _getTRTCCloudListener() {
    return _listener ??= TRTCCloudListener(
      onError: (errorCode, errorMsg) {
        _status = CallStatus.error(errorMsg);
        notifyListeners();
      },
      onEnterRoom: (result) {
        if (result > 0) {
          _status = CallStatus.roomEnteredSuccess;
          _isEnterRoomSuccess = true;
        } else {
          _status = CallStatus.failedToEnterRoom(result);
          _isEnterRoomSuccess = false;
        }
        notifyListeners();
      },
      onRemoteUserEnterRoom: (userId) {
        addRemoteUser(userId);
        _status = CallStatus.userJoined(userId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        removeRemoteUser(userId);
        _status = CallStatus.userLeft(userId);
        notifyListeners();
      },
      onUserVideoAvailable: (userId, available) {
        updateRemoteUserCameraState(userId, !available);
      },
      onUserAudioAvailable: (userId, available) {
        updateRemoteUserMicrophoneState(userId, !available);
      },
      onWarning: (warningCode, warningMsg) {
        _lastWarning = '$warningCode: $warningMsg';
        notifyListeners();
      },
      onTryToReconnect: () {
        _connectionState = 'reconnecting';
        notifyListeners();
      },
      onConnectionLost: () {
        _connectionState = 'lost';
        notifyListeners();
      },
      onConnectionRecovery: () {
        _connectionState = 'recovered';
        notifyListeners();
      },
      onStatistics: (statistics) {
        _rtt = statistics.rtt;
        _upLoss = statistics.upLoss;
        _downLoss = statistics.downLoss;
        _appCpu = statistics.appCpu;
        notifyListeners();
      },
      onSendFirstLocalVideoFrame: (streamType) {
        _addFrameEvent(FrameEvent.local('localVideo'));
        notifyListeners();
      },
      onSendFirstLocalAudioFrame: () {
        _addFrameEvent(FrameEvent.local('localAudio'));
        notifyListeners();
      },
      onFirstVideoFrame: (userId, streamType, width, height) {
        _addFrameEvent(FrameEvent.remote('remoteVideo', userId));
        notifyListeners();
      },
      onFirstAudioFrame: (userId) {
        _addFrameEvent(FrameEvent.remote('remoteAudio', userId));
        notifyListeners();
      },
      onUserVideoSizeChanged: (userId, streamType, newWidth, newHeight) {
        final user = _remoteUsers[userId];
        if (user != null) {
          user.videoWidth = newWidth;
          user.videoHeight = newHeight;
          notifyListeners();
        }
      },
      onRemoteVideoStatusUpdated: (userId, streamType, status, reason) {
        final user = _remoteUsers[userId];
        if (user != null) {
          user.isVideoBuffering = status == TRTCAVStatusType.loading;
          notifyListeners();
        }
      },
      onRemoteAudioStatusUpdated: (userId, status, reason) {
        final user = _remoteUsers[userId];
        if (user != null) {
          user.isAudioBuffering = status == TRTCAVStatusType.loading;
          notifyListeners();
        }
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
      // Software-level mute: doesn't stop/restart the camera hardware,
      // so the view and startLocalPreview are only called once.
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
      // startLocalPreview is called exactly once when the view is created.
      // Camera on/off is then controlled via muteLocalVideo (software-level).
      _trtcCloud?.startLocalPreview(true, id);
      _trtcCloud?.muteLocalVideo(TRTCVideoStreamType.big, _isLocalCameraMute);
    }
  }

  setRemoteViewId(String userId, int id) {
    if (!TRTCCloudVideoView.containsViewId(id)) return;
    if (_remoteUsers.containsKey(userId)) {
      _remoteUsers[userId]!.viewId = id;
      if (_remoteUsers[userId]!.isCameraMuted) {
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
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}

class RemoteUserState {
  final String userId;
  int viewId = 0;
  bool isCameraMuted;
  bool isMicrophoneMuted;
  int? videoWidth;
  int? videoHeight;
  bool isVideoBuffering = false;
  bool isAudioBuffering = false;

  RemoteUserState({
    required this.userId,
    this.isCameraMuted = false,
    this.isMicrophoneMuted = false,
  });
}

/// A first-frame milestone event shown in the call quality panel.
class FrameEvent {
  /// One of: localVideo, localAudio, remoteVideo, remoteAudio
  final String type;
  final String? userId;

  const FrameEvent._(this.type, this.userId);

  factory FrameEvent.local(String type) => FrameEvent._(type, null);
  factory FrameEvent.remote(String type, String userId) =>
      FrameEvent._(type, userId);
}
