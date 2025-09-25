import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';
import 'package:api_example/common/user_list_state.dart';

class ScreenShareState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  UserListState? userListState;

  String? _userId;
  int? _roomId;
  bool _isEnterRoom = false;
  bool _isInit = false;
  List<String> logs = [];

  bool get isInit => _isInit;
  bool get isEntered => _isEnterRoom;
  String? get userId => _userId;
  int? get roomId => _roomId;

  Future<void> enterRoom(String userId, int roomId) async {
    _userId = userId;
    _roomId = roomId;
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener ??= _getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
    userListState = UserListState(_trtcCloud!);
    userListState?.setLocalUser(userId);
    _trtcCloud?.enterRoom(
      TRTCParams(
        sdkAppId: GenerateTestUserSig.sdkAppId,
        userId: userId,
        roomId: roomId,
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
      ),
      TRTCAppScene.live,
    );
    _isInit = true;
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
    notifyListeners();
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    notifyListeners();
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
      onEnterRoom: (result) {
        if (result > 0) {
          _isEnterRoom = true;
          if (_userId != null) {
            userListState?.setLocalUser(_userId!);
            userListState?.refreshUserListWidget();
          }
        } else {
          _isEnterRoom = false;
        }
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onError: (code, msg) {
        logs.insert(0, 'Error: $msg($code)');
        notifyListeners();
      },
    );
  }

  // 屏幕共享相关方法
  void startScreenShare() {
    TRTCVideoEncParam param = TRTCVideoEncParam();
    param.videoResolution = TRTCVideoResolution.res_1920_1080;
    param.videoResolutionMode = TRTCVideoResolutionMode.landscape;
    _trtcCloud?.startScreenCapture(0, TRTCVideoStreamType.sub, param);
    logs.insert(0, 'Start screen share');
    notifyListeners();
  }

  void stopScreenShare() {
    _trtcCloud?.stopScreenCapture();
    logs.insert(0, 'Stop screen share');
    notifyListeners();
  }

  @override
  void dispose() {
    userListState?.dispose();
    TRTCCloud.destroySharedInstance();
    super.dispose();
  }
} 