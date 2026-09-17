import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:api_example/common/room_id_spec.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

import '../../../debug/generate_test_user_sig.dart';

class PublishMediaStreamAnchorState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  bool _isEnterRoom = false;
  bool _isPublishing = false;
  int? _localViewId;
  String _taskId = '';

  String _localUserId;
  String _localStrRoomId;

  TRTCPublishMode _publishMode = TRTCPublishMode.mixStreamToRoom;
  bool _audioOnly = false;
  bool _mixRemote = false;

  // Mix to room params
  String _mixStrRoomId;
  late String _mixUserId;

  // Mix to CDN params
  String _cdnUrl = '';

  // Encoder params
  final int _videoWidth = 1080;
  final int _videoHeight = 1920;
  int _videoBitrate = 5000;
  int _videoFps = 30;
  final int _videoGop = 3;
  final int _audioSampleRate = 48000;
  final int _audioChannelNum = 2;
  final int _audioBitrate = 128;

  // Publish status
  String _publishStatus = '';
  int _publishErrCode = -1;
  String _cdnStatus = '';

  // Remote users
  final Map<String, PublishRemoteUser> _remoteUsers = {};
  List<PublishRemoteUser> get remoteUsers => _remoteUsers.values.toList();

  // Getters
  bool get isEnterRoom => _isEnterRoom;
  bool get isPublishing => _isPublishing;
  int? get localViewId => _localViewId;
  String get taskId => _taskId;
  String get localUserId => _localUserId;
  String get localStrRoomId => _localStrRoomId;
  TRTCPublishMode get publishMode => _publishMode;
  bool get audioOnly => _audioOnly;
  bool get mixRemote => _mixRemote;
  String get mixStrRoomId => _mixStrRoomId;
  String get mixUserId => _mixUserId;
  String get cdnUrl => _cdnUrl;
  int get videoWidth => _videoWidth;
  int get videoHeight => _videoHeight;
  int get videoBitrate => _videoBitrate;
  int get videoFps => _videoFps;
  int get videoGop => _videoGop;
  int get audioSampleRate => _audioSampleRate;
  int get audioChannelNum => _audioChannelNum;
  int get audioBitrate => _audioBitrate;
  String get publishStatus => _publishStatus;
  int get publishErrCode => _publishErrCode;
  String get cdnStatus => _cdnStatus;

  PublishMediaStreamAnchorState({
    required String userId,
    required RoomIdSpec roomIdSpec,
  })  : _localUserId = userId,
        _localStrRoomId = roomIdSpec.effectiveStrRoomId,
        _mixStrRoomId = roomIdSpec.effectiveStrRoomId {
    _mixUserId = _generateRandomUserId();
  }

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _createListener();
    _trtcCloud?.registerListener(_listener!);
    notifyListeners();
  }

  TRTCCloudListener _createListener() {
    return TRTCCloudListener(
      onUserVideoAvailable: (userId, available) {
        if (available) {
          _remoteUsers[userId] ??= PublishRemoteUser(userId: userId);
        } else {
          _remoteUsers.remove(userId);
        }
        notifyListeners();
      },
      onRemoteUserEnterRoom: (userId) {
        _remoteUsers[userId] ??= PublishRemoteUser(userId: userId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        _remoteUsers.remove(userId);
        notifyListeners();
      },
      onStartPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _taskId = taskId;
        _publishErrCode = errCode;
        _publishStatus = errCode == 0
            ? 'Started (taskId: $taskId)'
            : 'Failed: $errMsg (code: $errCode)';
        notifyListeners();
      },
      onUpdatePublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _publishStatus = errCode == 0
            ? 'Updated (taskId: $taskId)'
            : 'Update failed: $errMsg (code: $errCode)';
        notifyListeners();
      },
      onStopPublishMediaStream: (taskId, errCode, errMsg, extraInfo) {
        _publishStatus = errCode == 0 ? 'Stopped' : 'Stop failed: $errMsg (code: $errCode)';
        _isPublishing = false;
        _taskId = '';
        notifyListeners();
      },
      onCdnStreamStateChanged: (cdnUrl, status, errCode, errMsg, extraInfo) {
        _cdnStatus = 'status=$status, code=$errCode';
        notifyListeners();
      },
    );
  }

  void setLocalViewId(int viewId) {
    if (_localViewId == viewId) return;
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    _localViewId = viewId;
    if (_isEnterRoom) {
      _trtcCloud?.startLocalPreview(true, viewId);
    }
  }

  void setRemoteViewId(String userId, int viewId) {
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    final user = _remoteUsers[userId];
    if (user == null || user.viewId == viewId) return;
    user.viewId = viewId;
    _trtcCloud?.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
  }

  void setPublishMode(TRTCPublishMode mode) {
    _publishMode = mode;
    notifyListeners();
  }

  void setAudioOnly(bool value) {
    _audioOnly = value;
    notifyListeners();
  }

  void setLocalStrRoomId(String value) {
    _localStrRoomId = value;
    notifyListeners();
  }

  void setLocalUserId(String value) {
    _localUserId = value;
    notifyListeners();
  }

  void setMixRemote(bool value) {
    _mixRemote = value;
    notifyListeners();
  }

  void setMixStrRoomId(String value) {
    _mixStrRoomId = value;
    notifyListeners();
  }

  void setMixUserId(String value) {
    _mixUserId = value;
    notifyListeners();
  }

  void setCdnUrl(String value) {
    _cdnUrl = value;
    notifyListeners();
  }

  void setVideoBitrate(int value) {
    _videoBitrate = value;
    notifyListeners();
  }

  void setVideoFps(int value) {
    _videoFps = value;
    notifyListeners();
  }

  Future<void> enterRoom() async {
    if (_isEnterRoom) return;

    final spec = RoomIdSpec(strRoomId: _localStrRoomId);
    final params = TRTCParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: _localUserId,
      roomId: spec.effectiveRoomId,
      strRoomId: spec.effectiveStrRoomId,
      role: TRTCRoleType.anchor,
      userSig: GenerateTestUserSig.genTestSig(_localUserId),
      streamId: _getStreamId(),
    );

    _trtcCloud?.callExperimentalAPI(
        '{"api": "setFramework", "params": {"framework": 7, "component": 2}}');

    if (_localViewId != null) {
      _trtcCloud?.startLocalPreview(true, _localViewId!);
    }
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
    _trtcCloud?.enterRoom(params, TRTCAppScene.live);
    _isEnterRoom = true;
    notifyListeners();
  }

  Future<void> exitRoom() async {
    if (_isPublishing) {
      await stopPublishMediaStream();
    }
    _trtcCloud?.stopLocalAudio();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  List<TRTCVideoLayout> _buildVideoLayoutList() {
    final w = _videoWidth;
    final h = _videoHeight;
    final layouts = <TRTCVideoLayout>[
      TRTCVideoLayout(
        fixedVideoUser: TRTCUser(
          userId: _localUserId,
          strRoomId: _localStrRoomId,
        ),
        fixedVideoStreamType: TRTCVideoStreamType.big,
        rect: TRTCRect(left: 0, top: 0, right: w, bottom: h),
        zOrder: 0,
        fillMode: TRTCVideoFillMode.fit,
      ),
    ];
    if (_mixRemote) {
      final remotes = _remoteUsers.values.toList();
      const int cols = 4;
      final tileW = (w / cols).round();
      final tileH = (h / 4).round();
      for (var i = 0; i < remotes.length; i++) {
        final col = i % cols;
        final row = i ~/ cols;
        layouts.add(
          TRTCVideoLayout(
            fixedVideoUser: TRTCUser(
              userId: remotes[i].userId,
              strRoomId: _localStrRoomId,
            ),
            fixedVideoStreamType: TRTCVideoStreamType.big,
            rect: TRTCRect(
              left: col * tileW,
              top: h - tileH - row * tileH,
              right: col * tileW + tileW,
              bottom: h - row * tileH,
            ),
            zOrder: 1 + i,
            fillMode: TRTCVideoFillMode.fit,
          ),
        );
      }
    }
    return layouts;
  }

  void startPublishMediaStream() {
    final target = TRTCPublishTarget(mode: _publishMode);

    if (_publishMode == TRTCPublishMode.mixStreamToRoom) {
      final mixSpec = RoomIdSpec(strRoomId: _mixStrRoomId);
      target.mixStreamIdentity = TRTCUser(
        userId: _mixUserId,
        intRoomId: mixSpec.effectiveRoomId,
        strRoomId: mixSpec.effectiveStrRoomId,
      );
    } else if (_publishMode == TRTCPublishMode.mixStreamToCdn) {
      final urls = _cdnUrl.split(',').where((u) => u.trim().isNotEmpty);
      target.cdnUrlList = urls
          .map((u) => TRTCPublishCdnUrl(rtmpUrl: u.trim()))
          .toList();
    }

    final config = TRTCStreamMixingConfig();

    if (!_audioOnly) {
      config.videoLayoutList = _buildVideoLayoutList();
    }

    final param = TRTCStreamEncoderParam(
      audioEncodedSampleRate: _audioSampleRate,
      audioEncodedChannelNum: _audioChannelNum,
      audioEncodedKbps: _audioBitrate,
      audioEncodedCodecType: 2,
    );

    if (_audioOnly) {
      param.videoEncodedWidth = 0;
      param.videoEncodedHeight = 0;
    } else {
      param.videoEncodedWidth = _videoWidth;
      param.videoEncodedHeight = _videoHeight;
      param.videoEncodedKbps = _videoBitrate;
      param.videoEncodedFPS = _videoFps;
      param.videoEncodedGOP = _videoGop;
    }

    _trtcCloud?.startPublishMediaStream(target, param, config);
    _isPublishing = true;
    _publishStatus = 'Starting...';
    notifyListeners();
  }

  Future<void> stopPublishMediaStream() async {
    _trtcCloud?.stopPublishMediaStream(_taskId);
    _publishStatus = 'Stopping...';
    notifyListeners();
  }

  /// Dynamically update publishing parameters (uses updatePublishMediaStream API).
  void updatePublishMediaStream() {
    if (_taskId.isEmpty) return;

    final target = TRTCPublishTarget(mode: _publishMode);

    if (_publishMode == TRTCPublishMode.mixStreamToRoom) {
      final mixSpec = RoomIdSpec(strRoomId: _mixStrRoomId);
      target.mixStreamIdentity = TRTCUser(
        userId: _mixUserId,
        intRoomId: mixSpec.effectiveRoomId,
        strRoomId: mixSpec.effectiveStrRoomId,
      );
    } else if (_publishMode == TRTCPublishMode.mixStreamToCdn) {
      final urls = _cdnUrl.split(',').where((u) => u.trim().isNotEmpty);
      target.cdnUrlList = urls
          .map((u) => TRTCPublishCdnUrl(rtmpUrl: u.trim()))
          .toList();
    }

    final config = TRTCStreamMixingConfig();

    if (!_audioOnly) {
      config.videoLayoutList = _buildVideoLayoutList();
    }

    final param = TRTCStreamEncoderParam(
      audioEncodedSampleRate: _audioSampleRate,
      audioEncodedChannelNum: _audioChannelNum,
      audioEncodedKbps: _audioBitrate,
      audioEncodedCodecType: 2,
    );

    if (_audioOnly) {
      param.videoEncodedWidth = 0;
      param.videoEncodedHeight = 0;
    } else {
      param.videoEncodedWidth = _videoWidth;
      param.videoEncodedHeight = _videoHeight;
      param.videoEncodedKbps = _videoBitrate;
      param.videoEncodedFPS = _videoFps;
      param.videoEncodedGOP = _videoGop;
    }

    _trtcCloud?.updatePublishMediaStream(_taskId, target, param, config);
    _publishStatus = 'Updating...';
    notifyListeners();
  }

  String _getStreamId() {
    return '${GenerateTestUserSig.sdkAppId}_${_localStrRoomId}_${_localUserId}_main';
  }

  String _generateRandomUserId() {
    final rng = Random();
    String line = '';
    for (var i = 0; i < 6; i++) {
      int num = rng.nextInt(10);
      if (num <= 0) num = rng.nextInt(10);
      line += num.toString();
    }
    return line;
  }

  @override
  void dispose() {
    if (_isPublishing) {
      _trtcCloud?.stopPublishMediaStream(_taskId);
    }
    _trtcCloud?.stopLocalAudio();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.exitRoom();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}

class PublishRemoteUser {
  final String userId;
  int? viewId;

  PublishRemoteUser({required this.userId});
}
