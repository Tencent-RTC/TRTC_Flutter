import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_trtc_cloud/core/store.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';
import 'package:tencent_trtc_cloud/core/event_center.dart';

/// Listener type enumeration
enum TRTCCloudListener {
  /// Error callback, which indicates that the SDK encountered an irrecoverable error and must be listened on. Corresponding UI reminders should be displayed based on the actual conditions
  ///
  /// *Parameters:*
  ///
  /// `errCode` Error code
  ///
  /// `errMsg` Error message
  /// <br> <br> <br>
  onError,

  /// Warning callback. This callback is used to alert you of some non-serious problems such as lag or recoverable decoding failure
  ///
  /// *Parameters:*
  ///
  /// `warningCode` Warning code
  ///
  /// `warningMsg` Warning message
  /// <br> <br> <br>
  onWarning,

  /// Callback for room entry
  ///
  /// After the `enterRoom()` API in [TRTCCloud] is called to enter a room, the `onEnterRoom(result)` callback will be received from the SDK.
  ///
  /// If room entry succeeded, `result` will be a positive number (`result` > 0), indicating the time in milliseconds (ms) used for entering the room.
  ///
  /// If room entry failed, `result` will be a negative number (`result` < 0), indicating the error code for room entry failure.
  ///
  /// *Parameters:*
  ///
  /// If `result` is greater than 0, it will be the time used for room entry in ms; if `result` is smaller than 0, it will be room entry error code.
  /// <br> <br> <br>
  onEnterRoom,

  /// Callback for room exit
  ///
  /// When the `exitRoom()` API in [TRTCCloud] is called, the logic related to room exit will be executed, such as releasing resources of audio/video devices and codecs. After resources are released, the SDK will use the `onExitRoom()` callback to notify you.
  ///
  /// If you need to call `enterRoom()` again or switch to another audio/video SDK, please wait until you receive the `onExitRoom()` callback; otherwise, exceptions such as occupied audio device may occur.
  ///
  /// *Parameters:*
  ///
  /// `reason` Reason for exiting the room. `0`: the user actively called `exitRoom` to exit the room; `1`: the user was kicked out of the room by the server; `2`: the room was dismissed.
  /// <br> <br> <br>
  onExitRoom,

  /// Callback for role switch
  ///
  /// Calling the `switchRole()` API in [TRTCCloud] will switch between the anchor and audience roles, which will be accompanied by a line switch process. After the SDK switches the roles, the `onSwitchRole()` event callback will be returned.
  ///
  /// *Parameters:*
  ///
  /// `errCode` Error code. `0` indicates a successful switch
  ///
  /// `errMsg`	Error message
  /// <br> <br> <br>
  onSwitchRole,

  /// A user enters the current room
  ///
  /// For the sake of performance, the behaviors of this notification will be different in two different application scenarios:
  ///
  /// Call scenario ([TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL] or [TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL]): users in this scenario do not have different roles, and this notification will be triggered whenever a user enters the room.
  ///
  /// Live streaming scenario ([TRTCCloudDef.TRTC_APP_SCENE_LIVE] or [TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM]): this scenario does not limit the number of audience users. If any user entering or exiting the room could trigger the callback, it would cause great performance loss. Therefore, this notification will be triggered only when an anchor rather than an audience user enters the room.
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  /// <br> <br> <br>
  onRemoteUserEnterRoom,

  /// A user exits the current room
  ///
  /// Similar to `onRemoteUserEnterRoom`, the behaviors of this notification will be different in two different application scenarios:
  ///
  /// Call scenario ([TRTCCloudDef.TRTC_APP_SCENE_VIDEOCALL] or [TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL]): users in this scenario do not have different roles, and this notification will be triggered whenever a user exits the room.
  ///
  /// Live streaming scenario ([TRTCCloudDef.TRTC_APP_SCENE_LIVE] or [TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM]): this notification will be triggered only when an anchor rather than an audience user exits the room.
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `reason` Reason for exiting the room. `0`: the user proactively exited the room; `1`: the user exited the room due to timeout; `2`: the user was kicked out of the room.
  /// <br> <br> <br>
  onRemoteUserLeaveRoom,

