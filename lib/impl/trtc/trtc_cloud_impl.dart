// ignore_for_file: prefer_final_fields
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:tencent_rtc_sdk/ai_transcriber_manager.dart';
import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_native.dart';
import 'package:tencent_rtc_sdk/bridge/trtc/trtc_method_channel.dart';
import 'package:tencent_rtc_sdk/impl/manager/ai_transcriber_manager_impl.dart';
import 'package:tencent_rtc_sdk/impl/manager/tx_audio_effect_manager_impl.dart';
import 'package:tencent_rtc_sdk/impl/manager/tx_beauty_manager_impl.dart';
import 'package:tencent_rtc_sdk/impl/manager/tx_device_manager_impl.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_video_view.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

import 'package:tencent_rtc_sdk/bindings/trtc/trtc_cloud_listener_native.dart';
import 'package:tencent_rtc_sdk/trtc_cloud.dart';

class TRTCCloudImpl extends TRTCCloud {
  final _tag = 'TRTCCloudImpl';
  static TRTCCloudImpl? _trtc;
  static TRTCLogParams _logParams = TRTCLogParams();
  static Future<TRTCCloud>? _initFuture;

  static bool _useTextureRender = false;

  static void _updateRenderType() {
    _useTextureRender = false;
    if (TRTCPlatform.isWindows || TRTCPlatform.isMacOS) {
      _useTextureRender = true;
      return;
    }
    if (TRTCPlatform.isOhos) {
      return;
    }
    try {
      final String result = TRTCCloudNative.instance
          .callExperimentalAPI('{"api": "getFlutterVideoRenderType"}');
      _useTextureRender = (result.trim() == '1');
    } catch (e) {
      debugPrint('TRTCCloudImpl _updateRenderType failed: $e');
    }
  }

  static bool get useTextureRender => _useTextureRender;

  late TXDeviceManagerImpl _deviceManager;
  late TXAudioEffectManagerImpl _audioEffectManager;

  TRTCCloudListenerNative? _listenerNative;

  TRTCAudioFrameCallbackNative? _audioFrameCallbackNative;
  TRTCLogCallbackNative? _logCallbackNative;

  TRTCVideoStreamType? _screenCaptureStreamType;

  static Future<TRTCCloud> sharedInstance() {
    return _initFuture ??= _createInstance();
  }

  static Future<TRTCCloud> _createInstance() async {
    await TRTCMethodChannel().initialize();
    TRTCCloudNative.sharedInstance();
    _trtc = TRTCCloudImpl();
    _updateRenderType();
    return _trtc!;
  }

