import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';

import '../../../debug/generate_test_user_sig.dart';

class LocalRecordState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  LocalRecordState({
    required this.userId,
    required this.roomIdSpec,
  });

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  final Map<String, RemoteRecordUser> _remoteUsers = {};
  List<RemoteRecordUser> get remoteUsers => _remoteUsers.values.toList();

  ValueNotifier<bool> isRecording = ValueNotifier(false);
  ValueNotifier<String> filePath = ValueNotifier('local_record');
  ValueNotifier<TRTCLocalRecordType> recordType =
      ValueNotifier(TRTCLocalRecordType.both);
  ValueNotifier<int> interval = ValueNotifier(-1);
  ValueNotifier<int> maxDurationPerFile = ValueNotifier(0);

  // Record event for UI toast (format: "type:detail")
  ValueNotifier<String?> recordEvent = ValueNotifier(null);

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
      _trtcCloud?.startRemoteView(
          remoteUserId, TRTCVideoStreamType.big, viewId);
    }
  }

  void exitRoom() {
    if (isRecording.value) {
      _trtcCloud?.stopLocalRecording();
      isRecording.value = false;
    }
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    _remoteUsers.clear();
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      _trtcCloud?.stopLocalRecording();
      isRecording.value = false;
    } else {
      if (interval.value != -1 &&
          (interval.value < 1000 || interval.value > 10000)) {
        recordEvent.value = 'error:interval';
        return;
      }
      if (maxDurationPerFile.value != 0 && maxDurationPerFile.value < 10000) {
        recordEvent.value = 'error:maxDuration';
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final fullPath =
          path.join(dir.path, '${filePath.value.isEmpty ? "local_record" : filePath.value}.mp4');
      _trtcCloud?.startLocalRecording(TRTCLocalRecordingParams(
        filePath: fullPath,
        recordType: recordType.value,
        interval: interval.value,
        maxDurationPerFile: maxDurationPerFile.value,
      ));
      isRecording.value = true;
    }
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) {
        debugPrint('LocalRecord onError: $code, $msg');
      },
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onRemoteUserEnterRoom: (remoteUserId) {
        _remoteUsers[remoteUserId] = RemoteRecordUser(userId: remoteUserId);
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
      onLocalRecordBegin: (code, storagePath) {
        recordEvent.value = 'begin:$code:$storagePath';
      },
      onLocalRecording: (duration, storagePath) {
        recordEvent.value = 'progress:$duration:$storagePath';
      },
      onLocalRecordFragment: (storagePath) {
        recordEvent.value = 'fragment:$storagePath';
      },
      onLocalRecordComplete: (code, storagePath) {
        recordEvent.value = 'complete:$code:$storagePath';
      },
    );
  }

  @override
  void dispose() {
    if (isRecording.value) {
      _trtcCloud?.stopLocalRecording();
    }
    _trtcCloud?.stopAllRemoteView();
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) {
      _trtcCloud?.unRegisterListener(_listener!);
    }
    super.dispose();
  }
}

class RemoteRecordUser {
  final String userId;
  int? viewId;
  bool isVideoAvailable;

  RemoteRecordUser({
    required this.userId,
    this.viewId,
    this.isVideoAvailable = false,
  });
}
