import 'package:api_example/common/user_list_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

import '../../../debug/generate_test_user_sig.dart';

class ScreenshotState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  UserListState? userListState;

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);
  ValueNotifier<bool> isLocalVideoEnabled = ValueNotifier(true);

  ValueNotifier<String> snapUserId = ValueNotifier("");
  ValueNotifier<TRTCSnapshotSourceType> sourceType = ValueNotifier(TRTCSnapshotSourceType.stream);
  ValueNotifier<String?> snapPath = ValueNotifier(null);

  String _truncatePath(String path) {
    final parts = path.split('/');
    return parts.length > 1 ? '.../${parts.last}' : path;
  }

  void initialize(TRTCCloud? trtcCloud, UserListState state)  {
    if (_isInitialized) return;
    _trtcCloud = trtcCloud;
    _listener = getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
    userListState = state;
    _isInitialized = true;
  }

  TRTCCloudListener getTRTCCloudListener() {
    return TRTCCloudListener(
        onSnapshotComplete: (userId, path, errCode, errMsg) {
          print("ScreenshotState onSnapshotComplete: $userId, $path, $errCode, $errMsg");
          if (errCode == 0) {
            Fluttertoast.showToast(msg: "snapshot success");
          } else {
            Fluttertoast.showToast(msg: "snapshot failed, $errMsg");
          }
          notifyListeners();
        }
    );
  }

  void enterRoom() {
    if (localUserId == null || roomId == null) {
      print("ScreenshotState localUserId or roomId is null");
      Fluttertoast.showToast(msg: "localUserId or roomId is null");
      return;
    }

    _trtcCloud?.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId,
            userId: localUserId!,
            roomId: roomId!,
            role: TRTCRoleType.anchor,
            userSig: GenerateTestUserSig.genTestSig(localUserId!)
        ), TRTCAppScene.videoCall);
    userListState?.setLocalUser(localUserId!);
    isEnterRoom.value = true;
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    isEnterRoom.value = false;
  }

  void snapShotVideo() {
    _trtcCloud?.snapshotVideo(
        snapUserId.value == localUserId ? "" : snapUserId.value,
        TRTCVideoStreamType.big,
        sourceType.value
    );
  }

  @override
  void dispose() {
    super.dispose();
    exitRoom();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    TRTCCloud.destroySharedInstance();
  }

}