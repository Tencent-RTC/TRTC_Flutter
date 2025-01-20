import 'dart:convert';

import '../trtc_cloud.dart';
import '../trtc_cloud_listener.dart';

/// @nodoc
class TRTCCloudListenerWeb {
  void handleJsCallBack(evenType, dynamic params) async {
    String typeStr = evenType;
    TRTCCloudListener? type;
    for (var item in TRTCCloudListener.values) {
      if (item.toString().replaceFirst("TRTCCloudListener.", "") == typeStr) {
        type = item;
        break;
      }
    }
    if (type == null) return;
    try {
      print('<<<========$typeStr  . params :$params');
      switch (type) {
        case TRTCCloudListener.onUserVoiceVolume:
        case TRTCCloudListener.onUserSubStreamAvailable:
        case TRTCCloudListener.onRemoteUserLeaveRoom:
        case TRTCCloudListener.onUserAudioAvailable:
        case TRTCCloudListener.onError:
        case TRTCCloudListener.onWarning:
        case TRTCCloudListener.onUserVideoAvailable:
          params = jsonDecode(params);
          break;
        case TRTCCloudListener.onEnterRoom:
          break;
        case TRTCCloudListener.onExitRoom:
          break;
        case TRTCCloudListener.onSwitchRole:
          break;
        case TRTCCloudListener.onRemoteUserEnterRoom:
          break;
        case TRTCCloudListener.onConnectOtherRoom:
          break;
        case TRTCCloudListener.onDisConnectOtherRoom:
          break;
        case TRTCCloudListener.onSwitchRoom:
          break;
        case TRTCCloudListener.onFirstVideoFrame:
          break;
        case TRTCCloudListener.onFirstAudioFrame:
          break;
        case TRTCCloudListener.onSendFirstLocalVideoFrame:
          break;
        case TRTCCloudListener.onSendFirstLocalAudioFrame:
          break;
        case TRTCCloudListener.onNetworkQuality:
          break;
        case TRTCCloudListener.onStatistics:
          break;
        case TRTCCloudListener.onConnectionLost:
          break;
        case TRTCCloudListener.onTryToReconnect:
          break;
        case TRTCCloudListener.onConnectionRecovery:
          break;
        case TRTCCloudListener.onSpeedTest:
          break;
        case TRTCCloudListener.onCameraDidReady:
          break;
        case TRTCCloudListener.onMicDidReady:
          break;
        case TRTCCloudListener.onRecvCustomCmdMsg:
          break;
        case TRTCCloudListener.onMissCustomCmdMsg:
          break;
        case TRTCCloudListener.onRecvSEIMsg:
          break;
        case TRTCCloudListener.onStartPublishing:
          break;
        case TRTCCloudListener.onStopPublishing:
          break;
        case TRTCCloudListener.onStartPublishCDNStream:
          break;
        case TRTCCloudListener.onStopPublishCDNStream:
          break;
        case TRTCCloudListener.onSetMixTranscodingConfig:
          break;
        case TRTCCloudListener.onMusicObserverStart:
          break;
        case TRTCCloudListener.onMusicObserverPlayProgress:
          break;
        case TRTCCloudListener.onMusicObserverComplete:
          break;
        case TRTCCloudListener.onSnapshotComplete:
          break;
        case TRTCCloudListener.onScreenCaptureStarted:
          break;
        case TRTCCloudListener.onScreenCapturePaused:
          break;
        case TRTCCloudListener.onScreenCaptureResumed:
          break;
        case TRTCCloudListener.onScreenCaptureStoped:
          break;
        case TRTCCloudListener.onDeviceChange:
          break;
        case TRTCCloudListener.onTestMicVolume:
          break;
        case TRTCCloudListener.onTestSpeakerVolume:
          break;
        case TRTCCloudListener.onLocalRecordBegin:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onLocalRecording:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onLocalRecordFragment:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onLocalRecordComplete:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onStartPublishMediaStream:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onUpdatePublishMediaStream:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onStopPublishMediaStream:
          // TODO: Handle this case.
          break;
        case TRTCCloudListener.onAudioRouteChanged:
          // TODO: Handle this case.
          break;
      }
      TRTCCloud cloud = (await TRTCCloud.sharedInstance())!;
      if (cloud.listener != null)
        cloud.listener!.doCallBack(type, params);
    } catch (error) {
      print(error);
    }
  }
}
