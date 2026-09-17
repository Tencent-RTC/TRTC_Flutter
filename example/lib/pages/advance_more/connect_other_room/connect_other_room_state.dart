import 'dart:convert';
import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class ConnectOtherRoomState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  ConnectOtherRoomState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, PkRemoteUser> _remoteUsers = {};
  List<PkRemoteUser> get remoteUsers => _remoteUsers.values.toList();

  ValueNotifier<bool> isConnecting = ValueNotifier(false);
  ValueNotifier<bool> isConnected = ValueNotifier(false);
  ValueNotifier<String?> resultEvent = ValueNotifier(null);

  /// The connected anchor's userId (set on success).
  String? _connectedUserId;
  String? get connectedUserId => _connectedUserId;

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
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.live,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
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

  /// Connect to another room for cross-room PK.
  /// Supports both numeric and string room IDs.
  void connectOtherRoom(String targetRoomId, String targetUserId) {
    if (_trtcCloud == null || targetRoomId.isEmpty || targetUserId.isEmpty) return;
    isConnecting.value = true;
    resultEvent.value = null;

    final parsed = int.tryParse(targetRoomId);
    final jsonStr = jsonEncode({
      if (parsed != null) 'roomId': parsed else 'strRoomId': targetRoomId,
      'userId': targetUserId,
    });
    _trtcCloud?.connectOtherRoom(jsonStr);
  }

  void disconnectOtherRoom() {
    if (_trtcCloud == null) return;
    isConnecting.value = true;
    resultEvent.value = null;
    _trtcCloud?.disconnectOtherRoom();
  }

  void exitRoom() {
    if (isConnected.value) {
      _trtcCloud?.disconnectOtherRoom();
    }
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('ConnectOtherRoom onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = PkRemoteUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId] ??
            (_remoteUsers[remoteUserId] = PkRemoteUser(userId: remoteUserId));
        user.isVideoAvailable = available;
        if (available) {
          if (user.viewId != null && user.viewId! > 0) {
            _trtcCloud?.startRemoteView(
                remoteUserId, TRTCVideoStreamType.big, user.viewId);
          }
        } else {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
        }
        notifyListeners();
      },
      onConnectOtherRoom: (remoteUserId, errCode, errMsg) {
        isConnecting.value = false;
        if (errCode == 0) {
          isConnected.value = true;
          _connectedUserId = remoteUserId;
          resultEvent.value = 'connect_success';
        } else {
          isConnected.value = false;
          resultEvent.value = 'connect_failed:$errCode:$errMsg';
        }
        notifyListeners();
      },
      onDisconnectOtherRoom: (errCode, errMsg) {
        isConnecting.value = false;
        isConnected.value = false;
        _connectedUserId = null;
        if (errCode == 0) {
          resultEvent.value = 'disconnect_success';
        } else {
          resultEvent.value = 'disconnect_failed:$errCode:$errMsg';
        }
        notifyListeners();
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

class PkRemoteUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable = false;
  PkRemoteUser({required this.userId});
}
