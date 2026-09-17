import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

import '../../../debug/generate_test_user_sig.dart';

class RenderParamsState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  RenderParamsState({
    required this.userId,
    required this.roomIdSpec,
  });

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteRenderUser> _remoteUsers = {};
  List<RemoteRenderUser> get remoteUsers => _remoteUsers.values.toList();

  String? _selectedRemoteUserId;
  String? get selectedRemoteUserId => _selectedRemoteUserId;

  // Local render params
  ValueNotifier<TRTCVideoRotation> localRotation =
      ValueNotifier(TRTCVideoRotation.rotation0);
  ValueNotifier<TRTCVideoFillMode> localFillMode =
      ValueNotifier(TRTCVideoFillMode.fill);
  ValueNotifier<TRTCVideoMirrorType> localMirrorType =
      ValueNotifier(TRTCVideoMirrorType.auto);

  // Remote render params (for currently selected user)
  ValueNotifier<TRTCVideoRotation> remoteRotation =
      ValueNotifier(TRTCVideoRotation.rotation0);
  ValueNotifier<TRTCVideoFillMode> remoteFillMode =
      ValueNotifier(TRTCVideoFillMode.fill);
  ValueNotifier<TRTCVideoMirrorType> remoteMirrorType =
      ValueNotifier(TRTCVideoMirrorType.auto);

  // Remote stream type: big / small / sub
  ValueNotifier<TRTCVideoStreamType> remoteStreamType =
      ValueNotifier(TRTCVideoStreamType.big);

  bool _isSwitchingStream = false;
  bool get isSwitchingStream => _isSwitchingStream;

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
    _addParamListeners();
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
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.videoCall,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void setLocalViewId(int viewId) {
    if (_localViewId == viewId) return;
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    _localViewId = viewId;
    _trtcCloud?.startLocalPreview(true, viewId);
    setLocalRenderParams();
  }

  void setRemoteViewId(String remoteUserId, int viewId) {
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    final user = _remoteUsers[remoteUserId];
    if (user == null || user.viewId == viewId) return;
    user.viewId = viewId;
    _startRemoteStream(remoteUserId);
  }

  /// Start (or restart) the remote stream for the selected stream type.
  void _startRemoteStream(String remoteUserId) {
    final user = _remoteUsers[remoteUserId];
    if (user == null || user.viewId == null) return;

    final streamType = remoteStreamType.value;
    final bool available = _isStreamAvailable(user, streamType);
    if (available) {
      _trtcCloud?.startRemoteView(remoteUserId, streamType, user.viewId);
      _trtcCloud?.setRemoteRenderParams(
        remoteUserId,
        streamType,
        user.renderParams,
      );
    }
  }

  bool _isStreamAvailable(RemoteRenderUser user, TRTCVideoStreamType type) {
    switch (type) {
      case TRTCVideoStreamType.big:
        return user.isVideoAvailable;
      case TRTCVideoStreamType.small:
        return user.isVideoAvailable;
      case TRTCVideoStreamType.sub:
        return user.isSubStreamAvailable;
    }
  }

  void selectRemoteUser(String? remoteUserId) {
    // Stop previous user's stream
    if (_selectedRemoteUserId != null && _selectedRemoteUserId != remoteUserId) {
      final prevUser = _remoteUsers[_selectedRemoteUserId!];
      if (prevUser != null && prevUser.viewId != null) {
        _trtcCloud?.stopRemoteView(prevUser.userId, remoteStreamType.value);
      }
    }

    _selectedRemoteUserId = remoteUserId;

    if (remoteUserId != null && _remoteUsers.containsKey(remoteUserId)) {
      final user = _remoteUsers[remoteUserId]!;
      final params = user.renderParams;
      remoteRotation.value = params.rotation;
      remoteFillMode.value = params.fillMode;
      remoteMirrorType.value = params.mirrorType;

      // Start stream for newly selected user
      _startRemoteStream(remoteUserId);
    }
    notifyListeners();
  }

  /// Change the remote stream type (big / small / sub).
  void changeRemoteStreamType(TRTCVideoStreamType type) {
    if (remoteStreamType.value == type) return;
    final targetId = _selectedRemoteUserId;
    if (targetId == null || targetId.isEmpty) {
      remoteStreamType.value = type;
      return;
    }

    final user = _remoteUsers[targetId];
    if (user == null) {
      remoteStreamType.value = type;
      return;
    }

    _isSwitchingStream = true;
    notifyListeners();

    // Stop old stream
    _trtcCloud?.stopRemoteView(targetId, remoteStreamType.value);
    remoteStreamType.value = type;

    // Start new stream
    if (user.viewId != null) {
      _startRemoteStream(targetId);
    }

    _isSwitchingStream = false;
    notifyListeners();
  }

  void exitRoom() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    _selectedRemoteUserId = null;
    notifyListeners();
  }

  void _addParamListeners() {
    for (var n in [localRotation, localFillMode, localMirrorType]) {
      n.addListener(() => setLocalRenderParams());
    }
    for (var n in [remoteRotation, remoteFillMode, remoteMirrorType]) {
      n.addListener(() => setRemoteRenderParams());
    }
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
      onError: (code, msg) {
        debugPrint('RenderParams onError: $code, $msg');
      },
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteRenderUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        if (_selectedRemoteUserId == remoteUserId) {
          _selectedRemoteUserId = null;
        }
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId];
        if (user == null) return;
        user.isVideoAvailable = available;
        if (available) {
          // Auto-start if this is the selected user and current stream is big/small
          if (remoteUserId == _selectedRemoteUserId &&
              (remoteStreamType.value == TRTCVideoStreamType.big ||
                  remoteStreamType.value == TRTCVideoStreamType.small) &&
              user.viewId != null) {
            _startRemoteStream(remoteUserId);
          }
        } else {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.small);
        }
        notifyListeners();
      },
      onUserSubStreamAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId];
        if (user == null) return;
        user.isSubStreamAvailable = available;
        if (available) {
          if (remoteUserId == _selectedRemoteUserId &&
              remoteStreamType.value == TRTCVideoStreamType.sub &&
              user.viewId != null) {
            _startRemoteStream(remoteUserId);
          }
        } else {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.sub);
        }
        notifyListeners();
      },
    );
  }

  void setLocalRenderParams() {
    _trtcCloud?.setLocalRenderParams(TRTCRenderParams(
      rotation: localRotation.value,
      fillMode: localFillMode.value,
      mirrorType: localMirrorType.value,
    ));
  }

  void setRemoteRenderParams() {
    final targetId = _selectedRemoteUserId;
    if (targetId == null || targetId.isEmpty) return;
    final user = _remoteUsers[targetId];
    if (user == null) return;

    user.renderParams = TRTCRenderParams(
      rotation: remoteRotation.value,
      fillMode: remoteFillMode.value,
      mirrorType: remoteMirrorType.value,
    );
    _trtcCloud?.setRemoteRenderParams(
      targetId,
      remoteStreamType.value,
      user.renderParams,
    );
  }

  @override
  void dispose() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    super.dispose();
  }
}

class RemoteRenderUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable;
  bool isSubStreamAvailable;
  TRTCRenderParams renderParams;

  RemoteRenderUser({
    required this.userId,
    this.viewId,
    this.isVideoAvailable = false,
    this.isSubStreamAvailable = false,
    TRTCRenderParams? renderParams,
  }) : renderParams = renderParams ??
            TRTCRenderParams(
              rotation: TRTCVideoRotation.rotation0,
              fillMode: TRTCVideoFillMode.fill,
              mirrorType: TRTCVideoMirrorType.auto,
            );
}
