import 'package:api_example/common/user_list_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

import '../../../debug/generate_test_user_sig.dart';

class VideoQualityState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isInitializing = false;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  List<UserInfo> users = [];
  UserListState? userListState;

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);
  ValueNotifier<bool> enableAdjustRes = ValueNotifier(false);
  ValueNotifier<int> minVideoBitrate = ValueNotifier(0);
  ValueNotifier<int> videoBitrate = ValueNotifier(1600);
  ValueNotifier<int> videoFps = ValueNotifier(10);
  ValueNotifier<TRTCVideoResolution> videoResolution = ValueNotifier(TRTCVideoResolution.res_1280_720);
  ValueNotifier<TRTCVideoResolutionMode> videoResolutionMode = ValueNotifier(TRTCVideoResolutionMode.portrait);
  ValueNotifier<TRTCVideoQosPreference> preference = ValueNotifier(TRTCVideoQosPreference.clear);

  void initialize(TRTCCloud? trtcCloud, UserListState state) {
    if (_isInitializing || _isInitialized) return;
    _isInitializing = true;

    userListState = state;
    try {
      _trtcCloud = trtcCloud;
      _listener = _getTRTCCloudListener();
      if (_listener != null) {
        _trtcCloud?.registerListener(_listener!);
      }
      _isInitialized = true;
      addParamListener();
      notifyListeners();
    } finally {
      _isInitializing = false;
    }
  }

  void enterRoom(String userId, int roomId) {
    localUserId = userId;
    this.roomId = roomId;

    _trtcCloud?.enterRoom(
        TRTCParams(
            sdkAppId: GenerateTestUserSig.sdkAppId,
            userId: userId,
            roomId: roomId,
            role: TRTCRoleType.anchor,
            userSig: GenerateTestUserSig.genTestSig(userId)
        ), TRTCAppScene.live);
    userListState?.setLocalUser(userId);
    isEnterRoom.value = true;
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    isEnterRoom.value = false;
  }

  @override
  void dispose() {
    super.dispose();
    _trtcCloud?.exitRoom();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    TRTCCloud.destroySharedInstance();
  }

  void addParamListener() {
    final listener = [enableAdjustRes, minVideoBitrate, videoBitrate, videoFps, videoResolution, videoResolutionMode];
    for (var element in listener) {
      element.addListener(() {
        setVideoEncParam();
      });
    }

    preference.addListener(() {
      setNetworkQosParam();
    });
  }

  void stopAllRemoteView() {
    _trtcCloud?.stopAllRemoteView();
  }

  _getTRTCCloudListener() {
    return TRTCCloudListener(
      onError: (code, msg) {
        print("TRTCAPIExample onError: $code, $msg");
      },
      onUserVideoAvailable: (userId, available) {
        print("TRTCAPIExample onUserVideoAvailable: $userId, $available");
      },
    );
  }

  void setNetworkQosParam() {
    TRTCNetworkQosParam param = TRTCNetworkQosParam(
      preference: preference.value,
    );
    _trtcCloud?.setNetworkQosParam(param);
  }

  void setVideoEncParam() {
    TRTCVideoEncParam param = TRTCVideoEncParam(
      enableAdjustRes: enableAdjustRes.value,
      minVideoBitrate: minVideoBitrate.value,
      videoBitrate: videoBitrate.value,
      videoFps: videoFps.value,
      videoResolution: videoResolution.value,
      videoResolutionMode: videoResolutionMode.value,
    );
    _trtcCloud?.setVideoEncoderParam(param);
  }

}