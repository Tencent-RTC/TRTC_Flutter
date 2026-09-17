import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

import '../../../debug/generate_test_user_sig.dart';

class VideoQualityState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  VideoQualityState({
    required this.userId,
    required this.roomIdSpec,
  });

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteVideoUser> _remoteUsers = {};
  List<RemoteVideoUser> get remoteUsers => _remoteUsers.values.toList();

  TRTCQuality _localQuality = TRTCQuality.unknown;
  TRTCQuality get localQuality => _localQuality;

  ValueNotifier<bool> enableAdjustRes = ValueNotifier(false);
  ValueNotifier<int> minVideoBitrate = ValueNotifier(0);
  ValueNotifier<int> videoBitrate = ValueNotifier(1600);
  ValueNotifier<int> videoFps = ValueNotifier(15);
  ValueNotifier<TRTCVideoResolution> videoResolution =
      ValueNotifier(TRTCVideoResolution.res_1280_720);
  ValueNotifier<TRTCVideoResolutionMode> videoResolutionMode =
      ValueNotifier(TRTCVideoResolutionMode.portrait);
  ValueNotifier<TRTCVideoQosPreference> preference =
      ValueNotifier(TRTCVideoQosPreference.clear);
  ValueNotifier<bool> videoEncoderMirror = ValueNotifier(false);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
    addParamListener();
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
        role: TRTCRoleType.anchor,
        userSig: GenerateTestUserSig.genTestSig(userId),
      ),
      TRTCAppScene.live,
    );
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
    setVideoEncParam();
    setNetworkQosParam();
    setVideoEncoderMirror();
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
      _trtcCloud?.startRemoteView(
          remoteUserId, TRTCVideoStreamType.big, viewId);
    }
  }

  void exitRoom() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  void addParamListener() {
    final encListeners = [
      enableAdjustRes,
      minVideoBitrate,
      videoBitrate,
      videoFps,
      videoResolution,
      videoResolutionMode,
    ];
    for (var element in encListeners) {
      element.addListener(() => setVideoEncParam());
    }
    videoEncoderMirror.addListener(() => setVideoEncoderMirror());
    preference.addListener(() => setNetworkQosParam());
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
      onError: (code, msg) {
        debugPrint('VideoQuality onError: $code, $msg');
      },
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteVideoUser(userId: remoteUserId);
        notifyListeners();
      },
      onRemoteUserLeaveRoom: (remoteUserId, reason) {
        _remoteUsers.remove(remoteUserId);
        notifyListeners();
      },
      onUserVideoAvailable: (remoteUserId, available) {
        final user = _remoteUsers[remoteUserId];
        if (user == null) return;
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
      onNetworkQuality: (localQuality, remoteQuality) {
        _localQuality = localQuality.quality;
        for (var rq in remoteQuality) {
          final user = _remoteUsers[rq.userId];
          if (user != null) {
            user.quality = rq.quality;
          }
        }
        notifyListeners();
      },
    );
  }

  void setNetworkQosParam() {
    _trtcCloud?.setNetworkQosParam(
      TRTCNetworkQosParam(preference: preference.value),
    );
  }

  void setVideoEncParam() {
    _trtcCloud?.setVideoEncoderParam(
      TRTCVideoEncParam(
        enableAdjustRes: enableAdjustRes.value,
        minVideoBitrate: minVideoBitrate.value,
        videoBitrate: videoBitrate.value,
        videoFps: videoFps.value,
        videoResolution: videoResolution.value,
        videoResolutionMode: videoResolutionMode.value,
      ),
    );
  }

  void setVideoEncoderMirror() {
    _trtcCloud?.setVideoEncoderMirror(videoEncoderMirror.value);
  }

  @override
  void dispose() {
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    super.dispose();
  }
}

class RemoteVideoUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable;
  TRTCQuality quality;

  RemoteVideoUser({
    required this.userId,
    this.viewId,
    this.isVideoAvailable = false,
    this.quality = TRTCQuality.unknown,
  });
}
