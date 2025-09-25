import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';

class SwitchRoomState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  String? _userId;
  int? _roomId;
  String _statusMessage = 'Not in room';
  bool _isEnterRoom = false;
  bool _isSwitching = false;
  int? _pendingRoomId; // 用于切换房间时暂存目标房间号

  UserListState? userListState;

  String? get userId => _userId;
  int? get roomId => _roomId;
  String get statusMessage => _statusMessage;
  bool get isEnterRoom => _isEnterRoom;
  bool get isSwitching => _isSwitching;

  Future<void> enterRoom(String userId, int roomId) async {
    _userId = userId;
    _roomId = roomId;
    _statusMessage = 'Entering room...';
    notifyListeners();
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener ??= _getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
    userListState = UserListState(_trtcCloud!);
    userListState?.setLocalUser(userId);
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomId,
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.live,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void switchRoom(int newRoomId) {
    if (_trtcCloud == null || _userId == null) return;
    _isSwitching = true;
    _statusMessage = 'Switching room...';
    _pendingRoomId = newRoomId;
    notifyListeners();
    final config = TRTCSwitchRoomConfig(
      userSig: GenerateTestUserSig.genTestSig(_userId!),
      roomId: newRoomId,
    );
    _trtcCloud?.switchRoom(config);
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _statusMessage = 'Exited room';
    notifyListeners();
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
      onEnterRoom: (result) {
        if (result > 0) {
          _isEnterRoom = true;
          _statusMessage = 'Enter room success';
        } else {
          _isEnterRoom = false;
          _statusMessage = 'Enter room failed: $result';
        }
        notifyListeners();
      },
      onSwitchRoom: (errCode, errMsg) {
        _isSwitching = false;
        if (errCode == 0) {
          // Switch room success, update roomId and rebuild userListState
          if (_trtcCloud != null && _userId != null) {
            userListState = UserListState(_trtcCloud!);
            userListState?.setLocalUser(_userId!);
            // Manually trigger local user stream pull logic
            userListState?.users[_userId!] = UserInfo(userId: _userId!, isLocalUser: true);
            userListState?.refreshUserListWidget();
          }
          if (_pendingRoomId != null) {
            _roomId = _pendingRoomId;
            _pendingRoomId = null;
          }
          _statusMessage = 'Switch room success';
        } else {
          _statusMessage = 'Switch room failed: $errMsg($errCode)';
        }
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        _statusMessage = 'Exited room';
        notifyListeners();
      },
      onError: (code, msg) {
        _statusMessage = 'Error: $msg($code)';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    userListState?.dispose();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
} 