  static void destroySharedInstance() {
    _trtc?._deviceManager.destroy();
    TXBeautyManagerImpl.destroyBeautyManager();
    _trtc?._audioEffectManager.destroy();

    _trtc?._logCallbackNative?.unRegisterNativeListener();
    _trtc?._logCallbackNative = null;

    _trtc?._audioFrameCallbackNative?.unRegisterNativeListener();
    _trtc?._audioFrameCallbackNative = null;

    _trtc?._listenerNative?.unRegisterNativeListener();
    _trtc?._listenerNative = null;

    _initFuture = null;
    _trtc = null;
    _useTextureRender = false;
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows) {
      TRTCMethodChannel().destroySharedInstance();
    }
    TRTCCloudNative.destroySharedInstance();
  }

  TRTCCloudImpl() {
    _deviceManager =
        TXDeviceManagerImpl(TRTCCloudNative.instance.getDeviceManager());
    _audioEffectManager = TXAudioEffectManagerImpl(
        TRTCCloudNative.instance.getAudioEffectManager());
  }

  // ignore: non_constant_identifier_names
  static void TRTCLog(String tag, String body, {int level = 0}) {
    TRTCCloudNative.instance.writeLog(level, "tencent_rtc_sdk", tag, body);
  }

  @override
  void registerListener(TRTCCloudListener func) {
    _listenerNative ??=
        TRTCCloudListenerNative(TRTCCloudNative.sharedInstanceNativePointer);
    _listenerNative?.addListener(func);
  }

  @override
  void unRegisterListener(TRTCCloudListener func) {
    _listenerNative?.removeListener(func);
  }

  @override
  void enterRoom(TRTCParams param, TRTCAppScene scene) {
    TRTCLog(
        _tag, "enterRoom sdkappid: ${param.sdkAppId} userId: ${param.userId}");
    TRTCCloudNative.instance.callExperimentalAPI(
        "{\"api\": \"setFramework\", \"params\": {\"framework\": 7, \"language\": 9}}");
    TRTCCloudNative.instance.enterRoom(param, scene.value());
  }

  @override
  TXDeviceManager getDeviceManager() {
    TRTCLog(_tag, "getDeviceManager");
    return _deviceManager;
  }

  @override
  void enableAudioVolumeEvaluation(
      bool enable, TRTCAudioVolumeEvaluateParams params) {
    TRTCLog(_tag, "enableAudioVolumeEvaluation enable: $enable");
    TRTCCloudNative.instance.enableAudioVolumeEvaluation(enable, params);
  }

  @override
  void exitRoom() {
    TRTCLog(_tag, "exitRoom");
    TRTCCloudNative.instance.exitRoom();
  }

  @override
  void muteLocalVideo(TRTCVideoStreamType streamType, bool mute) {
    TRTCLog(_tag, "muteLocalVideo streamType: $streamType mute: $mute");
    TRTCCloudNative.instance.muteLocalVideo(streamType.value(), mute);
  }

  @override
  void muteLocalAudio(bool mute) {
    TRTCLog(_tag, "muteLocalAudio mute: $mute");
    TRTCCloudNative.instance.muteLocalAudio(mute);
  }

  @override
  void muteRemoteVideoStream(
      String userId, TRTCVideoStreamType streamType, bool mute) {
    TRTCLog(_tag,
        "muteRemoteVideoStream userId: $userId streamType: $streamType mute: $mute");
    TRTCCloudNative.instance
        .muteRemoteVideoStream(userId, streamType.value(), mute);
  }

  @override
  void setGravitySensorAdaptiveMode(TRTCGSensorMode mode) {
    TRTCLog(_tag, "setGravitySensorAdaptiveMode mode: $mode");
    TRTCCloudNative.instance.setGravitySensorAdaptiveMode(mode.value());
  }

  @override
  void setLocalRenderParams(TRTCRenderParams params) {
    TRTCLog(_tag,
        "setLocalRenderParams rotation: ${params.rotation} fillMode: ${params.fillMode} mirrorType: ${params.mirrorType}");
    TRTCCloudNative.instance.setLocalRenderParams(params.rotation.value(),
        params.fillMode.value(), params.mirrorType.value());
  }

  @override
  void setNetworkQosParam(TRTCNetworkQosParam params) {
    TRTCLog(_tag, "setNetworkQosParam preference: ${params.preference}");
    TRTCCloudNative.instance.setNetworkQosParam(params);
  }

  @override
  void setVideoEncoderParam(TRTCVideoEncParam params) {
    TRTCLog(_tag, "setVideoEncoderParam");
    TRTCCloudNative.instance.setVideoEncoderParam(params);
  }

  @override
  void setVideoEncoderMirror(bool enable) {
    TRTCLog(_tag, "setVideoEncoderMirror enable: $enable");
    TRTCCloudNative.instance.setVideoEncoderMirror(enable);
  }

  @override
  void startLocalAudio(TRTCAudioQuality quality) {
    TRTCLog(_tag, "startLocalAudio quality: $quality");
    TRTCCloudNative.instance.startLocalAudio(quality.value());
  }

  @override
  void startLocalPreview(bool frontCamera, int? viewId) async {
    TRTCLog(
        _tag, "startLocalPreview frontCamera: $frontCamera viewId: $viewId");
    if (viewId != null && !TRTCCloudVideoView.containsViewId(viewId)) {
      TRTCLog(_tag, "startLocalPreview fail, viewId does not exist");
      return;
    }
    _updateRenderType();
    TRTCCloudNative.instance
        .startLocalPreview(frontCamera, _useTextureRender ? null : viewId);
    if (_useTextureRender) {
      if (viewId == null) {
        await TRTCMethodChannel()
            .unsetLocalTextureRender(TRTCVideoStreamType.big);
      } else {
        await TRTCMethodChannel()
            .setLocalTextureRender(viewId, TRTCVideoStreamType.big);
      }
    }
  }

  @override
  void startRemoteView(
      String userId, TRTCVideoStreamType streamType, int? viewId) async {
    TRTCLog(_tag,
        "startRemoteView userId: $userId streamType: $streamType viewId: $viewId");
    if (viewId != null && !TRTCCloudVideoView.containsViewId(viewId)) {
      TRTCLog(_tag, "startRemoteView fail, viewId does not exist");
      return;
    }
    _updateRenderType();
    TRTCCloudNative.instance.startRemoteView(
        userId, streamType.value(), _useTextureRender ? null : viewId);
    if (_useTextureRender) {
      if (viewId == null) {
        await TRTCMethodChannel().unsetRemoteTextureRender(userId, streamType);
      } else {
        await TRTCMethodChannel()
            .setRemoteTextureRender(userId, streamType, viewId);
      }
    }
  }

  @override
  void stopAllRemoteView() {
    TRTCLog(_tag, "stopAllRemoteView");
    TRTCCloudNative.instance.stopAllRemoteView();
  }

  @override
  void stopLocalAudio() {
    TRTCLog(_tag, "stopLocalAudio");
    TRTCCloudNative.instance.stopLocalAudio();
  }

  @override
  void stopLocalPreview() {
    TRTCLog(_tag, "stopLocalPreview");
    TRTCCloudNative.instance.stopLocalPreview();
    if (_useTextureRender) {
      TRTCMethodChannel().unsetLocalTextureRender(TRTCVideoStreamType.big);
    }
  }

  @override
  void stopRemoteView(String userId, TRTCVideoStreamType streamType) {
    TRTCLog(_tag, "stopRemoteView userId: $userId streamType: $streamType");
    TRTCCloudNative.instance.stopRemoteView(userId, streamType.value());
    if (_useTextureRender) {
      TRTCMethodChannel().unsetRemoteTextureRender(userId, streamType);
    }
  }

  @override
  void switchRole(TRTCRoleType role) {
    TRTCLog(_tag, "switchRole role: $role");
    TRTCCloudNative.instance.switchRole(role.value());
  }

  @override
  void switchRoom(TRTCSwitchRoomConfig config) {
    TRTCLog(_tag,
        "switchRoom roomId: ${config.roomId} strRoomId: ${config.strRoomId}");
    TRTCCloudNative.instance.switchRoom(config);
  }

  @override
  String callExperimentalAPI(String jsonStr) {
    if (!jsonStr.contains("enableVideoProcessByNative")) {
      return TRTCCloudNative.instance.callExperimentalAPI(jsonStr);
    }

    try {
      TRTCLog(_tag, "callExperimentalAPI jsonStr: $jsonStr");
      TRTCMethodChannel().enableVideoProcessByNative(jsonStr);
      return "success";
    } catch (e) {
      TRTCLog(
          _tag, "Error in callExperimentalAPI: jsonStr: $jsonStr, error: $e");
      return '';
    }
  }

  @override
  void connectOtherRoom(String param) {
    TRTCLog(_tag, "connectOtherRoom param: $param");
    TRTCCloudNative.instance.connectOtherRoom(param);
  }

  // @override
  // TRTCCloud createSubCloud() {
  //   // TODO: implement createSubCloud
  //   throw UnimplementedError();
  // }
  //
  // @override
  // void destroySubCloud(TRTCCloud subCloud) {
  //   // TODO: implement destroySubCloud
  // }

  @override
  void disconnectOtherRoom() {
    TRTCLog(_tag, "disconnectOtherRoom");
    TRTCCloudNative.instance.disconnectOtherRoom();
  }

  @override
  void enableCustomAudioCapture(bool enable) {
    TRTCLog(_tag, "enableCustomAudioCapture: $enable");
    TRTCCloudNative.instance.enableCustomAudioCapture(enable);
  }

  @override
  int enableSmallVideoStream(
      bool enable, TRTCVideoEncParam smallVideoEncParam) {
    TRTCLog(_tag,
        "enableSmallVideoStream: $enable smallVideoEncParam: $smallVideoEncParam");
    return TRTCCloudNative.instance
        .enableSmallVideoStream(enable, smallVideoEncParam);
  }

  @override
  int getAudioCaptureVolume() {
    TRTCLog(_tag, "getAudioCaptureVolume");
    return TRTCCloudNative.instance.getAudioCaptureVolume();
  }

  @override
  TXAudioEffectManager getAudioEffectManager() {
    TRTCLog(_tag, "getAudioEffectManager");
    return _audioEffectManager;
  }

  @override
  int getAudioPlayoutVolume() {
    TRTCLog(_tag, "getAudioPlayoutVolume");
    return TRTCCloudNative.instance.getAudioPlayoutVolume();
  }

  @override
  String getSDKVersion() {
    TRTCLog(_tag, "getSDKVersion");
    return TRTCCloudNative.instance.getSDKVersion();
  }

  @override
  TRTCScreenCaptureSourceList? getScreenCaptureSources(
      TRTCSize thumbnail, TRTCSize icon) {
    TRTCLog(_tag, "getScreenCaptureSources: thumbnail: $thumbnail icon: $icon");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return null;
    }
    return TRTCCloudNative.instance.getScreenCaptureSources(thumbnail, icon);
  }

  @override
  void muteAllRemoteAudio(bool mute) {
    TRTCLog(_tag, "muteAllRemoteAudio: $mute");
    TRTCCloudNative.instance.muteAllRemoteAudio(mute);
  }

  @override
  void muteRemoteAudio(String userId, bool mute) {
    TRTCLog(_tag, "muteRemoteAudio: $userId mute: $mute");
    TRTCCloudNative.instance.muteRemoteAudio(userId, mute);
  }

  @override
  void pauseScreenCapture() {
    TRTCLog(_tag, "pauseScreenCapture");
    TRTCCloudNative.instance.pauseScreenCapture();
  }

  @override
  void resumeScreenCapture() {
    TRTCLog(_tag, "resumeScreenCapture");
    TRTCCloudNative.instance.resumeScreenCapture();
  }

  @override
  void selectScreenCaptureTarget(TRTCScreenCaptureSourceInfo source,
      TRTCRect rect, TRTCScreenCaptureProperty property) {
    TRTCLog(_tag,
        "selectScreenCaptureTarget: source: $source rect: $rect property: $property");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.selectScreenCaptureTarget(source, rect, property);
  }

  @override
  void addExcludedShareWindow(int windowId) {
    TRTCLog(_tag, "addExcludedShareWindow: windowId: $windowId");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.addExcludedShareWindow(windowId);
  }

  @override
  void removeExcludedShareWindow(int windowId) {
    TRTCLog(_tag, "removeExcludedShareWindow: windowId: $windowId");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.removeExcludedShareWindow(windowId);
  }

  @override
  void removeAllExcludedShareWindow() {
    TRTCLog(_tag, "removeAllExcludedShareWindow");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.removeAllExcludedShareWindows();
  }

  @override
  void addIncludedShareWindow(int windowId) {
    TRTCLog(_tag, "addIncludedShareWindow: windowId: $windowId");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.addIncludedShareWindow(windowId);
  }

  @override
  void removeIncludedShareWindow(int windowId) {
    TRTCLog(_tag, "removeIncludedShareWindow: windowId: $windowId");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.removeIncludedShareWindow(windowId);
  }

  @override
  void removeAllIncludedShareWindow() {
    TRTCLog(_tag, "removeAllIncludedShareWindow");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.removeAllIncludedShareWindows();
  }

  @override
  void sendCustomAudioData(TRTCAudioFrame frame) {
    TRTCLog(_tag, "sendCustomAudioData: frame: $frame");
    TRTCCloudNative.instance.sendCustomAudioData(frame);
  }

  @override
  bool sendCustomCmdMsg(int cmdID, String data, bool reliable, bool ordered) {
    TRTCLog(_tag,
        "sendCustomCmdMsg: cmdID: $cmdID data: $data reliable: $reliable ordered: $ordered");
    return TRTCCloudNative.instance
        .sendCustomCmdMsg(cmdID, data, reliable, ordered);
  }

  @override
  bool sendSEIMsg(String data, int repeatCount) {
    TRTCLog(_tag, "sendSEIMsg: data: $data repeatCount: $repeatCount");
    return TRTCCloudNative.instance.sendSEIMsg(data, repeatCount);
  }

  @override
  void setAudioCaptureVolume(int volume) {
    TRTCLog(_tag, "setAudioCaptureVolume: $volume");
    TRTCCloudNative.instance.setAudioCaptureVolume(volume);
  }

  @override
  int setAudioFrameCallback(TRTCAudioFrameCallback? callback) {
    TRTCLog(_tag, "setAudioFrameCallback: $callback");
    if (callback != null) {
      _audioFrameCallbackNative ??= TRTCAudioFrameCallbackNative(
          TRTCCloudNative.sharedInstanceNativePointer);
      _audioFrameCallbackNative?.addListener(callback);
    } else {
      if (_audioFrameCallbackNative != null) {
        _audioFrameCallbackNative?.clearListeners();
      }
    }
    return 0;
  }

  @override
  void setAudioPlayoutVolume(int volume) {
    TRTCLog(_tag, "setAudioPlayoutVolume: $volume");
    TRTCCloudNative.instance.setAudioPlayoutVolume(volume);
  }

  @override
  void setDefaultStreamRecvMode(bool autoRecvAudio, bool autoRecvVideo) {
    TRTCLog(_tag,
        "setDefaultStreamRecvMode: autoRecvAudio: $autoRecvAudio autoRecvVideo: $autoRecvVideo");
    TRTCCloudNative.instance
        .setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo);
  }

  @override
  // void setLocalVideoCustomProcessCallback(TRTCVideoFrameCallback? callback) {
  //   // TODO: implement setLocalVideoCustomProcessCallback
  // }

  @override
  // int setLocalVideoRenderCallback(TRTCVideoPixelFormat format, TRTCVideoBufferType type, TRTCVideoRenderCallback? callback) {
  //   // TODO: implement setLocalVideoRenderCallback
  //   throw UnimplementedError();
  // }

  @override
  void setLogCallback(TRTCLogCallback? callback) {
    TRTCLog(_tag, "setLogCallback: $callback");
    if (callback != null) {
      _logCallbackNative ??=
          TRTCLogCallbackNative(TRTCCloudNative.sharedInstanceNativePointer);
      _logCallbackNative?.addListener(callback);
    } else {
      if (_logCallbackNative != null) {
        _logCallbackNative?.clearListeners();
      }
    }
  }

  // @override
  // void setLogParams(TRTCLogParams params) {
  //   TRTCLog(_tag, "setLogParams: $params");
  //   TRTCCloudNative.instance.setLogParams(params);
  // }

  @override
  void setRemoteAudioVolume(String userId, int volume) {
    TRTCLog(_tag, "setRemoteAudioVolume: $userId $volume");
    TRTCCloudNative.instance.setRemoteAudioVolume(userId, volume);
  }

  @override
  void setRemoteRenderParams(
      String userId, TRTCVideoStreamType streamType, TRTCRenderParams params) {
    TRTCLog(_tag, "setRemoteRenderParams: $userId $streamType $params");
    TRTCCloudNative.instance.setRemoteRenderParams(userId, streamType, params);
  }

  @override
  // int setRemoteVideoRenderCallback(String userId, TRTCVideoPixelFormat format, TRTCVideoBufferType type, TRTCVideoRenderCallback? callback) {
  //   // TODO: implement setRemoteVideoRenderCallback
  //   throw UnimplementedError();
  // }

  @override
  void setRemoteVideoStreamType(String userId, TRTCVideoStreamType streamType) {
    TRTCLog(_tag, "setRemoteVideoStreamType: $userId $streamType");
    TRTCCloudNative.instance.setRemoteVideoStreamType(userId, streamType);
  }

  @override
  void setSubStreamEncoderParam(TRTCVideoEncParam param) {
    TRTCLog(_tag, "setSubStreamEncoderParam: $param");
    TRTCCloudNative.instance.setSubStreamEncoderParam(param);
  }

  @override
  void setWatermark(String imagePath, TRTCVideoStreamType streamType, double x,
      double y, double width) {
    if (Platform.isWindows || Platform.isMacOS) {
      TRTCLog(_tag, "setWatermark is not currently supported on this platform");
      return;
    }
    TRTCLog(_tag, "setWatermark: $imagePath $streamType $x $y $width");
    TRTCMethodChannel().setWatermark(imagePath, streamType, x, y, width);
  }

  @override
  int startLocalRecording(TRTCLocalRecordingParams param) {
    TRTCLog(_tag, "startLocalRecording: $param");
    return TRTCCloudNative.instance.startLocalRecording(param);
  }

  @override
  void startPublishMediaStream(TRTCPublishTarget target,
      TRTCStreamEncoderParam param, TRTCStreamMixingConfig config) {
    TRTCLog(_tag, "startPublishMediaStream: $target $param $config");
    TRTCCloudNative.instance.startPublishMediaStream(target, param, config);
  }

  @override
  void startScreenCapture(int? viewId, TRTCVideoStreamType streamType,
      TRTCVideoEncParam encParam) async {
    TRTCLog(_tag,
        "startScreenCapture: viewId:$viewId, streamType:$streamType, encParam:$encParam");
    if (TRTCPlatform.isIOS) {
      TRTCMethodChannel().startScreenCapture(viewId, streamType, encParam);
      return;
    }
    int? effectiveViewId = viewId;
    if (effectiveViewId != null &&
        effectiveViewId != 0 &&
        !TRTCCloudVideoView.containsViewId(effectiveViewId)) {
      TRTCLog(
        _tag,
        "startScreenCapture WARNING: viewId=$effectiveViewId is invalid (not registered in TRTCCloudVideoView). "
        "Fallback to no local preview. Ensure the TRTCCloudVideoView is created and onViewCreated has fired before calling startScreenCapture.",
        level: 3, // warning
      );
      effectiveViewId = null;
    }
    _updateRenderType();
    final useTexture = _useTextureRender;
    TRTCCloudNative.instance.startScreenCapture(
        useTexture ? null : effectiveViewId, streamType, encParam);
    if (useTexture) {
      if (effectiveViewId == null || effectiveViewId == 0) {
        await TRTCMethodChannel().unsetLocalTextureRender(streamType);
        if (_screenCaptureStreamType == streamType) {
          _screenCaptureStreamType = null;
        }
      } else {
        _screenCaptureStreamType = streamType;
        await TRTCMethodChannel()
            .setLocalTextureRender(effectiveViewId, streamType);
      }
    }
  }

  @override
  void startScreenCaptureByReplaykit(TRTCVideoStreamType streamType,
      TRTCVideoEncParam encParam, String? appGroup) {
    if (TRTCPlatform.isIOS) {
      TRTCMethodChannel()
          .startScreenCaptureByReplaykit(streamType, encParam, appGroup);
    } else {
      TRTCLog(_tag,
          "startScreenCaptureByReplaykit is not currently supported on this platform");
    }
  }

  @override
  int startSpeedTest(TRTCSpeedTestParams params) {
    TRTCLog(_tag, "startSpeedTest: $params");
    return TRTCCloudNative.instance.startSpeedTest(params);
  }

  @override
  void startSystemAudioLoopback({String? deviceName}) {
    TRTCLog(_tag, "startSystemAudioLoopback: $deviceName");
    if (Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.startSystemAudioLoopback(deviceName: deviceName);
  }

  @override
  void stopLocalRecording() {
    TRTCLog(_tag, "stopLocalRecording");
    TRTCCloudNative.instance.stopLocalRecording();
  }

  @override
  void stopPublishMediaStream(String taskId) {
    TRTCLog(_tag, "stopPublishMediaStream: $taskId");
    TRTCCloudNative.instance.stopPublishMediaStream(taskId);
  }

  @override
  void stopScreenCapture() {
    TRTCLog(_tag, "stopScreenCapture");
    TRTCCloudNative.instance.stopScreenCapture();
    if (_useTextureRender && _screenCaptureStreamType != null) {
      final streamType = _screenCaptureStreamType!;
      _screenCaptureStreamType = null;
      TRTCMethodChannel().unsetLocalTextureRender(streamType);
    }
  }

  @override
  void stopSpeedTest() {
    TRTCLog(_tag, "stopSpeedTest");
    TRTCCloudNative.instance.stopSpeedTest();
  }

  @override
  void stopSystemAudioLoopback() {
    TRTCLog(_tag, "stopSystemAudioLoopback");
    if (Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.stopSystemAudioLoopback();
  }

  @override
  void updatePublishMediaStream(String taskId, TRTCPublishTarget target,
      TRTCStreamEncoderParam param, TRTCStreamMixingConfig config) {
    TRTCLog(_tag, "updatePublishMediaStream: $taskId $target $param $config");
    TRTCCloudNative.instance
        .updatePublishMediaStream(taskId, target, param, config);
  }

  @override
  void muteAllRemoteVideoStreams(bool mute) {
    TRTCLog(_tag, "muteAllRemoteVideoStreams: $mute");
    TRTCCloudNative.instance.muteAllRemoteVideoStreams(mute);
  }

  @override
  void setSystemAudioLoopbackVolume(int volume) {
    TRTCLog(_tag, "setSystemAudioLoopbackVolume: $volume");
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint("trtc-api not support");
      return;
    }
    TRTCCloudNative.instance.setSystemAudioLoopbackVolume(volume);
  }

  @override
  void setVideoMuteImage(String imagePath, int fps) {
    if (Platform.isWindows || Platform.isMacOS) {
      TRTCLog(_tag,
          "setVideoMuteImage is not currently supported on this platform");
      return;
    }
    TRTCLog(_tag, "setVideoMuteImage: $imagePath $fps");
    TRTCMethodChannel().setVideoMuteImage(imagePath, fps);
  }

  @override
  void showDebugView(int showType) {
    TRTCLog(_tag, "showDebugView: $showType");
    TRTCCloudNative.instance.showDebugView(showType);
  }

  @override
  void snapshotVideo(String userId, TRTCVideoStreamType streamType,
      TRTCSnapshotSourceType sourceType,
      {String? path}) {
    if (Platform.isWindows || Platform.isMacOS) {
      TRTCLog(
          _tag, "snapshotVideo is not currently supported on this platform");
      return;
    }
    TRTCLog(_tag, "snapshotVideo: $userId $streamType $sourceType");
    TRTCMethodChannel()
        .snapshotVideo(userId, streamType, sourceType, path ?? "");
  }

  @override
  void updateLocalView(int? viewId) {
    TRTCLog(_tag, "updateLocalView: $viewId");
    if (viewId != null && !TRTCCloudVideoView.containsViewId(viewId)) {
      TRTCLog(_tag, "updateLocalView fail, viewId does not exist");
      return;
    }
    _updateRenderType();
    TRTCCloudNative.instance.updateLocalView(_useTextureRender ? null : viewId);
    if (_useTextureRender) {
      if (viewId == null) {
        TRTCMethodChannel().unsetLocalTextureRender(TRTCVideoStreamType.big);
      } else {
        TRTCMethodChannel()
            .setLocalTextureRender(viewId, TRTCVideoStreamType.big);
      }
    }
  }

  @override
  void updateRemoteView(
      String userId, TRTCVideoStreamType streamType, int? viewId) {
    TRTCLog(_tag, "updateRemoteView: $userId $streamType $viewId");
    if (viewId != null && !TRTCCloudVideoView.containsViewId(viewId)) {
      TRTCLog(_tag, "updateRemoteView fail, viewId does not exist");
      return;
    }
    _updateRenderType();
    TRTCCloudNative.instance.updateRemoteView(
        userId, streamType, _useTextureRender ? null : viewId);
    if (_useTextureRender) {
      if (viewId == null) {
        TRTCMethodChannel().unsetRemoteTextureRender(userId, streamType);
      } else {
        TRTCMethodChannel().setRemoteTextureRender(userId, streamType, viewId);
      }
    }
  }

  @override
  void setConsoleEnabled(bool enabled) {
    TRTCLog(_tag, "setConsoleEnabled: $enabled");
    _logParams.consoleEnabled = enabled;
    TRTCCloudNative.instance.setLogParams(_logParams);
  }

  @override
  void setLogCompressEnabled(bool enabled) {
    TRTCLog(_tag, "setLogCompressEnabled: $enabled");
    _logParams.compressEnabled = enabled;
    TRTCCloudNative.instance.setLogParams(_logParams);
  }

  @override
  void setLogDirPath(String path) {
    TRTCLog(_tag, "setLogDirPath: $path");
    _logParams.filePath = path;
    TRTCCloudNative.instance.setLogParams(_logParams);
  }

  @override
  void setLogLevel(TRTCLogLevel level) {
    TRTCLog(_tag, "setLogLevel: $level");
    _logParams.level = level;
    TRTCCloudNative.instance.setLogParams(_logParams);
  }

  @override
  void setBeautyStyle(TRTCBeautyStyle style, int beautyLevel,
      int whitenessLevel, int ruddinessLevel) {
    TRTCCloudNative.instance
        .setBeautyStyle(style, beautyLevel, whitenessLevel, ruddinessLevel);
  }

  @override
  AITranscriberManager getAITranscriberManager() {
    TRTCLog(_tag, "getAITranscriberManager");
    return AITranscriberManagerImpl();
  }
}
