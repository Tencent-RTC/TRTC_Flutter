
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

import '../../../common/user_list_state.dart';
import '../../../debug/generate_test_user_sig.dart';

class SmallVideoStreamState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  UserListState? userListState;

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);

  ValueNotifier<bool> enableSmallVideo = ValueNotifier(false);

  ValueNotifier<bool> displaySmall = ValueNotifier(false);

  ValueNotifier<bool> enableAdjustRes = ValueNotifier(false);
  ValueNotifier<int> minVideoBitrate = ValueNotifier(0);
  ValueNotifier<int> videoBitrate = ValueNotifier(1600);
  ValueNotifier<int> videoFps = ValueNotifier(10);
  ValueNotifier<TRTCVideoResolution> videoResolution = ValueNotifier(TRTCVideoResolution.res_640_360);
  ValueNotifier<TRTCVideoResolutionMode> videoResolutionMode = ValueNotifier(TRTCVideoResolutionMode.portrait);


  void initialize(TRTCCloud? trtcCloud, UserListState state)  {
    if (_isInitialized) return;
    _trtcCloud = trtcCloud;
    userListState = state;
    _isInitialized = true;
  }

  void enterRoom() {
    if (localUserId == null || roomId == null) {
      print("SmallVideoStreamState localUserId or roomId is null");
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

  void enableAllRemoteUserDisplaySmallVideoStream() {
    displaySmall.value = !displaySmall.value;
    if (userListState != null && userListState!.users.isNotEmpty) {
      for (var userEntry in userListState!.users.entries) {
        if (userEntry.key != localUserId) {
          if (displaySmall.value) {
            _trtcCloud?.stopRemoteView(userEntry.key, TRTCVideoStreamType.big);
            _trtcCloud?.startRemoteView(userEntry.key, TRTCVideoStreamType.small, userEntry.value.viewId ?? 0);
          } else {
            _trtcCloud?.stopRemoteView(userEntry.key, TRTCVideoStreamType.small);
            _trtcCloud?.startRemoteView(userEntry.key, TRTCVideoStreamType.big, userEntry.value.viewId ?? 0);
          }
        }
      }
    }
  }

  void enableSmallVideoStream() {
    TRTCVideoEncParam param = TRTCVideoEncParam(
      enableAdjustRes: enableAdjustRes.value,
      minVideoBitrate: minVideoBitrate.value,
      videoBitrate: videoBitrate.value,
      videoFps: videoFps.value,
      videoResolution: videoResolution.value,
      videoResolutionMode: videoResolutionMode.value,
    );

    _trtcCloud?.enableSmallVideoStream(
        enableSmallVideo.value,
        param
    );
  }

  @override
  void dispose() {
    super.dispose();
    exitRoom();
    TRTCCloud.destroySharedInstance();
  }
}