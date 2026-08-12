import 'package:flutter/cupertino.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

class UserInfo extends ChangeNotifier{
  String userId;
  int? viewId;
  bool isLocalUser;

  UserInfo({
    required this.userId,
    this.isLocalUser = false,
  });

  void refreshUserWidget() {
    notifyListeners();
  }
}

class UserListState extends ChangeNotifier {
  TRTCCloud _trtcCloud;
  late TRTCCloudListener _listener;

  String _localUserId = 'none';
  Map<String, UserInfo> users = {};

  UserListState(this._trtcCloud) {
    _listener = getTRTCCloudListener();
    _trtcCloud.registerListener(_listener);
  }

  @override
  dispose() {
    super.dispose();
    users.clear();
    _trtcCloud.unRegisterListener(_listener);
  }

  setLocalUser(String userId) {
    _localUserId = userId;
  }

  refreshUserListWidget() {
    notifyListeners();
  }

  startStreamView(String userId, TRTCVideoStreamType streamType) {
    if (users[userId]?.viewId != null) {
      if (users[userId]!.isLocalUser) {
        _trtcCloud.startLocalPreview(true, users[userId]!.viewId!);
      } else {
        _trtcCloud.startRemoteView(userId, streamType, users[userId]!.viewId!);
      }
    }
  }

  TRTCCloudListener getTRTCCloudListener() {
    return TRTCCloudListener(
      onEnterRoom: (result) {
        users[_localUserId] = UserInfo(userId: _localUserId, isLocalUser: true);
        refreshUserListWidget();
      },
      onExitRoom: (reason) {
        users.clear();
        refreshUserListWidget();
      },
      onRemoteUserEnterRoom: (userId) {
        users[userId] = UserInfo(userId: userId, isLocalUser: false);
        refreshUserListWidget();
      },
      onRemoteUserLeaveRoom: (userId, reason) {
        users.remove(userId);
        refreshUserListWidget();
      },
    );
  }
}