  /// Callback for the result of requesting cross-room call (anchor competition)
  ///
  /// Calling the `connectOtherRoom()` API in [TRTCCloud] will establish a video call between two anchors in two different rooms, i.e., the "anchor competition" feature. The caller will receive the `onConnectOtherRoom()` callback to see whether the cross-room call is successful; and if so, all users in both rooms will receive the [onUserVideoAvailable] callback for anchor competition.
  ///
  /// *Parameters:*
  ///
  /// `userId` `userId` of the target anchor to compete with.
  ///
  /// `errCode`   Error code. `ERR_NULL` indicates a successful switch. For more information, please see [Error Codes](https://cloud.tencent.com/document/product/647/32257).
  ///
  /// `errMsg`   Error message
  /// <br> <br> <br>
  onConnectOtherRoom,

  /// Callback for the result of ending cross-room call (anchor competition)
  /// <br> <br> <br>
  onDisConnectOtherRoom,

  /// Callback for the result of room switching (switchRoom)
  ///
  /// *Parameters:*
  ///
  /// `errCode`   Error code
  ///
  /// `errMsg`   Error message
  /// <br> <br> <br>
  onSwitchRoom,

  /// Whether the remote user has a playable primary image (generally for camera)
  ///
  /// When the `onUserVideoAvailable(userId, true)` notification is received, it indicates that available video data frames of the specified image channel have arrived. At this time, the [TRTCCloud.startRemoteView] API needs to be called to load the image of the remote user. Then, the callback for rendering the first video frame, i.e., `onFirstVideoFrame(userid)`, will be received.
  ///
  /// When the `onUserVideoAvailable(userId, false)` notification is received, it indicates that the specified channel of remote image has been disabled, which may be because the user called [TRTCCloud.muteLocalVideo] or [TRTCCloud.stopLocalPreview].
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `available` Whether image is enabled
  /// <br> <br> <br>
  onUserVideoAvailable,

  /// Whether the remote user has a playable substream image (generally for screen sharing)
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `available` Whether screen sharing is enabled
  /// <br> <br> <br>
  onUserSubStreamAvailable,

  /// Whether the remote user has playable audio data
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `available` Whether audio is enabled
  /// <br> <br> <br>
  onUserAudioAvailable,

  /// Rendering of the first frame of a local or remote user starts
  ///
  /// If `userId` is `null`, it indicates that the captured local camera image starts to be rendered, which needs to be triggered by calling `startLocalPreview` first. If `userId` is not `null`, it indicates that the first video frame of the remote user starts to be rendered, which needs to be triggered by calling `startRemoteView` first.
  ///
  /// This callback will be triggered only after [TRTCCloud.startLocalPreview()] or [TRTCCloud.startRemoteView()] is called.
  ///
  /// *Parameters:*
  ///
  /// `userId` ID of the local or remote user. `userId == null` indicates the ID of the local user, while `userId != null` indicates the ID of a remote user.
  ///
  /// `streamType` Video stream type: camera or screen sharing.
  ///
  /// `width` Image width
  ///
  /// `height` Image height
  /// <br> <br> <br>
  onFirstVideoFrame,

  /// Playback of the first audio frame of a remote user starts (local audio is not supported for notification currently)
  ///
  /// *Parameters:*
  ///
  /// `userId` Remote user ID
  /// <br> <br> <br>
  onFirstAudioFrame,

  /// The first local audio frame data has been sent
  ///
  /// The SDK will start capturing the camera and encode the captured image after successful call of [TRTCCloud.enterRoom()] and [TRTCCloud.startLocalPreview()]. This callback event will be returned after the SDK successfully sends the first video frame data to the cloud.
  ///
  /// *Parameters:*
  ///
  /// `streamType` Video stream type: big image, small image, or substream image (screen sharing)
  /// <br> <br> <br>
  onSendFirstLocalVideoFrame,

  /// The first local audio frame data has been sent
  ///
  /// The SDK will start capturing the mic and encoding the captured audio after successful call of [TRTCCloud.enterRoom()] and [TRTCCloud.startLocalAudio()]. This callback event will be returned after the SDK successfully sends the first audio frame data to the cloud.
  /// <br> <br> <br>
  onSendFirstLocalAudioFrame,

