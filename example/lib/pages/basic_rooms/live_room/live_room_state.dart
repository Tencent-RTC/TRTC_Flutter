import 'package:api_example/common/room_id_spec.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/utils/bidirectional_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class RemoteUserState {
  final String userId;
  bool isAudioMuted;
  bool isVideoMuted;
  int? viewKey;
  bool isLocalUser;
  int volume;

  RemoteUserState({
    required this.userId,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
    this.viewKey,
    this.isLocalUser = false,
    this.volume = 100,
  });
}

class ViewManager {
  static const int maxAnchorCount = 4;
  final BidirectionalMap<String, int> _userViewMap = BidirectionalMap<String, int>();
  final List<int> _availableViewKeys = List.generate(maxAnchorCount, (index) => index);
  final Map<int, int> _viewKeyToViewId = {0: -1, 1: -1, 2: -1, 3: -1};

  bool isViewKeyAvailable(int key) => !_userViewMap.containsValue(key);
  String? getUserIdByViewKey(int key) => _userViewMap.getKey(key);
  bool get hasAvailableView => _availableViewKeys.isNotEmpty;

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

  bool updateUserView(String userId, int viewKey) {
    if (!isViewKeyAvailable(viewKey)) return false;
    releaseView(userId);
    _availableViewKeys.remove(viewKey);
    _userViewMap.add(userId, viewKey);
    return true;
  }

  int setViewId(int value) {
    for (final key in _viewKeyToViewId.keys) {
      if (_viewKeyToViewId[key] == -1) {
        _viewKeyToViewId[key] = value;
        return key;
      }
    }
    return -1;
  }

  int? getViewId(int viewKey) => _viewKeyToViewId[viewKey];

  void clear() {
    _userViewMap.clear();
    _viewKeyToViewId.updateAll((_, __) => -1);
    _availableViewKeys.clear();
    _availableViewKeys.addAll(List.generate(maxAnchorCount, (index) => index));
  }
}

