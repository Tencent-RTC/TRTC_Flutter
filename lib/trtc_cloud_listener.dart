// ignore_for_file: unintended_html_in_doc_comment
// ignore_for_file: comment_references
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';

class TRTCCloudListener {
  /// Error Event Callback
  ///
  /// Error event, which indicates that the SDK threw an irrecoverable error
  /// such as room entry failure or failure to start device.
  ///
  /// For more information, see [Error Codes](https://intl.cloud.tencent.com/document/product/647/35135).
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Error code.
  ///   - **errMsg(String)**:
  ///     - Error message.
  final void Function(int errCode, String errMsg)? onError;

  /// Warning Event Callback
  ///
  /// Warning event, which indicates that the SDK threw an error requiring attention,
  /// such as video lag or high CPU usage.
  ///
  /// For more information, see [Error Codes](https://intl.cloud.tencent.com/document/product/647/35135).
  ///
  /// - **Parameters:**
  ///   - **warningCode(int)**:
  ///     - Warning code.
  ///   - **warningMsg(String)**:
  ///     - Warning message.
  final void Function(int warningCode, String warningMsg)? onWarning;

  /// Whether Room Entry is Successful
  ///
  /// After calling the `enterRoom()` API in `TRTCCloud` to enter a room,
  /// you will receive the `onEnterRoom(result)` callback from `TRTCCloudDelegate`.
  ///
  /// - If room entry succeeded, `result` will be a positive number (`result > 0`),
  ///   indicating the time in milliseconds (ms) the room entry takes.
  /// - If room entry failed, `result` will be a negative number (`result < 0`),
  ///   indicating the error code for the failure.
  ///
  /// For more information on the error codes for room entry failure, see
  /// [Error Codes](https://intl.cloud.tencent.com/document/product/647/35135).
  ///
  /// - **Parameters:**
  ///   - **result(int)**:
  ///     - If `result` is greater than 0, it indicates the time (in ms) the room entry takes;
  ///       if `result` is less than 0, it represents the error code for room entry.
  ///
  /// > **Note**
  /// > 1. In TRTC versions below 6.6, the `onEnterRoom(result)` callback is returned
  /// >    only if room entry succeeds, and the `onError()` callback is returned if room entry fails.
  /// > 2. In TRTC 6.6 and above, the `onEnterRoom(result)` callback is returned regardless
  /// >    of whether room entry succeeds or fails, and the `onError()` callback is also returned
  /// >    if room entry fails.
  final void Function(int result)? onEnterRoom;

  /// Room Exit
  ///
  /// Calling the `exitRoom()` API in `TRTCCloud` will trigger the execution
  /// of room exit-related logic, such as releasing resources of audio/video
  /// devices and codecs.
  ///
  /// After all resources occupied by the SDK are released, the SDK will return
  /// the `onExitRoom()` callback.
  ///
  /// If you need to call `enterRoom()` again or switch to another audio/video SDK,
  /// please wait until you receive the `onExitRoom()` callback. Otherwise, you may
  /// encounter problems such as the camera or mic being occupied.
  ///
  /// - **Parameters:**
  ///   - **reason(int)**:
  ///     - Reason for room exit.
  ///       - `0`: the user called `exitRoom` to exit the room;
  ///       - `1`: the user was removed from the room by the server;
  ///       - `2`: the room was dismissed.
  final void Function(int reason)? onExitRoom;

  /// Role Switching
  ///
  /// You can call the `switchRole()` API in `TRTCCloud` to switch between
  /// the anchor and audience roles. This is accompanied by a line switching process.
  ///
  /// After the switching, the SDK will return the `onSwitchRole()` event callback.
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Error code. `ERR_NULL` indicates a successful switch.
  ///       For more information, please see [Error Codes](https://intl.cloud.tencent.com/document/product/647/35135).
  ///   - **errMsg(String)**:
  ///     - Error message.
  final void Function(int errCode, String errMsg)? onSwitchRole;

  /// Result of Room Switching
  ///
  /// You can call the `switchRoom()` API in `TRTCCloud` to switch from one
  /// room to another.
  ///
  /// After the switching, the SDK will return the `onSwitchRoom()` event callback.
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Error code. `ERR_NULL` indicates a successful switch.
  ///       For more information, please see [Error Codes](https://intl.cloud.tencent.com/document/product/647/35124).
  ///   - **errMsg(String)**:
  ///     - Error message.
  final void Function(int errCode, String errMsg)? onSwitchRoom;

  /// Result of Requesting Cross-Room Call
  ///
  /// You can call the `connectOtherRoom()` API in `TRTCCloud` to establish
  /// a video call with the anchor of another room. This is the “anchor
  /// competition” feature.
  ///
  /// The caller will receive the `onConnectOtherRoom()` callback, which can
  /// be used to determine whether the cross-room call is successful.
  ///
  /// If it is successful, all users in either room will receive the
  /// `onUserVideoAvailable()` callback from the anchor of the other room.
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Error code. `ERR_NULL` indicates that cross-room connection is
  ///       established successfully. For more information, please see
  ///       [Error Codes](https://intl.cloud.tencent.com/document/product/647/35135).
  ///   - **errMsg(String)**:
  ///     - Error message.
  ///   - **userId(String)**:
  ///     - The user ID of the anchor (in another room) to be called.
  final void Function(String userId, int errCode, String errMsg)?
      onConnectOtherRoom;

