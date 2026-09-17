import 'dart:io';

import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_native.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class ScreenshotState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  ScreenshotState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteVideoUser> _remoteUsers = {};
  List<RemoteVideoUser> get remoteUsers => _remoteUsers.values.toList();

  /// Last snapshot result for UI preview.
  ValueNotifier<SnapshotResult?> snapshotResult = ValueNotifier(null);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
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
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.videoCall,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
  }

  void setLocalViewId(int viewId) {
    if (_localViewId == viewId) return;
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    _localViewId = viewId;
    _trtcCloud?.startLocalPreview(true, viewId);
  }

  void setRemoteViewId(String remoteUserId, int viewId) {
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    final user = _remoteUsers[remoteUserId];
    if (user == null || user.viewId == viewId) return;
    user.viewId = viewId;
    if (user.isVideoAvailable) {
      _trtcCloud?.startRemoteView(remoteUserId, TRTCVideoStreamType.big, viewId);
    }
  }

  /// Per SDK doc: passing an empty userId means "screencapture the local video".
  /// Passing the local user's own userId is treated as a *remote* uid lookup
  /// (no remote decoder for it exists), so the SDK silently ignores the call.
  String _pendingSnapshotUserId = '';
  TRTCVideoStreamType _pendingStreamType = TRTCVideoStreamType.big;
  TRTCSnapshotSourceType _pendingSourceType = TRTCSnapshotSourceType.stream;
  bool _snapshotRetriedWithEmptyPath = false;

  Future<void> takeSnapshot(String? targetUserId, TRTCVideoStreamType streamType,
      TRTCSnapshotSourceType sourceType) async {
    final isLocal = targetUserId == null || targetUserId.isEmpty || targetUserId == userId;
    final effectiveUserId = isLocal ? '' : targetUserId;
    _pendingSnapshotUserId = effectiveUserId;
    _pendingStreamType = streamType;
    _pendingSourceType = sourceType;
    if (Platform.isAndroid) {
      _trtcCloud?.snapshotVideo(effectiveUserId, streamType, sourceType);
    } else if (Platform.isIOS) {
      _snapshotRetriedWithEmptyPath = false;
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/snapshot_${DateTime.now().millisecondsSinceEpoch}.png'
              .replaceAll(RegExp('/+'), '/');
      _trtcCloud?.snapshotVideo(effectiveUserId, streamType, sourceType,
          path: path);
    } else {
      TRTCCloudNative.instance.snapshotVideo(
          effectiveUserId, streamType, sourceType);
    }
  }

  bool _retrySnapshotWithEmptyPath(int errCode) {
    if (!Platform.isIOS || errCode == 0 || _snapshotRetriedWithEmptyPath) {
      return false;
    }
    _snapshotRetriedWithEmptyPath = true;
    _trtcCloud?.snapshotVideo(
        _pendingSnapshotUserId, _pendingStreamType, _pendingSourceType);
    return true;
  }

  void exitRoom() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('Screenshot onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteVideoUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId];
        if (user == null) return;
        user.isVideoAvailable = available;
        if (available) {
          if (user.viewId != null && user.viewId! > 0) {
            _trtcCloud?.startRemoteView(remoteUserId, TRTCVideoStreamType.big, user.viewId);
          }
        } else {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
        }
        notifyListeners();
      },
      onSnapshotComplete: (snapUserId, path, errCode, errMsg) {
        if (_retrySnapshotWithEmptyPath(errCode)) return;
        snapshotResult.value = SnapshotResult(
          userId: snapUserId,
          path: path,
          errCode: errCode,
          errMsg: errMsg,
        );
      },
    );
  }

  @override
  void dispose() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}

class SnapshotResult {
  final String userId;
  final String path;
  final int errCode;
  final String errMsg;

  SnapshotResult({
    required this.userId,
    required this.path,
    required this.errCode,
    required this.errMsg,
  });

  bool get isSuccess => errCode == 0;
  bool get fileExists => path.isNotEmpty && File(path).existsSync();
}

class RemoteVideoUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable;
  RemoteVideoUser({required this.userId, this.viewId, this.isVideoAvailable = false});
}
