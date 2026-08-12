// ignore_for_file: unintended_html_in_doc_comment
// ignore_for_file: comment_references
import 'package:tencent_rtc_sdk/ai_transcriber_manager.dart';
import 'package:tencent_rtc_sdk/impl/trtc/trtc_cloud_impl.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
import 'package:tencent_rtc_sdk/tx_device_manager.dart';
import 'package:tencent_rtc_sdk/tx_audio_effect_manager.dart';

/// The main API class of TRTC video call function
abstract class TRTCCloud {
  /// Create TRTCCloud instance (singleton mode)
  static Future<TRTCCloud> sharedInstance() async {
    return TRTCCloudImpl.sharedInstance();
  }

  /// Terminate TRTCCloud instance (singleton mode)
  static void destroySharedInstance() {
    TRTCCloudImpl.destroySharedInstance();
  }

  /// Add TRTC event callback
  ///
  /// You can use [TRTCCloudListener] to get various event notifications from the SDK, such as error codes, warning codes, and audio/video status parameters.
  void registerListener(TRTCCloudListener func);

  /// Remove TRTC event callback
  void unRegisterListener(TRTCCloudListener func);

  /// Enter an audio or video call room (hereinafter referred to as "enter room").
  ///
  /// All TRTC users need to enter a room before they can "publish" or "subscribe to" audio/video streams.
  /// "Publishing" refers to pushing their own streams to the cloud, and "subscribing to" refers to pulling the streams of other users in the room from the cloud.
  ///
  /// After calling this API, you will receive the [TRTCCloudListener.onEnterRoom] :
  ///
  /// If successfully entered the room, `result` is a positive number (`result` > 0), indicating the time taken to enter the room (in milliseconds).
  ///
  /// If entering the room fails, `result` is a negative number (`result` < 0), indicating the error code for the failure to enter the room.
  ///
  /// **Parameters:**
  /// - **param([TRTCParams])**:
  ///   - Room entry parameter, which is used to specify the user's identity, role, authentication credentials, and other information.
  ///
  /// - **scene([TRTCAppScene])**:
  ///   - Application scenario, which is used to specify the use case. The same [TRTCAppScene] should be configured for all users in the same room.
  ///
  /// Note:
  ///
  /// 1. If the `scene` is selected as [TRTCAppScene.live] or [TRTCAppScene.voiceChatRoom] ,
  /// the `role` field in `TRTCParams` must be used to specify the role of the current user.
  ///
  /// 2. Regardless of whether entering the room is successful, [enterRoom] must be paired with [exitRoom].
  /// Calling [enterRoom] again before calling [exitRoom] will result in unexpected errors.
  void enterRoom(TRTCParams param, TRTCAppScene scene);

  /// Exit room
  ///
  /// Calling this API will allow the user to leave the current audio or video room
  /// and release the camera, mic, speaker, and other device resources.
  ///
  /// After resources are released, the SDK will use the [TRTCCloudListener.onExitRoom] callback to notify you.
  ///
  /// If you need to call [enterRoom] again or switch to the SDK of another provider,
  /// it is recommended to wait until you receive the [TRTCCloudListener.onExitRoom] callback to
  /// avoid issues with the camera or mic being occupied.
  void exitRoom();

  /// Switch role
  ///
  /// This API is used to switch the user role between `anchor` and `audience`.
  ///
  /// As video live rooms and audio chat rooms need to support an audience of up to
  /// 100,000 concurrent online users, the rule "only anchors can publish their
  /// audio/video streams" has been set. Therefore, when some users want to publish
  /// their streams (so that they can interact with anchors), they need to switch
  /// their role to "anchor" first.
  ///
  /// You can use the `role` field in [TRTCParams] during room entry to specify
  /// the user role in advance or use the `switchRole` API to switch roles after
  /// room entry.
  ///
  /// **Parameters:**
  /// - **role([TRTCRoleType])**: Role, which is `anchor` by default.
  ///   - **[TRTCRoleType.anchor]**:
  ///     - Can publish audio/video streams.
  ///     - Up to 50 anchors can publish at the same time.
  ///   - **[TRTCRoleType.audience]**:
  ///     - Cannot publish streams, can only watch.
  ///     - Needs to switch to "anchor" role to publish.
  ///     - Supports up to 100,000 concurrent audience.
  ///
  /// **Note**
  /// 1. This API is only applicable to two scenarios: live streaming
  ///    ([TRTCAppScene.live]) and audio chat room ([TRTCAppScene.voiceChatRoom]).
  /// 2. If the `scene` you specify in [enterRoom] is [TRTCAppScene.videoCall]
  ///    or [TRTCAppScene.audioCall], please do not call this API.
  void switchRole(TRTCRoleType role);

  /// Switch room
  ///
  /// This API is used to quickly switch a user from one room to another.
  /// - If the user's role is `audience`, calling this API is equivalent to `exitRoom` (current room) + `enterRoom` (new room).
  /// - If the user's role is `anchor`, the API will retain the current audio/video publishing status while switching the room;
  /// therefore, during the room switch, camera preview and sound capturing will not be interrupted.
  ///
  /// This API is suitable for the online education scenario where the supervising teacher can perform fast room switch across multiple rooms.
  /// In this scenario, using `switchRoom` can get better smoothness and use less code than `exitRoom + enterRoom`.
  ///
  /// The API call result will be called back through [TRTCCloudListener.onSwitchRoom] .
  ///
  /// **Parameters:**
  /// - **config ([TRTCSwitchRoomConfig])**: Room parameter.
  ///
  /// > **Note**
  /// >
  /// > Due to the requirement for compatibility with legacy versions of the SDK, the `config` parameter contains both `roomId` and `strRoomId` parameters.
  /// You should pay special attention as detailed below when specifying these two parameters:
  /// >
  /// > 1. If you decide to use `strRoomId`, then set `roomId` to 0. If both are specified, `roomId` will be used.
  /// > 2. All rooms need to use either `strRoomId` or `roomId` at the same time. They cannot be mixed; otherwise, there will be many unexpected bugs.
  void switchRoom(TRTCSwitchRoomConfig config);

  /// Request cross-room call
  ///
  /// In TRTC, two anchors in different rooms can use the "cross-room call" feature to co-anchor across the rooms.
  /// They can engage in "co-anchoring competition" without the need to exit their own rooms.
  ///
  /// For example, when anchor A in room "001" uses [connectOtherRoom] to successfully call anchor B in room "002",
  /// all users in room "001" will receive the `onRemoteUserEnterRoom(B)` and `onUserVideoAvailable(B,true)` callbacks of anchor B,
  /// and all users in room "002" will receive the `onRemoteUserEnterRoom(A)` and `onUserVideoAvailable(A,true)` callbacks of anchor A.
  ///
  /// In short, cross-room call is to share between two anchors in different rooms, so that users in either room can see both of them.
  ///
  /// For the sake of compatibility of subsequent extended fields for cross-room call, parameters in JSON format are used currently and must contain at least two fields:
  ///
  /// * `roomId`: if anchor A in room "001" wants to co-anchor with anchor B in room "002", the `roomId` must be set to `002` when anchor A calls [connectOtherRoom] .
  ///
  /// * `userId`: if anchor A in room "001" wants to co-anchor with anchor B in room "002", the `userId` must be set to the `userId` of anchor B when anchor A calls [connectOtherRoom] .
  ///
  /// The result of requesting cross-room call will be returned through the [TRTCCloudListener.onConnectOtherRoom] callback.
  ///
  /// Sample call:
  /// ```
  /// var object = new Map();
  ///
  /// object['roomId'] = 155;
  ///
  /// object['userId'] = '57890';
  /// ```
  ///
  /// **Parameters:**
  /// - **param (String)**: You need to pass in a string parameter in JSON format:
  ///   - **roomId (int)**: Represents the room ID in numeric format.
  ///   - **strRoomId (String)**: Represents the room ID in string format.
  ///   - **userId (String)**: Represents the user ID of the target anchor.
  void connectOtherRoom(String param);

