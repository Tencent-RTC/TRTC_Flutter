import 'dart:collection';

import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:api_example/utils/bidirectional_map.dart';

class RemoteUserState {
  final String userId;
  bool isAudioMuted;
  bool isVideoMuted;
  int? viewKey;
  bool isLocalUser;

  RemoteUserState({
    required this.userId,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.viewKey,
    this.isLocalUser = false,
  });
}

class ViewManager {
  static const int MAX_ANCHOR_COUNT = 4;

  final BidirectionalMap<String, int> _userViewMap = BidirectionalMap<String, int>();
  final List<int> _availableViewKeys = List.generate(MAX_ANCHOR_COUNT, (index) => index);
  final Map<int, int> _viewKeyToViewId = {
    0: -1,
    1: -1,
    2: -1,
    3: -1,
  };

  bool isViewKeyAvailable(int key) {
    return !_userViewMap.containsValue(key);
  }

  String? getUserIdByViewKey(int key) {
    return _userViewMap.getKey(key);
  }

  bool updateUserView(String userId, int viewKey) {
    if (isViewKeyAvailable(viewKey)) {
      final oldViewKey = _userViewMap.getValue(userId);
      if (oldViewKey == null) {
        return false;
      }
      releaseView(userId);
      _availableViewKeys.remove(viewKey);
      _userViewMap.add(userId, viewKey);
      return true;
    } else {
      return false;
    }
  }

  int? allocateView(String userId) {
    if (_availableViewKeys.isEmpty) return null;

    final viewKey = _availableViewKeys.removeAt(0);
    _userViewMap.add(userId, viewKey);
    return viewKey;
  }

  void releaseView(String userId) {
    final viewKey = _userViewMap.getValue(userId);
    if (viewKey != null) {
      _userViewMap.remove(userId);
      _availableViewKeys.add(viewKey);
      _availableViewKeys.sort();
    }
  }

  int setViewId(int value) {
    if (_viewKeyToViewId.values.every((v) => v != -1)) {
      throw StateError('All view IDs are occupied');
    }

    if (value == -1) {
      throw ArgumentError('View ID cannot be 0');
    }

    if (_viewKeyToViewId.values.contains(value)) {
      throw ArgumentError('View ID $value already exists');
    }

    for (final key in _viewKeyToViewId.keys) {
      if (_viewKeyToViewId[key] == -1) {
        _viewKeyToViewId[key] = value;
        return key;
      }
    }
    return -1;
  }

  int? getViewId(int viewKey) => _viewKeyToViewId[viewKey];

  bool get hasAvailableView => _availableViewKeys.isNotEmpty;

  void clear() {
    _userViewMap.clear();
    _viewKeyToViewId.clear();
    _availableViewKeys.clear();
    _availableViewKeys.addAll(List.generate(MAX_ANCHOR_COUNT, (index) => index));
  }
}

class LiveRoomState extends ChangeNotifier {
  bool _isLocalCameraEnabled = false;
  bool _isLocalMicrophoneEnabled = false;
  String? _localUserId;
  int? _localViewKey;
  int? _roomId;
  bool _isCallActive = false;
  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  bool _isInitialized = false;
  final Map<String, RemoteUserState> _remoteUsers = {};
  String _statusMessage = 'Preparing...';
  bool _isEnterRoomSuccess = false;
  bool _isAnchor = false;
  bool _isFrontCamera = true;

  final ViewManager _viewManager = ViewManager();

  // Getters
  bool get isLocalCameraEnabled => _isLocalCameraEnabled;
  bool get isLocalMicrophoneEnabled => _isLocalMicrophoneEnabled;
  String? get localUserId => _localUserId;
  int? get roomId => _roomId;
  bool get isCallActive => _isCallActive;
  List<RemoteUserState> get remoteUsers => _remoteUsers.values.toList();
  bool get isInitialized => _isInitialized;
  String get statusMessage => _statusMessage;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;
  bool get isAnchor => _isAnchor;
  bool get isFrontCamera => _isFrontCamera;
  bool get canBecomeAnchor => _viewManager.hasAvailableView;
  ViewManager get viewManager => _viewManager;

  TRTCCloudListener? _listener;

