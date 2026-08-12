import 'package:api_example/common/user_list_state.dart';
import 'package:api_example/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

import '../../../debug/generate_test_user_sig.dart';

class VideoMuteImageState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  UserListState? userListState;

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);
  ValueNotifier<bool> isLocalVideoEnabled = ValueNotifier(true);

  List<String> pathList = ["assets/images/avatar3.png",
                           "assets/images/user_icon.png",
                           "assets/images/watermark_img.png"];

  ValueNotifier<String> imagePath = ValueNotifier("");
  ValueNotifier<int> fps = ValueNotifier(10);


  void initialize(TRTCCloud? trtcCloud, UserListState state)  {
    if (_isInitialized) return;
    _trtcCloud = trtcCloud;
    userListState = state;
    _isInitialized = true;
  }

  void enterRoom() {
    if (localUserId == null || roomId == null) {
      print("VideoMuteImageState localUserId or roomId is null");
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

  void muteLocalVideo() {
    if (_trtcCloud == null) return;
    _trtcCloud!.muteLocalVideo(TRTCVideoStreamType.big, isLocalVideoEnabled.value);
    isLocalVideoEnabled.value = !isLocalVideoEnabled.value;
    notifyListeners();
  }

  void setVideoMuteImage() async {
    if (imagePath.value.isEmpty) {
      print("VideoMuteImageState imagePath is empty");
      Fluttertoast.showToast(msg: "imagePath is empty");
      return;
    }
    String path = await Utils.getAssetsFilePath(imagePath.value);
    _trtcCloud?.setVideoMuteImage(path, fps.value);
  }

  @override
  void dispose() {
    super.dispose();
    exitRoom();
    TRTCCloud.destroySharedInstance();
  }

}