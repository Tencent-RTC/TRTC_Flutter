// ignore_for_file: avoid_print
import 'dart:typed_data';

import 'package:tencent_rtc_sdk/bridge/trtc/trtc_method_channel.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';

import 'package:tencent_rtc_sdk/tx_device_manager.dart';

import '../../bridge/trtc/trtc_channel_listener.dart';

abstract class ListenerParse<T> {
  final Set<T> _listeners = {};

  void addListener(T listener) {
    _listeners.add(listener);
  }

  void removeListener(T listener) {
    _listeners.remove(listener);
  }

  void clearListeners() {
    _listeners.clear();
  }

  void handleListener(String type, Map<String, dynamic> param);

  void _notifyListeners(void Function(T listener) callback) {
    final snapshot = Set<T>.from(_listeners);
    for (final listener in snapshot) {
      try {
        callback(listener);
      } catch (e) {
        print('Listener callback error: $e');
      }
    }
  }
}

class TRTCCloudListenerParse extends ListenerParse<TRTCCloudListener> {
  TRTCCloudListenerParse() {
    TRTCMethodChannel().setListener(getChannelListener());
  }

  TRTCChannelListener getChannelListener() {
    return TRTCChannelListener(handleNativeOnSnapshotComplete: (arguments) {
      var path = arguments["path"] ?? "";
      var errCode = arguments["errCode"] ?? -1;
      var errMsg = arguments["errMsg"] ?? "parameter parsing error";
      var userId = arguments["userId"] ?? "";

      _notifyListeners((listener) {
        listener.onSnapshotComplete?.call(userId, path, errCode, errMsg);
      });
    });
  }

