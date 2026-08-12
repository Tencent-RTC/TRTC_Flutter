import 'package:flutter/foundation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:api_example/debug/generate_test_user_sig.dart';

class SetBeautyStyleState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEntered = false;
  String? _userId;
  int? _roomId;
  TRTCBeautyStyle _style = TRTCBeautyStyle.smooth;
  int _beautyLevel = 5;
  int _whitenessLevel = 5;
  int _ruddinessLevel = 5;

  bool get isEntered => _isEntered;
  String? get userId => _userId;
  int? get roomId => _roomId;
  TRTCBeautyStyle get style => _style;
  int get beautyLevel => _beautyLevel;
  int get whitenessLevel => _whitenessLevel;
  int get ruddinessLevel => _ruddinessLevel;

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

  void setBeautyStyle(TRTCBeautyStyle style, int beautyLevel, int whitenessLevel, int ruddinessLevel) {
    _style = style;
    _beautyLevel = beautyLevel;
    _whitenessLevel = whitenessLevel;
    _ruddinessLevel = ruddinessLevel;
    _trtcCloud?.setBeautyStyle(style, beautyLevel, whitenessLevel, ruddinessLevel);
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