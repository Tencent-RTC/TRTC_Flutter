import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class SmallVideoStreamState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  SmallVideoStreamState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteVideoUser> _remoteUsers = {};
  List<RemoteVideoUser> get remoteUsers => _remoteUsers.values.toList();

  ValueNotifier<bool> enableSmallStream = ValueNotifier(false);
  ValueNotifier<int> smallVideoBitrate = ValueNotifier(400);
  ValueNotifier<int> smallVideoFps = ValueNotifier(15);
  ValueNotifier<TRTCVideoResolution> smallVideoResolution =
      ValueNotifier(TRTCVideoResolution.res_320_180);

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    _enterRoom();
    _addParamListeners();
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
      final type = user.useSmallStream
          ? TRTCVideoStreamType.sub
          : TRTCVideoStreamType.big;
      _trtcCloud?.startRemoteView(remoteUserId, type, viewId);
    }
  }

  void toggleRemoteStreamType(String remoteUserId) {
    final user = _remoteUsers[remoteUserId];
    if (user == null || !user.isVideoAvailable) return;
    user.useSmallStream = !user.useSmallStream;
    if (user.viewId != null && user.viewId! > 0) {
      final type = user.useSmallStream
          ? TRTCVideoStreamType.sub
          : TRTCVideoStreamType.big;
      _trtcCloud?.setRemoteVideoStreamType(remoteUserId, type);
      _trtcCloud?.startRemoteView(remoteUserId, type, user.viewId);
    }
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

  void _addParamListeners() {
    enableSmallStream.addListener(() => _updateSmallVideoStream());
    for (var n in [smallVideoBitrate, smallVideoFps, smallVideoResolution]) {
      n.addListener(() {
        if (enableSmallStream.value) _updateSmallVideoStream();
      });
    }
  }

  void _updateSmallVideoStream() {
    _trtcCloud?.enableSmallVideoStream(
      enableSmallStream.value,
      TRTCVideoEncParam(
        videoBitrate: smallVideoBitrate.value,
        videoFps: smallVideoFps.value,
        videoResolution: smallVideoResolution.value,
      ),
    );
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('SmallVideoStream onError: $code, $msg'),
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
            final type = user.useSmallStream
                ? TRTCVideoStreamType.sub
                : TRTCVideoStreamType.big;
            _trtcCloud?.startRemoteView(remoteUserId, type, user.viewId);
          }
        } else {
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.big);
          _trtcCloud?.stopRemoteView(remoteUserId, TRTCVideoStreamType.sub);
        }
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

class RemoteVideoUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable;
  bool useSmallStream;

  RemoteVideoUser({
    required this.userId,
    this.viewId,
    this.isVideoAvailable = false,
    this.useSmallStream = false,
  });
}