  @override
  handleListener(String type, Map<String, dynamic> param) {
    switch (type) {
      case "onError":
        _handleOnError(param);
        break;
      case "onWarning":
        _handleOnWarning(param);
        break;
      case "onEnterRoom":
        _handleOnEnterRoom(param);
        break;
      case "onExitRoom":
        _handleOnExitRoom(param);
        break;
      case "onSwitchRole":
        _handleOnSwitchRole(param);
        break;
      case "onSwitchRoom":
        _handleOnSwitchRoom(param);
        break;
      case "onConnectOtherRoom":
        _handleOnConnectOtherRoom(param);
        break;
      case "onDisconnectOtherRoom":
        _handleOnDisconnectOtherRoom(param);
        break;
      case "onRemoteUserEnterRoom":
        _handleOnRemoteUserEnterRoom(param);
        break;
      case "onRemoteUserLeaveRoom":
        _handleOnRemoteUserLeaveRoom(param);
        break;
      case "onUserVideoAvailable":
        _handleOnUserVideoAvailable(param);
        break;
      case "onUserSubStreamAvailable":
        _handleOnUserSubStreamAvailable(param);
        break;
      case "onUserAudioAvailable":
        _handleOnUserAudioAvailable(param);
        break;
      case "onFirstVideoFrame":
        _handleOnFirstVideoFrame(param);
        break;
      case "onFirstAudioFrame":
        _handleOnFirstAudioFrame(param);
        break;
      case "onSendFirstLocalVideoFrame":
        _handleOnSendFirstLocalVideoFrame(param);
        break;
      case "onSendFirstLocalAudioFrame":
        _handleOnSendFirstLocalAudioFrame(param);
        break;
      case "onRemoteVideoStatusUpdated":
        _handleOnRemoteVideoStatusUpdated(param);
        break;
      case "onRemoteAudioStatusUpdated":
        _handleOnRemoteAudioStatusUpdated(param);
        break;
      case "onUserVideoSizeChanged":
        _handleOnUserVideoSizeChanged(param);
        break;
      case "onNetworkQuality":
        _handleOnNetworkQuality(param);
        break;
      case "onStatistics":
        _handleOnStatistics(param);
        break;
      case "onSpeedTestResult":
        _handleOnSpeedTestResult(param);
        break;
      case "onConnectionLost":
        _handleOnConnectionLost(param);
        break;
      case "onTryToReconnect":
        _handleOnTryToReconnect(param);
        break;
      case "onConnectionRecovery":
        _handleOnConnectionRecovery(param);
        break;
      case "onCameraDidReady":
        _handleOnCameraDidReady(param);
        break;
      case "onMicDidReady":
        _handleOnMicDidReady(param);
        break;
      case "onAudioRouteChanged":
        _handleOnAudioRouteChanged(param);
        break;
      case "onUserVoiceVolume":
        _handleOnUserVoiceVolume(param);
        break;
      case "onAudioDeviceCaptureVolumeChanged":
        _handleOnAudioDeviceCaptureVolumeChanged(param);
        break;
      case "onAudioDevicePlayoutVolumeChanged":
        _handleOnAudioDevicePlayoutVolumeChanged(param);
        break;
      case "onSystemAudioLoopbackError":
        _handleOnSystemAudioLoopbackError(param);
        break;
      case "onTestMicVolume":
        _handleOnTestMicVolume(param);
        break;
      case "onTestSpeakerVolume":
        _handleOnTestSpeakerVolume(param);
        break;
      case "onRecvCustomCmdMsg":
        _handleOnRecvCustomCmdMsg(param);
        break;
      case "onMissCustomCmdMsg":
        _handleOnMissCustomCmdMsg(param);
        break;
      case "onRecvSEIMsg":
        _handleOnRecvSEIMsg(param);
        break;
      case "onStartPublishMediaStream":
        _handleOnStartPublishMediaStream(param);
        break;
      case "onUpdatePublishMediaStream":
        _handleOnUpdatePublishMediaStream(param);
        break;
      case "onStopPublishMediaStream":
        _handleOnStopPublishMediaStream(param);
        break;
      case "onCdnStreamStateChanged":
        _handleOnCdnStreamStateChanged(param);
        break;
      case "onScreenCaptureStarted":
        _handleOnScreenCaptureStarted(param);
        break;
      case "onScreenCapturePaused":
        _handleOnScreenCapturePaused(param);
        break;
      case "onScreenCaptureResumed":
        _handleOnScreenCaptureResumed(param);
        break;
      case "onScreenCaptureStopped":
        _handleOnScreenCaptureStopped(param);
        break;
      case "onScreenCaptureCovered":
        _handleOnScreenCaptureCovered(param);
        break;
      case "onLocalRecordBegin":
        _handleOnLocalRecordBegin(param);
        break;
      case "onLocalRecording":
        _handleOnLocalRecording(param);
        break;
      case "onLocalRecordFragment":
        _handleOnLocalRecordFragment(param);
        break;
      case "onLocalRecordComplete":
        _handleOnLocalRecordComplete(param);
        break;
      default:
        break;
    }
  }

  _handleOnError(Map<String, dynamic> param) {
    int errCode = param['errCode'];
    String errMsg = param['errMsg'];

    _notifyListeners((listener) {
      listener.onError?.call(errCode, errMsg);
    });
  }

  _handleOnWarning(Map<String, dynamic> param) {
    int warnCode = param['warningCode'];
    String warnMsg = param['warningMsg'];

    _notifyListeners((listener) {
      listener.onWarning?.call(warnCode, warnMsg);
    });
  }

  _handleOnEnterRoom(Map<String, dynamic> param) {
    int result = param['result'];

    _notifyListeners((listener) {
      listener.onEnterRoom?.call(result);
    });
  }

  _handleOnExitRoom(Map<String, dynamic> param) {
    int reason = param['reason'];

    _notifyListeners((listener) {
      listener.onExitRoom?.call(reason);
    });
  }

  _handleOnSwitchRoom(Map<String, dynamic> param) {
    int errCode = param['errCode'];
    String errMsg = param['errMsg'];

    _notifyListeners((listener) {
      listener.onSwitchRoom?.call(errCode, errMsg);
    });
  }

  _handleOnSwitchRole(Map<String, dynamic> param) {
    int errCode = param['errCode'];
    String errMsg = param['errMsg'];

    _notifyListeners((listener) {
      listener.onSwitchRole?.call(errCode, errMsg);
    });
  }