  /// Whether system audio capturing is enabled successfully (for desktop OS only)
  ///
  /// On macOS, you can call startSystemAudioLoopback to install an audio driver and have the SDK capture the audio played back by the system.
  ///
  /// On Windows systems, you can use startSystemAudioLoopback to have the SDK capture the audio played back by the system.
  ///
  /// In use cases such as video teaching and music live streaming, the teacher can use this feature to let the SDK capture the sound of the video played by his or her computer, so that students in the room can hear the sound too.
  ///
  /// The SDK returns this callback after trying to enable system audio capturing. To determine whether it is actually enabled, pay attention to the error parameter in the callback.
  ///
  /// *Parameters:*
  ///
  /// `errCode` If it is 0 , system audio capturing is enabled successfully. Otherwise, it is not.
  /// <br> <br> <br>
  onSystemAudioLoopbackError,

  /// Network quality: this callback is triggered once every 2 seconds to collect statistics of the current network upstreaming and downstreaming quality
  ///
  /// `userId` is the local user ID, indicating the current local video quality
  ///
  /// *Parameters:*
  ///
  /// `localQuality` Upstream network quality
  ///
  /// `remoteQuality` Downstream network quality
  /// <br> <br> <br>
  onNetworkQuality,

  /// Callback for technical metric statistics
  ///
  /// If you are familiar with audio/video terms, you can use this callback to get all technical metrics of the SDK. If you are developing an audio/video project for the first time, you can focus only on the `onNetworkQuality` callback.
  ///
  /// *Note:* the callback is triggered once every 2 seconds
  ///
  /// *Parameters:*
  ///
  /// `statics` Status data
  /// <br> <br> <br>
  onStatistics,

  /// The connection between SDK and server is closed
  /// <br> <br> <br>
  onConnectionLost,

  /// The SDK tries to connect to the server again
  /// <br> <br> <br>
  onTryToReconnect,

  /// The connection between SDK and server has been restored
  /// <br> <br> <br>
  onConnectionRecovery,

  /// Callback for server speed test. SDK tests the speed of multiple server IPs, and the test result of each IP is returned through this callback notification
  ///
  /// *Parameters:*
  ///
  /// `currentResult` Current speed test result
  ///
  /// `finishedCount` Number of servers on which speed test has been performed
  ///
  /// `totalCount` Total number of servers on which speed test needs to be performed
  /// <br> <br> <br>
  @Deprecated("Server speed test callback of the startSpeedTest interface. If you are using startSpeedTestWithParams, use the onSpeedTestResult callback")
  onSpeedTest,

  /// Callback of network speed test.
  ///
  /// The callback is triggered by startSpeedTestWithParams.
  ///
  /// *Parameters:*
  ///
  /// `result` Speed test data, including loss rates, rtt and bandwidth rates, please refer to TRTCSpeedTestResult for details.
  /// <br> <br> <br>
  onSpeedTestResult,

  /// Camera is ready
  /// <br> <br> <br>
  onCameraDidReady,

  /// Mic is ready
  /// <br> <br> <br>
  onMicDidReady,

  /// Callback for volume, including the volume of each `userId` and total remote volume
  ///
  /// The `enableAudioVolumeEvaluation` API in [TRTCCloud] can be used to enable this callback or set its triggering interval. It should be noted that after [TRTCCloud.enableAudioVolumeEvaluation] is called to enable the volume callback, no matter whether there is a user speaking in the channel, the callback will be called at the set time interval. If there is no one speaking, `userVolumes` will be empty, and `totalVolume` will be `0`.
  ///
  /// *Note:* if `userId` is the local user ID, it indicates the volume of the local user. `userVolumes` only includes the volume information of users who are speaking (i.e., volume is not 0).
  ///
  /// *Parameters:*
  ///
  /// userVolumes Volume of all members who are speaking in the room. Value range: `0`–`100`.
  ///
  /// totalVolume Total volume of all remote members. Value range: `0`–`100`.
  /// <br> <br> <br>
  onUserVoiceVolume,

