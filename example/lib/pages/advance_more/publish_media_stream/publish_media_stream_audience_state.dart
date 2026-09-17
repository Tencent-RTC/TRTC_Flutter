import 'package:flutter/foundation.dart';
import 'package:api_example/common/room_id_spec.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

import '../../../debug/generate_test_user_sig.dart';

class PublishMediaStreamAudienceState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;

  bool _isEnterRoom = false;
  String _strRoomId;
  String _userId;

  final Map<String, AudienceRemoteUser> _remoteUsers = {};
  List<AudienceRemoteUser> get remoteUsers => _remoteUsers.values.toList();

  bool get isEnterRoom => _isEnterRoom;
  String get strRoomId => _strRoomId;
  String get userId => _userId;

  PublishMediaStreamAudienceState({
    required String userId,
    required RoomIdSpec roomIdSpec,
  })  : _userId = userId,
        _strRoomId = roomIdSpec.effectiveStrRoomId;

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
          _remoteUsers[userId] ??= AudienceRemoteUser(userId: userId);
        } else {
          _remoteUsers.remove(userId);
        }
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        _remoteUsers.remove(userId);
        notifyListeners();
      },
    );
  }

  void setStrRoomId(String value) {
    _strRoomId = value;
    notifyListeners();
  }

  void setUserId(String value) {
    _userId = value;
    notifyListeners();
  }

  void setRemoteViewId(String userId, int viewId) {
    if (!TRTCCloudVideoView.containsViewId(viewId)) return;
    final user = _remoteUsers[userId];
    if (user == null || user.viewId == viewId) return;
    user.viewId = viewId;
    _trtcCloud?.startRemoteView(userId, TRTCVideoStreamType.big, viewId);
  }

  Future<void> enterRoom() async {
    if (_isEnterRoom) return;

    final spec = RoomIdSpec(strRoomId: _strRoomId);
    final params = TRTCParams(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: _userId,
      roomId: spec.effectiveRoomId,
      strRoomId: spec.effectiveStrRoomId,
      role: TRTCRoleType.audience,
      userSig: GenerateTestUserSig.genTestSig(_userId),
    );

    _trtcCloud?.callExperimentalAPI(
        '{"api": "setFramework", "params": {"framework": 7, "component": 2}}');
    _trtcCloud?.enterRoom(params, TRTCAppScene.live);
    _isEnterRoom = true;
    notifyListeners();
  }

  Future<void> exitRoom() async {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    if (_isEnterRoom) {
      _trtcCloud?.stopAllRemoteView();
      _trtcCloud?.exitRoom();
    }
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
}

class AudienceRemoteUser {
  final String userId;
  int? viewId;

  AudienceRemoteUser({required this.userId});
}