  _handleOnConnectOtherRoom(Map<String, dynamic> param) {
    String userId = param['userId'];
    int errCode = param['errCode'];
    String errMsg = param['errMsg'];

    _notifyListeners((listener) {
      listener.onConnectOtherRoom?.call(userId, errCode, errMsg);
    });
  }

  _handleOnDisconnectOtherRoom(Map<String, dynamic> param) {
    int errCode = param['errCode'];
    String errMsg = param['errMsg'];

    _notifyListeners((listener) {
      listener.onDisconnectOtherRoom?.call(errCode, errMsg);
    });
  }

  _handleOnUserVideoAvailable(Map<String, dynamic> param) {
    String userId = param['userId'];
    bool available = param['available'];

    _notifyListeners((listener) {
      listener.onUserVideoAvailable?.call(userId, available);
    });
  }

  _handleOnUserSubStreamAvailable(Map<String, dynamic> param) {
    String userId = param['userId'];
    bool available = param['available'];

    _notifyListeners((listener) {
      listener.onUserSubStreamAvailable?.call(userId, available);
    });
  }

  _handleOnUserAudioAvailable(Map<String, dynamic> param) {
    String userId = param['userId'];
    bool available = param['available'];

    _notifyListeners((listener) {
      listener.onUserAudioAvailable?.call(userId, available);
    });
  }

  _handleOnRemoteUserEnterRoom(Map<String, dynamic> param) {
    String userId = param['userId'];

    _notifyListeners((listener) {
      listener.onRemoteUserEnterRoom?.call(userId);
    });
  }

  _handleOnRemoteUserLeaveRoom(Map<String, dynamic> param) {
    String userId = param['userId'];
    int reason = param['reason'];

    _notifyListeners((listener) {
      listener.onRemoteUserLeaveRoom?.call(userId, reason);
    });
  }

  _handleOnFirstVideoFrame(Map<String, dynamic> param) {
    String userId = param['userId'];
    int streamType = param['streamType'];
    int width = param['width'];
    int height = param['height'];

    _notifyListeners((listener) {
      listener.onFirstVideoFrame?.call(
          userId, TRTCVideoStreamTypeExt.fromValue(streamType), width, height);
    });
  }

  _handleOnFirstAudioFrame(Map<String, dynamic> param) {
    String userId = param['userId'];

    _notifyListeners((listener) {
      listener.onFirstAudioFrame?.call(userId);
    });
  }

  _handleOnSendFirstLocalVideoFrame(Map<String, dynamic> param) {
    int streamType = param['streamType'];

    _notifyListeners((listener) {
      listener.onSendFirstLocalVideoFrame
          ?.call(TRTCVideoStreamTypeExt.fromValue(streamType));
    });
  }

