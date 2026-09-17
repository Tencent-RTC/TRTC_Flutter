import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import '../../../debug/generate_test_user_sig.dart';
import '../../../utils/utils.dart';

class SetWatermarkState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  SetWatermarkState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;
  String? _watermarkPath;

  bool get isEnterRoom => _isEnterRoom;

  TRTCVideoStreamType _streamType = TRTCVideoStreamType.big;
  double _x = 0.01;
  double _y = 0.01;
  double _width = 0.2;

  TRTCVideoStreamType get streamType => _streamType;
  double get x => _x;
  double get y => _y;
  double get watermarkWidth => _width;

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    // Pre-load watermark image to temp file path
    _watermarkPath = await Utils.getAssetsFilePath('assets/images/watermark_img.png');
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
    _applyWatermark();
  }

  void setStreamType(TRTCVideoStreamType type) {
    _streamType = type;
    _applyWatermark();
    notifyListeners();
  }

  void setX(double value) {
    _x = value;
    _applyWatermark();
    notifyListeners();
  }

  void setY(double value) {
    _y = value;
    _applyWatermark();
    notifyListeners();
  }

  void setWidth(double value) {
    _width = value;
    _applyWatermark();
    notifyListeners();
  }

  void _applyWatermark() {
    if (_watermarkPath == null || _watermarkPath!.isEmpty) return;
    _trtcCloud?.setWatermark(_watermarkPath!, _streamType, _x, _y, _width);
  }

  void exitRoom() {
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('Watermark onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        if (_isEnterRoom) _applyWatermark();
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
