@JS()
// ignore: library_names
library TrtcWrapper;

import 'Simulation_js.dart' if (dart.library.html) 'package:js/js.dart';

/// @nodoc
// @anonymous
@JS('TrtcWrapper')
class TrtcWrapper {
  external TrtcWrapper();
  external constructor();
  external String getSDKVersion();
  external void setEventHandler(Function params);
  external void sharedInstance();
  external void destroySharedInstance();
  external void enterRoom(param);
  external void exitRoom();
  external void startLocalAudio(param);
  external void stopLocalAudio(param);
  external void setAudioCaptureVolume(param);
  external void muteLocalAudio(param);
  external void muteLocalVideo(param);
  external int getAudioCaptureVolume(param);
  external void stopRemoteView(param);
  external void stopLocalPreview(param);
  external void startLocalPreview(element, viewId, param);
  external void updateLocalView(element, divId, param);
  external void updateRemoteView(element, divId, param);
  external void startRemoteView(element, divId, param);
  external void muteRemoteAudio(param);
  external void muteAllRemoteAudio(param);
  external void setRemoteAudioVolume(param);
  external void setAudioPlayoutVolume(param);
  external int getAudioPlayoutVolume(param);
  external void stopAllRemoteView(param);
  external void muteRemoteVideoStream(param);
  external void muteAllRemoteVideoStreams(param);

  external void setAudioRoute(arguments);

  external void switchCamera(arguments);

  external void switchRole(arguments);

  external void connectOtherRoom(arguments);

  external void disconnectOtherRoom(arguments);

  external void setDefaultStreamRecvMode(arguments);

  external void setLogCompressEnabled(arguments);

  external void setLogDirPath(arguments);

  external void setLogLevel(arguments);

  external void callExperimentalAPI(arguments);

  external void setConsoleEnabled(arguments);

  external void showDebugView(arguments);

  external void startPublishing(arguments);

  external void stopPublishing(arguments);

  external void startPublishCDNStream(arguments);

  external void stopPublishCDNStream(arguments);

  external void setMixTranscodingConfig(arguments);

  external void startScreenCapture(arguments);

  external void stopScreenCapture(arguments);

  external void pauseScreenCapture(arguments);

  external void resumeScreenCapture(arguments);

  external void setLocalRenderParams(_args);
  //设置视频编码器的编码参数
  external void setVideoEncoderParam(_args);
  // 开启大小画面双路编码模式
  external int enableEncSmallVideoStream(_args);
  // 切换指定远端用户的大小画面
  external int setRemoteVideoStreamType(_args);
  // 启用音量大小提示
  external int enableAudioVolumeEvaluation(_args);

  /// 设备管理start
  external Future<String> getDevicesList(_args);
  external Future<int> setCurrentDevice(_args);
  external Future<String> getCurrentDevice(_args);
  external Future<int> setCurrentDeviceVolume(_args);
  external Future<int> getCurrentDeviceVolume(_args);
  external Future<int> setCurrentDeviceMute(_args);
  external Future<bool> getCurrentDeviceMute(_args);
  external Future<int> startCameraDeviceTest(_args);
  external Future<int> stopCameraDeviceTest(_args);
  external Future<int> startMicDeviceTest(_args);
  external Future<int> stopMicDeviceTest(_args);
  external Future<int> startSpeakerDeviceTest(_args);
  external Future<int> stopSpeakerDeviceTest(_args);

  /// 设备管理end
  external void setWatermark(_args);

  /// 背景音乐相关start
  external void startPlayMusic(_args);
  external void stopPlayMusic(_args);
  external void resumePlayMusic(_args);
  external void pausePlayMusic(_args);

  /// 背景音乐相关end
}
