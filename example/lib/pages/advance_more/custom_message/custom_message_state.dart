import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class CustomMessageState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  CustomMessageState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, MsgRemoteUser> _remoteUsers = {};
  List<MsgRemoteUser> get remoteUsers => _remoteUsers.values.toList();

  final List<MessageEntry> _messages = [];
  List<MessageEntry> get messages => List.unmodifiable(_messages);

  int _missedMsgCount = 0;
  int get missedMsgCount => _missedMsgCount;

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

  bool sendCustomCmdMsg(int cmdId, String data, bool reliable, bool ordered) {
    if (_trtcCloud == null) return false;
    final success = _trtcCloud!.sendCustomCmdMsg(cmdId, data, reliable, ordered);
    _addMessage(MessageEntry(
      type: MessageType.cmd,
      direction: MessageDirection.sent,
      userId: userId,
      data: data,
      cmdId: cmdId,
      reliable: reliable,
      ordered: ordered,
    ));
    return success;
  }

  bool sendSEIMsg(String data, int repeatCount) {
    if (_trtcCloud == null) return false;
    final success = _trtcCloud!.sendSEIMsg(data, repeatCount);
    _addMessage(MessageEntry(
      type: MessageType.sei,
      direction: MessageDirection.sent,
      userId: userId,
      data: data,
      repeatCount: repeatCount,
    ));
    return success;
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void exitRoom() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  void _addMessage(MessageEntry entry) {
    _messages.add(entry);
    if (_messages.length > 100) {
      _messages.removeAt(0);
    }
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('CustomMessage onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = MsgRemoteUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId] ??
            (_remoteUsers[remoteUserId] = MsgRemoteUser(userId: remoteUserId));
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
      onRecvCustomCmdMsg: (remoteUserId, cmdId, seq, message) {
        _addMessage(MessageEntry(
          type: MessageType.cmd,
          direction: MessageDirection.received,
          userId: remoteUserId,
          data: message,
          cmdId: cmdId,
          seq: seq,
        ));
      },
      onRecvSEIMsg: (remoteUserId, message) {
        _addMessage(MessageEntry(
          type: MessageType.sei,
          direction: MessageDirection.received,
          userId: remoteUserId,
          data: message,
        ));
      },
      onMissCustomCmdMsg: (userId, cmdId, errCode, missed) {
        _missedMsgCount += missed;
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

enum MessageType { cmd, sei }
enum MessageDirection { sent, received }

class MessageEntry {
  final MessageType type;
  final MessageDirection direction;
  final String userId;
  final String data;
  final int? cmdId;
  final int? seq;
  final bool? reliable;
  final bool? ordered;
  final int? repeatCount;
  final DateTime timestamp;

  MessageEntry({
    required this.type,
    required this.direction,
    required this.userId,
    required this.data,
    this.cmdId,
    this.seq,
    this.reliable,
    this.ordered,
    this.repeatCount,
  }) : timestamp = DateTime.now();
}

class MsgRemoteUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable = false;
  MsgRemoteUser({required this.userId});
}