  /// Result of ending cross-room call
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Error code. For more information, please see [Error Codes](https://intl.cloud.tencent.com/document/product/647/35135).
  ///   - **errMsg(String)**:
  ///     - Error message.
  final void Function(int errCode, String errMsg)? onDisconnectOtherRoom;

  /// A User Entered the Room
  ///
  /// Due to performance concerns, this callback works differently in different
  /// scenarios (i.e., `AppScene`, which you can specify by setting the second
  /// parameter when calling `enterRoom`).
  ///
  /// - **Live Streaming Scenarios** ([TRTCAppScene.live] or [TRTCAppScene.voiceChatRoom]):
  ///   In live streaming scenarios, a user is either in the role of an anchor
  ///   or audience. The callback is returned only when an anchor enters the room.
  ///
  /// - **Call Scenarios** ([TRTCAppScene.videoCall] or [TRTCAppScene.audioCall]):
  ///   In call scenarios, the concept of roles does not apply (all users can
  ///   be considered as anchors), and the callback is returned when any user
  ///   enters the room.
  ///
  /// - **Parameters:**
  ///   - **userId(String)**:
  ///     - User ID of the remote user.
  ///
  /// > **Note**
  /// >
  /// > 1. The `onRemoteUserEnterRoom` callback indicates that a user entered
  /// >    the room, but it does not necessarily mean that the user enabled
  /// >    audio or video.
  /// >
  /// > 2. If you want to know whether a user enabled video, we recommend you
  /// >    use the [onUserVideoAvailable] callback.
  final void Function(String userId)? onRemoteUserEnterRoom;

  /// A User Exited the Room
  ///
  /// As with `onRemoteUserEnterRoom`, this callback works differently in
  /// different scenarios (i.e., [TRTCAppScene] , which you can specify by setting
  /// the second parameter when calling `enterRoom`).
  ///
  /// - **Live Streaming Scenarios** ([TRTCAppScene.live] or [TRTCAppScene.voiceChatRoom]):
  ///   The callback is triggered only when an anchor exits the room.
  ///
  /// - **Call Scenarios** ([TRTCAppScene.videoCall] or [TRTCAppScene.audioCall]):
  ///   In call scenarios, the concept of roles does not apply, and the callback
  ///   is returned when any user exits the room.
  ///
  /// - **Parameters:**
  ///   - **reason(int)**:
  ///     - Reason for room exit.
  ///       - `0`: the user exited the room voluntarily;
  ///       - `1`: the user exited the room due to timeout;
  ///       - `2`: the user was removed from the room;
  ///       - `3`: the anchor user exited the room due to switching to audience.
  ///   - **userId(String)**:
  ///     - User ID of the remote user.
  final void Function(String userId, int reason)? onRemoteUserLeaveRoom;

  /// A Remote User Published/Unpublished Primary Stream Video
  ///
  /// The primary stream is usually used for camera images. If you receive the
  /// [onUserVideoAvailable] (userId, true) callback, it indicates that the
  /// user has available primary stream video.
  ///
  /// You can then call [startRemoteView] to subscribe to the remote user’s
  /// video. If the subscription is successful, you will receive the
  /// [onFirstVideoFrame] (userId) callback, which indicates that the first
  /// video frame of the user is rendered.
  ///
  /// If you receive the [onUserVideoAvailable] (userId, false) callback, it
  /// indicates that the video of the remote user is disabled, which may be
  /// because the user called [muteLocalVideo] or [stopLocalPreview].
  ///
  /// - **Parameters:**
  ///   - **available(bool)**:
  ///     - Whether the user published (or unpublished) primary stream video.
  ///       - `true`: published;
  ///       - `false`: unpublished.
  ///   - **userId(String)**:
  ///     - User ID of the remote user.
  final void Function(String userId, bool available)? onUserVideoAvailable;

  /// A Remote User Published/Unpublished Substream Video
  ///
  /// The substream is usually used for screen sharing images. If you receive the
  /// [onUserSubStreamAvailable] (userId, true) callback, it indicates that the
  /// user has available substream video.
  ///
  /// You can then call [startRemoteView] to subscribe to the remote user’s
  /// video. If the subscription is successful, you will receive the
  /// [onFirstVideoFrame] (userId) callback, which indicates that the first
  /// frame of the user is rendered.
  ///
  /// - **Parameters:**
  ///   - **available(bool)**:
  ///     - Whether the user published (or unpublished) substream video.
  ///       - `true`: published;
  ///       - `false`: unpublished.
  ///   - **userId(String)**:
  ///     - User ID of the remote user.
  ///
  /// > **Note**
  /// >
  /// > The API used to display substream images is [startRemoteView],
  final void Function(String userId, bool available)? onUserSubStreamAvailable;

  /// A Remote User Published/Unpublished Audio
  ///
  /// If you receive the [onUserAudioAvailable] (userId, true) callback, it
  /// indicates that the user published audio.
  /// - In auto-subscription mode, the SDK will play the user’s audio automatically.
  /// - In manual subscription mode, you can call [muteRemoteAudio] (userid, false)
  /// to play the user’s audio.
  ///
  /// - **Parameters:**
  ///   - **available(bool)**:
  ///     - Whether the user published (or unpublished) audio.
  ///       - `true`: published;
  ///       - `false`: unpublished.
  ///   - **userId(String)**:
  ///     - User ID of the remote user.
  ///
  /// > **Note**
  /// >
  /// > The auto-subscription mode is used by default. You can switch to the
  /// > manual subscription mode by calling [setDefaultStreamRecvMode],
  /// > but it must be called before room entry for the switch to take effect.
  final void Function(String userId, bool available)? onUserAudioAvailable;

  /// The SDK Started Rendering the First Video Frame of the Local or a Remote User
  ///
  /// The SDK returns this event callback when it starts rendering your first
  /// video frame or that of a remote user. The `userId` in the callback can
  /// help you determine whether the frame is yours or a remote user’s.
  /// - If `userId` is empty, it indicates that the SDK has started rendering
  /// your first video frame. The precondition is that you have called
  /// [startLocalPreview] or [startScreenCapture].
  /// - If `userId` is not empty, it indicates that the SDK has started
  /// rendering the first video frame of a remote user. The precondition is
  /// that you have called [startRemoteView] to subscribe to the user’s video.
  ///
  /// - **Parameters:**
  ///   - **height(int)**:
  ///     - Video height.
  ///   - **streamType([TRTCVideoStreamType])**:
  ///     - Video stream type. The primary stream (`Main`) is usually used for
  ///       camera images, and the substream (`Sub`) for screen sharing images.
  ///   - **userId(String)**:
  ///     - The user ID of the local or a remote user. If it is empty, it
  ///       indicates that the first local video frame is available; if it is
  ///       not empty, it indicates that the first video frame of a remote user
  ///       is available.
  ///   - **width(int)**:
  ///     - Video width.
  ///
  /// > **Note**
  /// >
  /// > 1. The callback of the first local video frame being rendered is
  /// > triggered only after you call [startLocalPreview] or
  /// > [startScreenCapture].
  /// >
  /// > 2. The callback of the first video frame of a remote user being
  /// > rendered is triggered only after you call [startRemoteView] or
  /// > startRemoteSubStreamView.
  final void Function(
          String userId, TRTCVideoStreamType streamType, int width, int height)?
      onFirstVideoFrame;

  /// The SDK Started Playing the First Audio Frame of a Remote User
  ///
  /// The SDK returns this callback when it plays the first audio frame of a
  /// remote user. The callback is not returned for the playing of the first
  /// audio frame of the local user.
  ///
  /// - **Parameters:**
  ///   - **userId(String)**:
  ///     - User ID of the remote user.
  final void Function(String userId)? onFirstAudioFrame;

  /// The First Local Video Frame Was Published
  ///
  /// After you enter a room and call [startLocalPreview] or
  /// [startScreenCapture] to enable local video capturing (whichever happens
  /// first), the SDK will start video encoding and publish the local video
  /// data via its network module to the cloud.
  ///
  /// It returns the `onSendFirstLocalVideoFrame` callback after publishing the
  /// first local video frame.
  ///
  /// - **Parameters:**
  ///   - **streamType([TRTCVideoStreamType])**:
  ///     - Video stream type. The primary stream (`Main`) is usually used for
  ///       camera images, and the substream (`Sub`) for screen sharing images.
  final void Function(TRTCVideoStreamType streamType)?
      onSendFirstLocalVideoFrame;

  /// The First Local Audio Frame Was Published
  ///
  /// After you enter a room and call [startLocalAudio] to enable audio
  /// capturing (whichever happens first), the SDK will start audio encoding
  /// and publish the local audio data via its network module to the cloud.
  ///
  /// The SDK returns the `onSendFirstLocalAudioFrame` callback after sending
  /// the first local audio frame.
  final void Function()? onSendFirstLocalAudioFrame;

  /// Change of Remote Video Status
  ///
  /// You can use this callback to get the status (`Playing`, `Loading`, or
  /// `Stopped`) of the video of each remote user and display it on the UI.
  ///
  /// - **Parameters:**
  ///   - **reason([TRTCAVStatusChangeReason])**:
  ///     - Reason for the change of status.
  ///   - **status([TRTCAVStatusType])**:
  ///     - Video status, which may be `Playing`, `Loading`, or `Stopped`.
  ///   - **streamType([TRTCVideoStreamType])**:
  ///     - Video stream type. The primary stream (`Main`) is usually used for
  ///       camera images, and the substream (`Sub`) for screen sharing images.
  ///   - **userId(String)**:
  ///     - User ID.
  final void Function(
      String userId,
      TRTCVideoStreamType streamType,
      TRTCAVStatusType status,
      TRTCAVStatusChangeReason reason)? onRemoteVideoStatusUpdated;

  /// Change of Remote Audio Status
  ///
  /// You can use this callback to get the status (`Playing`, `Loading`, or
  /// `Stopped`) of the audio of each remote user and display it on the UI.
  ///
  /// - **Parameters:**
  ///   - **reason([TRTCAVStatusChangeReason])**:
  ///     - Reason for the change of status.
  ///   - **status([TRTCAVStatusType])**:
  ///     - Audio status, which may be `Playing`, `Loading`, or `Stopped`.
  ///   - **userId(String)**:
  ///     - User ID.
  final void Function(String userId, TRTCAVStatusType status,
      TRTCAVStatusChangeReason reason)? onRemoteAudioStatusUpdated;

  /// Change of Remote Video Size
  ///
  /// If you receive the `onUserVideoSizeChanged(userId, streamType, newWidth, newHeight)`
  /// callback, it indicates that the user changed the video size. It may be triggered
  /// by `setVideoEncoderParam` or `setSubStreamEncoderParam`.
  ///
  /// - **Parameters:**
  ///   - **newHeight(int)**:
  ///     - Video height.
  ///   - **newWidth(int)**:
  ///     - Video width.
  ///   - **streamType([TRTCVideoStreamType])**:
  ///     - Video stream type. The primary stream (`Main`) is usually used for
  ///       camera images, and the substream (`Sub`) for screen sharing images.
  ///   - **userId(String)**:
  ///     - User ID.
  final void Function(String userId, TRTCVideoStreamType streamType,
      int newWidth, int newHeight)? onUserVideoSizeChanged;

  /// Real-time Network Quality Statistics
  ///
  /// This callback is returned every 2 seconds and notifies you of the upstream
  /// and downstream network quality detected by the SDK.
  ///
  /// The SDK uses a built-in proprietary algorithm to assess the current latency,
  /// bandwidth, and stability of the network and returns a result.
  ///
  /// If the result is `1` (excellent), it means that the current network conditions
  /// are excellent; if it is `6` (down), it means that the current network conditions
  /// are too bad to support TRTC calls.
  ///
  /// - **Parameters:**
  ///   - **localQuality([TRTCQualityInfo])**:
  ///     - Upstream network quality.
  ///   - **remoteQuality(List<TRTCQualityInfo>)**:
  ///     - Downstream network quality, which refers to the data quality finally
  ///       measured on the local side after the data flow passes through a complete
  ///       transmission link of "remote -> cloud -> local". Therefore, the downlink
  ///       network quality here represents the joint impact of the remote uplink and
  ///       the local downlink.
  ///
  /// > **Note**
  /// > The uplink quality of remote users cannot be determined independently through
  /// > this interface.
  final void Function(
          TRTCQualityInfo localQuality, List<TRTCQualityInfo> remoteQuality)?
      onNetworkQuality;

  /// Real-time Statistics on Technical Metrics
  ///
  /// This callback is returned every 2 seconds and notifies you of the statistics
  /// on technical metrics related to video, audio, and network. The metrics are
  /// listed in [TRTCStatistics] :
  /// - Video statistics: video resolution (`resolution`), frame rate (`FPS`),
  ///   bitrate (`bitrate`), etc.
  /// - Audio statistics: audio sample rate (`samplerate`), number of audio
  ///   channels (`channel`), bitrate (`bitrate`), etc.
  /// - Network statistics: the round trip time (`rtt`) between the SDK and the
  ///   cloud (SDK -> Cloud -> SDK), packet loss rate (`loss`), upstream traffic
  ///   (`sentBytes`), downstream traffic (`receivedBytes`), etc.
  ///
  /// - **Parameters:**
  ///   - **statistics([TRTCStatistics])**:
  ///     - Statistics, including local statistics and the statistics of remote users.
  ///
  /// > **Note**
  /// > If you want to learn about only the current network quality and do not want
  /// > to spend much time analyzing the statistics returned by this callback, we
  /// > recommend you use [onNetworkQuality].
  final void Function(TRTCStatistics statistics)? onStatistics;

  /// Callback of Network Speed Test
  ///
  /// The callback is triggered by `startSpeedTest`.
  ///
  /// - **Parameters:**
  ///   - **result([TRTCSpeedTestResult])**:
  ///     - Speed test data, including loss rates, RTT, and bandwidth rates.
  final void Function(TRTCSpeedTestResult result)? onSpeedTestResult;

  /// The SDK was disconnected from the cloud
  final void Function()? onConnectionLost;

  /// The SDK is reconnecting to the cloud
  final void Function()? onTryToReconnect;

  /// The SDK is reconnected to the cloud
  final void Function()? onConnectionRecovery;

  /// The camera is ready
  final void Function()? onCameraDidReady;

  /// The mic is ready
  final void Function()? onMicDidReady;

  /// The audio route is changed
  final void Function(TXAudioRoute newRoute, TXAudioRoute oldRoute)?
      onAudioRouteChanged;

  /// Volume
  ///
  /// The SDK can assess the volume of each channel and return this callback on a
  /// regular basis. You can display, for example, a waveform or volume bar on the
  /// UI based on the statistics returned.
  ///
  /// You need to first call [enableAudioVolumeEvaluation] to enable the feature
  /// and set the interval for the callback.
  ///
  /// Note that the SDK returns this callback at the specified interval regardless
  /// of whether someone is speaking in the room.
  ///
  /// - **Parameters:**
  ///   - **totalVolume([int])**:
  ///     - The total volume of all remote users. Value range: 0-100.
  ///   - **userVolumes(List<[TRTCVolumeInfo]>)**:
  ///     - An array that represents the volume of all users who are speaking in the room.
  ///
  /// > **Note**
  /// > `userVolumes` is an array. If `userId` is empty, the elements in the array
  /// > represent the volume of the local user’s audio. Otherwise, they represent
  /// > the volume of a remote user’s audio.
  final void Function(List<TRTCVolumeInfo> userVolumes, int totalVolume)?
      onUserVoiceVolume;

  /// The Capturing Volume of the Mic Changed
  ///
  /// On desktop OS such as macOS and Windows, users can set the capturing volume
  /// of the mic in the audio control panel.
  ///
  /// The higher volume a user sets, the higher the volume of raw audio captured
  /// by the mic.
  ///
  /// On some keyboards and laptops, users can also mute the mic by pressing a
  /// key (whose icon is a crossed-out mic).
  ///
  /// When users set the mic capturing volume via the UI or a keyboard shortcut,
  /// the SDK will return this callback.
  ///
  /// - **Parameters:**
  ///   - **muted(bool)**:
  ///     - Whether the mic is muted. `true`: muted; `false`: unmuted.
  ///   - **volume(int)**:
  ///     - System audio capturing volume, which users can set in the audio control
  ///       panel. Value range: 0-100.
  ///
  /// > **Note**
  /// > You need to call [enableAudioVolumeEvaluation] and set the callback interval
  /// > (`interval` > 0) to enable the callback. To disable the callback, set
  /// > `interval` to `0`.
  final void Function(int volume, bool muted)?
      onAudioDeviceCaptureVolumeChanged;

  /// The Playback Volume Changed
  ///
  /// On desktop OS such as macOS and Windows, users can set the system’s playback
  /// volume in the audio control panel.
  ///
  /// On some keyboards and laptops, users can also mute the speaker by pressing a
  /// key (whose icon is a crossed-out speaker).
  ///
  /// When users set the system’s playback volume via the UI or a keyboard shortcut,
  /// the SDK will return this callback.
  ///
  /// - **Parameters:**
  ///   - **muted(bool)**:
  ///     - Whether the speaker is muted. `true`: muted; `false`: unmuted.
  ///   - **volume(int)**:
  ///     - The system playback volume, which users can set in the audio control
  ///       panel. Value range: 0-100.
  ///
  /// > **Note**
  /// > You need to call [enableAudioVolumeEvaluation] and set the callback interval
  /// > (`interval` > 0) to enable the callback. To disable the callback, set
  /// > `interval` to `0`.
  final void Function(int volume, bool muted)?
      onAudioDevicePlayoutVolumeChanged;

  /// Whether System Audio Capturing is Enabled Successfully (for Desktop OS Only)
  ///
  /// On macOS, you can call [startSystemAudioLoopback] to install an audio driver
  /// and have the SDK capture the audio played back by the system.
  ///
  /// On Windows systems, you can use [startSystemAudioLoopback] to have the SDK
  /// capture the audio played back by the system.
  ///
  /// In use cases such as video teaching and music live streaming, the teacher can
  /// use this feature to let the SDK capture the sound of the video played by his
  /// or her computer, so that students in the room can hear the sound too.
  ///
  /// The SDK returns this callback after trying to enable system audio capturing.
  /// To determine whether it is actually enabled, pay attention to the error
  /// parameter in the callback.
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - If it is `ERR_NULL`, system audio capturing is enabled successfully.
  ///       Otherwise, it is not.
  final void Function(int errCode)? onSystemAudioLoopbackError;

  /// Volume During Mic Test
  ///
  /// When you call [startMicDeviceTest] to test the mic, the SDK will keep
  /// returning this callback. The `volume` parameter represents the volume of
  /// the audio captured by the mic.
  ///
  /// If the value of the `volume` parameter fluctuates, the mic works properly.
  /// If it is `0` throughout the test, it indicates that there is a problem
  /// with the mic, and users should be prompted to switch to a different mic.
  ///
  /// - **Parameters:**
  ///   - **volume(int)**:
  ///     - Captured mic volume. Value range: 0-100.
  final void Function(int volume)? onTestMicVolume;

  /// Volume During Speaker Test
  ///
  /// When you call [startSpeakerDeviceTest] to test the speaker, the SDK will
  /// keep returning this callback.
  ///
  /// The `volume` parameter in the callback represents the volume of audio sent
  /// by the SDK to the speaker for playback. If its value fluctuates but users
  /// cannot hear any sound, the speaker is not working properly.
  ///
  /// - **Parameters:**
  ///   - **volume(int)**:
  ///     - The volume of audio sent by the SDK to the speaker for playback.
  ///       Value range: 0-100.
  final void Function(int volume)? onTestSpeakerVolume;

  /// Receipt of Custom Message
  ///
  /// When a user in a room uses [sendCustomCmdMsg] to send a custom message,
  /// other users in the room can receive the message through the
  /// `onRecvCustomCmdMsg` callback.
  ///
  /// - **Parameters:**
  ///   - **cmdID(int)**:
  ///     - Command ID.
  ///   - **message(String)**:
  ///     - Message data.
  ///   - **seq(int)**:
  ///     - Message serial number.
  ///   - **userId(String)**:
  ///     - User ID.
  final void Function(String userId, int cmdId, int seq, String message)?
      onRecvCustomCmdMsg;

  /// Loss of Custom Message
  ///
  /// When you use [sendCustomCmdMsg] to send a custom UDP message, even if
  /// you enable reliable transfer (by setting `reliable` to `true`), there is
  /// still a chance of message loss. Reliable transfer only helps maintain a
  /// low probability of message loss, which meets the reliability requirements
  /// in most cases.
  ///
  /// If the sender sets `reliable` to `true`, the SDK will use this callback
  /// to notify the recipient of the number of custom messages lost during a
  /// specified time period (usually 5s) in the past.
  ///
  /// - **Parameters:**
  ///   - **cmdID(int)**:
  ///     - Command ID.
  ///   - **errCode(int)**:
  ///     - Error code.
  ///   - **missed(int)**:
  ///     - Number of lost messages.
  ///   - **userId(String)**:
  ///     - User ID.
  ///
  /// > **Note**
  /// > The recipient receives this callback only if the sender sets `reliable` to `true`.
  final void Function(String userId, int cmdId, int errCode, int missed)?
      onMissCustomCmdMsg;

  /// Receipt of SEI Message
  ///
  /// If a user in the room uses [sendSEIMsg] to send an SEI message via video
  /// frames, other users in the room can receive the message through the
  /// `onRecvSEIMsg` callback.
  ///
  /// - **Parameters:**
  ///   - **message(String)**:
  ///     - Data.
  ///   - **userId(String)**:
  ///     - User ID.
  final void Function(String userId, String message)? onRecvSEIMsg;

  /// Callback for Starting to Publish
  ///
  /// When you call `startPublishMediaStream` to publish a stream to the
  /// TRTC backend, the SDK will immediately update the command to the
  /// cloud server.
  ///
  /// The SDK will then receive the publishing result from the cloud server
  /// and will send the result to you via this callback.
  ///
  /// - **Parameters:**
  ///   - **code(int)**:
  ///     - `0`: Successful; other values: Failed.
  ///   - **extraInfo(String)**:
  ///     - Additional information. For some error codes, there may be
  ///       additional information to help you troubleshoot the issues.
  ///   - **message(String)**:
  ///     - The callback information.
  ///   - **taskId(String)**:
  ///     - If a request is successful, a task ID will be returned via the
  ///       callback. You need to provide this task ID when you call
  ///       `updatePublishMediaStream` to modify publishing parameters or
  ///       `stopPublishMediaStream` to stop publishing.
  final void Function(
          String taskId, int errCode, String errMsg, String extraInfo)?
      onStartPublishMediaStream;

  /// Callback for Modifying Publishing Parameters
  ///
  /// When you call `updatePublishMediaStream` to modify publishing
  /// parameters, the SDK will immediately update the command to the
  /// cloud server.
  ///
  /// The SDK will then receive the modification result from the cloud
  /// server and will send the result to you via this callback.
  ///
  /// - **Parameters:**
  ///   - **code(int)**:
  ///     - `0`: Successful; other values: Failed.
  ///   - **extraInfo(String)**:
  ///     - Additional information. For some error codes, there may be
  ///       additional information to help you troubleshoot the issues.
  ///   - **message(String)**:
  ///     - The callback information.
  ///   - **taskId(String)**:
  ///     - The task ID you pass in when calling `updatePublishMediaStream`,
  ///       which is used to identify a request.
  final void Function(
          String taskId, int errCode, String errMsg, String extraInfo)?
      onUpdatePublishMediaStream;

  /// Callback for Stopping Publishing
  ///
  /// When you call `stopPublishMediaStream` to stop publishing, the SDK
  /// will immediately update the command to the cloud server.
  ///
  /// The SDK will then receive the modification result from the cloud
  /// server and will send the result to you via this callback.
  ///
  /// - **Parameters:**
  ///   - **code(int)**:
  ///     - `0`: Successful; other values: Failed.
  ///   - **extraInfo(String)**:
  ///     - Additional information. For some error codes, there may be
  ///       additional information to help you troubleshoot the issues.
  ///   - **message(String)**:
  ///     - The callback information.
  ///   - **taskId(String)**:
  ///     - The task ID you pass in when calling `stopPublishMediaStream`,
  ///       which is used to identify a request.
  final void Function(
          String taskId, int errCode, String errMsg, String extraInfo)?
      onStopPublishMediaStream;

  /// Callback for Change of RTMP/RTMPS Publishing Status
  ///
  /// When you call `startPublishMediaStream` to publish a stream to the
  /// TRTC backend, the SDK will immediately update the command to the
  /// cloud server.
  ///
  /// If you set the publishing destination ([TRTCPublishTarget]) to the
  /// URL of Tencent Cloud or a third-party CDN, you will be notified of
  /// the RTMP/RTMPS publishing status via this callback.
  ///
  /// - **Parameters:**
  ///   - **cdnUrl(String)**:
  ///     - The URL you specify in [TRTCPublishTarget] when you call
  ///       `startPublishMediaStream`.
  ///   - **code(int)**:
  ///     - The publishing result. `0`: Successful; other values: Failed.
  ///   - **extraInfo(String)**:
  ///     - Additional information. For some error codes, there may be
  ///       additional information to help you troubleshoot the issues.
  ///   - **message(String)**:
  ///     - The publishing information.
  ///   - **status(int)**:
  ///     - The publishing status:
  ///       - `0`: The publishing has not started yet or has ended. This
  ///         value will be returned after you call `stopPublishMediaStream`.
  ///       - `1`: The TRTC server is connecting to the CDN server. If the
  ///         first attempt fails, the TRTC backend will retry multiple
  ///         times and will return this value via the callback (every five
  ///         seconds). After publishing succeeds, the value `2` will be
  ///         returned. If a server error occurs or publishing is still
  ///         unsuccessful after 60 seconds, the value `4` will be returned.
  ///       - `2`: The TRTC server is publishing to the CDN. This value
  ///         will be returned if the publishing succeeds.
  ///       - `3`: The TRTC server is disconnected from the CDN server and
  ///         is reconnecting. If a CDN error occurs or publishing is
  ///         interrupted, the TRTC backend will try to reconnect and resume
  ///         publishing and will return this value via the callback (every
  ///         five seconds). After publishing resumes, the value `2` will
  ///         be returned. If a server error occurs or the attempt to resume
  ///         publishing is still unsuccessful after 60 seconds, the value
  ///         `4` will be returned.
  ///       - `4`: The TRTC server is disconnected from the CDN server and
  ///         failed to reconnect within the timeout period. In this case,
  ///         the publishing is deemed to have failed. You can call
  ///         `updatePublishMediaStream` to try again.
  ///       - `5`: The TRTC server is disconnecting from the CDN server.
  ///         After you call `stopPublishMediaStream`, the SDK will return
  ///         this value first and then the value `0`.
  final void Function(String cdnUrl, int status, int errCode, String errMsg,
      String extraInfo)? onCdnStreamStateChanged;

  /// Screen sharing started
  final void Function()? onScreenCaptureStarted;

  /// Screen Sharing Was Paused
  ///
  /// The SDK returns this callback when you call `pauseScreenCapture`
  /// to pause screen sharing.
  ///
  /// - **Parameters:**
  ///   - **reason(int)**:
  ///     - Reason for the pause:
  ///       - `0`: The user paused screen sharing.
  ///       - `1`: Screen sharing was paused because the shared window
  ///         became invisible (Mac) or due to setting parameters (Windows).
  ///       - `2`: Screen sharing was paused because the shared window
  ///         became minimized (only for Windows).
  ///       - `3`: Screen sharing was paused because the shared window
  ///         became invisible (only for Windows).
  final void Function(int reason)? onScreenCapturePaused;

  /// Screen Sharing Was Resumed
  ///
  /// The SDK returns this callback when you call `resumeScreenCapture`
  /// to resume screen sharing.
  ///
  /// - **Parameters:**
  ///   - **reason(int)**:
  ///     - Reason for the resume:
  ///       - `0`: The user resumed screen sharing.
  ///       - `1`: Screen sharing was resumed automatically after the
  ///         shared window became visible again (Mac) or after setting
  ///         parameters (Windows).
  ///       - `2`: Screen sharing was resumed automatically after the
  ///         shared window became minimized and then recovered (only for
  ///         Windows).
  ///       - `3`: Screen sharing was resumed automatically after the
  ///         shared window became visible again (only for Windows).
  final void Function(int reason)? onScreenCaptureResumed;

  /// Screen Sharing Stopped
  ///
  /// The SDK returns this callback when you call `stopScreenCapture`
  /// to stop screen sharing.
  ///
  /// - **Parameters:**
  ///   - **reason(int)**:
  ///     - Reason for stopping:
  ///       - `0`: The user stopped screen sharing.
  ///       - `1`: Screen sharing stopped because the shared window was closed.
  final void Function(int reason)? onScreenCaptureStopped;

  /// The Shared Window Was Covered (for Windows only)
  ///
  /// The SDK returns this callback when the shared window is covered
  /// and cannot be captured. Upon receiving this callback, you can
  /// prompt users via the UI to move and expose the window.
  final void Function()? onScreenCaptureCovered;

  /// Local Recording Started
  ///
  /// When you call `startLocalRecording` to start local recording,
  /// the SDK returns this callback to notify you whether recording
  /// has started successfully.
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Status of the recording:
  ///       - `0`: Successful.
  ///       - `-1`: Failed.
  ///       - `-2`: Unsupported format.
  ///       - `-6`: Recording has been started. Stop recording first.
  ///       - `-7`: Recording file already exists and needs to be deleted.
  ///       - `-8`: Recording directory does not have write permission.
  ///         Please check the directory permission.
  ///   - **storagePath(String)**:
  ///     - Storage path of the recording file.
  final void Function(int errCode, String storagePath)? onLocalRecordBegin;

  /// Local Media is Being Recorded
  ///
  /// The SDK returns this callback regularly after local recording
  /// has started successfully via the calling of `startLocalRecording`.
  ///
  /// You can capture this callback to stay up to date with the status
  /// of the recording task.
  ///
  /// You can set the callback interval when calling `startLocalRecording`.
  ///
  /// - **Parameters:**
  ///   - **duration(int)**:
  ///     - Cumulative duration of recording, in milliseconds.
  ///   - **storagePath(String)**:
  ///     - Storage path of the recording file.
  final void Function(int duration, String storagePath)? onLocalRecording;

  /// Record Fragment Finished
  ///
  /// When fragment recording is enabled, this callback will be invoked
  /// when each fragment file is finished.
  ///
  /// - **Parameters:**
  ///   - **storagePath(String)**:
  ///     - Storage path of the fragment.
  final void Function(String storagePath)? onLocalRecordFragment;

  /// Local Recording Stopped
  ///
  /// When you call `stopLocalRecording` to stop local recording,
  /// the SDK returns this callback to notify you of the recording result.
  ///
  /// - **Parameters:**
  ///   - **errCode(int)**:
  ///     - Status of the recording:
  ///       - `0`: Successful.
  ///       - `-1`: Failed.
  ///       - `-2`: Switching resolution or horizontal and vertical screen
  ///         causes the recording to stop.
  ///       - `-3`: Recording duration is too short or no video or audio
  ///         data is received. Check the recording duration or whether
  ///         audio or video capture is enabled.
  ///   - **storagePath(String)**:
  ///     - Storage path of the recording file.
  final void Function(int errCode, String storagePath)? onLocalRecordComplete;

  /// Finished Taking a Local Screenshot
  final void Function(String userId, String path, int errCode, String errMsg)?
      onSnapshotComplete;

  TRTCCloudListener({
    this.onError,
    this.onWarning,
    this.onEnterRoom,
    this.onExitRoom,
    this.onSwitchRole,
    this.onSwitchRoom,
    this.onConnectOtherRoom,
    this.onDisconnectOtherRoom,
    this.onRemoteUserEnterRoom,
    this.onRemoteUserLeaveRoom,
    this.onUserVideoAvailable,
    this.onUserSubStreamAvailable,
    this.onUserAudioAvailable,
    this.onFirstVideoFrame,
    this.onFirstAudioFrame,
    this.onSendFirstLocalVideoFrame,
    this.onSendFirstLocalAudioFrame,
    this.onRemoteVideoStatusUpdated,
    this.onRemoteAudioStatusUpdated,
    this.onUserVideoSizeChanged,
    this.onNetworkQuality,
    this.onStatistics,
    this.onSpeedTestResult,
    this.onConnectionLost,
    this.onTryToReconnect,
    this.onConnectionRecovery,
    this.onCameraDidReady,
    this.onMicDidReady,
    this.onAudioRouteChanged,
    this.onUserVoiceVolume,
    this.onAudioDeviceCaptureVolumeChanged,
    this.onAudioDevicePlayoutVolumeChanged,
    this.onSystemAudioLoopbackError,
    this.onTestMicVolume,
    this.onTestSpeakerVolume,
    this.onRecvCustomCmdMsg,
    this.onMissCustomCmdMsg,
    this.onRecvSEIMsg,
    this.onStartPublishMediaStream,
    this.onUpdatePublishMediaStream,
    this.onStopPublishMediaStream,
    this.onCdnStreamStateChanged,
    this.onScreenCaptureStarted,
    this.onScreenCapturePaused,
    this.onScreenCaptureResumed,
    this.onScreenCaptureStopped,
    this.onScreenCaptureCovered,
    this.onLocalRecordBegin,
    this.onLocalRecording,
    this.onLocalRecordFragment,
    this.onLocalRecordComplete,
    this.onSnapshotComplete,
  });
}

/// @nodoc
class TRTCVideoFrameCallback {
  final void Function() onGLContextCreated;