  _handleOnSendFirstLocalAudioFrame(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onSendFirstLocalAudioFrame?.call();
    });
  }

  _handleOnRemoteVideoStatusUpdated(Map<String, dynamic> param) {
    String userId = param['userId'];
    int streamType = param['streamType'];
    int status = param['statusType'];
    int changeReason = param['changeReason'];

    _notifyListeners((listener) {
      listener.onRemoteVideoStatusUpdated?.call(
          userId,
          TRTCVideoStreamTypeExt.fromValue(streamType),
          TRTCAVStatusTypeExt.fromValue(status),
          TRTCAVStatusChangeReasonExt.fromValue(changeReason));
    });
  }

  _handleOnRemoteAudioStatusUpdated(Map<String, dynamic> param) {
    String userId = param['userId'];
    int status = param['statusType'];
    int changeReason = param['changeReason'];

    _notifyListeners((listener) {
      listener.onRemoteAudioStatusUpdated?.call(
          userId,
          TRTCAVStatusTypeExt.fromValue(status),
          TRTCAVStatusChangeReasonExt.fromValue(changeReason));
    });
  }

  _handleOnUserVideoSizeChanged(Map<String, dynamic> param) {
    String userId = param['userId'];
    int streamType = param['streamType'];
    int newWidth = param['newWidth'];
    int newHeight = param['newHeight'];

    _notifyListeners((listener) {
      listener.onUserVideoSizeChanged?.call(userId,
          TRTCVideoStreamTypeExt.fromValue(streamType), newWidth, newHeight);
    });
  }

  _handleOnSpeedTestResult(Map<String, dynamic> param) {
    TRTCSpeedTestResult result = TRTCSpeedTestResult.fromJson(param);

    _notifyListeners((listener) {
      listener.onSpeedTestResult?.call(result);
    });
  }

  _handleOnConnectionLost(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onConnectionLost?.call();
    });
  }

  _handleOnTryToReconnect(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onTryToReconnect?.call();
    });
  }

  _handleOnConnectionRecovery(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onConnectionRecovery?.call();
    });
  }

  _handleOnCameraDidReady(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onCameraDidReady?.call();
    });
  }

  _handleOnMicDidReady(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onMicDidReady?.call();
    });
  }

  _handleOnAudioRouteChanged(Map<String, dynamic> param) {
    int newRoute = param['newRoute'];
    int oldRoute = param['oldRoute'];

    _notifyListeners((listener) {
      listener.onAudioRouteChanged?.call(TXAudioRouteExt.fromValue(newRoute),
          TXAudioRouteExt.fromValue(oldRoute));
    });
  }

  _handleOnTestMicVolume(Map<String, dynamic> param) {
    int volume = param['volume'];

    _notifyListeners((listener) {
      listener.onTestMicVolume?.call(volume);
    });
  }

  _handleOnTestSpeakerVolume(Map<String, dynamic> param) {
    int volume = param['volume'];

    _notifyListeners((listener) {
      listener.onTestSpeakerVolume?.call(volume);
    });
  }

  _handleOnRecvCustomCmdMsg(Map<String, dynamic> param) {
    String userId = param['userId'];
    int cmdId = param['cmdId'];
    int seq = param['seq'];
    String message = param['message'];

    _notifyListeners((listener) {
      listener.onRecvCustomCmdMsg?.call(userId, cmdId, seq, message);
    });
  }

  _handleOnMissCustomCmdMsg(Map<String, dynamic> param) {
    String msg = param['msg'];
    int cmdId = param['cmdId'];
    int errCode = param['errCode'];
    int missed = param['missed'];

    _notifyListeners((listener) {
      listener.onMissCustomCmdMsg?.call(msg, cmdId, errCode, missed);
    });
  }

  _handleOnRecvSEIMsg(Map<String, dynamic> param) {
    String userId = param['userId'];
    String message = param['message'];

    _notifyListeners((listener) {
      listener.onRecvSEIMsg?.call(userId, message);
    });
  }

  _handleOnStartPublishMediaStream(Map<String, dynamic> param) {
    String taskId = param['taskId'];
    int code = param['code'];
    String message = param['message'];
    String extraInfo = param['extraInfo'];

    _notifyListeners((listener) {
      listener.onStartPublishMediaStream
          ?.call(taskId, code, message, extraInfo);
    });
  }

  _handleOnUpdatePublishMediaStream(Map<String, dynamic> param) {
    String taskId = param['taskId'];
    int code = param['code'];
    String message = param['message'];
    String extraInfo = param['extraInfo'];

    _notifyListeners((listener) {
      listener.onUpdatePublishMediaStream
          ?.call(taskId, code, message, extraInfo);
    });
  }

  _handleOnStopPublishMediaStream(Map<String, dynamic> param) {
    String taskId = param['taskId'];
    int code = param['code'];
    String message = param['message'];
    String extraInfo = param['extraInfo'];

    _notifyListeners((listener) {
      listener.onStopPublishMediaStream?.call(taskId, code, message, extraInfo);
    });
  }

  _handleOnCdnStreamStateChanged(Map<String, dynamic> param) {
    String cdnUrl = param['cdnUrl'];
    int status = param['status'];
    int code = param['code'];
    String message = param['message'];
    String extraInfo = param['extraInfo'];

    _notifyListeners((listener) {
      listener.onCdnStreamStateChanged
          ?.call(cdnUrl, status, code, message, extraInfo);
    });
  }

  _handleOnScreenCaptureStarted(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onScreenCaptureStarted?.call();
    });
  }

  _handleOnScreenCapturePaused(Map<String, dynamic> param) {
    int reason = param['reason'];

    _notifyListeners((listener) {
      listener.onScreenCapturePaused?.call(reason);
    });
  }

  _handleOnScreenCaptureResumed(Map<String, dynamic> param) {
    int reason = param['reason'];

    _notifyListeners((listener) {
      listener.onScreenCaptureResumed?.call(reason);
    });
  }

  _handleOnScreenCaptureStopped(Map<String, dynamic> param) {
    int reason = param['reason'];

    _notifyListeners((listener) {
      listener.onScreenCaptureStopped?.call(reason);
    });
  }

  _handleOnScreenCaptureCovered(Map<String, dynamic> param) {
    _notifyListeners((listener) {
      listener.onScreenCaptureCovered?.call();
    });
  }

  _handleOnLocalRecordBegin(Map<String, dynamic> param) {
    int errCode = param['errCode'];
    String storagePath = param['storagePath'];

    _notifyListeners((listener) {
      listener.onLocalRecordBegin?.call(errCode, storagePath);
    });
  }

  _handleOnLocalRecording(Map<String, dynamic> param) {
    int duration = param['duration'];
    String storagePath = param['storagePath'];

    _notifyListeners((listener) {
      listener.onLocalRecording?.call(duration, storagePath);
    });
  }

  _handleOnLocalRecordFragment(Map<String, dynamic> param) {
    String storagePath = param['storagePath'];

    _notifyListeners((listener) {
      listener.onLocalRecordFragment?.call(storagePath);
    });
  }

  _handleOnLocalRecordComplete(Map<String, dynamic> param) {
    int errCode = param['errCode'];
    String storagePath = param['storagePath'];

    _notifyListeners((listener) {
      listener.onLocalRecordComplete?.call(errCode, storagePath);
    });
  }

  _handleOnUserVoiceVolume(Map<String, dynamic> param) {
    List<TRTCVolumeInfo> volumeInfo = [];
    List userVolumes = param['userVolumes'];
    for (var i = 0; i < userVolumes.length; i++) {
      volumeInfo.add(TRTCVolumeInfo.fromJson(userVolumes[i]));
    }

    int totalVolume = param['totalVolume'];

    _notifyListeners((listener) {
      listener.onUserVoiceVolume?.call(volumeInfo, totalVolume);
    });
  }

  _handleOnAudioDeviceCaptureVolumeChanged(Map<String, dynamic> param) {
    int volume = param['volume'];
    bool muted = param['muted'];

    _notifyListeners((listener) {
      listener.onAudioDeviceCaptureVolumeChanged?.call(volume, muted);
    });
  }

  _handleOnAudioDevicePlayoutVolumeChanged(Map<String, dynamic> param) {
    int volume = param['volume'];
    bool muted = param['muted'];

    _notifyListeners((listener) {
      listener.onAudioDevicePlayoutVolumeChanged?.call(volume, muted);
    });
  }

  _handleOnSystemAudioLoopbackError(Map<String, dynamic> param) {
    int errCode = param['errCode'];

    _notifyListeners((listener) {
      listener.onSystemAudioLoopbackError?.call(errCode);
    });
  }

  _handleOnNetworkQuality(Map<String, dynamic> param) {
    TRTCQualityInfo localInfo = TRTCQualityInfo.fromJson(param['localQuality']);

    List<TRTCQualityInfo> remoteInfoList = [];
    List remoteQualityList = param['remoteQuality'];
    for (var i = 0; i < remoteQualityList.length; i++) {
      remoteInfoList.add(TRTCQualityInfo.fromJson(remoteQualityList[i]));
    }

    _notifyListeners((listener) {
      listener.onNetworkQuality?.call(localInfo, remoteInfoList);
    });
  }

  _handleOnStatistics(Map<String, dynamic> param) {
    TRTCStatistics statistics = TRTCStatistics.fromJson(param);

    _notifyListeners((listener) {
      listener.onStatistics?.call(statistics);
    });
  }
}