  /// Exit cross-room call
  ///
  /// The result will be returned through the [TRTCCloudListener.onDisconnectOtherRoom] .
  void disconnectOtherRoom();

  /// Set Subscription Mode (which must be set before room entry for it to take effect)
  ///
  /// You can switch between the "automatic subscription" and "manual subscription" modes through this API:
  /// - **Automatic subscription**: This is the default mode, where the user will immediately receive the audio/video streams in the room after room entry,
  /// so that the audio will be automatically played back, and the video will be automatically decoded
  /// (you still need to bind the rendering control through the [startRemoteView] API).
  ///
  /// - **Manual subscription**: After room entry, the user needs to manually call the [startRemoteView] API to start subscribing to
  /// and decoding the video stream and call the [muteRemoteAudio] (false) API to start playing back the audio stream.
  ///
  /// In most scenarios, users will subscribe to the audio/video streams of all anchors in the room after room entry.
  /// Therefore, TRTC adopts the automatic subscription mode by default in order to achieve the best "instant streaming experience".
  ///
  /// In your application scenario, if there are many audio/video streams being published at the same time in each room,
  /// and each user only wants to subscribe to 1–2 streams of them, we recommend you use the "manual subscription" mode to reduce the traffic costs.
  ///
  /// **Parameters:**
  /// - **autoRecvAudio (bool)**:
  ///   - `true`: Automatic subscription to audio.
  ///   - `false`: Manual subscription to audio by calling [muteRemoteAudio] (false) .
  ///   - **Default value**: `true`.
  ///
  /// - **autoRecvVideo (bool)**:
  ///   - `true`: Automatic subscription to video.
  ///   - `false`: Manual subscription to video by calling `startRemoteView`.
  ///   - **Default value**: `true`.
  ///
  /// > **Note**
  /// >
  /// > 1. The configuration takes effect only if this API is called before room entry (`enterRoom`).
  /// > 2. In the automatic subscription mode, if the user does not call [startRemoteView] to subscribe to the video stream after room entry,
  /// the SDK will automatically stop subscribing to the video stream in order to reduce traffic consumption.
  void setDefaultStreamRecvMode(bool autoRecvAudio, bool autoRecvVideo);

  /// Publish a stream
  ///
  /// After this API is called, the TRTC server will relay the stream of the local user to a CDN (after transcoding or without transcoding),
  /// or transcode and publish the stream to a TRTC room.
  ///
  /// You can use the [TRTCPublishMode] parameter in [TRTCPublishTarget] to specify the publishing mode.
  ///
  /// **Parameters:**
  /// - **config([TRTCStreamMixingConfig])**:
  ///   - The On-Cloud MixTranscoding settings. This parameter is invalid in the relay-to-CDN mode.
  ///   It is required if you transcode and publish the stream to a CDN or to a TRTC room.
  ///
  /// - **params([TRTCStreamEncoderParam])**:
  ///   - The encoding settings. This parameter is required if you transcode and publish the stream to a CDN or to a TRTC room.
  ///   If you relay to a CDN without transcoding, to improve the relaying stability and playback compatibility, we also recommend you set this parameter.
  ///
  /// - **target([TRTCPublishTarget])**:
  ///   - The publishing destination. You can relay the stream to a CDN (after transcoding or without transcoding) or transcode and publish the stream to a TRTC room.
  ///
  /// > **Note**
  /// >
  /// > 1. The SDK will send a task ID to you via the [TRTCCloudListener.onStartPublishMediaStream] callback.
  /// >
  /// > 2. You can start a publishing task only once and cannot initiate two tasks that use the same publishing mode and publishing CDN URL.
  /// Note the task ID returned, which you need to pass to [updatePublishMediaStream] to modify the publishing parameters or [stopPublishMediaStream] to stop the task.
  /// >
  /// > 3. You can specify up to 10 CDN URLs in `target`. You will be charged only once for transcoding even if you relay to multiple CDNs.
  /// >
  /// > 4. To avoid causing errors, do not specify the same URLs for different publishing tasks executed at the same time.
  /// We recommend you add "sdkappid_roomid_userid_main" to URLs to distinguish them from one another and avoid application conflicts.
  void startPublishMediaStream(TRTCPublishTarget target,
      TRTCStreamEncoderParam param, TRTCStreamMixingConfig config);

  /// Modify publishing parameters
  ///
  /// You can use this API to change the parameters of a publishing task initiated by [startPublishMediaStream].
  ///
  /// **Parameters:**
  /// - **config([TRTCStreamMixingConfig])**:
  ///   - The On-Cloud MixTranscoding settings. This parameter is invalid in the relay-to-CDN mode.
  ///   It is required if you transcode and publish the stream to a CDN or to a TRTC room.
  ///
  /// - **params([TRTCStreamEncoderParam])**:
  ///   - The encoding settings. This parameter is required if you transcode and publish the stream to a CDN or to a TRTC room.
  ///   If you relay to a CDN without transcoding, to improve the relaying stability and playback compatibility, we recommend you set this parameter.
  ///
  /// - **target([TRTCPublishTarget])**:
  ///   - The publishing destination. You can relay the stream to a CDN (after transcoding or without transcoding) or transcode and publish the stream to a TRTC room.
  ///
  /// - **taskId(String)**:
  ///   - The task ID returned to you via the [TRTCCloudListener.onStartPublishMediaStream] callback.
  ///
  /// > **Note**
  /// >
  /// > 1. You can use this API to add or remove CDN URLs to publish to (you can publish to up to 10 CDNs at a time).
  /// To avoid causing errors, do not specify the same URLs for different tasks executed at the same time.
  /// >
  /// > 2. You can use this API to switch a relaying task to transcoding or vice versa.
  /// For example, in cross-room communication, you can first call [startPublishMediaStream] to relay to a CDN.
  /// When the anchor requests cross-room communication, call this API, passing in the task ID to switch the relaying task to a transcoding task.
  /// This can ensure that the live stream and CDN playback are not interrupted (you need to keep the encoding parameters consistent).
  /// >
  /// > 3. You can not switch output between "only audio" 、 "only video" and "audio and video" for the same task.
  void updatePublishMediaStream(String taskId, TRTCPublishTarget target,
      TRTCStreamEncoderParam param, TRTCStreamMixingConfig config);

  /// Stop publishing
  ///
  /// You can use this API to stop a task initiated by [startPublishMediaStream].
  ///
  /// **Parameters:**
  /// - **taskId(String)**:
  ///   - The task ID returned to you via the [TRTCCloudListener.onStartPublishMediaStream] callback.
  ///
  /// > **Note**
  /// >
  /// > 1. If the task ID is not saved to your backend, you can call [startPublishMediaStream] again when an anchor re-enters the room after abnormal exit.
  /// The publishing will fail, but the TRTC backend will return the task ID to you.
  /// >
  /// > 2. If `taskId` is left empty, the TRTC backend will end all tasks you started through [startPublishMediaStream].
  /// You can leave it empty if you have started only one task or want to stop all publishing tasks started by you.
  void stopPublishMediaStream(String taskId);

  /// Enable the preview image of local camera
  ///
  /// If this API is called before [enterRoom] , the SDK will only enable the camera and wait until [enterRoom] is called before starting push.
  ///
  /// If it is called after [enterRoom] , the SDK will enable the camera and automatically start pushing the video stream.
  ///
  /// When the first camera video frame starts to be rendered, you will receive the [TRTCCloudListener.onCameraDidReady] callback.
  ///
  /// **Parameters:**
  /// - **frontCamera(bool)**:
  ///   - true: front camera; false: rear camera.
  ///   - Only works on mobile devices.
  /// - **view(int)**:
  ///   - Control that carries the video image.
  ///
  /// > **Note**
  /// >
  /// > If you want to preview the camera image and adjust the beauty filter parameters through `BeautyManager` before going live, you can:
  /// >
  /// > - Scheme 1: Call [startLocalPreview] before calling [enterRoom].
  /// > - Scheme 2: Call [startLocalPreview] and [muteLocalVideo] (true) after calling [enterRoom].
  void startLocalPreview(bool frontCamera, int? viewId);