  /// Callback for receipt of custom message
  ///
  /// When a user in a room uses [TRTCCloud.sendCustomCmdMsg] to send a custom message, other users in the room can receive the message through the `onRecvCustomCmdMsg` API.
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `cmdID` Command ID
  ///
  /// `seq` Message serial number
  ///
  /// `message` Message data
  /// <br> <br> <br>
  onRecvCustomCmdMsg,

  /// Callback for loss of custom message
  ///
  /// TRTC uses the UDP channel; therefore, even if reliable transfer is set, it cannot guarantee that no message will be lost; instead, it can only reduce the message loss rate to a very small value and meet general reliability requirements. After reliable transfer is set on the sender, the SDK will use this callback to notify of the number of custom messages lost during transfer in the specified past time period (usually 5s).
  ///
  /// *Note:*
  ///
  /// Only when reliable transfer is set on the sender can the receiver receive the callback for message loss.
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `cmdID` Data stream ID
  ///
  /// `errCode` Error code. The value is `-1` on the current version
  ///
  /// `missed` Number of lost messages
  /// <br> <br> <br>
  onMissCustomCmdMsg,

  /// Callback for receipt of SEI message
  ///
  /// When a user in a room uses [TRTCCloud.sendSEIMsg] to send data, other users in the room can receive the data through the `onRecvSEIMsg` API.
  ///
  /// *Parameters:*
  ///
  /// `userId` User ID
  ///
  /// `message` Data
  /// <br> <br> <br>
  onRecvSEIMsg,

  /// Callback for starting pushing to Tencent Cloud CSS CDN, which corresponds to the `startPublishing()` API in [TRTCCloud]
  ///
  /// *Parameters:*
  ///
  /// `errCode`	`0`: success; other values: failure
  ///
  /// `errMsg`	Specific cause of error
  /// <br> <br> <br>
  onStartPublishing,

  /// Callback for stopping pushing to Tencent Cloud CSS CDN, which corresponds to the `stopPublishing()` API in [TRTCCloud]
  ///
  /// *Parameters:*
  ///
  /// `errCode` `0`: success; other values: failure
  ///
  /// `errMsg`	Specific cause of error
  /// <br> <br> <br>
  onStopPublishing,

  /// Callback for completion of starting relayed push to CDN
  ///
  /// This callback corresponds to the `startPublishCDNStream()` API in [TRTCCloud]
  ///
  /// *Note:* if `Start` callback is successful, the relayed push request has been successfully sent to Tencent Cloud. If the target CDN is exceptional, relayed push may fail.
  ///
  /// *Parameters:*
  ///
  /// `errCode` `0`: success; other values: failure
  ///
  /// `errMsg` Specific cause of error
  /// <br> <br> <br>
  onStartPublishCDNStream,

  /// Callback for completion of stopping relayed push to CDN
  ///
  /// This callback corresponds to the `stopPublishCDNStream()` API in [TRTCCloud]
  ///
  /// *Parameters:*
  ///
  /// `errCode` `0`: success; other values: failure
  ///
  /// `errMsg` Specific cause of error
  /// <br> <br> <br>
  onStopPublishCDNStream,

  /// Callback for setting On-Cloud MixTranscoding parameters, which corresponds to the `setMixTranscodingConfig()` API in [TRTCCloud]
  ///
  /// *Parameters:*
  ///
  /// `errCode` `0`: success; other values: failure
  ///
  /// `errMsg` Specific cause of error
  /// <br> <br> <br>
  onSetMixTranscodingConfig,

  /// Background music playback start
  /// <br> <br> <br>
  onMusicObserverStart,

  /// Background music playback progress
  /// <br> <br> <br>
  onMusicObserverPlayProgress,

  /// Background music playback end
  /// <br> <br> <br>
  onMusicObserverComplete,

  /// Callback for screencapturing completion
  ///
  /// *Parameters:*
  ///
  /// `errCode` of `0`: success; other values: failure
  /// <br> <br> <br>
  onSnapshotComplete,

  /// This callback will be returned by the SDK when screen sharing is started
  /// <br> <br> <br>
  onScreenCaptureStarted,

  /// This callback will be returned by the SDK when screen sharing is paused
  ///
  /// *Parameters:*
  ///
  /// `reason` Reason. `0`: the user paused proactively; `1`: screen sharing was paused as the screen window became invisible
  ///
  /// *Note:* the value called back is only valid for iOS
  /// <br> <br> <br>
  onScreenCapturePaused,

