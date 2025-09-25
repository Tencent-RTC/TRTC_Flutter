import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';

class SetWatermarkState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEntered = false;
  String? _userId;
  int? _roomId;
  String _imagePath = '';
  TRTCVideoStreamType _streamType = TRTCVideoStreamType.big;
  double _x = 0.01;
  double _y = 0.01;
  double _width = 0.2;

  bool get isEntered => _isEntered;
  String? get userId => _userId;
  int? get roomId => _roomId;
  String get imagePath => _imagePath;
  TRTCVideoStreamType get streamType => _streamType;
  double get x => _x;
  double get y => _y;
  double get width => _width;

  Future<void> enterRoom(String userId, int roomId) async {
    _userId = userId;
    _roomId = roomId;
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener ??= _getTRTCCloudListener();
    _trtcCloud?.registerListener(_listener!);
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
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void setWatermark(String imagePath, TRTCVideoStreamType streamType, double x, double y, double width) {
    _imagePath = imagePath;
    _streamType = streamType;
    _x = x;
    _y = y;
    _width = width;
    _trtcCloud?.setWatermark(imagePath, streamType, x, y, width);
    notifyListeners();
  }

  TRTCCloudListener _getTRTCCloudListener() {
    return TRTCCloudListener(
      onEnterRoom: (result) {
        _isEntered = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEntered = false;
        notifyListeners();
      },
      onError: (code, msg) {
        notifyListeners();
      },
    );
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    _isEntered = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _trtcCloud?.unRegisterListener(_listener!);
    _trtcCloud?.exitRoom();
    super.dispose();
  }
} 