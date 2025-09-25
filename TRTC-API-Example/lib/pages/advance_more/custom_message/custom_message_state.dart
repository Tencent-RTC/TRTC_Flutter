import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';
 

class CustomMessageState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  String? _userId;
  int? _roomId;
  String _statusMessage = 'Not in room';
  bool _isEnterRoom = false;

  UserListState? userListState;

  final List<String> _messages = <String>[];
  List<String> get messages => List.unmodifiable(_messages);

  String? get userId => _userId;
  int? get roomId => _roomId;
  String get statusMessage => _statusMessage;
  bool get isEnterRoom => _isEnterRoom;

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

  bool sendCustomCmdMsg(int cmdId, String data, {bool reliable = true, bool ordered = true}) {
    if (_trtcCloud == null) return false;
    return _trtcCloud!.sendCustomCmdMsg(cmdId, data, reliable, ordered);
  }

  bool sendSEIMsg(String data, int repeatCount) {
    if (_trtcCloud == null) return false;
    return _trtcCloud!.sendSEIMsg(data, repeatCount);
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
      onRecvCustomCmdMsg: (userId, cmdId, seq, message) {
        print("trtc-api onRecvCustomCmdMsg: userId:$userId cmdId:$cmdId seq:$seq message:$message");
        _appendMessage('[CMD][$userId] id:$cmdId seq:$seq -> $message');
      },
      onRecvSEIMsg: (userId, message) {
        print("trtc-api onRecvCustomCmdMsg: userId:$userId message:$message");
        _appendMessage('[SEI][$userId] -> $message');
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

  void _appendMessage(String text) {
    final DateTime now = DateTime.now();
    final String time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    _messages.add('[$time] $text');
    if (_messages.length > 100) {
      _messages.removeAt(0);
    }
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    userListState?.dispose();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
} 