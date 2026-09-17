import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';

class SetBeautyStyleState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  SetBeautyStyleState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;

  TRTCBeautyStyle _style = TRTCBeautyStyle.smooth;
  int _beautyLevel = 5;
  int _whitenessLevel = 5;
  int _ruddinessLevel = 5;

  TRTCBeautyStyle get style => _style;
  int get beautyLevel => _beautyLevel;
  int get whitenessLevel => _whitenessLevel;
  int get ruddinessLevel => _ruddinessLevel;

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
        userSig: GenerateTestUserSig.genTestSig(userId),
        role: TRTCRoleType.anchor,
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
    // Apply initial beauty settings once preview starts
    _applyBeauty();
  }

  void setStyle(TRTCBeautyStyle style) {
    _style = style;
    _applyBeauty();
    notifyListeners();
  }

  void setBeautyLevel(int level) {
    _beautyLevel = level;
    _applyBeauty();
    notifyListeners();
  }

  void setWhitenessLevel(int level) {
    _whitenessLevel = level;
    _applyBeauty();
    notifyListeners();
  }

  void setRuddinessLevel(int level) {
    _ruddinessLevel = level;
    _applyBeauty();
    notifyListeners();
  }

  void _applyBeauty() {
    _trtcCloud?.setBeautyStyle(_style, _beautyLevel, _whitenessLevel, _ruddinessLevel);
  }

  void exitRoom() {
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('BeautyStyle onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        if (_isEnterRoom) _applyBeauty();
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    if (_listener != null) _trtcCloud?.unRegisterListener(_listener!);
    super.dispose();
  }
}
