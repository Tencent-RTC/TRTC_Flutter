import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

import '../../../common/user_list_state.dart';
import '../../../debug/generate_test_user_sig.dart';

class DeviceManagerState extends ChangeNotifier {
  TRTCCloud? _trtcCloud;
  TXDeviceManager? _deviceManager;
  bool _isInitialized = false;

  String? localUserId;
  int? roomId;
  UserListState? userListState;

  double focusPositionX = 0.5;
  double focusPositionY = 0.5;

  int height = 360;
  int width = 640;

  ValueNotifier<bool> isEnterRoom = ValueNotifier(false);
  ValueNotifier<bool> isMicrophoneOpen = ValueNotifier(false);

  ValueNotifier<bool> frontCamera = ValueNotifier(true);
  ValueNotifier<double> cameraZoomRatio = ValueNotifier(1.0);
  ValueNotifier<bool> cameraAutofocus = ValueNotifier(false);
  ValueNotifier<bool> cameraTorch = ValueNotifier(false);
  ValueNotifier<TXAudioRoute> audioRoute = ValueNotifier(TXAudioRoute.speakerPhone);
  ValueNotifier<TXCameraCaptureMode> captureMode = ValueNotifier(TXCameraCaptureMode.auto);

  void initialize(TRTCCloud? trtcCloud, UserListState state)  {
    if (_isInitialized) return;
    _trtcCloud = trtcCloud;
    _deviceManager = _trtcCloud?.getDeviceManager();
    userListState = state;
    _isInitialized = true;
    setDeviceManagerListener();
    _deviceManager?.setAudioRoute(TXAudioRoute.speakerPhone);
  }

  void enterRoom() {
    if (localUserId == null || roomId == null) {
      print("DeviceManagerState localUserId or roomId is null");
      Fluttertoast.showToast(msg: "localUserId or roomId is null");
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
    isEnterRoom.value = true;
    _trtcCloud?.startLocalAudio(TRTCAudioQuality.defaultMode);
  }

  void exitRoom() {
    _trtcCloud?.exitRoom();
    isEnterRoom.value = false;
    isMicrophoneOpen.value = false;
  }

  @override
  void dispose() {
    super.dispose();
    exitRoom();
    TRTCCloud.destroySharedInstance();
  }

  void setDeviceManagerListener() {
    frontCamera.addListener(() {
      if (frontCamera.value) {
        if (cameraAutofocus.value) {
          cameraAutofocus.value = false;
        }
      }
      _deviceManager?.switchCamera(frontCamera.value);
    });

    cameraZoomRatio.addListener(() {
      _deviceManager?.setCameraZoomRatio(cameraZoomRatio.value);
    });

    cameraAutofocus.addListener(() {
      _deviceManager?.enableCameraTorch(cameraAutofocus.value);
    });

    cameraTorch.addListener(() {
      _deviceManager?.enableCameraTorch(cameraTorch.value);
    });

    audioRoute.addListener(() {
      _deviceManager?.setAudioRoute(audioRoute.value);
    });
  }

  void enableCameraAutoFocus(bool enabled) {
    _deviceManager?.enableCameraAutoFocus(enabled);
    cameraAutofocus.value = enabled;
  }

  getAudioRouteListener() {
    return TXDeviceObserver(
      onDeviceChanged: (deviceId, type, state) {
        print("DeviceManagerState onDeviceChanged: $deviceId, $type, $state");
        Fluttertoast.showToast(msg: "onDeviceChanged: $deviceId, $type, $state");
      },
    );
  }

  isFrontCamera() {
    var isFront = _deviceManager?.isFrontCamera();
    Fluttertoast.showToast(msg: "isFrontCamera: $isFront");
  }

  getCameraZoomMaxRatio() {
    var ratio = _deviceManager?.getCameraZoomMaxRatio();
    Fluttertoast.showToast(msg: "getCameraZoomMaxRatio: $ratio");
  }

  isAutoFocusEnabled() {
    var isEnabled = _deviceManager?.isAutoFocusEnabled();
    Fluttertoast.showToast(msg: "isAutoFocusEnabled: $isEnabled");
  }

  setCameraFocusPosition() {
    int? result = _deviceManager?.setCameraFocusPosition(focusPositionX, focusPositionY);
    if (result != null) {
      Fluttertoast.showToast(msg: "setCameraFocusPosition: $result");
    }
  }

  setCameraCaptureParam() {
    _deviceManager?.setCameraCaptureParam(
        TXCameraCaptureParam(
          mode: captureMode.value,
          width: width,
          height: height,
        )
    );
  }
}