  /// This callback will be returned by the SDK when screen sharing is resumed
  ///
  /// *Parameters:*
  ///
  /// `reason` Reason for resumption. `0`: the user resumed proactively; `1`: screen sharing was resumed as the screen window became visible
  ///
  /// *Note:* the value called back is only valid for iOS
  /// <br> <br> <br>
  onScreenCaptureResumed,

  /// This callback will be returned by the SDK when screen sharing is stopped
  ///
  /// *Parameters:*
  ///
  ///`reason` Reason for stop. `0`: the user stopped proactively; `1`: screen sharing stopped as the shared window was closed
  /// <br> <br> <br>
  onScreenCaptureStoped,

  /// When the local recording task has started, the SDK will notify through this callback
  ///
  /// *Parameters:*
  ///
  /// `errCode`
  ///   -`0`: The recording task is started successfully.
  ///   -`1`: An internal error caused the recording task to fail to start.
  ///   -`2`: The file suffix name is incorrect (such as unsupported recording format).
  ///   -`6`: Recording has been started and needs to be stopped first.
  ///   -`7`: The recording file already exists and the file needs to be deleted first.
  ///   -`8`: The recording directory does not have write permissions. Please check the directory permissions.
  ///
  /// `storagePath`   Recording file storage path.
  /// <br> <br> <br>
  onLocalRecordBegin,

  /// When the local recording task is in progress, the SDK will periodically notify you through this callback
  ///
  /// You can set the throwing interval of this event callback when startingLocalRecording.
  ///
  /// *Parameters:*
  ///
  /// `duration`   The accumulated duration of recording, in milliseconds.
  ///
  /// `storagePath`   Recording file storage path.
  /// <br> <br> <br>
  onLocalRecording,

  /// When you enable segmented recording, the SDK will notify you through this callback every time a segment is completed.
  ///
  /// *Parameters:*
  ///
  /// `storagePath`   Shard file storage path.
  /// <br> <br> <br>
  onLocalRecordFragment,

  /// When the local recording task has ended, the SDK will notify you through this callback
  ///
  /// *Parameters:*
  ///
  /// `errCode`
  ///           -`0`: The recording task ends successfully.
  ///           -`1`: Recording failed.
  ///           -`2`: Switching resolution or horizontal and vertical screens causes the recording to end.
  ///           -`3`: The recording time is too short, or no video or audio data was collected. Please check the recording time, or whether audio and video collection has been turned on.
  ///
  /// `storagePath`   Recording file storage path.
  /// <br> <br> <br>
  onLocalRecordComplete,

  /// Callback for local device connection and disconnection
  ///
  /// *Note:* this callback only supports Windows and macOS platforms
  ///
  /// *Parameters:*
  ///
  /// `deviceId`  Device ID
  ///
  /// `type`   Device type
  ///
  /// `state`   Event type
  /// <br> <br> <br>
  onDeviceChange,

  /// Callback for mic test volume
  ///
  /// The mic test API [TXDeviceManager.startMicDeviceTest] will trigger this callback
  ///
  /// *Note:* this callback only supports Windows and macOS platforms
  ///
  /// *Parameters:*
  ///
  /// `volume`   Volume value between 0 and 100
  /// <br> <br> <br>
  onTestMicVolume,

  /// Callback for speaker test volume
  ///
  /// The speaker test API [TXDeviceManager.startSpeakerDeviceTest] will trigger this callback
  ///
  /// *Note:* this callback only supports Windows and macOS platforms
  ///
  /// *Parameters:*
  ///
  /// `volume`   Volume value between 0 and 100
  /// <br> <br> <br>
  onTestSpeakerVolume,

  /// Callback for starting to publish
  ///
  /// `code`:  `0` : Successful; other values: Failed.
  ///
  /// `extraInfo`: Additional information. For some error codes, there may be additional information to help you troubleshoot the issues.
  ///
  /// `message`: The callback information.
  ///
  /// `taskId`: If a request is successful, a task ID will be returned via the callback. You need to provide this task ID when you call [TRTCCloud.updatePublishMediaStream] to modify publishing parameters or [TRTCCloud.stopPublishMediaStream] to stop publishing.
  /// <br> <br> <br>
  onStartPublishMediaStream,