  final void Function(TRTCVideoFrame srcFrame, TRTCVideoFrame dstFrame)
      onProcessVideoFrame;

  final void Function() onGLContextDestroy;

  TRTCVideoFrameCallback({
    required this.onGLContextCreated,
    required this.onProcessVideoFrame,
    required this.onGLContextDestroy,
  });
}

/// @nodoc
class TRTCVideoRenderCallback {
  final void Function(
          String userId, TRTCVideoStreamType streamType, TRTCVideoFrame frame)
      onRenderVideoFrame;

  TRTCVideoRenderCallback({
    required this.onRenderVideoFrame,
  });
}

/// @nodoc
class TRTCAudioFrameCallback {
  final void Function(TRTCAudioFrame frame) onCapturedAudioFrame;

  final void Function(TRTCAudioFrame frame) onLocalProcessedAudioFrame;

  final void Function(TRTCAudioFrame frame, String userId) onPlayAudioFrame;

  final void Function(TRTCAudioFrame frame) onMixedPlayAudioFrame;

  final void Function(TRTCAudioFrame frame) onMixedAllAudioFrame;

  TRTCAudioFrameCallback({
    required this.onCapturedAudioFrame,
    required this.onLocalProcessedAudioFrame,
    required this.onPlayAudioFrame,
    required this.onMixedPlayAudioFrame,
    required this.onMixedAllAudioFrame,
  });
}

class TRTCLogCallback {
  /// Printing of Local Log
  ///
  /// If you want to capture the local log printing event, you can configure
  /// the log callback to have the SDK return to you via this callback all
  /// logs that are to be printed.
  ///
  /// - **Parameters:**
  ///   - **level([TRTCLogLevel])**:
  ///     - Log level.
  ///   - **log(String)**:
  ///     - Log content.
  ///   - **module(String)**:
  ///     - Reserved field, which is not defined at the moment and has a
  ///       fixed value of `TXLiteAVSDK`.
  final void Function(String log, TRTCLogLevel level, String module) onLog;

  TRTCLogCallback({
    required this.onLog,
  });
}