  Future<void> initializeRoom({
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
      roomId: _roomId ?? 123456,
      role: _isAnchor ? TRTCRoleType.anchor : TRTCRoleType.audience,
      userSig: GenerateTestUserSig.genTestSig(_localUserId!)
    ), TRTCAppScene.live);
  }


  _getTRTCCloudListener() {
    return _listener ??= TRTCCloudListener(
      onError: (errorCode, errorMsg) {
        _statusMessage = 'Error: $errorMsg';
        notifyListeners();
      },
      onEnterRoom: (result) {
        print("TRTCCloudListener onEnterRoom: $result");
        if (result > 0) {
          _statusMessage = 'Room entered successfully';
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
        if (available) {
          if (_viewManager.hasAvailableView) {
            final viewKey = _viewManager.allocateView(userId);
            if (viewKey != null) {
              updateRemoteUserCameraState(userId, false, viewKey);
            }
          } else {
            _statusMessage = 'Room anchor limit reached';
            notifyListeners();
          }
        } else {
          final user = _remoteUsers[userId];
          if (user != null && user.viewKey != null) {
            _viewManager.releaseView(userId);
            updateRemoteUserCameraState(userId, true, -1);
          }
        }
      },
      onUserAudioAvailable: (userId, available) {
      },
    );
  }

  Future<void> switchRole() async {
    if (_trtcCloud != null) {
      if (!_isAnchor && !canBecomeAnchor) {
        _statusMessage = 'Room anchor limit reached';
        notifyListeners();
        return;
      }

      _isAnchor = !_isAnchor;
      _trtcCloud?.switchRole(_isAnchor ? TRTCRoleType.anchor : TRTCRoleType.audience);

      if (_isAnchor) {
        _statusMessage = 'Switched to anchor';
      } else {
        _statusMessage = 'Switched to audience';
        _trtcCloud?.stopLocalPreview();
        _trtcCloud?.stopLocalAudio();
        if (_localViewKey != null) {
          _viewManager.releaseView(_localUserId!);
        }
        _localViewKey = null;

        _isLocalCameraEnabled = false;
        _isLocalMicrophoneEnabled = false;
      }
      notifyListeners();
    }
  }

  getUserVideoMutedStatus(String? userId) {
    if (userId == null) {
      return true;
    }
    if (userId == _localUserId) {
      return false;
    } else {
      final user = _remoteUsers[userId]!;
      return user.isVideoMuted;
    }
  }

  getUserAudioMutedStatus(String? userId) {
    if (userId == null) {
      return true;
    }
    if (userId == _localUserId) {
      return false;
    } else {
      final user = _remoteUsers[userId]!;
      return user.isAudioMuted;
    }
  }

  muteVideoStream(String? userId)  {
    if (userId == null) {
      Fluttertoast.showToast(msg: "Invalid User");
      return;
    }
    if (userId == _localUserId) {
      Fluttertoast.showToast(msg: "Can't mute local video");
    } else {
      final user = _remoteUsers[userId]!;
      user.isVideoMuted = !user.isVideoMuted;
      _trtcCloud?.muteRemoteVideoStream(userId, TRTCVideoStreamType.big, user.isVideoMuted);
    }
    notifyListeners();
  }

  muteAudioStream(String? userId)  {
    if (userId == null) {
      Fluttertoast.showToast(msg: "Invalid User");
      return;
    }
    if (userId == _localUserId) {
     Fluttertoast.showToast(msg: "Can't mute local audio");
    } else {
      final user = _remoteUsers[userId]!;
      user.isAudioMuted = !user.isAudioMuted;
      _trtcCloud?.muteRemoteAudio(userId, user.isAudioMuted);
    }
    notifyListeners();
  }

  switchViewPosition(String userId, int viewKey) {
    if (_viewManager.isViewKeyAvailable(viewKey)) {
      final viewId = _viewManager.getViewId(viewKey);
      if (viewId != null && _viewManager.updateUserView(userId, viewKey)) {
        if (userId == _localUserId) {
          _trtcCloud?.updateLocalView(viewId);
        } else {
          _trtcCloud?.updateRemoteView(userId, TRTCVideoStreamType.big, viewId);
        }
      }
      notifyListeners();
    } else {
      Fluttertoast.showToast(msg: "Position already occupied");
    }
  }

  updateLocalCameraState(bool enabled) {
    if (_isLocalCameraEnabled != enabled && _trtcCloud != null && _isAnchor) {
      _isLocalCameraEnabled = enabled;

      if (enabled && _viewManager.hasAvailableView) {
        final viewKey = _viewManager.allocateView(_localUserId!);
        if (viewKey != null) {
          final viewId = _viewManager.getViewId(viewKey);
          _localViewKey = viewKey;
          if (viewId != null && viewId != -1) {
            _trtcCloud?.startLocalPreview(_isFrontCamera, viewId);
          }
        }
      } else if (!enabled) {
        _trtcCloud?.stopLocalPreview();
        if (_localViewKey != null) {
          _viewManager.releaseView(_localUserId!);
        }
        _localViewKey = null;
      }
      notifyListeners();
    }
  }

  updateLocalMicrophoneState(bool enabled) {
    if (_isLocalMicrophoneEnabled != enabled && _trtcCloud != null && _isAnchor) {
      _isLocalMicrophoneEnabled = enabled;
      if (enabled) {
        _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
      } else {
        _trtcCloud?.stopLocalAudio();
      }
      notifyListeners();
    }
  }

  switchCamera() {
    if (_trtcCloud != null && _isAnchor) {
      _isFrontCamera = !_isFrontCamera;
      _deviceManager?.switchCamera(_isFrontCamera);
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
      final user = _remoteUsers[userId];
      if (user?.viewKey != null) {
        _trtcCloud?.stopRemoteView(userId, TRTCVideoStreamType.big);
        _viewManager.releaseView(userId);
      }
      _remoteUsers.remove(userId);
      notifyListeners();
    }
  }

  void updateRemoteUserCameraState(String userId, bool isMuted, int viewKey) {
    if (_remoteUsers.containsKey(userId)) {
      final user = _remoteUsers[userId]!;
      user.viewKey = viewKey;

      if (isMuted) {
        _trtcCloud?.stopRemoteView(userId, TRTCVideoStreamType.big);
      } else {
        final viewId = _viewManager.getViewId(viewKey);
        if (viewId != null &&  viewId != -1) {
          _trtcCloud?.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
        }
      }
      notifyListeners();
    }
  }

  void setViewId(int viewId) {
    try {
      int key = _viewManager.setViewId(viewId);
      if (key != -1 && _viewManager.isViewKeyAvailable(key)) {
        final userId = _viewManager.getUserIdByViewKey(key);
        if (userId != null) {
          if (userId == _localUserId) {
            _trtcCloud?.startLocalPreview(true, viewId);
          } else {
            _trtcCloud?.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
          }
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  exitRoom() {
    _isCallActive = false;
    _remoteUsers.clear();
    _viewManager.clear();
    if (_trtcCloud != null) {
      _trtcCloud?.exitRoom();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    exitRoom();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}