  /// Update the preview image of local camera
  void updateLocalView(int? viewId);

  /// Stop camera preview
  void stopLocalPreview();

  /// Pause/Resume publishing local video stream
  ///
  /// This API can pause (or resume) publishing the local video image.
  /// After the pause, other users in the same room will not be able to see the local image.
  ///
  /// This API is equivalent to the two APIs of `startLocalPreview/stopLocalPreview` when TRTCVideoStreamTypeBig is specified, but has higher performance and response speed.
  ///
  /// The `startLocalPreview/stopLocalPreview` APIs need to enable/disable the camera,
  /// which are hardware device-related operations, so they are very time-consuming.
  ///
  /// In contrast, `muteLocalVideo` only needs to pause or allow the data stream at the software level,
  /// so it is more efficient and more suitable for scenarios where frequent enabling/disabling are needed.
  ///
  /// After local video publishing is paused, other members in the same room will receive the `onUserVideoAvailable(userId, false)` callback notification.
  ///
  /// After local video publishing is resumed, other members in the same room will receive the `onUserVideoAvailable(userId, true)` callback notification.
  ///
  /// **Parameters:**
  /// - **mute(bool)**:
  ///   - true: pause; false: resume.
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Specify for which video stream to pause (or resume). Only [TRTCVideoStreamType.big] and [TRTCVideoStreamType.sub] are supported.
  void muteLocalVideo(TRTCVideoStreamType streamType, bool mute);

  /// Subscribe to remote user's video stream and bind video rendering control
  ///
  /// Calling this API allows the SDK to pull the video stream of the specified `userId`
  /// and render it to the rendering control specified by the `view` parameter.
  /// You can set the display mode of the video image through [setRemoteRenderParams].
  ///
  /// - If you already know the `userId` of a user who has a video stream in the room,
  ///   you can directly call [startRemoteView] to subscribe to the user's video image.
  ///
  /// - If you don't know which users in the room are publishing video streams,
  ///   you can wait for the notification from [TRTCCloudListener.onUserVideoAvailable] after [enterRoom].
  ///
  /// Calling this API only starts pulling the video stream, and the image needs to be loaded
  /// and buffered at this time. After the buffering is completed, you will receive a notification
  /// from [TRTCCloudListener.onFirstVideoFrame].
  ///
  /// **Parameters:**
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Video stream type of the `userId` specified for watching:
  ///     - HD big image: [TRTCVideoStreamType.big]
  ///     - Smooth small image: [TRTCVideoStreamType.small] (the remote user should enable dual-channel encoding
  ///       through [enableSmallVideoStream] for this parameter to take effect)
  ///     - Substream image (usually used for screen sharing): [TRTCVideoStreamType.sub]
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  /// - **viewId(int)**:
  ///   - Rendering control that carries the video image.
  ///
  /// > **Note**
  /// >
  /// > The following requires your attention:
  /// >
  /// > 1. The SDK supports watching the big image and substream image or small image and substream image
  /// >    of a `userId` at the same time, but does not support watching the big image and small image
  /// >    at the same time.
  /// >
  /// > 2. Only when the specified `userId` enables dual-channel encoding through [enableSmallVideoStream]
  /// >    can the user's small image be viewed.
  /// >
  /// > 3. If the small image of the specified `userId` does not exist, the SDK will switch to the big
  /// >    image of the user by default.
  void startRemoteView(
      String userId, TRTCVideoStreamType streamType, int? viewId);

