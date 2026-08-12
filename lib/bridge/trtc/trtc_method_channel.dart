import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_rtc_sdk/bridge/trtc/trtc_channel_listener.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class TRTCMethodChannel {
  static final TRTCMethodChannel _instance = TRTCMethodChannel._internal();
  static const MethodChannel _channel = MethodChannel("TencentRTCffi");

  TRTCChannelListener? _listener;
  bool _isHandlerSet = false;

  // AI Transcriber callbacks
  void Function(dynamic)? _onRealtimeTranscriberStarted;
  void Function(dynamic)? _onReceiveTranscriberMessage;
  void Function(dynamic)? _onRealtimeTranscriberStopped;
  void Function(dynamic)? _onRealtimeTranscriberError;

  TRTCMethodChannel._internal();

  factory TRTCMethodChannel() => _instance;

  void _ensureHandlerSet() {
    if (_isHandlerSet) return;
    _isHandlerSet = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onSnapshotComplete":
          _listener?.handleNativeOnSnapshotComplete?.call(call.arguments);
          break;
        case "onRealtimeTranscriberStarted":
          _onRealtimeTranscriberStarted?.call(call.arguments);
          break;
        case "onReceiveTranscriberMessage":
          _onReceiveTranscriberMessage?.call(call.arguments);
          break;
        case "onRealtimeTranscriberStopped":
          _onRealtimeTranscriberStopped?.call(call.arguments);
          break;
        case "onRealtimeTranscriberError":
          _onRealtimeTranscriberError?.call(call.arguments);
          break;
        default:
          break;
      }
    });
  }

  setListener(TRTCChannelListener? listener) {
    _listener = listener;
    _ensureHandlerSet();
  }

  void setTranscriberCallbacks({
    void Function(dynamic)? onStarted,
    void Function(dynamic)? onMessage,
    void Function(dynamic)? onStopped,
    void Function(dynamic)? onError,
  }) {
    _onRealtimeTranscriberStarted = onStarted;
    _onReceiveTranscriberMessage = onMessage;
    _onRealtimeTranscriberStopped = onStopped;
    _onRealtimeTranscriberError = onError;
    _ensureHandlerSet();
  }

  Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  Future<void> setLocalTextureRender(
      int viewId, TRTCVideoStreamType streamType) async {
    await _channel.invokeMethod('setLocalTextureRender',
        {"viewId": viewId, "streamType": streamType.value()});
  }

  Future<void> setRemoteTextureRender(
      String userId, TRTCVideoStreamType streamType, int viewId) async {
    await _channel.invokeMethod('setRemoteTextureRender',
        {"streamType": streamType.value(), "userId": userId, "viewId": viewId});
  }

  Future<void> unsetLocalTextureRender(TRTCVideoStreamType streamType) async {
    await _channel.invokeMethod(
        'unsetLocalTextureRender', {"streamType": streamType.value()});
  }

  Future<void> unsetRemoteTextureRender(
      String userId, TRTCVideoStreamType streamType) async {
    await _channel.invokeMethod('unsetRemoteTextureRender',
        {"userId": userId, "streamType": streamType.value()});
  }

  Future<int> startCameraDeviceTest(int viewId) async {
    final code = await _channel.invokeMethod<int>('startCameraDeviceTest', {
      'viewId': viewId,
    });
    return code ?? -1;
  }

  Future<void> stopCameraDeviceTest() async {
    await _channel.invokeMethod('stopCameraDeviceTest');
  }

  Future<void> snapshotVideo(String userId, TRTCVideoStreamType streamType,
      TRTCSnapshotSourceType sourceType, String path) async {
    _channel.invokeMethod("snapshotVideo", {
      "userId": userId,
      "streamType": streamType.value(),
      "sourceType": sourceType.value(),
      "path": path,
    });
  }

  Future<void> setVideoMuteImage(String imagePath, int fps) async {
    _channel.invokeMethod("setVideoMuteImage", {
      "imagePath": imagePath,
      "fps": fps,
    });
  }

  Future<void> setWatermark(String imagePath, TRTCVideoStreamType streamType,
      double x, double y, double width) async {
    _channel.invokeMethod("setWatermark", {
      "imagePath": imagePath,
      "streamType": streamType.value(),
      "x": x,
      "y": y,
      "width": width,
    });
  }

  Future<void> enableVideoProcessByNative(String jsonStr) async {
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final params = jsonMap['params'] as Map<String, dynamic>? ?? {};
    await _channel.invokeMethod('enableVideoProcessByNative', params);
  }

  Future<void> startScreenCapture(int? viewId, TRTCVideoStreamType streamType,
      TRTCVideoEncParam encParam) async {
    Map<String, dynamic> encParamMap = {
      'videoResolution': encParam.videoResolution.value(),
      'videoResolutionMode': encParam.videoResolutionMode.value(),
      'videoFps': encParam.videoFps,
      'videoBitrate': encParam.videoBitrate,
      'minVideoBitrate': encParam.minVideoBitrate,
      'enableAdjustRes': encParam.enableAdjustRes,
    };
    await _channel.invokeMethod('startScreenCapture', {
      'streamType': streamType.value(),
      'encParam': encParamMap,
    });
  }

  Future<void> startScreenCaptureByReplaykit(TRTCVideoStreamType streamType,
      TRTCVideoEncParam encParam, String? appGroup) async {
    Map<String, dynamic> encParamMap = {
      'videoResolution': encParam.videoResolution.value(),
      'videoResolutionMode': encParam.videoResolutionMode.value(),
      'videoFps': encParam.videoFps,
      'videoBitrate': encParam.videoBitrate,
      'minVideoBitrate': encParam.minVideoBitrate,
      'enableAdjustRes': encParam.enableAdjustRes,
    };
    await _channel.invokeMethod('startScreenCaptureByReplaykit', {
      'streamType': streamType.value(),
      'encParam': encParamMap,
      'appGroup': appGroup ?? "",
    });
  }

  Future<void> destroySharedInstance() async {
    await _channel.invokeMethod("destroySharedInstance");
  }

  // AITranscriberManager methods

  Future<void> startRealtimeTranscriber(Map<String, dynamic> params) async {
    await _channel.invokeMethod('startRealtimeTranscriber', params);
  }

  Future<void> stopRealtimeTranscriber(String transcriberRobotId) async {
    await _channel.invokeMethod('stopRealtimeTranscriber', {
      'transcriberRobotId': transcriberRobotId,
    });
  }

  Future<void> pauseReceivingTranscriberMessage() async {
    await _channel.invokeMethod('pauseReceivingTranscriberMessage');
  }

  Future<void> resumeReceivingTranscriberMessage() async {
    await _channel.invokeMethod('resumeReceivingTranscriberMessage');
  }

  Future<void> addTranscriberListener() async {
    await _channel.invokeMethod('addTranscriberListener');
  }

  Future<void> removeTranscriberListener() async {
    await _channel.invokeMethod('removeTranscriberListener');
  }
}