  /// Callback for modifying publishing parameters
  ///
  /// `code`:  `0` : Successful; other values: Failed.
  ///
  /// `extraInfo`: Additional information. For some error codes, there may be additional information to help you troubleshoot the issues.
  ///
  /// `message`: The callback information.
  ///
  /// `taskId`: If a request is successful, a task ID will be returned via the callback. You need to provide this task ID when you call [TRTCCloud.updatePublishMediaStream] to modify publishing parameters or [TRTCCloud.stopPublishMediaStream] to stop publishing.
  /// <br> <br> <br>
  onUpdatePublishMediaStream,

  /// Callback for stopping publishing
  ///
  /// `code`:  `0` : Successful; other values: Failed.
  ///
  /// `extraInfo`: Additional information. For some error codes, there may be additional information to help you troubleshoot the issues.
  ///
  /// `message`: The callback information.
  ///
  /// `taskId`: If a request is successful, a task ID will be returned via the callback. You need to provide this task ID when you call [TRTCCloud.updatePublishMediaStream] to modify publishing parameters or [TRTCCloud.stopPublishMediaStream] to stop publishing.
  /// <br> <br> <br>
  onStopPublishMediaStream,

  /// The audio route changed (for mobile devices only)
  ///
  /// Audio route is the route (speaker or receiver) through which audio is played.
  /// - When audio is played through the receiver, the volume is relatively low, and the sound can be heard only when the phone is put near the ear. This mode has a high level of privacy and is suitable for answering calls.
  /// - When audio is played through the speaker, the volume is relatively high, and there is no need to put the phone near the ear. This mode enables the "hands-free" feature.
  /// - When audio is played through the wired earphone.
  /// - When audio is played through the bluetooth earphone.
  /// - When audio is played through the USB sound card.
  ///
  /// *Parameters:*
  ///
  /// `route`: Audio route, i.e., the route (speaker or receiver) through which audio is played
  ///
  /// `fromRoute`: The audio route used before the change
  onAudioRouteChanged,
}

/// Music preload observer for listening to the preload progress of the music track.
class TXMusicPreloadObserver {
  const TXMusicPreloadObserver({
    this.onLoadProgress,
    this.onLoadError,
  });

  /// Background music preload progress
  final void Function(int id, int process)? onLoadProgress;

  /// Background music preload error
  final void Function(int id, int errCode)? onLoadError;
}

/// @nodoc
/// Listener object
class TRTCCloudListenerWrapper {
  Set<ListenerValue> listeners = Set();

  TXMusicPreloadObserver? _musicPreloadObserver;

  TRTCCloudListenerWrapper(MethodChannel channel) {
    channel.setMethodCallHandler((methodCall) async {
      var arguments;
      if (!kIsWeb && Platform.isWindows) {
        arguments = methodCall.arguments;
      } else {
        arguments = jsonDecode(methodCall.arguments);
      }
      switch (methodCall.method) {
        case 'onListener':
          _handleOnListener(arguments);
          _handleTextureRenderData(arguments);
          break;
        case 'onMusicPreloadObserver':
          _handleOnMusicPreloadObserver(arguments);
          break;
        default:
          throw MissingPluginException();
      }
    });
  }

  void doCallBack(type, params) {
    for (var item in listeners) {
      item(type, params);
    }
  }

  void addListener(ListenerValue func) {
    listeners.add(func);
  }

  void removeListener(ListenerValue func) {
    listeners.remove(func);
  }

  void setPreloadObserver(TXMusicPreloadObserver? observer) {
    _musicPreloadObserver = observer;
  }

  _handleTextureRenderData(dynamic arguments) {
    String typeStr = arguments['type'];
    var params = arguments['params'];

    if (typeStr == "onEnterRoom") {
      EventCenter().notify(onEnterRoomEvent);
      Store.sharedInstance().setLocalTextureParam(TRTCRenderParams());
    } else if (typeStr == "onExitRoom") {
      Store.sharedInstance().clean();
    } else if (typeStr == "onRemoteUserEnterRoom") {
      Store.sharedInstance().setUserRenderParamsMap(params.toString(), TRTCRenderParams());
    } else if (typeStr == "onRemoteUserLeaveRoom") {
      Store.sharedInstance().deleteUser(params["userId"].toString());
    }
  }

