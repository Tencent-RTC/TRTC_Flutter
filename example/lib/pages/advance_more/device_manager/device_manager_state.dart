import 'package:api_example/common/room_id_spec.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import '../../../debug/generate_test_user_sig.dart';

class DeviceManagerState extends ChangeNotifier {
  final String userId;
  final RoomIdSpec roomIdSpec;

  DeviceManagerState({required this.userId, required this.roomIdSpec});

  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  TRTCCloudListener? _listener;
  bool _isEnterRoom = false;
  int? _localViewId;

  bool get isEnterRoom => _isEnterRoom;
  TXDeviceManager? get deviceManager => _deviceManager;

  ValueNotifier<bool> frontCamera = ValueNotifier(true);
  ValueNotifier<double> cameraZoomRatio = ValueNotifier(1.0);
  ValueNotifier<bool> cameraAutoFocus = ValueNotifier(false);
  ValueNotifier<bool> cameraTorch = ValueNotifier(false);
  ValueNotifier<TXAudioRoute> audioRoute = ValueNotifier(TXAudioRoute.speakerPhone);
  ValueNotifier<String?> resultMessage = ValueNotifier(null);

  double focusPositionX = 0.5;
  double focusPositionY = 0.5;
  int captureWidth = 640;
  int captureHeight = 360;
  TXCameraCaptureMode captureMode = TXCameraCaptureMode.auto;

  // Device volume (mic capture / speaker playout), range 0-100
  ValueNotifier<int> micVolume = ValueNotifier(100);
  ValueNotifier<int> speakerVolume = ValueNotifier(100);
  bool micMuted = false;
  bool speakerMuted = false;

  Future<void> initialize() async {
    _trtcCloud = await TRTCCloud.sharedInstance();
    _deviceManager = _trtcCloud?.getDeviceManager();
    _listener = _getListener();
    _trtcCloud?.registerListener(_listener!);
    _setupDeviceListeners();
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
  }

  void _setupDeviceListeners() {
    frontCamera.addListener(() {
      _deviceManager?.switchCamera(frontCamera.value);
    });
    cameraZoomRatio.addListener(() {
      _deviceManager?.setCameraZoomRatio(cameraZoomRatio.value);
    });
    cameraTorch.addListener(() {
      _deviceManager?.enableCameraTorch(cameraTorch.value);
    });
    audioRoute.addListener(() {
      _deviceManager?.setAudioRoute(audioRoute.value);
    });
  }

  void toggleFrontCamera() {
    frontCamera.value = !frontCamera.value;
    notifyListeners();
  }

  void toggleAutoFocus() {
    final enabled = !cameraAutoFocus.value;
    _deviceManager?.enableCameraAutoFocus(enabled);
    cameraAutoFocus.value = enabled;
    notifyListeners();
  }

  void toggleTorch() {
    cameraTorch.value = !cameraTorch.value;
    notifyListeners();
  }

  void setAudioRoute(TXAudioRoute route) {
    audioRoute.value = route;
    notifyListeners();
  }

  // ─── Device volume APIs ─────────────────────────────────────

  void setMicVolume(int volume) {
    micVolume.value = volume;
    _deviceManager?.setCurrentDeviceVolume(TXMediaDeviceType.mic, volume);
  }

  void setSpeakerVolume(int volume) {
    speakerVolume.value = volume;
    _deviceManager?.setCurrentDeviceVolume(TXMediaDeviceType.speaker, volume);
  }

  void toggleMicMute() {
    micMuted = !micMuted;
    _deviceManager?.setCurrentDeviceMute(TXMediaDeviceType.mic, micMuted);
    notifyListeners();
  }

  void toggleSpeakerMute() {
    speakerMuted = !speakerMuted;
    _deviceManager?.setCurrentDeviceMute(TXMediaDeviceType.speaker, speakerMuted);
    notifyListeners();
  }

  void queryMicVolume() {
    final v = _deviceManager?.getCurrentDeviceVolume(TXMediaDeviceType.mic);
    if (v != null && v >= 0) micVolume.value = v;
    resultMessage.value = 'mic_volume:${micVolume.value}';
  }

  void querySpeakerVolume() {
    final v = _deviceManager?.getCurrentDeviceVolume(TXMediaDeviceType.speaker);
    if (v != null && v >= 0) speakerVolume.value = v;
    resultMessage.value = 'speaker_volume:${speakerVolume.value}';
  }

  void setFocusPosition(double x, double y) {
    focusPositionX = x;
    focusPositionY = y;
    _deviceManager?.setCameraFocusPosition(x, y);
    notifyListeners();
  }

  void setCaptureParam(int width, int height, TXCameraCaptureMode mode) {
    captureWidth = width;
    captureHeight = height;
    captureMode = mode;
    _deviceManager?.setCameraCaptureParam(
      TXCameraCaptureParam(mode: mode, width: width, height: height),
    );
    notifyListeners();
  }

  void queryFrontCamera() {
    final result = _deviceManager?.isFrontCamera() ?? false;
    resultMessage.value = 'front_camera:$result';
  }

  void queryMaxZoomRatio() {
    final result = _deviceManager?.getCameraZoomMaxRatio() ?? 0;
    resultMessage.value = 'max_zoom:$result';
  }

  void queryAutoFocus() {
    final result = _deviceManager?.isAutoFocusEnabled() ?? false;
    resultMessage.value = 'auto_focus:$result';
  }

  void exitRoom() {
    _trtcCloud?.stopLocalPreview();
    _trtcCloud?.exitRoom();
    _isEnterRoom = false;
    notifyListeners();
  }

  TRTCCloudListener _getListener() {
    return TRTCCloudListener(
      onError: (code, msg) => debugPrint('DeviceManager onError: $code, $msg'),
      onEnterRoom: (result) {
        _isEnterRoom = result > 0;
        notifyListeners();
      },
      onExitRoom: (reason) {
        _isEnterRoom = false;
        notifyListeners();
      },
      onAudioRouteChanged: (newRoute, oldRoute) {
        // Guard against re-entry: assigning audioRoute triggers the listener
        // that calls setAudioRoute back to the SDK.
        if (audioRoute.value != newRoute) {
          audioRoute.value = newRoute;
        }
        resultMessage.value = 'audio_route:${newRoute.name}';
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
