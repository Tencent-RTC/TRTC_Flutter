import 'package:api_example/common/user_list_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

import '../../../debug/generate_test_user_sig.dart';

class RenderParamsState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  UserListState? userListState;

  // Local render parameters
  ValueNotifier<TRTCVideoRotation> localRotation = ValueNotifier(TRTCVideoRotation.rotation0);
  ValueNotifier<TRTCVideoFillMode> localFillMode = ValueNotifier(TRTCVideoFillMode.fill);
  ValueNotifier<TRTCVideoMirrorType> localMirrorType = ValueNotifier(TRTCVideoMirrorType.auto);

  ValueNotifier<String> selectRemoteUserId = ValueNotifier("");
  ValueNotifier<TRTCVideoRotation> remoteRotation = ValueNotifier(TRTCVideoRotation.rotation0);
  ValueNotifier<TRTCVideoFillMode> remoteFillMode = ValueNotifier(TRTCVideoFillMode.fill);
  ValueNotifier<TRTCVideoMirrorType> remoteMirrorType = ValueNotifier(TRTCVideoMirrorType.auto);

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);

  // Remote render parameters (stored per user)
  final Map<String, TRTCRenderParams> _remoteRenderParams = {};

  void initialize(TRTCCloud? trtcCloud, UserListState state)  {
    if (_isInitialized) return;
    _trtcCloud = trtcCloud;
    userListState = state;
    _isInitialized = true;
    setLocalRenderParamsListener();
  }

  void setLocalRenderParamsListener() {
    final listener = [localRotation, localFillMode, localMirrorType];
    for (var notifier in listener) {
      notifier.addListener(() {
        setLocalRenderParams();
      });
    }

    final remoteListener = [remoteRotation, remoteFillMode, remoteMirrorType];
    for (var notifier in remoteListener) {
      notifier.addListener(() {
        setRemoteRenderParams();
      });
    }
  }

  void enterRoom() {
    if (localUserId == null || roomId == null) {
      print("localUserId or roomId is null");
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

  @override
  void dispose() {
    super.dispose();
    exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  void setLocalRenderParams() {
    _trtcCloud?.setLocalRenderParams(TRTCRenderParams(
      rotation: localRotation.value,
      fillMode: localFillMode.value,
      mirrorType: localMirrorType.value,
    ));
  }

  void setRemoteRenderParams() {
    if (selectRemoteUserId.value.isEmpty) {
      print("selectRemoteUserId is null");
      return;
    }
    _trtcCloud?.setRemoteRenderParams(selectRemoteUserId.value, TRTCVideoStreamType.big, TRTCRenderParams(
      rotation: remoteRotation.value,
      fillMode: remoteFillMode.value,
      mirrorType: remoteMirrorType.value,
    ));
  }

  void updateUserRenderParams(String userId, TRTCVideoStreamType streamType) {
    final params = _remoteRenderParams[userId] ?? TRTCRenderParams(
      rotation: TRTCVideoRotation.rotation0,
      fillMode: TRTCVideoFillMode.fill,
      mirrorType: TRTCVideoMirrorType.auto,
    );

    remoteRotation.value = params.rotation;
    remoteFillMode.value = params.fillMode;
    remoteMirrorType.value = params.mirrorType;
  }

  // Get remote render params for a specific user
  TRTCRenderParams? getRemoteRenderParams(String userId) {
    return _remoteRenderParams[userId];
  }
}