class LiveRoomState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  LiveRoomState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  TRTCCloudListener? _listener;

  bool _isEnterRoom = false;
  bool get isEnterRoom => _isEnterRoom;

  bool _isAnchor = false;
  bool get isAnchor => _isAnchor;

  bool _isFrontCamera = true;
  bool get isFrontCamera => _isFrontCamera;

  bool _isLocalCameraEnabled = false;
  bool get isLocalCameraEnabled => _isLocalCameraEnabled;

  bool _isLocalMicEnabled = false;
  bool get isLocalMicEnabled => _isLocalMicEnabled;

  bool _allVideoMuted = false;
  bool get allVideoMuted => _allVideoMuted;

  bool _allAudioMuted = false;
  bool get allAudioMuted => _allAudioMuted;

  int? _localViewKey;

  final Map<String, RemoteUserState> _remoteUsers = {};
  List<RemoteUserState> get remoteUsers => _remoteUsers.values.toList();

  final ViewManager _viewManager = ViewManager();
  ViewManager get viewManager => _viewManager;
  bool get canBecomeAnchor => _viewManager.hasAvailableView;

  ValueNotifier<String?> eventMessage = ValueNotifier(null);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _deviceManager = _trtcCloud?.getDeviceManager();
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
        role: _isAnchor ? TRTCRoleType.anchor : TRTCRoleType.audience,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.live,
    );
  }

  void switchRole() {
    if (!_isAnchor && !canBecomeAnchor) {
      _emitEvent('anchor_limit');
      return;
    }
    _isAnchor = !_isAnchor;
    _trtcCloud?.switchRole(_isAnchor ? TRTCRoleType.anchor : TRTCRoleType.audience);
    if (!_isAnchor) {
      _trtcCloud?.stopLocalPreview();
      _trtcCloud?.stopLocalAudio();
      if (_localViewKey != null) _viewManager.releaseView(userId);
      _localViewKey = null;
      _isLocalCameraEnabled = false;
      _isLocalMicEnabled = false;
    }
    _emitEvent(_isAnchor ? 'switch_anchor' : 'switch_audience');
    notifyListeners();
  }

  void toggleLocalCamera() {
    if (!_isAnchor) return;
    _isLocalCameraEnabled = !_isLocalCameraEnabled;
    if (_isLocalCameraEnabled && _viewManager.hasAvailableView) {
      final viewKey = _viewManager.allocateView(userId);
      if (viewKey != null) {
        _localViewKey = viewKey;
        final viewId = _viewManager.getViewId(viewKey);
        if (viewId != null && viewId != -1) {
          _trtcCloud?.startLocalPreview(_isFrontCamera, viewId);
        }
      }
    } else if (!_isLocalCameraEnabled) {
      _trtcCloud?.stopLocalPreview();
      if (_localViewKey != null) _viewManager.releaseView(userId);
      _localViewKey = null;
    }
    notifyListeners();
  }

  void toggleLocalMic() {
    if (!_isAnchor) return;
    _isLocalMicEnabled = !_isLocalMicEnabled;
    if (_isLocalMicEnabled) {
      _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
    } else {
      _trtcCloud?.stopLocalAudio();
    }
    notifyListeners();
  }

  void switchCamera() {
    if (!_isAnchor) return;
    _isFrontCamera = !_isFrontCamera;
    _deviceManager?.switchCamera(_isFrontCamera);
    notifyListeners();
  }

  void toggleRemoteVideo(String remoteUserId) {
    final user = _remoteUsers[remoteUserId];
    if (user == null) return;
    user.isVideoMuted = !user.isVideoMuted;
    _trtcCloud?.muteRemoteVideoStream(remoteUserId, TRTCVideoStreamType.big, user.isVideoMuted);
    notifyListeners();
  }

  void toggleRemoteAudio(String remoteUserId) {
    final user = _remoteUsers[remoteUserId];
    if (user == null) return;
    user.isAudioMuted = !user.isAudioMuted;
    _trtcCloud?.muteRemoteAudio(remoteUserId, user.isAudioMuted);
    notifyListeners();
  }

  void setRemoteVolume(String remoteUserId, int volume) {
    final user = _remoteUsers[remoteUserId];
    if (user == null) return;
    user.volume = volume;
    _trtcCloud?.setRemoteAudioVolume(remoteUserId, volume);
    notifyListeners();
  }

  void toggleAllRemoteVideo() {
    _allVideoMuted = !_allVideoMuted;
    _trtcCloud?.muteAllRemoteVideoStreams(_allVideoMuted);
    for (final user in _remoteUsers.values) {
      user.isVideoMuted = _allVideoMuted;
    }
    _emitEvent(_allVideoMuted ? 'all_video_muted' : 'all_video_resumed');
    notifyListeners();
  }

  void toggleAllRemoteAudio() {
    _allAudioMuted = !_allAudioMuted;
    _trtcCloud?.muteAllRemoteAudio(_allAudioMuted);
    for (final user in _remoteUsers.values) {
      user.isAudioMuted = _allAudioMuted;
    }
    _emitEvent(_allAudioMuted ? 'all_audio_muted' : 'all_audio_resumed');
    notifyListeners();
  }

  void switchViewPosition(String targetUserId, int newViewKey) {
    if (!_viewManager.isViewKeyAvailable(newViewKey)) {
      _emitEvent('position_occupied');
      return;
    }
    final viewId = _viewManager.getViewId(newViewKey);
    if (viewId != null && _viewManager.updateUserView(targetUserId, newViewKey)) {
      if (targetUserId == userId) {
        _trtcCloud?.updateLocalView(viewId);
      } else {
        _trtcCloud?.updateRemoteView(targetUserId, TRTCVideoStreamType.big, viewId);
      }
    }
    notifyListeners();
  }

  void setViewId(int viewId) {
    final key = _viewManager.setViewId(viewId);
    if (key != -1) {
      final uid = _viewManager.getUserIdByViewKey(key);
      if (uid != null) {
        if (uid == userId) {
          _trtcCloud?.startLocalPreview(_isFrontCamera, viewId);
        } else {
          _trtcCloud?.startRemoteView(uid, TRTCVideoStreamType.big, viewId);
        }
      }
    }
  }

  void _emitEvent(String event) => eventMessage.value = event;

  void exitRoom() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.stopLocalAudio();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    _viewManager.clear();
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('LiveRoom onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onSwitchRole: (errCode, errMsg) {
        _emitEvent(errCode == 0 ? 'switch_role_ok' : 'switch_role_fail:$errMsg');
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteUserState(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        final user = _remoteUsers[remoteUserId];
        if (user?.viewKey != null) {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
          _viewManager.releaseView(remoteUserId);
        }
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        if (available) {
          if (_viewManager.hasAvailableView) {
            final viewKey = _viewManager.allocateView(remoteUserId);
            if (viewKey != null) {
              final user = _remoteUsers[remoteUserId];
              if (user != null) {
                user.viewKey = viewKey;
                final viewId = _viewManager.getViewId(viewKey);
                if (viewId != null && viewId != -1) {
                  _trtcCloud?.startRemoteView(remoteUserId, TRTCVideoStreamType.big, viewId);
                }
              }
            }
          } else {
            _emitEvent('anchor_limit');
          }
        } else {
          final user = _remoteUsers[remoteUserId];
          if (user?.viewKey != null) {
            _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
            _viewManager.releaseView(remoteUserId);
            user?.viewKey = null;
          }
        }
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.stopLocalAudio();
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}
