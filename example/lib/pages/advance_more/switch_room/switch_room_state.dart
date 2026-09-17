import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class SwitchRoomState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  SwitchRoomState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  /// Current room spec (updated after a successful switch).
  RoomIdSpec _currentRoomSpec = const RoomIdSpec();
  RoomIdSpec get currentRoomSpec => _currentRoomSpec;

  final Map<String, RemoteUser> _remoteUsers = {};
  List<RemoteUser> get remoteUsers => _remoteUsers.values.toList();

  ValueNotifier<bool> isSwitching = ValueNotifier(false);
  ValueNotifier<String?> switchResult = ValueNotifier(null);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    _currentRoomSpec = roomIdSpec;
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

  /// Switch to a new room. Supports both numeric and string room IDs.
  void switchRoom(String newRoomId) {
    if (_trtcCloud == null || newRoomId.isEmpty) return;
    isSwitching.value = true;
    switchResult.value = null;

    final parsed = int.tryParse(newRoomId);
    final config = TRTCSwitchRoomConfig(
      userSig: GenerateTestUserSig.genTestSig(userId),
      roomId: parsed ?? 0,
      strRoomId: parsed != null ? '' : newRoomId,
    );
    _trtcCloud?.switchRoom(config);
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
      onError: (code, msg) => debugPrint('SwitchRoom onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId] ??
            (_remoteUsers[remoteUserId] = RemoteUser(userId: remoteUserId));
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
      onSwitchRoom: (errCode, errMsg) {
        isSwitching.value = false;
        if (errCode == 0) {
          // Update current room spec based on the pending switch
          // The new room ID was already passed to switchRoom; we update here.
          switchResult.value = 'success';
          // Clear remote users from the old room
          _remoteUsers.clear();
        } else {
          switchResult.value = 'failed:$errCode:$errMsg';
        }
        notifyListeners();
      },
    );
  }

  /// Called from the page after switchRoom succeeds to update the displayed
  /// room ID, since onSwitchRoom doesn't carry the new room ID.
  void updateCurrentRoomId(RoomIdSpec newSpec) {
    _currentRoomSpec = newSpec;
    notifyListeners();
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

class RemoteUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable = false;
  RemoteUser({required this.userId});
}
