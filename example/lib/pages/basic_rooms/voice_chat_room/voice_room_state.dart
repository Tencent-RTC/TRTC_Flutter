import 'dart:collection';

import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:api_example/utils/bidirectional_map.dart';

class AudioUser {
  final String userId;
  bool isMuted;
  bool isLocalUser;
  bool isSpeaking;

  AudioUser({
    required this.userId,
    this.isMuted = false,
    this.isLocalUser = false,
    this.isSpeaking = false,
  });
}

class ViewManager {
  static const int MAX_ANCHOR_COUNT = 4;

  final BidirectionalMap<String, int> _userViewMap = BidirectionalMap<String, int>();
  final Queue<int> _availableViewKeys = Queue.from(List.generate(MAX_ANCHOR_COUNT, (index) => index));

  bool isViewKeyAvailable(int key) {
    return _userViewMap.containsValue(key);
  }

  String? getUserIdByViewKey(int key) {
    return _userViewMap.getKey(key);
  }

  int? allocateView(String userId) {
    if (_availableViewKeys.isEmpty) return null;

    final viewKey = _availableViewKeys.removeFirst();
    _userViewMap.add(userId, viewKey);
    return viewKey;
  }

  void releaseView(String userId) {
    final viewKey = _userViewMap.getValue(userId);
    if (viewKey != null) {
      _userViewMap.remove(userId);
      _availableViewKeys.addFirst(viewKey);
    }
  }

  bool get hasAvailableView => _availableViewKeys.isNotEmpty;

  void clear() {
    _userViewMap.clear();
    _availableViewKeys.clear();
    _availableViewKeys.addAll(List.generate(MAX_ANCHOR_COUNT, (index) => index));
  }
}

class VoiceRoomState extends ChangeNotifier {
  bool _isLocalMicrophoneEnabled = true;
  bool _isLocalSpeakerEnabled = true;
  String? _localUserId;
  int? _roomId;
  bool _isCallActive = false;
  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  bool _isInitialized = false;
  final Map<String, AudioUser> _audioUsers = {};
  String _statusMessage = 'Initializing...';
  bool _isEnterRoomSuccess = false;
  bool _isAnchor = false;

  final ViewManager _viewManager = ViewManager();

  // Getters
  bool get isLocalMicrophoneEnabled => _isLocalMicrophoneEnabled;
  bool get isLocalSpeakerEnabled => _isLocalSpeakerEnabled;
  String? get localUserId => _localUserId;
  int? get roomId => _roomId;
  bool get isCallActive => _isCallActive;
  List<AudioUser> get audioUsers => _audioUsers.values.toList();
  bool get isInitialized => _isInitialized;
  String get statusMessage => _statusMessage;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;
  bool get isAnchor => _isAnchor;
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
    ), TRTCAppScene.voiceChatRoom);

    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
    _deviceManager?.setAudioRoute(TXAudioRoute.speakerPhone);
    _trtcCloud?.enableAudioVolumeEvaluation(true, TRTCAudioVolumeEvaluateParams(
      interval: 300,
    ));
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
          _isEnterRoomSuccess = true;
        } else {
          _statusMessage = 'Failed to enter room: $result';
          _isEnterRoomSuccess = false;
        }
        notifyListeners();
      },
      onRemoteUserEnterRoom: (userId) {
        _statusMessage = 'User $userId joined the room';
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        removeAudioUser(userId);
        _statusMessage = 'User $userId left the room';
        notifyListeners();
      },
      onUserAudioAvailable: (userId, available) {
        if (available) {
          if (_viewManager.hasAvailableView) {
            final viewKey = _viewManager.allocateView(userId);
            if (viewKey != null) {
              addAudioUser(userId);
            }
          } else {
            _statusMessage = 'Room anchor limit reached';
            notifyListeners();
          }
        } else {
          removeAudioUser(userId);
        }
      },
      onUserVoiceVolume: (userVolumes, totalVolume) {
        for (final userVolume in userVolumes) {
          if (userVolume.userId == "") userVolume.userId = localUserId ?? "";

          print("TRTCCloudListener onUserVoiceVolume: ${userVolume.userId} ${userVolume.volume}");
          if (_audioUsers.containsKey(userVolume.userId)) {
            _audioUsers[userVolume.userId]!.isSpeaking = userVolume.volume > 10;
            notifyListeners();
          }
        }
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
        if (_isLocalMicrophoneEnabled) {
          _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
          addAudioUser(_localUserId!);
        }
      } else {
        _statusMessage = 'Switched to audience';
        _trtcCloud?.stopLocalAudio();
        _isLocalMicrophoneEnabled = false;
        removeAudioUser(_localUserId!);
      }
      notifyListeners();
    }
  }

  updateLocalMicrophoneState(bool enabled) {
    if (_isLocalMicrophoneEnabled != enabled && _trtcCloud != null && _isAnchor) {
      _isLocalMicrophoneEnabled = enabled;
      if (enabled) {
        _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
        addAudioUser(_localUserId!);
      } else {
        _trtcCloud?.stopLocalAudio();
        removeAudioUser(_localUserId!);
      }
      notifyListeners();
    }
  }

  updateLocalSpeakerState(bool enabled) {
    if (_isLocalSpeakerEnabled != enabled && _trtcCloud != null) {
      _isLocalSpeakerEnabled = enabled;
      _deviceManager?.setAudioRoute(
        enabled ? TXAudioRoute.speakerPhone : TXAudioRoute.earpiece,
      );
      notifyListeners();
    }
  }

  void addAudioUser(String userId) {
    if (!_audioUsers.containsKey(userId)) {
      _audioUsers[userId] = AudioUser(
        userId: userId,
        isLocalUser: userId == _localUserId,
      );
      notifyListeners();
    }
  }

  void removeAudioUser(String userId) {
    if (_audioUsers.containsKey(userId)) {
      _viewManager.releaseView(userId);
      _audioUsers.remove(userId);
      notifyListeners();
    }
  }

  exitRoom() {
    _isCallActive = false;
    _audioUsers.clear();
    _viewManager.clear();
    if (_trtcCloud != null) {
      _trtcCloud?.exitRoom();
      _trtcCloud?.enableAudioVolumeEvaluation(false, TRTCAudioVolumeEvaluateParams());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}
