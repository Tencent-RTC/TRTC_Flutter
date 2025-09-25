import 'package:api_example/common/user_list_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

import '../../../debug/generate_test_user_sig.dart';

class LocalRecordState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  UserListState? userListState;

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);

  ValueNotifier<bool> isRecording = ValueNotifier(false);
  ValueNotifier<String> filePath = ValueNotifier("");
  ValueNotifier<TRTCLocalRecordType> recordType = ValueNotifier(TRTCLocalRecordType.both);
  ValueNotifier<int> interval = ValueNotifier(-1);
  ValueNotifier<int> maxDurationPerFile = ValueNotifier(0);

  void initialize(TRTCCloud? trtcCloud, UserListState state)  {
    if (_isInitialized) return;
    _trtcCloud = trtcCloud;
    _listener = getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
    userListState = state;
    _isInitialized = true;
    setLocalRecordListener();
  }

  void setLocalRecordListener() {
    isRecording.addListener(() {
      updateLocalRecordingState();
    });
  }

  TRTCCloudListener getTRTCCloudListener() {
    return TRTCCloudListener(
      onLocalRecordBegin: (code, storagePath) {
        print("onLocalRecordBegin: $code, $storagePath");
        Fluttertoast.showToast(msg: "onLocalRecordBegin: $code, $storagePath");
      },
      onLocalRecording: (duration, storagePath) {
        print("onLocalRecording: $duration, $storagePath");
        Fluttertoast.showToast(msg: "onLocalRecording: $duration, $storagePath");
      },
      onLocalRecordFragment: (storagePath) {
        print("onLocalRecordFragment: $storagePath");
        Fluttertoast.showToast(msg: "onLocalRecordFragment: $storagePath");
      },
      onLocalRecordComplete: (code, storagePath) {
        print("onLocalRecordComplete: $code, $storagePath");
        Fluttertoast.showToast(msg: "onLocalRecordComplete: $code, $storagePath");
      },
    );
  }

  void enterRoom() {
    if (localUserId == null || roomId == null) {
      print("VideoContentState localUserId or roomId is null");
      Fluttertoast.showToast(msg: "User ID or Room ID cannot be empty");
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
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.speech);
    isEnterRoom.value = true;
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    isEnterRoom.value = false;
  }

  Future<String> _getRecordingPath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, '$fileName.mp4');
  }

  void updateLocalRecordingState() async {
    if (isRecording.value) {
      if (interval.value != -1 && (interval.value < 1000 || interval.value > 10000)) {
        Fluttertoast.showToast(msg: "Recording interval must be -1 or between 1000-10000 ms");
        isRecording.value = false;
        return;
      }
      if (maxDurationPerFile.value != 0 && maxDurationPerFile.value < 10000) {
        Fluttertoast.showToast(msg: "Max file duration must be 0 or ≥10000 ms");
        isRecording.value = false;
        return;
      }
      final fullPath = await _getRecordingPath(filePath.value);
      _trtcCloud?.startLocalRecording(TRTCLocalRecordingParams(
        filePath: fullPath,
        recordType: recordType.value,
        interval: interval.value,
        maxDurationPerFile: maxDurationPerFile.value,
      ));
    } else {
      _trtcCloud?.stopLocalRecording();
    }
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