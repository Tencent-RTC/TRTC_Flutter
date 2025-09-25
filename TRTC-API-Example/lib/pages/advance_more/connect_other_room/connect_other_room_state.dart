import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';
import 'dart:convert';

class ConnectOtherRoomState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  String? _userId;
  int? _roomId;
  String _statusMessage = 'Not in room';
  bool _isEnterRoom = false;
  bool _isConnecting = false;
  bool _isConnected = false;
  String? _targetUserId;
  int? _targetRoomId;

  UserListState? userListState;

  String? get userId => _userId;
  int? get roomId => _roomId;
  String get statusMessage => _statusMessage;
  bool get isEnterRoom => _isEnterRoom;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;
  String? get targetUserId => _targetUserId;
  int? get targetRoomId => _targetRoomId;

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

  void connectOtherRoom(int targetRoomId, String targetUserId) {
    if (_trtcCloud == null) return;
    _isConnecting = true;
    _statusMessage = 'Connecting to other room...';
    _targetRoomId = targetRoomId;
    _targetUserId = targetUserId;
    notifyListeners();
    final jsonStr = jsonEncode({
      'roomId': targetRoomId,
      'userId': targetUserId,
    });
    _trtcCloud?.connectOtherRoom(jsonStr);
  }

  void disconnectOtherRoom() {
    if (_trtcCloud == null) return;
    _isConnecting = true;
    _statusMessage = 'Disconnecting from other room...';
    notifyListeners();
    _trtcCloud?.disconnectOtherRoom();
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
      onConnectOtherRoom: (userId, errCode, errMsg) {
        _isConnecting = false;
        if (errCode == 0) {
          _isConnected = true;
          _statusMessage = 'Connect other room success';
        } else {
          _isConnected = false;
          _statusMessage = 'Connect other room failed: $errMsg($errCode)';
        }
        notifyListeners();
      },
      onDisconnectOtherRoom: (errCode, errMsg) {
        _isConnecting = false;
        if (errCode == 0) {
          _isConnected = false;
          _statusMessage = 'Disconnect other room success';
        } else {
          _statusMessage = 'Disconnect other room failed: $errMsg($errCode)';
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