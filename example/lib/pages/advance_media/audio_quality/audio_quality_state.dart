import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';

class AudioUser {
  final String userId;
  bool isSpeaking;
  bool isMuted;
  bool hasStream;
  bool isLocalUser;

  AudioUser({
    required this.userId,
    this.isSpeaking = false,
    this.isMuted = false,
    this.hasStream = false,
    this.isLocalUser = false,
  });
}

class AudioQualityState extends ChangeNotifier {
  final String userId;
  final String roomId;
  final List<AudioUser> _users = [];
  TRTCAudioQuality _selectedQualityMode = TRTCAudioQuality.defaultMode;
  double _captureVolume = 50;
  double _playbackVolume = 50;
  bool _isInitialized = false;
  String _statusMessage = 'Initializing...';
  bool _isEnterRoomSuccess = false;
  bool _isLocalMicrophoneEnabled = true;
  bool _isLocalSpeakerEnabled = true;

  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  TRTCCloudListener? _listener;

  AudioQualityState({
    required this.userId,
    required this.roomId,
  }) {
    _initialize();
  }

  List<AudioUser> get users => List.unmodifiable(_users);
  TRTCAudioQuality get selectedQualityMode => _selectedQualityMode;
  double get captureVolume => _captureVolume;
  double get playbackVolume => _playbackVolume;
  bool get isInitialized => _isInitialized;
  String get statusMessage => _statusMessage;
  bool get isEnterRoomSuccess => _isEnterRoomSuccess;
  bool get isLocalMicrophoneEnabled => _isLocalMicrophoneEnabled;
  bool get isLocalSpeakerEnabled => _isLocalSpeakerEnabled;

  Future<void> _initialize() async {
    try {
      await _initializeTRTC();
      _users.add(AudioUser(
        userId: userId,
        isLocalUser: true,
      ));
      _isInitialized = true;
      _statusMessage = 'Room is ready';
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Initialization failed: $e';
      notifyListeners();
    }
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
      userId: userId,
      roomId: int.parse(roomId),
      role: TRTCRoleType.anchor,
      userSig: GenerateTestUserSig.genTestSig(userId)
    ), TRTCAppScene.voiceChatRoom);

    _trtcCloud?.startLocalAudio(_selectedQualityMode);
    _trtcCloud?.enableAudioVolumeEvaluation(true, TRTCAudioVolumeEvaluateParams(
      interval: 300,
    ));
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
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
        _statusMessage = 'User $userId joined the room';
        addUser(userId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        removeUser(userId);
        _statusMessage = 'User $userId left the room';
        notifyListeners();
      },
      onUserAudioAvailable: (userId, available) {
        updateRemoteUserAudioState(userId, available);
      },
      onUserVoiceVolume: (userVolumes, totalVolume) {
        for (final userVolume in userVolumes) {
          if (userVolume.userId == "") userVolume.userId = userId;
          final index = _users.indexWhere((user) => user.userId == userVolume.userId);
          if (index != -1) {
            _users[index].isSpeaking = userVolume.volume > 10;
            notifyListeners();
          }
        }
      },
    );
  }

  String getQualityString(TRTCAudioQuality quality) {
    switch (quality) {
      case TRTCAudioQuality.speech:
        return 'Speech';
      case TRTCAudioQuality.music:
        return 'Music';
      default:
        return 'Standard';
    }
  }

  void updateQualityMode(TRTCAudioQuality quality) {
    if (_selectedQualityMode != quality) {
      _selectedQualityMode = quality;
      _trtcCloud?.startLocalAudio(quality);
      notifyListeners();
    }
  }

  void updateCaptureVolume(double volume) {
    if (_captureVolume != volume) {
      _captureVolume = volume;
      _trtcCloud?.setAudioCaptureVolume(volume.toInt());
      notifyListeners();
    }
  }

  void updatePlaybackVolume(double volume) {
    if (_playbackVolume != volume) {
      _playbackVolume = volume;
      _trtcCloud?.setAudioPlayoutVolume(volume.toInt());
      notifyListeners();
    }
  }

  void addUser(String userId) {
    if (!_users.any((user) => user.userId == userId)) {
      _users.add(AudioUser(userId: userId));
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    _users.removeWhere((user) => user.userId == userId);
    notifyListeners();
  }

  void updateUserSpeaking(String userId, bool isSpeaking) {
    final index = _users.indexWhere((user) => user.userId == userId);
    if (index != -1) {
      final user = _users[index];
      if (user.isSpeaking != isSpeaking) {
        user.isSpeaking = isSpeaking;
        notifyListeners();
      }
    }
  }

  void toggleUserMute(String muteUserId) {
    final index = _users.indexWhere((user) => user.userId == muteUserId);
    if (index != -1) {
      final user = _users[index];
      user.isMuted = !user.isMuted;
      if (muteUserId == userId) {
        _trtcCloud?.muteLocalAudio(user.isMuted);
      } else {
        _trtcCloud?.muteRemoteAudio(muteUserId, user.isMuted);
      }
      notifyListeners();
    }
  }

  void updateRemoteUserAudioState(String userId, bool isAvailable) {
    final index = _users.indexWhere((user) => user.userId == userId);
    if (index != -1) {
      final user = _users[index];
      if (user.hasStream != !isAvailable) {
        user.hasStream = !isAvailable;
        notifyListeners();
      }
    }
  }

  void updateLocalMicrophoneState(bool enabled) {
    if (_isLocalMicrophoneEnabled != enabled && _trtcCloud != null) {
      _isLocalMicrophoneEnabled = enabled;
      if (enabled) {
        _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
      } else {
        _trtcCloud?.stopLocalAudio();
      }
      notifyListeners();
    }
  }

  void updateLocalSpeakerState(bool enabled) {
    if (_isLocalSpeakerEnabled != enabled && _trtcCloud != null) {
      _isLocalSpeakerEnabled = enabled;
      _deviceManager?.setAudioRoute(
        enabled ? TXAudioRoute.speakerPhone : TXAudioRoute.earpiece,
      );
      notifyListeners();
    }
  }

  Future<void> exitRoom() async {
    try {
      _users.clear();
      _isInitialized = false;
      _statusMessage = 'Room exited';
      if (_trtcCloud != null) {
        _trtcCloud?.exitRoom();
      }
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Failed to exit room: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}