class TRTCAudioFrameCallbackParse
    extends ListenerParse<TRTCAudioFrameCallback> {
  @override
  void handleListener(String type, Map<String, dynamic> param) {
    // 旧格式兼容：不带音频数据的回调
    handleListenerWithData(type, param, null);
  }

  /// 新格式：带音频数据的回调处理
  void handleListenerWithData(
      String type, Map<String, dynamic> param, Uint8List? audioData) {
    switch (type) {
      case 'onCapturedAudioFrame':
        _handleOnCapturedAudioFrame(param, audioData);
        break;
      case 'onLocalProcessedAudioFrame':
        _handleOnLocalProcessedAudioFrame(param, audioData);
        break;
      case 'onPlayAudioFrame':
        _handleOnPlayAudioFrame(param, audioData);
        break;
      case 'onMixedPlayAudioFrame':
        _handleOnMixedPlayAudioFrame(param, audioData);
        break;
      case 'onMixedAllAudioFrame':
        _handleOnMixedAllAudioFrame(param, audioData);
        break;
      default:
        break;
    }
  }

  _handleOnCapturedAudioFrame(
      Map<String, dynamic> param, Uint8List? audioData) {
    TRTCAudioFrame frame = audioData != null
        ? TRTCAudioFrame.fromJsonWithData(param['frame'], audioData)
        : TRTCAudioFrame.fromJson(param['frame']);

    _notifyListeners((listener) {
      listener.onCapturedAudioFrame(frame);
    });
  }

  _handleOnLocalProcessedAudioFrame(
      Map<String, dynamic> param, Uint8List? audioData) {
    TRTCAudioFrame frame = audioData != null
        ? TRTCAudioFrame.fromJsonWithData(param['frame'], audioData)
        : TRTCAudioFrame.fromJson(param['frame']);

    _notifyListeners((listener) {
      listener.onLocalProcessedAudioFrame(frame);
    });
  }

  _handleOnPlayAudioFrame(Map<String, dynamic> param, Uint8List? audioData) {
    TRTCAudioFrame frame = audioData != null
        ? TRTCAudioFrame.fromJsonWithData(param['frame'], audioData)
        : TRTCAudioFrame.fromJson(param['frame']);
    String userId = param['userId'];

    _notifyListeners((listener) {
      listener.onPlayAudioFrame(frame, userId);
    });
  }

  _handleOnMixedPlayAudioFrame(
      Map<String, dynamic> param, Uint8List? audioData) {
    TRTCAudioFrame frame = audioData != null
        ? TRTCAudioFrame.fromJsonWithData(param['frame'], audioData)
        : TRTCAudioFrame.fromJson(param['frame']);

    _notifyListeners((listener) {
      listener.onMixedPlayAudioFrame(frame);
    });
  }

  _handleOnMixedAllAudioFrame(
      Map<String, dynamic> param, Uint8List? audioData) {
    TRTCAudioFrame frame = audioData != null
        ? TRTCAudioFrame.fromJsonWithData(param['frame'], audioData)
        : TRTCAudioFrame.fromJson(param['frame']);

    _notifyListeners((listener) {
      listener.onMixedAllAudioFrame(frame);
    });
  }
}

class TRTCLogCallbackParse extends ListenerParse<TRTCLogCallback> {
  @override
  void handleListener(String type, Map<String, dynamic> param) {
    switch (type) {
      case 'onLog':
        _handleOnLog(param);
        break;
      default:
        break;
    }
  }

  _handleOnLog(Map<String, dynamic> param) {
    String log = param['log'];
    int level = param['log_level'];
    String module = param['module'];

    _notifyListeners((listener) {
      listener.onLog(log, TRTCLogLevelExt.fromValue(level), module);
    });
  }
}
