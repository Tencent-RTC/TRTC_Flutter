import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js_util';
import 'Simulation_js.dart' if (dart.library.html) 'package:js/js.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import './trtc_cloud_js.dart';
import 'dart:ui' as ui;
import 'trtc_cloud_listener_web.dart';

const trtcCloudChannelView = 'trtcCloudChannelView';

/// @nodoc
class TencentTRTCCloudWeb {
  static late MethodChannel _channel;
  static TrtcWrapper? _trtcCloudWrapper;
  static void registerWith(Registrar registrar) {
    _channel = MethodChannel(
      'trtcCloudChannel',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = TencentTRTCCloudWeb();
    _channel.setMethodCallHandler(pluginInstance.handleMethodCall);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(trtcCloudChannelView,
        (int viewId) {
      var divId = 'HTMLID_$trtcCloudChannelView' + viewId.toString();
      var element = DivElement()..setAttribute("id", divId);
      MethodChannel(trtcCloudChannelView + '_$viewId', const StandardMethodCodec(), registrar)
          .setMethodCallHandler((call) => pluginInstance.handleViewMethodCall(call, element, divId));
      return element;
    });
  }

  Future<dynamic> handleViewMethodCall(
      MethodCall call, Element element, String divId) async {
    var args = '';
    if (call.arguments != null) {
      args = jsonEncode(call.arguments);
      // 不能用map，在release模式下有问题
      //Map<String, dynamic>.from(call.arguments);
    }
    print("============>>> method: ${call.method} , arguments :  ${call.arguments}");
    switch (call.method) {
      case 'startLocalPreview':
        _trtcCloudWrapper!.startLocalPreview(element, divId, args);
        break;
      case 'updateLocalView':
        _trtcCloudWrapper!.updateLocalView(element, divId, args);
        break;
      case 'updateRemoteView':
        _trtcCloudWrapper!.updateRemoteView(element, divId, args);
        break;
      case 'startRemoteView':
        _trtcCloudWrapper!.startRemoteView(element, divId, args);
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'trtcCloudChannelView for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  void initSharedInstance() {
    _trtcCloudWrapper = new TrtcWrapper();
    TRTCCloudListenerWeb _webCallback = new TRTCCloudListenerWeb();
    if (_trtcCloudWrapper != null) {
      _trtcCloudWrapper!.setEventHandler(
        allowInterop(
          (String evenType, dynamic data) {
            _webCallback.handleJsCallBack(evenType, data);
          },
        ),
      );
    }
    _trtcCloudWrapper!.sharedInstance();
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    print(
        "============>>>  method: ${call.method} , arguments :  ${call.arguments}");

    if (_trtcCloudWrapper == null && call.method != 'sharedInstance') {
      print('_trtcCloudWrapper is null');
      return Future.value(true);
    }
    var args = '';
    if (call.arguments != null) {
      args = jsonEncode(call.arguments);
      // 不能用map，在release模式下有问题
      //Map<String, dynamic>.from(call.arguments);
    }
    switch (call.method) {
      case "sharedInstance":
        initSharedInstance();
        return Future.value(true);
      case "destroySharedInstance":
        _trtcCloudWrapper!.destroySharedInstance();
        return Future.value(true);
      case "enterRoom":
        _trtcCloudWrapper!.enterRoom(args);
        return Future.value(true);
      case "exitRoom":
        _trtcCloudWrapper!.exitRoom();
        return Future.value(true);
      case "switchRole":
        _trtcCloudWrapper!.switchRole(args);
        return Future.value(true);
      case "stopLocalPreview":
        _trtcCloudWrapper!.stopLocalPreview(args);
        return Future.value(true);
      case "muteRemoteAudio":
        _trtcCloudWrapper!.muteRemoteAudio(args);
        return Future.value(true);
      case "muteAllRemoteAudio":
        _trtcCloudWrapper!.muteAllRemoteAudio(args);
        return Future.value(true);
      case "setRemoteAudioVolume":
        _trtcCloudWrapper!.setRemoteAudioVolume(args);
        return Future.value(true);
      case "stopRemoteView":
        _trtcCloudWrapper!.stopRemoteView(args);
        return Future.value(true);
      case "startLocalAudio":
        _trtcCloudWrapper!.startLocalAudio(args);
        return Future.value(true);
      case "stopLocalAudio":
        _trtcCloudWrapper!.stopLocalAudio(args);
        return Future.value(true);
      case "stopAllRemoteView":
        _trtcCloudWrapper!.stopAllRemoteView(args);
        return Future.value(true);
      case "setVideoEncoderParam":
        _trtcCloudWrapper!.setVideoEncoderParam(args);
        return Future.value(true);
      case "enableEncSmallVideoStream":
        return Future.value(_trtcCloudWrapper!.enableEncSmallVideoStream(args));
      case "muteLocalAudio":
        _trtcCloudWrapper!.muteLocalAudio(args);
        return Future.value(true);
      case "muteLocalVideo":
        _trtcCloudWrapper!.muteLocalVideo(args);
        return Future.value(true);
      case "enableAudioVolumeEvaluation":
        return Future.value(
            _trtcCloudWrapper!.enableAudioVolumeEvaluation(args));
      case "startScreenCapture":
        _trtcCloudWrapper!.startScreenCapture(args);
        return Future.value(true);
      case "stopScreenCapture":
        _trtcCloudWrapper!.stopScreenCapture(args);
        return Future.value(true);
      case "getSDKVersion": 
        return Future.value(_trtcCloudWrapper!.getSDKVersion());
      case "getDevicesList":
        String json = await promiseToFuture(_trtcCloudWrapper!.getDevicesList(args));
        Map map = jsonDecode(json);
        return map;
      case "setCurrentDevice":
        return promiseToFuture(_trtcCloudWrapper!.setCurrentDevice(args));
      case "getCurrentDevice":
        String json = await promiseToFuture(_trtcCloudWrapper!.getCurrentDevice(args));
        Map map = jsonDecode(json);
        return map;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'trtc_plugin for web doesn\'t implement \'${call.method}\'',
        );
    }
  }
}