  _handleOnListener(dynamic arguments) {
    String typeStr = arguments['type'];
    var params = arguments['params'];

    TRTCCloudListener? type;

    for (var item in TRTCCloudListener.values) {
      if (item.toString().replaceFirst("TRTCCloudListener.", "") ==
          typeStr) {
        type = item;
        break;
      }
    }
    if (type == null) {
      throw MissingPluginException();
    }
    for (var item in listeners) {
      item(type, params);
    }
  }

  _handleOnMusicPreloadObserver(dynamic arguments) {
    String typeStr = arguments['type'];
    switch (typeStr) {
      case 'onLoadProgress':
        int id = arguments['id'];
        int progress = arguments['progress'];
        if (_musicPreloadObserver != null) {
          _musicPreloadObserver!.onLoadProgress!(id, progress);
        }
        break;
      case 'onLoadError':
        int id = arguments['id'];
        int errCode = arguments['errCode'];
        if (_musicPreloadObserver != null) {
          _musicPreloadObserver!.onLoadError!(id, errCode);
        }
        break;
      default:
        break;
    }
  }
}

/// @nodoc
typedef ListenerValue<P> = void Function(TRTCCloudListener type, P? params);

/// Audio frame listener for listening to audio frame data captured in the TRTC.
class TRTCAudioFrameListener {
  const TRTCAudioFrameListener({this.onCapturedAudioFrame});

  /// Callback for audio data collected locally and pre-processed by the audio module
  ///
  /// After the user has set up the audio data customization callback, the SDK will internally callback the newly captured and pre-processed (ANS, AEC, AGC) data to the user in PCM format via this interface.
  /// - This interface calls back the audio with a fixed time frame length of 0.02s in PCM format.
  /// - The formula for converting time frame length to byte frame length is `sample rate × time frame length × number of channels × sample point bit width`.
  /// - Using TRTC's default audio recording format of 48000 sample rate, mono, and 16 bit width, the byte frame length is `48000 × 0.02s × 1 × 16bit = 15360bit = 1920 bytes`.
  final void Function(TRTCAudioFrame audioFrame)? onCapturedAudioFrame;
}

/// @nodoc
class TRTCAudioFrameListenerPlatformMethod {
  BasicMessageChannel? _basicMessageChannel;
  TRTCAudioFrameListener? _listener;

  TRTCAudioFrameListenerPlatformMethod(String channelName) {
    _basicMessageChannel = BasicMessageChannel(channelName + "_basic_channel", JSONMessageCodec());
  }

  Future<void> setAudioFrameListener(TRTCAudioFrameListener? listener) async {
    if (listener != null) {
      _listener = listener;
      _basicMessageChannel!.setMessageHandler((message) async {
        message as Map<String, dynamic>;
        _handleArguments(message);
      });
    } else {
      _listener = null;
    }
  }

  _handleArguments(Map<String, dynamic> arguments) {
    String method = arguments['method'] as String;
    switch(method) {
      case 'onCapturedAudioFrame':
        _handleOnCapturedAudioFrameData(arguments['params']);
        break;
      default:
        break;
    }
  }

  _handleOnCapturedAudioFrameData(Map<String, dynamic> params) {
    TRTCAudioFrame audioFrame = TRTCAudioFrame();

    if (params['data'] != null) {
      audioFrame.data = Uint8List.fromList(List<int>.from(params['data']));
    }

    if (params['sampleRate'] != null) {
      audioFrame.sampleRate = params['sampleRate'];
    }

    if (params['channels'] != null) {
      audioFrame.channels = params['channels'];
    }

    if (params['timestamp'] != null) {
      audioFrame.timestamp = params['timestamp'];
    }

    if (params['extraData'] != null) {
      audioFrame.extraData = Uint8List.fromList(List<int>.from(params['extraData']));
    }

    if (_listener != null && _listener!.onCapturedAudioFrame != null) {
      _listener!.onCapturedAudioFrame!(audioFrame);
    }
  }
}