  /// Update remote user's video rendering control
  ///
  /// This API can be used to update the rendering control of the remote video image.
  /// It is often used in interactive scenarios where the display area needs to be switched.
  ///
  /// **Parameters:**
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Type of the stream for which to set the preview window (only [TRTCVideoStreamType.big]
  ///     and [TRTCVideoStreamType.sub] are supported).
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  /// - **viewId(int)**:
  ///   - Control that carries the video image.
  void updateRemoteView(
      String userId, TRTCVideoStreamType streamType, int? viewId);

  /// Stop subscribing to remote user's video stream and release rendering control
  ///
  /// Calling this API will cause the SDK to stop receiving the user's video stream
  /// and release the decoding and rendering resources for the stream.
  ///
  /// **Parameters:**
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Video stream type of the `userId` specified for watching:
  ///     - HD big image: [TRTCVideoStreamType.big]
  ///     - Smooth small image: [TRTCVideoStreamType.small]
  ///     - Substream image (usually used for screen sharing): [TRTCVideoStreamType.sub]
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  void stopRemoteView(String userId, TRTCVideoStreamType streamType);

  /// Stop subscribing to all remote users' video streams and release all rendering resources
  ///
  /// Calling this API will cause the SDK to stop receiving all remote video streams
  /// and release all decoding and rendering resources.
  ///
  /// > **Note**
  /// >
  /// > If a substream image (screen sharing) is being displayed, it will also be stopped.
  void stopAllRemoteView();

  /// Set the image to be displayed when the video stream is paused
  ///
  /// When the local video stream is paused (e.g., via [muteLocalVideo]), the SDK will display
  /// the specified image instead of the last video frame.
  ///
  /// **Parameters:**
  /// - **imagePath(String)**:
  ///   - Path to the image file. Supported formats: JPG, PNG.
  ///   - Example paths:
  ///     - Android: `/storage/emulated/0/Android/data/com.tencent.rtc.flutter.example/files/image.jpg`
  ///     - iOS: `/Library/Caches/image.jpg`
  /// - **fps(int)**:
  ///   - Frame rate of the image display (in frames per second).
  ///
  /// **Note:**
  /// - This API is currently not supported on macOS and Windows.
  void setVideoMuteImage(String imagePath, int fps);

  /// Set watermark
  ///
  /// This API adds a watermark to the local video stream. The watermark will be displayed
  /// in the top-left corner of the video by default, but you can adjust its position and size.
  ///
  /// **Parameters:**
  /// - **imagePath(String)**:
  ///   - Path to the watermark image file. Supported formats: JPG, PNG.
  ///   - Example paths:
  ///     - Android: `/storage/emulated/0/Android/data/com.tencent.rtc.flutter.example/files/watermark.png`
  ///     - iOS: `/Library/Caches/watermark.png`
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Video stream type to which the watermark is added ([TRTCVideoStreamType.big] or [TRTCVideoStreamType.sub]).
  /// - **x(double)**:
  ///   - X coordinate of the watermark's top-left corner (normalized to 0.0–1.0).
  /// - **y(double)**:
  ///   - Y coordinate of the watermark's top-left corner (normalized to 0.0–1.0).
  /// - **width(double)**:
  ///   - Width of the watermark (normalized to 0.0–1.0).
  ///
  /// **Note:**
  /// - This API is currently not supported on macOS and Windows.
  void setWatermark(String imagePath, TRTCVideoStreamType streamType, double x,
      double y, double width);

  /// Pause/Resume subscribing to remote user's video stream
  ///
  /// This API only pauses/resumes receiving the specified user's video stream
  /// but does not release displaying resources; therefore, the video image will freeze
  /// at the last frame before it is called.
  ///
  /// **Parameters:**
  /// - **mute(bool)**:
  ///   - Whether to pause receiving.
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Specify for which video stream to pause (or resume):
  ///     - HD big image: [TRTCVideoStreamType.big]
  ///     - Smooth small image: [TRTCVideoStreamType.small]
  ///     - Substream image (usually used for screen sharing): [TRTCVideoStreamType.sub]
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  ///
  /// > **Note**
  /// >
  /// > This API can be called before room entry, and the pause status will be reset
  /// > after room exit.
  /// >
  /// > After calling this API to pause receiving the video stream from a specific user,
  /// > simply calling the [startRemoteView] API will not be able to play the video from
  /// > that user. You need to call [muteRemoteVideoStream] (false) or
  /// > [muteAllRemoteVideoStreams] (false) to resume it.
  void muteRemoteVideoStream(
      String userId, TRTCVideoStreamType streamType, bool mute);

  /// Pause/Resume subscribing to all remote users' video streams
  ///
  /// This API only pauses/resumes receiving all users' video streams
  /// but does not release displaying resources; therefore, the video image
  /// will freeze at the last frame before it is called.
  ///
  /// **Parameters:**
  /// - **mute(bool)**:
  ///   - Whether to pause receiving.
  ///
  /// > **Note**
  /// >
  /// > This API can be called before room entry, and the pause status will be reset
  /// > after room exit.
  /// >
  /// > After calling this interface to pause receiving video streams from all users,
  /// > simply calling the [startRemoteView] interface will not be able to play the
  /// > video from a specific user. You need to call [muteRemoteVideoStream] (false) or
  /// > [muteAllRemoteVideoStreams] (false) to resume it.
  void muteAllRemoteVideoStreams(bool mute);

  /// Set the encoding parameters of video encoder
  ///
  /// This setting can determine the quality of image viewed by remote users,
  /// which is also the image quality of on-cloud recording files.
  ///
  /// **Parameters:**
  /// - **params([TRTCVideoEncParam])**:
  ///   - It is used to set relevant parameters for the video encoder.
  void setVideoEncoderParam(TRTCVideoEncParam params);

  /// Set the image mirroring mode of the encoder output.
  ///
  /// **Parameters:**
  /// - **enable(bool)**:
  ///   - Whether to enable the image mirroring mode. Default value: false
  void setVideoEncoderMirror(bool enable);

  /// Set network quality control parameters
  ///
  /// This setting determines the quality control policy in a poor network
  /// environment, such as "image quality preferred" or "smoothness preferred".
  ///
  /// **Parameters:**
  /// - **param([TRTCNetworkQosParam])**:
  ///   - It is used to set relevant parameters for network quality control.
  void setNetworkQosParam(TRTCNetworkQosParam params);

  /// Set the rendering parameters of local video image
  ///
  /// The parameters that can be set include video image rotation angle,
  /// fill mode, and mirror mode.
  ///
  /// **Parameters:**
  /// - **params([TRTCRenderParams])**:
  ///   - Video image rendering parameters.
  void setLocalRenderParams(TRTCRenderParams params);

  /// Set the rendering mode of remote video image
  ///
  /// The parameters that can be set include video image rotation angle,
  /// fill mode, and mirror mode.
  ///
  /// **Parameters:**
  /// - **params([TRTCRenderParams])**:
  ///   - Video image rendering parameters.
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - It can be set to the primary stream image ([TRTCVideoStreamType.big])
  ///   or substream image ([TRTCVideoStreamType.sub]).
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  void setRemoteRenderParams(
      String userId, TRTCVideoStreamType streamType, TRTCRenderParams params);

  /// Enable dual-channel encoding mode with big and small images
  ///
  /// In this mode, the current user's encoder will output two channels of
  /// video streams, i.e., **HD big image** and **Smooth small image**,
  /// at the same time (only one channel of audio stream will be output though).
  ///
  /// In this way, other users in the room can choose to subscribe to the
  /// **HD big image** or **Smooth small image** according to their own
  /// network conditions or screen size.
  ///
  /// **Parameters:**
  /// - **enable(bool)**:
  ///   - Whether to enable small image encoding. Default value: false
  /// - **smallVideoEncParam([TRTCVideoEncParam])**:
  ///   - Video parameters of small image stream.
  ///
  /// **Note:**
  /// Dual-channel encoding will consume more CPU resources and network
  /// bandwidth; therefore, this feature can be enabled on macOS, Windows,
  /// or high-spec tablets, but is not recommended for phones.
  ///
  /// **Return Description:**
  /// - 0: success;
  /// - -1: the current big image has been set to a lower quality, and it
  ///   is not necessary to enable dual-channel encoding.
  int enableSmallVideoStream(bool enable, TRTCVideoEncParam smallVideoEncParam);

  /// Switch the big/small image of specified remote user
  ///
  /// After an anchor in a room enables dual-channel encoding, the video
  /// image that other users in the room subscribe to through
  /// [startRemoteView] will be **HD big image** by default.
  ///
  /// You can use this API to select whether the image subscribed to is
  /// the big image or small image. The API can take effect before or
  /// after [startRemoteView] is called.
  ///
  /// **Parameters:**
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Video stream type, i.e., big image or small image.
  ///   - Default value: [TRTCVideoStreamType.big]
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  ///
  /// **Note:**
  /// To implement this feature, the target user must have enabled the
  /// dual-channel encoding mode through [enableSmallVideoStream];
  /// otherwise, this API will not work.
  void setRemoteVideoStreamType(String userId, TRTCVideoStreamType streamType);

  /// Screencapture video(Only supports Windows)
  ///
  /// You can use this API to screencapture the local video image or the
  /// primary stream image and substream (screen sharing) image of a
  /// remote user.
  ///
  /// **Parameters:**
  /// - **sourceType([TRTCSnapshotSourceType])**:
  ///   - Video image source, which can be the video stream image
  ///   ([TRTCSnapshotSourceType.stream], generally in higher definition),
  ///   the video rendering image ([TRTCSnapshotSourceType.view]), or
  ///   the capture picture ([TRTCSnapshotSourceType.capture]). The
  ///   captured picture screenshot will be clearer.
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Video stream type, which can be the primary stream image
  ///   ([TRTCVideoStreamType.big], generally for camera) or substream
  ///   image ([TRTCVideoStreamType.sub], generally for screen sharing).
  /// - **userId(String)**:
  ///   - User ID. A null value indicates to screencapture the local video.
  ///
  /// > **Note:**
  /// > On Windows, only video image from the [TRTCSnapshotSourceType.stream] source can be screencaptured currently.
  void snapshotVideo(String userId, TRTCVideoStreamType streamType,
      TRTCSnapshotSourceType sourceType,
      {String? path});

  /// Set the adaptation mode of gravity sensing
  ///
  /// After turning on gravity sensing, if the device on the collection
  /// end rotates, the images on the collection end and the audience
  /// will be rendered accordingly to ensure that the image in the
  /// field of view is always facing up.
  ///
  /// It only takes effect in the camera capture scene inside the SDK,
  /// and only takes effect on the mobile terminal.
  ///
  /// **Notes:**
  /// 1. This interface only works for the collection end. If you only
  ///    watch the picture in the room, opening this interface is invalid.
  /// 2. When the capture device is rotated 90 degrees or 270 degrees,
  ///    the picture seen by the capture device or the audience may be
  ///    cropped to maintain proportional coordination.
  ///
  /// **Parameters:**
  /// - **mode([TRTCGSensorMode])**:
  ///   - Gravity sensing mode, ,
  ///   default value: [TRTCGSensorMode.uiAutoLayout].
  void setGravitySensorAdaptiveMode(TRTCGSensorMode mode);

  /// Enable local audio capturing and publishing
  ///
  /// The SDK does not enable the mic by default. When a user wants to
  /// publish the local audio, the user needs to call this API to enable
  /// mic capturing and encode and publish the audio to the current room.
  ///
  /// After local audio capturing and publishing is enabled, other users
  /// in the room will receive the [TRTCCloudListener.onUserAudioAvailable] notification
  /// indicating that the user's audio is available.
  ///
  /// **Parameters:**
  /// - **quality([TRTCAudioQuality])**:
  ///   - Sound quality:
  ///     - [TRTCAudioQuality.speech] : Smooth: sample rate: 16 kHz;
  ///       mono channel; audio bitrate: 16 Kbps. This is suitable for
  ///       audio call scenarios, such as online meeting and audio call.
  ///     - [TRTCAudioQuality.defaultMode] : Default: sample rate: 48 kHz;
  ///       mono channel; audio bitrate: 50 Kbps. This is the default
  ///       sound quality of the SDK and recommended if there are no
  ///       special requirements.
  ///     - [TRTCAudioQuality.music] : HD: sample rate: 48 kHz; dual
  ///       channel + full band; audio bitrate: 128 Kbps. This is
  ///       suitable for scenarios where Hi-Fi music transfer is required,
  ///       such as online karaoke and music live streaming.
  ///
  /// **Note:**
  /// This API will check the mic permission. If the current application
  /// does not have permission to use the mic, the SDK will automatically
  /// ask the user to grant the mic permission.
  void startLocalAudio(TRTCAudioQuality quality);

  /// Stop local audio capturing and publishing
  ///
  /// After local audio capturing and publishing is stopped, other users
  /// in the room will receive the [TRTCCloudListener.onUserAudioAvailable] notification
  /// indicating that the user's audio is no longer available.
  void stopLocalAudio();

  /// Pause/Resume publishing local audio stream
  ///
  /// After local audio publishing is paused, other users in the room
  /// will receive the [TRTCCloudListener.onUserAudioAvailable] notification indicating
  /// that the user's audio is no longer available (userId, false).
  ///
  /// After local audio publishing is resumed, other users in the room
  /// will receive the [TRTCCloudListener.onUserAudioAvailable] notification indicating
  /// that the user's audio is available again (userId, true).
  ///
  /// Different from [stopLocalAudio], [muteLocalAudio] (true) does not
  /// release the mic permission; instead, it continues to send mute
  /// packets with extremely low bitrate.
  ///
  /// This is very suitable for scenarios that require on-cloud recording,
  /// as video file formats such as MP4 have a high requirement for audio
  /// continuity. An MP4 recording file cannot be played back smoothly
  /// if [stopLocalAudio] is used.
  ///
  /// Therefore, `muteLocalAudio` instead of `stopLocalAudio` is recommended
  /// in scenarios where the requirement for recording file quality is high.
  ///
  /// **Parameters:**
  /// - **mute(bool)**:
  ///   - `true`: mute;
  ///   - `false`: unmute.
  void muteLocalAudio(bool mute);

  /// Pause/Resume playing back remote audio stream
  ///
  /// When you mute the remote audio of a specified user, the SDK will
  /// stop playing back the user's audio and pulling the user's audio data.
  ///
  /// **Parameters:**
  /// - **mute(bool)**:
  ///   - `true`: mute;
  ///   - `false`: unmute.
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  ///
  /// **Note:**
  /// This API works when called either before or after room entry
  /// (enterRoom), and the mute status will be reset to `false` after
  /// room exit (exitRoom).
  void muteRemoteAudio(String userId, bool mute);

  /// Pause/Resume playing back all remote users' audio streams
  ///
  /// When you mute the audio of all remote users, the SDK will stop
  /// playing back all their audio streams and pulling all their audio data.
  ///
  /// **Parameters:**
  /// - **mute(bool)**:
  ///   - `true`: mute;
  ///   - `false`: unmute.
  ///
  /// > **Note**
  /// >
  /// > This API works when called either before or after room entry (enterRoom), and the mute status will be reset to ` false ` after room exit (exitRoom).
  /// >
  void muteAllRemoteAudio(bool mute);

  /// Set the audio playback volume of a remote user
  ///
  /// You can mute the audio of a remote user through
  /// `setRemoteAudioVolume(userId, 0)`.
  ///
  /// **Parameters:**
  /// - **userId(String)**:
  ///   - ID of the specified remote user.
  /// - **volume(int)**:
  ///   - Volume. 100 is the original volume.
  ///   - Value range: [0, 150].
  ///   - Default value: 100.
  ///
  /// **Note:**
  /// If 100 is still not loud enough for you, you can set the volume
  /// to up to 150, but there may be side effects.
  void setRemoteAudioVolume(String userId, int volume);

  /// Set the capturing volume of local audio
  ///
  /// **Parameters:**
  /// - **volume(int)**:
  ///   - Volume. 100 is the original volume.
  ///   - Value range: [0, 150].
  ///   - Default value: 100.
  ///
  /// **Note:**
  /// If 100 is still not loud enough for you, you can set the volume
  /// to up to 150, but there may be side effects.
  void setAudioCaptureVolume(int volume);

  /// Get the capturing volume of local audio
  int getAudioCaptureVolume();

  /// Set the playback volume of remote audio
  ///
  /// This API controls the volume of the sound ultimately delivered
  /// by the SDK to the system for playback. It affects the volume
  /// of the recorded local audio file but not the volume of in-ear
  /// monitoring.
  ///
  /// **Parameters:**
  /// - **volume(int)**:
  ///   - Volume. 100 is the original volume.
  ///   - Value range: [0, 150].
  ///   - Default value: 100.
  ///
  /// **Note:**
  /// If 100 is still not loud enough for you, you can set the volume
  /// to up to 150, but there may be side effects.
  void setAudioPlayoutVolume(int volume);

  /// Get the playback volume of remote audio
  int getAudioPlayoutVolume();

  /// Enable volume reminder
  ///
  /// After this feature is enabled, the SDK will return the audio
  /// volume assessment information of the local user who sends
  /// stream and remote users in the [TRTCCloudListener.onUserVoiceVolume]
  ///
  /// **Parameters:**
  /// - **enable(bool)**:
  ///   - Whether to enable the volume prompt. It’s disabled by default.
  /// - **params([TRTCAudioVolumeEvaluateParams])**:
  ///   - Volume evaluation and other related parameters.
  ///
  /// **Note:**
  /// To enable this feature, call this API before calling [startLocalAudio] .
  void enableAudioVolumeEvaluation(
      bool enable, TRTCAudioVolumeEvaluateParams params);

  /// Start local media recording
  ///
  /// This API records the audio/video content during live streaming
  /// into a local file.
  ///
  /// **Parameters:**
  /// - **params([TRTCLocalRecordingParams])**:
  ///   - Recording parameter.
  int startLocalRecording(TRTCLocalRecordingParams param);

  /// Stop local media recording
  ///
  /// If a recording task has not been stopped through this API before room exit, it will be automatically stopped after room exit.
  void stopLocalRecording();

  /// Get device management class ([TXDeviceManager])
  TXDeviceManager getDeviceManager();

  ///Set special effects such as beauty, brightening, and rosy skin filters
  /// The SDK is integrated with two skin smoothing algorithms of different styles:
  /// "Smooth" style, which uses a more radical algorithm for more obvious effect and is suitable for show live streaming.
  /// "Natural" style, which retains more facial details for more natural effect and is suitable for most live streaming use cases.
  ///
  /// **Parameters:**
  /// - **style**
  ///   - Skin smoothening algorithm ("smooth" or "natural")
  /// - **beautyLevel**
  ///   - Strength of the beauty filter. Value range: 0–9; 0 indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  /// - **whitenessLevel**
  ///   - Strength of the brightening filter. Value range: 0–9; 0 indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  /// - **ruddinessLevel**
  ///   - Strength of the rosy skin filter. Value range: 0–9; 0 indicates that the filter is disabled, and the greater the value, the more obvious the effect.
  void setBeautyStyle(TRTCBeautyStyle style, int beautyLevel,
      int whitenessLevel, int ruddinessLevel);

  /// Get sound effect management class ([TXAudioEffectManager])
  ///
  /// [TXAudioEffectManager] is a sound effect management API, through
  /// which you can implement the following features:
  /// - **Background music**: Both online music and local music can be
  ///   played back with various features such as speed adjustment, pitch
  ///   adjustment, original voice, accompaniment, and loop.
  /// - **In-ear monitoring**: The sound captured by the mic is played
  ///   back in the headphones in real time, which is generally used for
  ///   music live streaming.
  /// - **Reverb effect**: Karaoke room, small room, big hall, deep,
  ///   resonant, and other effects.
  /// - **Voice changing effect**: Young girl, middle-aged man, heavy
  ///   metal, and other effects.
  /// - **Short sound effect**: Short sound effect files such as applause
  ///   and laughter are supported (for files less than 10 seconds in
  ///   length, please set the `isShortFile` parameter to `true`).
  TXAudioEffectManager getAudioEffectManager();

  /// Enable system audio capturing (Only supports Windows)
  ///
  /// This API captures audio data from the sound card of the anchor’s
  /// computer and mixes it into the current audio stream of the SDK.
  /// This ensures that other users in the room hear the audio played
  /// back by the anchor’s computer.
  ///
  /// In online education scenarios, a teacher can use this API to have
  /// the SDK capture the audio of instructional videos and broadcast it
  /// to students in the room.
  ///
  /// In live music scenarios, an anchor can use this API to have the
  /// SDK capture the music played back by his or her player so as to
  /// add background music to the room.
  ///
  /// **Parameters:**
  /// - **deviceName(String)**:
  ///   - If this parameter is empty, the audio of the entire system is captured.
  ///
  /// **Note:**
  /// - On the Windows platform, you can specify the parameter
  ///   `deviceName` to the absolute path of an executable file (such as
  ///   `QQMusic.exe`) of a certain application. In this case, the SDK
  ///   will only capture the sound of that application (32-bit version
  ///   of the SDK is supported, 64-bit version of the SDK requires
  ///   Windows version 10.0.19042 or higher).
  /// - You can also specify `deviceName` as the name of a certain
  ///   speaker device to capture specific speaker sound (you can use
  ///   the getDevicesList interface in TXDeviceManager to obtain the
  ///   speaker devices of type [TXMediaDeviceType.speaker]).
  /// - On the Windows platform, you can also specify `deviceName` as
  ///   the process ID of a certain process (in the format of
  ///   "process_xxx", where xxx is the process ID), and then the SDK
  ///   will capture the sound of that process (requires Windows version
  ///   10.0.19042 or higher).
  /// - Alternatively, on the Windows platform, you can specify
  ///   `deviceName` as the process ID of a certain process to be
  ///   excluded (in the format of "exclude_process_xxx", where xxx is
  ///   the process ID), and then the SDK will capture all sounds
  ///   except for that process (requires Windows version 10.0.19042 or
  ///   higher).
  /// - About speaker device name you can see [TXDeviceManager] .
  void startSystemAudioLoopback({String? deviceName});

  /// Stop system audio capturing(Only supports Windows)
  void stopSystemAudioLoopback();

  /// Set the volume of system audio capturing(Only supports Windows)
  ///
  /// **Parameters:**
  /// - **volume(int)**:
  ///   - Set volume. Value range: [0, 150].
  ///   - Default value: 100.
  void setSystemAudioLoopbackVolume(int volume);

  /// Start screen sharing
  ///
  /// This API can capture the content of the entire screen or a specified
  /// application and share it with other users in the same room.
  /// (iOS platform calls this interface to support only sharing within the application. System-level sharing requires the use of [startScreenCaptureByReplaykit])
  ///
  /// **Parameters:**
  /// - **encParam([TRTCVideoEncParam])**:
  ///   - Image encoding parameters used for screen sharing, which can be
  ///   set to empty, indicating to let the SDK choose the optimal encoding
  ///   parameters (such as resolution and bitrate).
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Channel used for screen sharing, which can be the primary stream
  ///   ([TRTCVideoStreamType.big]) or substream ([TRTCVideoStreamType.sub]).
  /// - **viewId(int)**:
  ///   - Parent control of the rendering control, which can be set to 0,
  ///   indicating not to display the preview of the shared screen.
  ///   (Currently only Android can do local preview)
  ///
  /// **Note:**
  /// 1. A user can publish at most one primary stream ([TRTCVideoStreamType.big])
  ///    and one substream ([TRTCVideoStreamType.sub]) at the same time.
  /// 2. By default, screen sharing uses the substream image. If you want to
  ///    use the primary stream for screen sharing, you need to stop camera
  ///    capturing (through [stopLocalPreview]) in advance to avoid conflicts.
  /// 3. Only one user can use the substream for screen sharing in the same
  ///    room at any time; that is, only one user is allowed to enable the
  ///    substream in the same room at any time.
  /// 4. When there is already a user in the room using the substream for
  ///    screen sharing, calling this API will return the
  ///    [TRTCCloudListener.onError] (ERR_SERVER_CENTER_ANOTHER_USER_PUSH_SUB_VIDEO) callback.
  void startScreenCapture(
      int? viewId, TRTCVideoStreamType streamType, TRTCVideoEncParam encParam);

  /// Start screen sharing by ReplayKit (for iOS only)
  ///
  /// This interface supports you to share the entire iOS system screen.
  ///
  /// **Parameters:**
  /// - **encParam([TRTCVideoEncParam])**:
  ///   - Image encoding parameters used for screen sharing, which can be
  ///   set to empty, indicating to let the SDK choose the optimal encoding
  ///   parameters (such as resolution and bitrate).
  /// - **streamType([TRTCVideoStreamType])**:
  ///   - Channel used for screen sharing, which can be the primary stream
  ///   ([TRTCVideoStreamType.big]) or substream ([TRTCVideoStreamType.sub]).
  /// - **appGroup(String)**:
  ///   - The Application Group Identifier shared by your app and the screen recording process.
  ///   - You can specify this parameter as nil, but it is recommended that you set it according to the documentation for better reliability.
  void startScreenCaptureByReplaykit(TRTCVideoStreamType streamType,
      TRTCVideoEncParam encParam, String? appGroup);

  /// Stop screen sharing
  void stopScreenCapture();

  /// Pause screen sharing
  void pauseScreenCapture();

  /// Resume screen sharing
  void resumeScreenCapture();

  /// Enumerate shareable screens and windows (for desktop systems only)
  ///
  /// When you integrate the screen sharing feature of a desktop system,
  /// you generally need to display a UI for selecting the sharing target,
  /// so that users can use the UI to choose whether to share the entire
  /// screen or a certain window.
  ///
  /// Through this API, you can query the IDs, names, and thumbnails of
  /// sharable windows on the current system. We provide a default UI
  /// implementation in the demo for your reference.
  ///
  /// **Parameters:**
  /// - **iconSize([TRTCSize])**:
  ///   - Specify the icon size of the window to be obtained.
  /// - **thumbnailSize([TRTCSize])**:
  ///   - Specify the thumbnail size of the window to be obtained. The
  ///   thumbnail can be drawn on the window selection UI.
  ///
  /// **Return Description:**
  /// - List of windows (including the screen).
  TRTCScreenCaptureSourceList? getScreenCaptureSources(
      TRTCSize thumbnail, TRTCSize icon);

  /// Select the screen or window to share (for desktop systems only)
  ///
  /// After you get the sharable screens and windows through
  /// [getScreenCaptureSources] , you can call this API to select the
  /// target screen or window you want to share.
  ///
  /// During the screen sharing process, you can also call this API at
  /// any time to switch the sharing target.
  ///
  /// The following four sharing modes are supported:
  /// - **Sharing the entire screen**:
  ///   - For `source` whose `type` is `Screen` in `sourceInfoList`,
  ///   set `captureRect` to `{0, 0, 0, 0}`.
  /// - **Sharing a specified area**:
  ///   - For `source` whose `type` is `Screen` in `sourceInfoList`,
  ///   set `captureRect` to a non-nullptr value, e.g., `{100, 100, 300, 300}`.
  /// - **Sharing an entire window**:
  ///   - For `source` whose `type` is `Window` in `sourceInfoList`,
  ///   set `captureRect` to `{0, 0, 0, 0}`.
  /// - **Sharing a specified window area**:
  ///   - For `source` whose `type` is `Window` in `sourceInfoList`,
  ///   set `captureRect` to a non-nullptr value, e.g., `{100, 100, 300, 300}`.
  ///
  /// **Parameters:**
  /// - **rect([TRTCRect])**:
  ///   - Specify the area to be captured.
  /// - **property([TRTCScreenCaptureProperty])**:
  ///   - Specify the attributes of the screen sharing target, such as
  ///   capturing the cursor and highlighting the captured window.
  /// - **source([TRTCScreenCaptureSourceInfo])**:
  ///   - Specify sharing source.
  ///
  /// **Note:**
  /// - Setting the highlight border color and width parameters does not
  ///   take effect on macOS.
  void selectScreenCaptureTarget(TRTCScreenCaptureSourceInfo source,
      TRTCRect rect, TRTCScreenCaptureProperty property);

  /// Add specified windows to the exclusion list of screen sharing (for desktop systems only)
  ///
  /// The excluded windows will not be shared. This feature is generally used to add a certain application's window to the
  /// exclusion list to avoid privacy issues.
  /// You can set the filtered windows before starting screen sharing or dynamically add the filtered windows during
  /// screen sharing.
  ///
  /// **Parameters:**
  /// - **windowID(int)**:
  ///   - Window not to be shared (window ID on macOS or HWND on Windows).
  ///
  /// **Note:**
  /// 1. This API takes effect only if the `type` in [TRTCScreenCaptureSourceInfo] is specified as
  ///    `TRTCScreenCaptureSourceTypeScreen`; that is, the feature of excluding specified windows works only when the
  ///    entire screen is shared.
  /// 2. The windows added to the exclusion list through this API will be automatically cleared by the SDK after room exit.
  /// 3. On macOS, please pass in the window ID (CGWindowID), which can be obtained through the `sourceId` member in
  ///    [TRTCScreenCaptureSourceInfo].
  void addExcludedShareWindow(int windowID);

  /// Remove specified windows from the exclusion list of screen sharing (for desktop systems only)
  ///
  /// **Parameters:**
  /// - **windowID(int)**:
  ///   - Window ID to be removed from the exclusion list.
  void removeExcludedShareWindow(int windowID);

  /// Remove all windows from the exclusion list of screen sharing (for desktop systems only)
  void removeAllExcludedShareWindow();

  /// Add specified windows to the inclusion list of screen sharing (for desktop systems only)
  ///
  /// This API takes effect only if the `type` in [TRTCScreenCaptureSourceInfo] is specified as
  /// `TRTCScreenCaptureSourceTypeWindow`; that is, the feature of additionally including specified windows works only
  /// when a window is shared.
  /// You can call it before or after [startScreenCapture].
  ///
  /// **Parameters:**
  /// - **windowID(int)**:
  ///   - Window to be shared (which is a window handle `HWND` on Windows).
  ///
  /// **Note:**
  /// The windows added to the inclusion list by this method will be automatically cleared by the SDK after room exit.
  void addIncludedShareWindow(int windowID);

  /// Remove specified windows from the inclusion list of screen sharing (for desktop systems only)
  ///
  /// This API takes effect only if the `type` in [TRTCScreenCaptureSourceInfo] is specified as
  /// `TRTCScreenCaptureSourceTypeWindow`.
  /// That is, the feature of additionally including specified windows works only when a window is shared.
  ///
  /// **Parameters:**
  /// - **windowID(int)**:
  ///   - Window to be shared (window ID on macOS or HWND on Windows).
  void removeIncludedShareWindow(int windowID);

  /// Remove all windows from the inclusion list of screen sharing (for desktop systems only)
  ///
  /// This API takes effect only if the `type` in [TRTCScreenCaptureSourceInfo] is specified as
  /// `TRTCScreenCaptureSourceTypeWindow`.
  /// That is, the feature of additionally including specified windows works only when a window is shared.
  void removeAllIncludedShareWindow();

  /// Set the video encoding parameters of screen sharing (i.e., substream) (for desktop and mobile systems)
  ///
  /// This API can set the image quality of screen sharing (i.e., the
  /// substream) viewed by remote users, which is also the image quality
  /// of screen sharing in on-cloud recording files.
  ///
  /// Please note the differences between the following two APIs:
  /// - ** [setVideoEncoderParam] **:
  ///   - Used to set the video encoding parameters of the primary stream
  ///   image ([TRTCVideoStreamType.big], generally for camera).
  /// - ** [setSubStreamEncoderParam] **:
  ///   - Used to set the video encoding parameters of the substream image
  ///   ([TRTCVideoStreamType.sub], generally for screen sharing).
  ///
  /// **Parameters:**
  /// - **param([TRTCVideoEncParam])**:
  ///   - Substream encoding parameters.
  void setSubStreamEncoderParam(TRTCVideoEncParam param);

  /// Enable custom audio capturing mode
  ///
  /// After this mode is enabled, the SDK will not run the original audio
  /// capturing process (i.e., stopping mic data capturing) and will retain
  /// only the audio encoding and sending capabilities.
  ///
  /// You need to use [sendCustomAudioData] to continuously insert the
  /// captured audio data into the SDK.
  ///
  /// **Parameters:**
  /// - **enable(bool)**:
  ///   - Whether to enable.
  ///   - Default value: false.
  ///
  /// **Note:**
  /// - As acoustic echo cancellation (AEC) requires strict control over
  ///   the audio capturing and playback time, after custom audio capturing
  ///   is enabled, AEC may fail.
  void enableCustomAudioCapture(bool enable);

  /// Deliver captured audio data to SDK
  ///
  /// We recommend you enter the following information for the
  /// [TRTCAudioFrame] parameter (other fields can be left empty):
  /// - **audioFormat**:
  ///   - Audio data format, which can only be [TRTCAudioFrameFormat.pcm].
  /// - **data**:
  ///   - Audio frame buffer. Audio frame data must be in PCM format,
  ///   and it supports a frame length of 5–100 ms (20 ms is recommended).
  ///   Length calculation method:
  ///   **For example, if the sample rate is 48000, then the frame length
  ///   for mono channel will be `48000 * 0.02s * 1 * 16 bit = 15360 bit =
  ///   1920 bytes`.**
  /// - **sampleRate**:
  ///   - Sample rate. Valid values: 16000, 24000, 32000, 44100, 48000.
  /// - **channel**:
  ///   - Number of channels (if stereo is used, data is interwoven).
  ///   - Valid values: 1: mono channel; 2: dual channel.
  /// - **timestamp (ms)**:
  ///
  /// **Parameters:**
  /// - **frame([TRTCAudioFrame])**:
  ///   - Audio data.
  ///
  /// **Note:**
  /// - Please call this API accurately at intervals of the frame length;
  ///   otherwise, sound lag may occur due to uneven data delivery intervals.
  void sendCustomAudioData(TRTCAudioFrame frame);

  /// Use UDP channel to send custom message to all users in room
  ///
  /// This API allows you to use TRTC's UDP channel to broadcast custom
  /// data to other users in the current room for signaling transfer.
  ///
  /// Other users in the room can receive the message through the [TRTCCloudListener.onRecvCustomCmdMsg].
  ///
  /// **Parameters:**
  /// - **cmdID(int)**:
  ///   - Message ID.
  ///   - Value range: 1–10.
  /// - **data(String)**:
  ///   - Message to be sent. The maximum length of one single message is 1 KB.
  /// - **ordered(bool)**:
  ///   - Whether orderly sending is enabled, i.e., whether the data packets
  ///   should be received in the same order in which they are sent; if so,
  ///   a certain delay will be caused.
  /// - **reliable(bool)**:
  ///   - Whether reliable sending is enabled. Reliable sending can achieve
  ///   a higher success rate but with a longer reception delay than
  ///   unreliable sending.
  ///
  /// **Note:**
  /// 1. Up to 30 messages can be sent per second to all users in the room
  ///    (this is not supported for web and mini program currently).
  /// 2. A packet can contain up to 1 KB of data; if the threshold is
  ///    exceeded, the packet is very likely to be discarded by the
  ///    intermediate router or server.
  /// 3. A client can send up to 8 KB of data in total per second.
  /// 4. `reliable` and `ordered` must be set to the same value (`true`
  ///    or `false`) and cannot be set to different values currently.
  /// 5. We strongly recommend you set different `cmdID` values for messages
  ///    of different types. This can reduce message delay when orderly
  ///    sending is required.
  /// 6. Currently only the anchor role is supported.
  ///
  /// **Return Description:**
  /// - `true`: sent the message successfully;
  /// - `false`: failed to send the message.
  bool sendCustomCmdMsg(int cmdID, String data, bool reliable, bool ordered);

  /// Use SEI channel to send custom message to all users in room
  ///
  /// This API allows you to use TRTC's SEI channel to broadcast custom
  /// data to other users in the current room for signaling transfer.
  ///
  /// The header of a video frame has a header data block called SEI.
  /// This API works by embedding the custom signaling data you want to
  /// send in the SEI block and sending it together with the video frame.
  ///
  /// Therefore, the SEI channel has a better compatibility than
  /// [sendCustomCmdMsg] as the signaling data can be transferred to
  /// the CSS CDN along with the video frame.
  ///
  /// However, because the data block of the video frame header cannot
  /// be too large, we recommend you limit the size of the signaling
  /// data to only a few bytes when using this API.
  ///
  /// The most common use is to embed the custom timestamp into video
  /// frames through this API so as to implement a perfect alignment
  /// between the message and video image (such as between the teaching
  /// material and video signal in the education scenario).
  ///
  /// Other users in the room can receive the message through the [TRTCCloudListener.onRecvSEIMsg] .
  ///
  /// **Parameters:**
  /// - **data(String)**:
  ///   - Data to be sent, which can be up to 1 KB (1,000 bytes).
  /// - **repeatCount(int)**:
  ///   - Data sending count.
  ///
  /// **Note:**
  /// This API has the following restrictions:
  /// 1. The data will not be instantly sent after this API is called;
  ///    instead, it will be inserted into the next video frame after
  ///    the API call.
  /// 2. Up to 30 messages can be sent per second to all users in the
  ///    room (this limit is shared with [sendCustomCmdMsg]).
  /// 3. Each packet can be up to 1 KB (this limit is shared with
  ///    [sendCustomCmdMsg]). If a large amount of data is sent, the
  ///    video bitrate will increase, which may reduce the video quality
  ///    or even cause lagging.
  /// 4. Each client can send up to 8 KB of data in total per second
  ///    (this limit is shared with [sendCustomCmdMsg]).
  /// 5. If multiple times of sending is required (i.e., `repeatCount`
  ///    > 1), the data will be inserted into subsequent `repeatCount`
  ///    video frames in a row for sending, which will increase the
  ///    video bitrate.
  /// 6. If `repeatCount` is greater than 1, the data will be sent for
  ///    multiple times, and the same message may be received multiple
  ///    times in the [TRTCCloudListener.onRecvSEIMsg] callback; therefore, deduplication
  ///    is required.
  ///
  /// **Return Description:**
  /// - `true`: the message is allowed and will be sent with subsequent
  ///   video frames;
  /// - `false`: the message is not allowed to be sent.
  bool sendSEIMsg(String data, int repeatCount);

  /// Start network speed test (used before room entry)
  ///
  /// **Parameters:**
  /// - **params(TRTCSpeedTestParams)**:
  ///   - Speed test options.
  ///
  /// **Note:**
  /// 1. The speed measurement process will incur a small amount of
  ///    basic service fees.
  /// 2. Please perform the network speed test before room entry,
  ///    because if performed after room entry, the test will affect
  ///    the normal audio/video transfer, and its result will be
  ///    inaccurate due to interference in the room.
  /// 3. Only one network speed test task is allowed to run at the
  ///    same time.
  ///
  /// **Return Description:**
  /// - Interface call result, `<0`: failure.
  int startSpeedTest(TRTCSpeedTestParams params);

  /// Stop network speed test
  void stopSpeedTest();

  int setAudioFrameCallback(TRTCAudioFrameCallback? callback);

  /// Get SDK version information
  String getSDKVersion();

  /// Set log output level
  ///
  /// **Parameters:**
  /// - **level([TRTCLogLevel])**:
  ///   - Default value: [TRTCLogLevel.none].
  void setLogLevel(TRTCLogLevel level);

  /// Enable/Disable console log printing
  ///
  /// **Parameters:**
  /// - **enabled(bool)**:
  ///   - Specify whether to enable console log printing, which is
  ///     disabled by default.
  void setConsoleEnabled(bool enabled);

  /// Enable/Disable local log compression
  ///
  /// If compression is enabled, the log size will significantly reduce,
  /// but logs can be read only after being decompressed by the Python
  /// script provided by Tencent Cloud.
  ///
  /// If compression is disabled, logs will be stored in plaintext and
  /// can be read directly in Notepad, but will take up more storage capacity.
  ///
  /// **Parameters:**
  /// - **enabled(bool)**:
  ///   - Specify whether to enable log compression, which is enabled
  ///     by default.
  void setLogCompressEnabled(bool enabled);

  /// Set local log storage path
  ///
  /// You can use this API to change the default storage path of the SDK's
  /// local logs, which is as follows:
  /// - **Windows**: `C:/Users/[username]/AppData/Roaming/liteav/log`, i.e.,
  ///   under `%appdata%/liteav/log`.
  /// - **iOS or macOS**: under `sandbox Documents/log`.
  /// - **Android**: under `/app directory/files/log/liteav/`.
  ///
  /// **Parameters:**
  /// - **path(String)**:
  ///   - Log storage path.
  ///
  /// > **Note**
  /// > Please be sure to call this API before all other APIs and make sure
  /// > that the directory you specify exists and your application has
  /// > read/write permissions for the directory.
  void setLogDirPath(String path);

  /// Set log callback
  void setLogCallback(TRTCLogCallback? callback);

  /// Display dashboard
  ///
  /// "Dashboard" is a semi-transparent floating layer for debugging
  /// information on top of the video rendering control. It is used to
  /// display audio/video information and event information to facilitate
  /// integration and debugging.
  ///
  /// **Parameters:**
  /// - **showType(int)**:
  ///   - `0`: does not display;
  ///   - `1`: displays lite edition (only with audio/video information);
  ///   - `2`: displays full edition (with audio/video information and
  ///     event information).
  void showDebugView(int showType);

  /// Call experimental APIs
  String callExperimentalAPI(String jsonStr);

  /// Get AI Transcriber Manager
  ///
  /// This API returns the AITranscriberManager singleton for managing
  /// real-time transcription and translation features.
  ///
  /// Before using AI transcription:
  /// 1. Go to "Console -> Feature Configuration -> Value-Added Features" to
  ///    enable AI intelligent recognition features (speech-to-text, real-time translation).
  /// 2. See [documentation](https://cloud.tencent.com/document/product/647/126312) for details.
  ///
  /// **Return Description:**
  /// - AITranscriberManager singleton instance
  AITranscriberManager getAITranscriberManager();
}
