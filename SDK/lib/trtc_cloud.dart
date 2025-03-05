import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_trtc_cloud/deprecated_trtc_cloud.dart';
import 'package:tencent_trtc_cloud/core/store.dart';
import 'trtc_cloud_video_view.dart';
import 'trtc_cloud_listener.dart';
import 'trtc_cloud_def.dart';
import 'tx_beauty_manager.dart';
import 'tx_audio_effect_manager.dart';
import 'tx_device_manager.dart';

/// Main API class for the TRTC video call feature
class TRTCCloud extends DeprecatedTRTCCloud {
  static TRTCCloud? _trtcCloud;

  static const MethodChannel _channel = const MethodChannel('trtcCloudChannel');

  TRTCCloudListenerWrapper? listener;

  MethodChannel? _cloudChannel;

  TRTCAudioFrameListenerPlatformMethod? _audioFrameListener;

  TXAudioEffectManager? _audioEffectManager;
  TXBeautyManager? _txBeautyManager;
  TXDeviceManager? _txDeviceManager;

  static Future<String?> getPlatformVersion() async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Create a `TRTCCloud` singleton for room entry, preview, push stream, pull stream, etc.
  static Future<TRTCCloud?> sharedInstance() async {
    if (_trtcCloud == null) {
      _trtcCloud = new TRTCCloud();
      _trtcCloud?._cloudChannel = _channel;
      await _channel.invokeMethod('sharedInstance');
    }
    return _trtcCloud;
  }

  /// Terminate a `TRTCCloud` singleton
  static Future<void> destroySharedInstance() async {
    await _channel.invokeMethod('destroySharedInstance');
    _trtcCloud?._cloudChannel = null;
    _trtcCloud = null;
  }

  /// Create a child TRTC instance (for concurrent viewing in multiple rooms)
  ///
  /// By calling this interface, you can create multiple TRTCCloud instances so that you can enter multiple different rooms to watch audio and video streams at the same time.
  ///
  /// Sample code
  /// ```
  /// cloud = (await TRTCCloud.sharedInstance())!;
  /// //Create child instance
  /// subCloud = await cloud!.createSubCloud();
  /// //Destroy child instance
  /// cluod.destroySubCloud(subCloud);
  /// ```
  ///
  /// **Notice**
  /// - Currently child instances cannot support custom rendering.
  /// - The same user can use the same userId to enter multiple rooms with different roomIds.
  /// - You can set [TRTCCloudListener] for different instances to obtain respective event notifications.
  /// - The same user can push streams in multiple TRTCCloud instances, and can also call local audio and video-related interfaces in sub-instances.
  ///
  /// **Return value:** TRTC instance
  ///
  /// **Not supported on:**
  /// - web
  /// - MacOS
  /// - Windows
  Future<TRTCCloud> createSubCloud() async {
    TRTCCloud cloud = new TRTCCloud();
    MethodChannel channel = MethodChannel("trtcCloudChannel_${cloud.hashCode}");
    await _cloudChannel!.invokeMethod("createSubCloud", {
      "channelName" : channel.name,
    });
    cloud._cloudChannel = channel;
    return cloud;
  }

  /// Destroy the child TRTC instance
  ///
  /// **Not supported on:**
  /// - web
  /// - MacOS
  /// - Windows
  Future<void> destroySubCloud(TRTCCloud cloud) {
    if (cloud == _trtcCloud) {
      print("TRTCCloud : Singleton objects cannot be destroyed through this interface");
      return Future<void>.value();
    }
    return _cloudChannel!.invokeMethod("destroySubCloud", {
      "channelName" : cloud._cloudChannel!.name,
    });
  }

  /// Set an event listener, through which users can get various status notifications from `TRTCCloud`
  ///
  /// For more information, please see the definitions in [TRTCCloudListener] in the `trtc_cloud_listener` file
  void registerListener(ListenerValue func) {
    if (listener == null) {
      listener = TRTCCloudListenerWrapper(_cloudChannel!);
    }
    listener!.addListener(func);
  }

  /// Remove message listener
  void unRegisterListener(ListenerValue func) {
    if (listener == null) {
      listener = TRTCCloudListenerWrapper(_cloudChannel!);
    }
    listener!.removeListener(func);
  }

  /// Enter an audio/video call room (hereinafter referred to as "Enter Room").
  ///
  /// After calling this API, you will receive the `onEnterRoom(result)` callback from [TRTCCloudListener] :
  ///
  /// If room entry succeeded, `result` will be a positive number (`result` > 0), indicating the time in milliseconds (ms) used for entering the room.
  ///
  /// If room entry failed, `result` will be a negative number (`result` < 0), indicating the error code for room entry failure.
  ///
  /// **Parameters:**
  ///
  /// `param` Room entry parameters. For more information, please see the definition of the [TRTCParams] parameter in `trtc_cloud_def.dart`
  ///
  /// `scene` Application scenario. Currently, video call (VideoCall), live streaming (Live), audio call (AudioCall), and voice chat room (VoiceChatRoom) are supported.
  ///
  /// **Note:**
  ///
  /// 1. If `scene` is selected as `TRTC_APP_SCENE_LIVE` or `TRTC_APP_SCENE_VOICE_CHATROOM`, you must use the `role` field in `TRTCParams` to specify the role of the current user.
  ///
  /// 2. No matter whether room entry is successful, [enterRoom] must be used together with [exitRoom]. If [enterRoom] is called again before [exitRoom] is called, an unexpected error will occur.
  Future<void> enterRoom(TRTCParams param, int scene) {
    if (kIsWeb || Platform.isAndroid || Platform.isWindows) {
      return _cloudChannel!.invokeMethod('enterRoom', {
        "sdkAppId": param.sdkAppId,
        "userId": param.userId,
        "userSig": param.userSig,
        "roomId": param.roomId.toString(),
        "strRoomId": param.strRoomId,
        "role": param.role,
        "streamId": param.streamId,
        "userDefineRecordId": param.userDefineRecordId,
        "privateMapKey": param.privateMapKey,
        "businessInfo": param.businessInfo,
        "scene": scene,
      });
    } else {
      return _cloudChannel!.invokeMethod('enterRoom', {
        "param": jsonEncode(param),
        "scene": scene,
      });
    }
  }

  /// Start the custom rendering of local video with external texture
  ///
  /// After this method is set, the SDK will skip its own rendering process and call back the captured data. Therefore, you need to complete image rendering on your own.
  ///
  /// For more information on the parameters, please see the definition of [CustomLocalRender]
  ///
  /// **Returned value**: `textureId`
  ///
  /// For more information, please see [Custom Capturing and Rendering](https://cloud.tencent.com/document/product/647/34066)
  ///
  /// Sample call
  /// ```
  /// var textureId = await trtcCloud.setLocalVideoRenderListener(
  ///            CustomLocalRender(
  ///               userId: userInfo['userId'],
  ///                isFront: true,
  ///                streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
  ///                width: 360,
  ///                height: 738));
  ///
  /// Texture(key: valueKey, textureId: textureId)
  /// ```
  /// When to call: call after room entry succeeds
  ///
  /// **Not supported on:**
  /// - web
  Future<int?> setLocalVideoRenderListener(CustomLocalRender param) {
    return _cloudChannel!.invokeMethod('setLocalVideoRenderListener', {
      "userId": param.userId,
      "isFront": param.isFront,
      "streamType": param.streamType,
      "width": param.width,
      "height": param.height,
    });
  }

  /// @nodoc
  ///
  /// Update the width and height of the local video
  Future<void> updateLocalVideoRender(int width, int height) {
    return _cloudChannel!.invokeMethod('updateLocalVideoRender', {
      "width": width,
      "height": height,
    });
  }

  /// @nodoc
  ///
  /// Update the width and height of the remote video
  Future<void> updateRemoteVideoRender(int textureID, int width, int height) {
    return _cloudChannel!.invokeMethod('updateRemoteVideoRender', {
      "textureID": textureID,
      "width": width,
      "height": height,
    });
  }

  /// Set up a custom rendering callback for the remote video. the SDK will skip the original rendering process and callback the received data. you will need to complete the screen rendering yourself at this time.
  ///
  /// For more information on the parameters, please see the definition of [CustomRemoteRender]
  ///
  /// **Returned value**: `textureId`
  ///
  /// For more information, please see [Custom Capturing and Rendering](https://cloud.tencent.com/document/product/647/34066)
  ///
  /// Sample call
  /// ```
  /// var textureId = await trtcCloud.setRemoteVideoRenderListener(
  ///        CustomRemoteRender(
  ///            userId: userId,
  ///            streamType: TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
  ///            width: 360,
  ///            height: 369));
  ///
  /// Texture(key: valueKey, textureId: textureId)
  /// ```
  /// When to call: call when `onUserVideoAvailable` is `true`
  ///
  /// **Not supported on:**
  /// - web
  Future<int?> setRemoteVideoRenderListener(CustomRemoteRender param) {
    return _cloudChannel!.invokeMethod('setRemoteVideoRenderListener', {
      "userId": param.userId,
      "streamType": param.streamType,
      "width": param.width,
      "height": param.height,
    });
  }

  /// Unregister custom rendering callbacks
  ///
  /// The `textureID` generated when [setLocalVideoRenderListener] or [setRemoteVideoRenderListener] is called. You need to call this API to unregister when the texture is no longer needed
  ///
  /// When to call: call when [TRTCCloudListener.onUserVideoAvailable] is `false` or the page is disposed
  ///
  /// **Not supported on:**
  /// - web
  Future<void> unregisterTexture(int textureID) {
    return _cloudChannel!.invokeMethod('unregisterTexture', {
      "textureID": textureID,
    });
  }

  /// Exit room
  ///
  /// When the [exitRoom] API is called, the logic related to room exit will be executed, such as releasing resources of audio/video devices and codecs. After resources are released, the SDK will use the [TRTCCloudListener.onExitRoom] callback to notify you.
  ///
  /// If you need to call [enterRoom] again or switch to another audio/video SDK, please wait until you receive the [TRTCCloudListener.onExitRoom] callback; otherwise, exceptions such as occupied camera or mic may occur; for example, the common issue with switching between media volume and call volume on Android is caused by this problem.
  Future<void> exitRoom() {
    return _cloudChannel!.invokeMethod('exitRoom');
  }

  /// Request cross-room calls so that two different rooms can share audio and video streams (e.g., "anchor PK" scenarios).
  ///
  /// In TRTC, two anchors in different rooms can use the "cross-room call" feature to co-anchor across the rooms. They can engage in "co-anchoring competition" without the need to exit their own rooms.
  ///
  /// For example, when anchor A in room "001" uses [connectOtherRoom] to successfully call anchor B in room "002", all users in room "001" will receive the `onRemoteUserEnterRoom(B)` and `onUserVideoAvailable(B,true)` callbacks of anchor B, and all users in room "002" will receive the `onRemoteUserEnterRoom(A)` and `onUserVideoAvailable(A,true)` callbacks of anchor A.
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
  ///
  /// trtcCloud.connectOtherRoom(jsonEncode(object));
  /// ```
  /// **Parameters:**
  ///
  /// `param` Co-anchoring parameters in the format of JSON string. `roomId` indicates the target room number, and `userId` indicates the target user ID.
  ///
  /// **Not supported on:**
  /// - web
  Future<void> connectOtherRoom(String param) {
    return _cloudChannel!.invokeMethod('connectOtherRoom', {
      "param": param,
    });
  }

  /// Exit cross-room call
  ///
  /// The result of exiting cross-room call will be returned through the [TRTCCloudListener.onDisConnectOtherRoom] callback.
  ///
  /// **Not supported on:**
  /// - web
  Future<void> disconnectOtherRoom() {
    return _cloudChannel!.invokeMethod('disconnectOtherRoom');
  }

  /// Switch roles (applicable only to the live streaming scenarios [TRTCCloudDef.TRTC_APP_SCENE_LIVE] and [TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM])
  ///
  /// In the live streaming scenario, a user may need to switch between "audience" and "anchor" roles. You can use the `role` field in [TRTCParams] before room entry to determine the role or use the [switchRole] API to switch roles after room entry.
  ///
  /// **Parameters:**
  ///
  /// `role` Target role, which is anchor by default:
  ///
  /// `TRTCCloudDef.TRTCRoleAnchor`: anchor, who can upstream video and audio. Up to 50 anchors are allowed to upstream videos at the same time in one room.
  ///
  /// `TRTCCloudDef.TRTCRoleAudience`: audience, who can only watch the video but cannot upstream video or audio. There is no upper limit for the number of audience users in one room.
  Future<void> switchRole(int role // Target role, which is anchor by default:
      ) {
    return _cloudChannel!.invokeMethod('switchRole', {
      "role": role,
    });
  }

  /// Set audio/video data reception mode, which must be set before room entry for it to take effect
  ///
  /// To deliver an excellent instant streaming experience, the SDK automatically receives audio/video upon successful room entry by default, that is, you will immediately receive audio/video data from all remote users. If you use this API mainly in scenarios where automatic video data reception is not required, such as audio chat, you can select the reception mode based on your actual needs.
  ///
  /// **Parameters:**
  ///
  /// `autoRecvAudio` `true`: audio data will be automatically received; `false`: [muteRemoteAudio] needs to be called to send or cancel a request. Default value: `true`
  ///
  /// `autoRecvVideo` `true`: video data will be automatically received; `false`: [startRemoteView]/[stopRemoteView] needs to be called to send or cancel a request. Default value: `true`
  ///
  /// **Note:** this API takes effect only if it is set before room entry.
  ///
  /// **Not supported on:**
  /// - web
  Future<void> setDefaultStreamRecvMode(
      bool
          autoRecvAudio, // true: audio data will be automatically received; false: `muteRemoteAudio` needs to be called to send or cancel a request. Default value: true
      bool
          autoRecvVideo // true: video data will be automatically received; false: `startRemoteView/stopRemoteView` needs to be called to send or cancel a request. Default value: true
      ) {
    return _cloudChannel!.invokeMethod('setDefaultStreamRecvMode', {
      "autoRecvAudio": autoRecvAudio,
      "autoRecvVideo": autoRecvVideo,
    });
  }

  /// Switch room. Allows users to quickly switch from one room to another
  ///
  /// After this API is called, the original room will be exited, and audio/video data sending in the original room and audio/video playback to all remote users will be stopped, but the local video preview will be continued. After new room entry succeeds, the original audio/video data sending status will be automatically restored.
  ///
  /// The API call result will be called back through [TRTCCloudListener.onSwitchRoom].
  ///
  /// **Not supported on:**
  /// - web
  Future<void> switchRoom(TRTCSwitchRoomConfig config) {
    return _cloudChannel!.invokeMethod('switchRoom', {
      "config": jsonEncode(config),
    });
  }

  /// Start pushing to Tencent Cloud CSS CDN
  ///
  /// This API specifies the `StreamId` corresponding to the current user's audio/video stream in Tencent Cloud CDN and thus specify the current user's CDN playback address.
  ///
  /// For example, if you use the following code to set the `StreamId` of the current user's primary image to `user_stream_001`, then the CDN playback address corresponding to the user's primary image is: `http://yourdomain/live/user_stream_001.flv`, where `yourdomain` is your playback domain name with an ICP filing. You can configure your playback domain name in the [CSS console](https://console.cloud.tencent.com/live). Tencent Cloud doesn't provide a default playback domain name.
  ///
  /// You can also specify the `streamId` when setting the [TRTCParams] parameter of [enterRoom] , which is the recommended approach.
  ///
  /// **Parameters:**
  ///
  /// `streamId` Custom stream ID.
  ///
  /// `streamType` Only [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG] and [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB] are supported.
  ///
  /// **Note:**
  ///
  /// You need to enable the "Enable Relayed Push" option on the "Function Configuration" page in the [TRTC console](https://console.cloud.tencent.com/trtc) first.
  ///
  /// *If you select "Specified stream for relayed push", you can use this API to push the corresponding audio/video stream to Tencent Cloud CDN and specify the entered stream ID.
  ///
  /// *If you select "Global auto-relayed push", you can use this API to adjust the default stream ID.
  ///
  /// **Not supported on:**
  /// - web
  Future<void> startPublishing(String streamId, int streamType) {
    return _cloudChannel!.invokeMethod('startPublishing', {
      "streamId": streamId,
      "streamType": streamType,
    });
  }

  /// Stop pushing to Tencent Cloud CSS CDN
  ///
  /// **Not supported on:**
  /// - web
  Future<void> stopPublishing() {
    return _cloudChannel!.invokeMethod('stopPublishing');
  }

  /// Start relaying to the live streaming CDN of another cloud
  ///
  /// The `startPublishCDNStream()` API is similar to [startPublishing()] , but it supports relaying to the live streaming CDN of another cloud.
  ///
  /// **Parameters:**
  ///
  /// `param` CDN relaying parameter. For more information, please see [TRTCPublishCDNParam]
  ///
  /// **Note:**
  ///
  /// Using [startPublishing()] to bind Tencent Cloud CSS CDN does not incur fees, while using `startPublishCDNStream()` to bind the live streaming CDN of another cloud incurs relaying fees.
  ///
  /// **Not supported on:**
  /// - web
  Future<void> startPublishCDNStream(TRTCPublishCDNParam param) {
    return _cloudChannel!.invokeMethod('startPublishCDNStream', {
      "param": jsonEncode(param),
    });
  }

  /// Stop relaying to non-Tencent Cloud address
  ///
  /// **Not supported on:**
  /// - web
  Future<void> stopPublishCDNStream() {
    return _cloudChannel!.invokeMethod('stopPublishCDNStream');
  }

  /// Set the layout and transcoding parameters of On-Cloud MixTranscoding
  ///
  /// If you have enabled the "Enable Relayed Push" option on the "Function Configuration" page in the TRTC console, then every channel in the room will have a default CSS CDN address.
  ///
  /// There may be multiple anchors in a room, each sending their own video and audio, but CDN audience needs only one live stream. Therefore, you need to mix multiple audio/video streams into one standard live stream, which requires mixtranscoding.
  ///
  /// When you call the `setMixTranscodingConfig()` API, the SDK will send a command to the Tencent Cloud transcoding server to combine multiple audio/video streams in the room into one stream. You can use the "mixUsers" parameter to set the position of each channel of image and specify whether to mix only audio. You can also set the encoding parameters of the mixed stream, including "videoWidth", "videoHeight", and "videoBitrate".
  ///
  /// For more information, please see [On-Cloud MixTranscoding](https://cloud.tencent.com/document/product/647/16827).
  ///
  /// **Parameters:**
  ///
  /// `config` For more information, please see the description of `TRTCTranscodingConfig` in `trtc_cloud_def.dart`. If `null` is passed in, On-Cloud MixTranscoding will be canceled.
  ///
  /// **Not supported on:**
  /// - web
  Future<void> setMixTranscodingConfig(TRTCTranscodingConfig? config) {
    if (kIsWeb) {
      return _cloudChannel!.invokeMethod(
          'setMixTranscodingConfig', jsonEncode(config));
    }
    return _cloudChannel!.invokeMethod('setMixTranscodingConfig', {
      "config": jsonEncode(config),
    });
  }

  /// Pause/Resume pushing local video data
  ///
  /// After the local video pushing is paused, other members in the room will receive the `onUserVideoAvailable(userId, false)` callback notification. After the local video pushing is resumed, other members in the room will receive the `onUserVideoAvailable(userId, true)` callback notification.
  ///
  /// **Parameters:**
  ///
  /// `mute` `true`: paused; `false`: resumed
  Future<void> muteLocalVideo(
      bool mute // true: blocked; false: enabled. Default value: false
      ) {
    return _cloudChannel!.invokeMethod('muteLocalVideo', {
      "mute": mute,
    });
  }

  /// Set an alternative image for when the local screen is paused to replace the black screen that users see when they enter a room without video streaming
  ///
  /// After the local video pushing is paused, the image set through this API will still be pushed
  ///
  /// **Parameters:**
  ///
  /// `assetUrl` can be an asset resource address defined in Flutter such as 'images/watermark_img.png' or an online image address
  ///
  /// `fps` Frame rate of the image set to be pushed. Minimum value: `5`. Maximum value: `20`. Default value: `10`
  ///
  /// **Not supported on:**
  /// - web
  /// - Windows
  Future<int?> setVideoMuteImage(
      String? assetUrl, // Resource address in `assets`
      int fps) async {
    String? imageUrl = assetUrl;
    String type = 'network'; // Online image by default
    if (assetUrl != null && assetUrl.indexOf('http') != 0) {
      type = 'local';
    }
    return _cloudChannel!.invokeMethod(
        'setVideoMuteImage', {"imageUrl": imageUrl, "type": type, "fps": fps});
  }

  /// Enable the local camera to preview the screen, and turn on video push streaming only when [enterRoom] is called (if it has been called, video push streaming will start automatically)
  ///
  /// When the first camera video frame starts to be rendered, you will receive the `onFirstVideoFrame(null)` callback in [TRTCCloudListener].
  ///
  /// **Parameters:**
  ///
  /// `frontCamera` `true`: front camera; `false`: rear camera.
  ///
  /// `viewId`   `viewId` generated by [TRTCCloudVideoView]
  ///
  /// **Platform not supported：**
  /// - macOS
  Future<void> startLocalPreview(bool frontCamera, int? viewId) {
    if (viewId == null) {
      return _cloudChannel!
          .invokeMethod('startLocalPreview', {"isFront": frontCamera});
    } else {
      return TRTCCloudVideoViewController(viewId)
          .startLocalPreview(frontCamera, _cloudChannel!.name);
    }
  }

  /// Update the preview image of local video
  ///
  /// **Note:** When viewtype is [TRTCCloudDef.TRTC_VideoView_TextureView] is valid for Android
  ///
  /// **Parameters:**
  ///
  /// `viewId`: Control that carries the video image
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> updateLocalView(int viewId) {
    return TRTCCloudVideoViewController(viewId).updateLocalView(viewId, _cloudChannel!.name);
  }

  /// Update the window of remote video image
  ///
  /// **Note:** When viewtype is [TRTCCloudDef.TRTC_VideoView_TextureView] is valid for Android
  ///
  /// **Parameters:**
  ///
  /// `userId`:   `userId` of the specified remote user
  ///
  /// `streamType`: Video stream type of the `userId` specified for watching:
  ///
  /// `viewId`: Control that carries the video image
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> updateRemoteView(String userId, int streamType, int viewId) {
    return TRTCCloudVideoViewController(viewId)
        .updateRemoteView(userId, streamType, viewId, _cloudChannel!.name);
  }

  /// Stop local video capturing and preview
  Future<void> stopLocalPreview() {
    return _cloudChannel!.invokeMethod('stopLocalPreview');
  }

  /// Display remote video image or substream and bind the video rendering control at the same time.
  ///
  /// **Parameters:**
  ///
  /// `userId`:   `userId` of the specified remote user
  ///
  /// `streamType`: Video stream type of the `userId` specified for watching:
  ///
  ///* HD big image: [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]
  ///
  ///* Smooth big image: [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL]
  ///
  ///* Substream (screen sharing): [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB]
  ///
  /// `viewId`:   `viewId` generated by [TRTCCloudVideoView]
  ///
  /// **Platform not supported：**
  /// - macOS
  Future<void> startRemoteView(String userId, int streamType, int? viewId) {
    if (viewId == null) {
      return _cloudChannel!.invokeMethod(
          'startRemoteView', {"userId": userId, "streamType": streamType});
    } else {
      return TRTCCloudVideoViewController(viewId)
          .startRemoteView(userId, streamType, _cloudChannel!.name);
    }
  }

  /// Stop subscribing to remote user's video stream and release rendering control
  ///
  /// Video stream type of the `userId` specified for stopping watching:
  ///
  /// **Parameters:**
  ///
  /// `userId`   User ID
  ///
  /// `streamType`:
  ///
  ///* HD big image: [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]
  ///
  ///* Smooth big image: [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL]
  ///
  ///* Substream (screen sharing): [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB]
  ///
  /// **Platform not supported：**
  /// - macOS
  Future<void> stopRemoteView(String userId, int streamType) {
    return _cloudChannel!.invokeMethod(
        'stopRemoteView', {"userId": userId, "streamType": streamType});
  }

  /// Stop subscribing to all remote users' video streams and release all rendering resources
  ///
  /// **Note:** if there is a screen sharing image, it will be stopped together with other remote video images.
  Future<void> stopAllRemoteView() {
    return _cloudChannel!.invokeMethod('stopAllRemoteView');
  }

  /// Pause/Resume subscribing to remote user's video stream
  ///
  /// This API only pauses/resumes receiving the specified user's video stream but does not release displaying resources; therefore, the video image will freeze at the last frame before it is called.
  ///
  /// **Parameters:**
  ///
  /// `userId`: Remote user ID
  ///
  /// `mute`: Whether to pause receiving
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> muteRemoteVideoStream(String userId, bool mute) {
    return _cloudChannel!.invokeMethod('muteRemoteVideoStream', {
      "userId": userId,
      "mute": mute,
    });
  }

  /// Pause/Resume subscribing to all remote users' video streams
  ///
  /// This API only pauses/resumes receiving all users' video streams but does not release displaying resources; therefore, the video image will freeze at the last frame before it is called.
  ///
  /// **Parameters:**
  ///
  /// `mute`: Whether to pause receiving
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> muteAllRemoteVideoStreams(bool mute // 是否停止接收
      ) {
    return _cloudChannel!.invokeMethod('muteAllRemoteVideoStreams', {
      "mute": mute,
    });
  }

  /// Set the encoding parameters of video encoder
  ///
  /// This setting can determine the quality of image viewed by remote users, which is also the image quality of on-cloud recording files.
  ///
  /// **Parameters:**
  ///
  /// `param`: Video encoding parameters. For more information, please see the definition of [TRTCVideoEncParam]
  Future<void> setVideoEncoderParam(
      TRTCVideoEncParam
          param // 视频编码参数，详情请参考 TRTCCloudDef.java 中的 TRTCVideoEncParam 定义。
      ) {
    if (kIsWeb) {
      return _cloudChannel!.invokeMethod('setVideoEncoderParam', jsonEncode(param));
    }
    return _cloudChannel!.invokeMethod('setVideoEncoderParam', {
      "param": jsonEncode(param),
    });
  }

  /// Set network quality control parameters
  ///
  /// These settings determine the bandwidth limit practices of the SDK in various network conditions (e.g., whether to "ensure definition" or "ensure smoothness" on a weak network)
  ///
  /// **Parameters:**
  ///
  /// `param`: QoS parameters. For more information, please see the definition of [TRTCNetworkQosParam] in `trtc_cloud_def.dart`
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setNetworkQosParam(TRTCNetworkQosParam param) {
    return _cloudChannel!
        .invokeMethod('setNetworkQosParam', {"param": jsonEncode(param)});
  }

  /// Set the rendering mode of local image
  ///
  /// **Parameters:**
  ///
  /// `renderParams`: rendering parameters (fill mode, rotation angle, mirror mode, etc.). For more information, please see the definition of the [TRTCRenderParams] parameter in `trtc_cloud_def.dart`
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setLocalRenderParams(TRTCRenderParams renderParams) {
    Store.sharedInstance().setLocalTextureParam(renderParams);
    return _cloudChannel!.invokeMethod('setLocalRenderParams', {
      "param": jsonEncode(renderParams),
    });
  }

  /// Set remote image parameters
  ///
  /// **Parameters:**
  ///
  /// `userId`:   User ID
  ///
  /// `streamType`:  Video stream type
  ///
  ///* HD big image: [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]
  ///
  ///* Smooth big image: [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL]
  ///
  ///* Substream (screen sharing): [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB]
  ///
  /// `renderParams`: rendering parameters (fill mode, rotation angle, mirror mode, etc.). For more information, please see the definition of the [TRTCRenderParams] parameter in `trtc_cloud_def.dart`
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setRemoteRenderParams(
      String userId, int streamType, TRTCRenderParams renderParams) {
    if(Store.sharedInstance().userRenderParamsMap[userId] != null) {
      Store.sharedInstance().setUserRenderParamsMap(userId, renderParams);
    }
    return _cloudChannel!.invokeMethod('setRemoteRenderParams', {
      "userId": userId,
      "streamType": streamType,
      "param": jsonEncode(renderParams),
    });
  }

  /// Set the direction of image output by video encoder (i.e., video image viewed by remote user and recorded by server)
  ///
  /// When an Android phone or tablet is rotated 180 degrees, as the capture direction of the camera does not change, the video image viewed by remote users will be upside-down. In this case, you can call this API to rotate the image output by the SDK to remote users 180 degrees, so that remote users can view the normal image.
  ///
  /// **Note:** the SDK will enable the G-sensor by default, and this API won't take effect in this case. It will work only after G-sensor is disabled.
  ///
  /// **Parameters:**
  ///
  /// `rotation` Clockwise rotation angle. Currently, only 0 degrees and 180 degrees are supported:
  ///
  /// [TRTCCloudDef.TRTC_VIDEO_ROTATION_0] : no rotation (default value); [TRTCCloudDef.TRTC_VIDEO_ROTATION_180] : clockwise rotation by 180 degrees
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setVideoEncoderRotation(
      int rotation // Currently, rotation angles of `TRTC_VIDEO_ROTATION_0` and `TRTC_VIDEO_ROTATION_180` are supported. Default
      ) {
    return _cloudChannel!.invokeMethod('setVideoEncoderRotation', {
      "rotation": rotation,
    });
  }

  /// Set the mirror mode of image output by encoder
  ///
  /// This API does not change the preview image of the local camera; instead, it changes the video image viewed by the remote user (and recorded by the server).
  ///
  /// **Parameters:**
  ///
  /// `mirror` `true`: mirrored; `false`: not mirrored. Default value: `false`
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setVideoEncoderMirror(
      bool mirror // true: mirrored; false: not mirrored. Default value: false
      ) {
    return _cloudChannel!.invokeMethod('setVideoEncoderMirror', {
      "mirror": mirror,
    });
  }

  /// Set the adaptation mode of the G-sensor
  ///
  /// **Parameters:**
  ///
  /// `mode` G-sensor mode:
  ///
  /// [TRTCCloudDef.TRTC_GSENSOR_MODE_DISABLE] : disable the G-sensor
  ///
  /// [TRTCCloudDef.TRTC_GSENSOR_MODE_UIAUTOLAYOUT] : enable the G-sensor. The SDK will not automatically adjust the screen direction of the local view based on the gyroscope; instead, it will be taken care of by the automatic layout feature of the Android system (this requires the G-sensor adaptation option to be enabled on your application UI).
  ///
  /// [TRTCCloudDef.TRTC_GSENSOR_MODE_UIFIXLAYOUT] : enable the G-sensor. The SDK will automatically adjust the screen direction of the local view based on the gyroscope.
  ///
  /// **Platform not supported：**
  /// - web
  /// - Windows
  Future<void> setGSensorMode(
      int mode // G-sensor mode. For more information, please see the definition of `TRTC_GSENSOR_MODE`. Default value: TRTC_GSENSOR_MODE_UIFIXLAYOUT
      ) {
    return _cloudChannel!.invokeMethod('setGSensorMode', {
      "mode": mode,
    });
  }

  /// Enable dual-channel encoding mode for large and small images, which is convenient for users in different network conditions to subscribe to different images
  ///
  /// If the current user is a major role (such as anchor, teacher, or host) in the room and uses PC or Mac, this mode can be enabled. In this mode, the current user will output two channels of video streams, i.e., **HD** and **Smooth**, at the same time (only one channel of audio stream will be output though). This mode will consume more network bandwidth and CPU computing resources.
  ///
  /// As for remote audience in the same room:
  ///
  ///* If the downstream network is good, they can select the **HD big image**.
  ///* If the downstream network is poor, they can select the **Smooth small image**.
  ///
  /// **Note:** dual-channel encoding will consume more CPU resources and network bandwidth; therefore, this feature can be enabled on macOS, Windows, or high-spec tablets, but should not be enabled on phones.
  ///
  /// **Parameters:**
  ///
  /// `enable` Whether to enable small image encoding. Default value: `false`
  ///
  /// `smallVideoEncParam` Video parameters of small image stream. For more information, please see the definition of [TRTCVideoEncParam]
  ///
  /// **Returned value**:
  ///
  /// `0`: success; `-1`: the big image is already of the lowest image quality
  ///
  /// **Platform not supported：**
  /// - Windows
  Future<int?> enableEncSmallVideoStream(
      bool
          enable, // Whether to enable small image encoding. Default value: false
      TRTCVideoEncParam
          smallVideoEncParam // Video parameters of small image stream
      ) {
    return _cloudChannel!.invokeMethod('enableEncSmallVideoStream', {
      "enable": enable,
      "smallVideoEncParam": jsonEncode(smallVideoEncParam),
    });
  }

  /// Select whether to view the big or small image of the specified `uid`
  ///
  /// **Note:**
  ///* To implement this feature, the dual-channel encoding mode must be enabled by the `uid` through [enableEncSmallVideoStream]; otherwise, this operation will not take effect.
  ///* If this API is not called to set the image, the image watched through [startRemoteView] is the big image by default.
  ///
  /// **Parameters:**
  ///
  /// `userId`: User ID
  ///
  /// `streamType`:  Video stream type, i.e., big image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]) or small image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL]). Default value: big image
  ///
  /// **Platform not supported：**
  /// - web
  Future<int?> setRemoteVideoStreamType(
      String userId, // User ID
      int streamType // Video stream type, i.e., big image or small image. Default value: big image
      ) {
    return _cloudChannel!.invokeMethod('setRemoteVideoStreamType', {
      "userId": userId,
      "streamType": streamType,
    });
  }

  /// Screencapture video
  ///
  /// This API takes screenshots of the local, remote primary stream, or remote substream image.
  ///
  /// **Parameters:**
  ///
  /// `userId`: User ID. `null` indicates to screencapture the local video. For the local video, only the camera image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]) can be screencaptured.
  ///
  /// `streamType`: Video stream type. Camera image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]) and screen sharing image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB]) are supported.
  ///
  /// `path`:   This path must be accurate to the file name and extension. The extension determines the format of the image. Currently, supported formats include PNG, JPG, and WEBP. For example, if the specified path is `path/to/test.png`, then a PNG image will be generated. Please specify a valid path with read/write permissions; otherwise, the image file cannot be generated.
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> snapshotVideo(
    String?
        userId, // User ID. `null` indicates to screencapture the local video. For the local video, only the camera image (TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG) can be screencaptured.
    int streamType, // Video stream type. Camera image (TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG) and screen sharing image (TRTCCloudDef#TRTC_VIDEO_STREAM_TYPE_SUB) are supported.
    int sourceType, // 0-stream  1-view
    String path, // Screenshot storage address
  ) {
    return _cloudChannel!.invokeMethod('snapshotVideo', {
      "userId": userId,
      "streamType": streamType,
      "path": path,
      "sourceType": sourceType
    });
  }

  /// Enables local microphone capture and publishes the audio stream to the current room with the ability to set the sound quality.
  ///
  /// This function will start mic capturing and transfer audio data to other users in the room. The SDK doesn't enable local audio capturing and upstreaming by default, and you need to call this function to enable it; otherwise, other users in the room cannot hear you.
  ///
  /// The higher the sound quality of the anchor, the better the sound effect to the audience, but the higher the required bandwidth, so there may be lags if the bandwidth is limited.
  ///
  /// **Parameters:**
  ///
  /// * [TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH], Smooth: sample rate: 16 kHz; mono channel; audio bitrate: 16 Kbps. This is suitable for audio call scenarios, such as online meeting and audio call.
  /// * [TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT], Default: sample rate: 48 kHz; mono channel; audio bitrate: 50 Kbps. This is the default sound quality of the SDK and recommended if there are no special requirements.
  /// * [TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC], HD: sample rate: 48 kHz; dual channel + full band; audio bitrate: 128 Kbps. This is suitable for scenarios where Hi-Fi music transfer is required, such as karaoke and music live streaming.
  Future<void> startLocalAudio(int quality) {
    return _cloudChannel!.invokeMethod('startLocalAudio', {"quality": quality});
  }

  /// Disable local audio capturing and upstreaming
  ///
  /// When local audio capturing and upstreaming is disabled, other members in the room will receive the `onUserAudioAvailable(false)` callback notification.
  Future<void> stopLocalAudio() {
    return _cloudChannel!.invokeMethod('stopLocalAudio');
  }

  /// Mute/Unmute local audio
  ///
  /// After local audio is muted, other members in the room will receive the `onUserAudioAvailable(userId, false)` callback notification. After local audio is unmuted, other members in the room will receive the `onUserAudioAvailable(userId, true)` callback notification.
  ///
  /// Different from [stopLocalAudio], [muteLocalAudio] doesn't stop sending audio/video data; instead, it continues to send mute packets with extremely low bitrate. Since some video file formats such as MP4 have a high requirement for audio continuity, an MP4 recording file cannot be played back smoothly if [stopLocalAudio] is used. Therefore, [muteLocalAudio] is recommended in scenarios where the requirement for recording quality is high, so as to record MP4 files with better compatibility.
  ///
  /// **Parameters:**
  ///
  /// `mute` `true`: muted; `false`: unmuted
  Future<void> muteLocalAudio(bool mute // true：屏蔽；false：开启，默认值：false。
      ) {
    return _cloudChannel!.invokeMethod('muteLocalAudio', {
      "mute": mute,
    });
  }

  /// Mute/Unmute the specified remote user's audio
  ///
  /// **Parameters:**
  ///
  /// `userId` Remote user ID
  ///
  /// `mute` `true`: muted; `false`: unmuted
  ///
  /// **Note:** when the specified user is muted, the system will stop receiving and playing back the user's remote audio stream. When the user is unmuted, the system will automatically pull and play back the user's remote audio stream.
  Future<void> muteRemoteAudio(
      String userId, // Remote user ID
      bool mute // true: muted; false: not muted
      ) {
    return _cloudChannel!.invokeMethod('muteRemoteAudio', {
      "userId": userId,
      "mute": mute,
    });
  }

  /// Mute/Unmute all users' audio
  ///
  /// **Parameters:**
  ///
  /// `mute` `true`: muted; `false`: unmuted
  ///
  /// **Note:** when all users are muted, the system will stop receiving and playing back all users' remote audio streams. When all users are unmuted, the system will automatically pull and play back all users' remote audio streams.
  Future<void> muteAllRemoteAudio(bool mute // true: muted; false: not muted
      ) {
    return _cloudChannel!.invokeMethod('muteAllRemoteAudio', {
      "mute": mute,
    });
  }

  /// Set the playback volume of the specified remote user
  ///
  /// **Parameters:**
  ///
  /// `userId`: Remote user ID
  ///
  /// `volume`: Volume. Value range: `0`–`100`
  Future<void> setRemoteAudioVolume(
      String userId, // Remote user ID
      int volume // Volume. Value range: 0–100
      ) {
    return _cloudChannel!.invokeMethod('setRemoteAudioVolume', {
      "userId": userId,
      "volume": volume,
    });
  }

  /// Set the capturing volume of local audio
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. Value range: `0`–`100`
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setAudioCaptureVolume(
      int volume // volume Volume. Value range: 0–100. Default value: 100
      ) {
    return _cloudChannel!.invokeMethod('setAudioCaptureVolume', {
      "volume": volume,
    });
  }

  /// Get the capturing volume of local audio
  ///
  /// **Platform not supported：**
  /// - web
  Future<int?> getAudioCaptureVolume() {
    return _cloudChannel!.invokeMethod('getAudioCaptureVolume');
  }

  /// Set the playback volume of remote audio
  ///
  /// This function controls the volume of the sound ultimately delivered to the system for playback. It affects the volume of the recorded local audio file but not the volume of in-ear monitoring.
  ///
  /// **Parameters:**
  ///
  /// `volume` Volume. Value range: `0`–`100`
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setAudioPlayoutVolume(
      int volume // volume Volume. Value range: 0–100. Default value: 100
      ) {
    return _cloudChannel!.invokeMethod('setAudioPlayoutVolume', {
      "volume": volume,
    });
  }

  /// Get the playback volume of remote audio
  ///
  /// **Platform not supported：**
  /// - web
  Future<int?> getAudioPlayoutVolume() {
    return _cloudChannel!.invokeMethod('getAudioPlayoutVolume');
  }

  /// Enable volume reminder
  ///
  /// After this feature is enabled, the evaluation result of the volume by the SDK will be obtained in [TRTCCloudListener.onUserVoiceVolume]. To enable this feature, call this API before calling [startLocalAudio()].
  ///
  /// **Parameters:**
  ///
  /// `intervalMs` determines the interval in ms for triggering the `onUserVoiceVolume` callback. The minimum interval is 100 ms. If the value is smaller than 0, the callback will be disabled. We recommend you set this parameter to 300 ms. For detailed callback rules, please see the description of `onUserVoiceVolume`.
  Future<void> enableAudioVolumeEvaluation(
      int intervalMs // Determines the interval in ms for triggering the `onUserVoiceVolume` callback. The minimum interval is 100 ms. If the value is smaller than 0, the callback will be disabled. We recommend you set this parameter to 300 ms. For detailed callback rules, please see the description of `onUserVoiceVolume`.
      ) {
    return _cloudChannel!.invokeMethod('enableAudioVolumeEvaluation', {
      "intervalMs": intervalMs,
    });
  }

  /// Starts audio recording, mixing and recording all current audio into one file.
  ///
  /// After this API is called, the SDK will record all audios (such as local audio, remote audio, and background music) in the current call to a file. No matter whether room entry is performed, this API will take effect once called. If audio recording is still ongoing when [exitRoom] is called, it will stop automatically.
  ///
  /// **Parameters:**
  ///
  /// [TRTCAudioRecordingParams]  Audio recording parameters
  ///
  /// **Returned value**:
  ///
  /// `0`: success; `-1`: audio recording has been started; `-2`: failed to create file or directory; `-3`: the audio format of the specified file extension is not supported; `-1001`: incorrect parameter
  ///
  /// **Platform not supported：**
  /// - web
  Future<int?> startAudioRecording(TRTCAudioRecordingParams param) async {
    return _cloudChannel!.invokeMethod('startAudioRecording', {
      "param": jsonEncode(param),
    });
  }

  /// Stop audio recording
  ///
  /// If audio recording is still ongoing when [exitRoom] is called, it will stop automatically.
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> stopAudioRecording() {
    return _cloudChannel!.invokeMethod('stopAudioRecording');
  }

  /// Start local media recording with both audio and video data
  ///
  /// This API records the audio/video content during live streaming into a local file.
  ///
  /// **Parameters:**
  ///
  /// `params` Recording parameters. For more information, please see [TRTCLocalRecordingParams]
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> startLocalRecording(TRTCLocalRecordingParams param) async {
    return _cloudChannel!.invokeMethod('startLocalRecording', {
      "param": jsonEncode(param),
    });
  }

  /// Stop local media recording
  ///
  /// If a recording task has not been stopped through this API before room exit, it will be automatically stopped after room exit.
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> stopLocalRecording() {
    return _cloudChannel!.invokeMethod('stopLocalRecording');
  }

  /// Enable system audio capturing
  ///
  /// **Platform not supported：**
  /// - web
  /// - iOS
  Future<void> startSystemAudioLoopback([String path = '']) {
    return _cloudChannel!.invokeMethod('startSystemAudioLoopback', {
      "path": path,
    });
  }

  /// Stop system audio capturing
  ///
  ///  **Platform not supported：**
  ///  - web
  ///  - iOS
  Future<void> stopSystemAudioLoopback() {
    return _cloudChannel!.invokeMethod('stopSystemAudioLoopback');
  }

  /// Get a device management module for managing audio and video related devices such as cameras, microphones, and speakers
  ///
  /// **Platform not supported：**
  /// - web
  TXDeviceManager getDeviceManager() {
    if (_txDeviceManager == null) {
      _cloudChannel!.invokeMethod('getDeviceManager');
      _txDeviceManager = new TXDeviceManager(_cloudChannel!);
    }
    return _txDeviceManager!;
  }

  /// Get the beauty filter management object, you can modify the beauty, filter, redness and other parameters
  ///
  /// **Platform not supported：**
  /// - web
  /// - Windows
  TXBeautyManager getBeautyManager() {
    if (_txBeautyManager == null) {
      _cloudChannel!.invokeMethod('getBeautyManager');
      _txBeautyManager = new TXBeautyManager(_cloudChannel!);
    }
    return _txBeautyManager!;
  }

  /// Adds a watermark to the specified location
  ///
  /// The watermark position is determined by the `x`, `y`, and `width` parameters.
  ///* `x`: X coordinate of watermark, which is a floating point number between 0 and 1.
  ///* `y`: Y coordinate of watermark, which is a floating point number between 0 and 1.
  ///* `width`: width of watermark, which is a floating point number between 0 and 1.
  ///* `height`: it does not need to be set. The SDK will automatically calculate it according to the watermark image's aspect ratio.
  ///
  /// For example, if the current encoding resolution is 540x960 and `(x, y, width)` is set to `(0.1, 0.1, 0.2)`, then the coordinates of the top-left point of the watermark will be `(540 * 0.1, 960 * 0.1)`, i.e., `(54, 96)`, the watermark width will be `540 * 0.2 = 108 px`, and the height will be calculated automatically.
  ///
  /// **Parameters:**
  ///
  /// `assetUrl` can be an asset resource address defined in Flutter such as 'images/watermark_img.png' or an online image address
  ///
  /// `streamType` `setWatermark` needs to be called twice if the screen sharing channel also requires a watermark. For more information, please see [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG]
  ///
  /// `x` Unified X coordinate of the watermark position. Value range: `[0,1]`
  ///
  /// `y` Unified Y coordinate of the watermark position. Value range: `[0,1]`
  ///
  /// `width` Unified width of the watermark. Value range: `[0,1]`
  ///
  /// **Platform not supported：**
  /// - web
  /// - Windows
  Future<void> setWatermark(
      String assetUrl, // Resource address in `assets`
      int streamType,
      double x,
      double y,
      double width) async {
    String imageUrl = assetUrl;
    String type = 'network'; // Online image by default
    if (assetUrl.indexOf('http') != 0) {
      type = 'local';
    }
    return _cloudChannel!.invokeMethod('setWatermark', {
      "type": type,
      "imageUrl": imageUrl,
      "streamType": streamType,
      "x": x.toString(),
      "y": y.toString(),
      "width": width.toString()
    });
  }

  /// Enumerate shareable screens and windows (this interface only supports Windows)
  /// 
  /// When you connect the screen sharing function of the desktop system, 
  /// you generally need to display an interface for selecting the sharing target, 
  /// so that users can use this interface to choose whether to share the entire screen or a certain window.
  /// 
  /// Through this interface, you can query the ID, name and thumbnail of the windows available for sharing in the current system.
  ///
  /// **Parameters:**
  /// 
  /// `thumbnailWidth` Specify the width of the window shrinkage of the window.
  /// 
  /// `thumbnailHeight` Specify the height of the slight diagram of the window to be obtained.
  /// 
  /// `iconWidth` Specify the width of the window icon to be obtained.
  /// 
  /// `iconHeight` Specify the height of the window icon to be obtained.
  Future<TRTCScreenCaptureSourceList> getScreenCaptureSources({
    required int thumbnailWidth,
    required int thumbnailHeight,
    required int iconWidth,
    required int iconHeight,}) async {
    dynamic sourceInfoResult = await _cloudChannel!.invokeMethod('getScreenCaptureSources', {
      "thumbnailWidth": thumbnailWidth,
      "thumbnailHeight": thumbnailHeight,
      "iconWidth": iconWidth,
      "iconHeight": iconHeight,
    });
    Map<String, dynamic> sourceInfoMap;
    if (sourceInfoResult is Map<Object?, Object?>) {
      sourceInfoMap = sourceInfoResult.cast<String, dynamic>();
    } else {
      throw Exception('Unexpected result type: ${sourceInfoResult.runtimeType}');
    }
    return TRTCScreenCaptureSourceList.fromJson(sourceInfoMap);
  }

  /// Select the screen or window you want to share (this interface only supports Windows)
  /// 
  /// After you obtain the screens and windows that can be shared through [getScreenCaptureSources],
  /// you can call this interface to select the target screen or window you want to share.
  /// 
  /// During the screen sharing process, 
  /// you can also call this interface at any time to switch the sharing target.
  ///
  /// Support the following four cases:
  /// - Share the entire screen: Type in SourceInfolist is Source of Screen, Capture is set to {0, 0, 0, 0}
  /// - Share designated area: Type in SourceInfolist is Source of Screen.
  /// - Share the entire window: Type in SourceInfolist is Source of Window, Capture is set to {0, 0, 0, 0}
  /// - Sharing window area: Type in SourceInfolist is Source of Window. 
  /// 
  /// **Parameters:**
  /// 
  /// `sourceInfo` Specify the sharing source
  /// 
  /// `property` Specify the attributes of the screen sharing target, including capture mouse, highlight capture window, etc. For details, refer to TRTCScreenCaptureProperty definition
  /// 
  /// `captureLeft` & `captureTop` & `captureRight` & `captureBottom` Specify the capture area
  Future<void> selectScreenCaptureTarget(TRTCScreenCaptureSourceInfo sourceInfo, TRTCScreenCaptureProperty property, {
    int captureLeft = 0,
    int captureTop = 0,
    int captureRight = 0,
    int captureBottom = 0,
  }) async {
    return await _cloudChannel!.invokeMethod('selectScreenCaptureTarget', {
      "sourceInfo": sourceInfo.toJson(),
      "property": property.toJson(),
      "captureLeft": captureLeft,
      "captureTop": captureTop,
      "captureRight": captureRight,
      "captureBottom": captureBottom,
    });
  }

  /// Start desktop screen sharing, grab what's on the user's screen and share it with other users in the same room
  ///
  /// **Parameters:**
  ///
  /// `encParams` Screen sharing encoding parameters. We recommend you use the above configuration. If you set `encParams` to `nil`, the encoding parameter settings before `startScreenCapture` is called will be used.
  ///
  /// `appGroup` This parameter takes effect only for iOS and can be ignored for Android. It is the `Application Group Identifier` shared by the primary app and broadcast process
  ///
  /// If `appGroup` is empty on iOS, it will only become in-app screen sharing, and it takes effect only on iOS 13.0 and above
  ///
  /// [Screen sharing](https://cloud.tencent.com/document/product/647/45751)
  ///
  /// **Platform not supported：**
  /// - macOS
  Future<void> startScreenCapture(int streamType, TRTCVideoEncParam encParams,
      {String shareUserId = '',
      String shareUserSig = '',
      String appGroup = ''}) {
    if (kIsWeb) {
      return _cloudChannel!.invokeMethod('startScreenCapture', {
        "shareUserId": shareUserId,
        "shareUserSig": shareUserSig,
        "streamType": streamType
      });
    }
    if (!kIsWeb && Platform.isAndroid) {
      return _cloudChannel!.invokeMethod('startScreenCapture',
          {"encParams": jsonEncode(encParams), "streamType": streamType});
    }
    if (!kIsWeb && Platform.isIOS && appGroup != '') {
      return _cloudChannel!.invokeMethod('startScreenCaptureByReplaykit', {
        "encParams": jsonEncode(encParams),
        "appGroup": appGroup,
        "streamType": streamType,
      });
    } else if (!kIsWeb && Platform.isIOS && appGroup == '') {
      return _cloudChannel!.invokeMethod('startScreenCaptureInApp', {
        "encParams": jsonEncode(encParams),
        "streamType": streamType,
      });
    }
    return _cloudChannel!.invokeMethod('startScreenCapture',
        {"streamType": streamType, "encParams": jsonEncode(encParams)});
  }

  /// Stop screen capture
  Future<void> stopScreenCapture() {
    return _cloudChannel!.invokeMethod('stopScreenCapture');
  }

  /// Pause screen sharing
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> pauseScreenCapture() {
    return _cloudChannel!.invokeMethod('pauseScreenCapture');
  }

  /// Resume screen sharing
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> resumeScreenCapture() {
    return _cloudChannel!.invokeMethod('resumeScreenCapture');
  }

  Future<void> setSubStreamEncoderParam(TRTCVideoEncParam param) {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('setSubStreamEncoderParam', 
        {"param": jsonEncode(param)},
      );
    }
    return Future.value();
  }

  Future<void> setSubStreamMixVolume(int volume) {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('setSubStreamMixVolume', 
        {"volume": volume},
      );
    }
    return Future.value(); 
  }

  Future<void> addExcludedShareWindow(int windowId) {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('addExcludedShareWindow', 
        {"windowId": windowId},
      );
    }
    return Future.value();
  }

  Future<void> removeExcludedShareWindow(int windowId) {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('removeExcludedShareWindow', 
        {"windowId": windowId},
      );
    }
    return Future.value();
  }

  Future<void> removeAllExcludedShareWindow() {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('removeAllExcludedShareWindow');
    }
    return Future.value();
  }

  Future<void> addIncludedShareWindow(int windowId) {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('addIncludedShareWindow', 
        {"windowId": windowId},
      );
    }
    return Future.value();
  }

  Future<void> removeIncludedShareWindow(int windowId) {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('removeIncludedShareWindow', 
        {"windowId": windowId},
      );
    }
    return Future.value();
  }

  Future<void> removeAllIncludedShareWindow() {
    if (Platform.isWindows) {
      return _cloudChannel!.invokeMethod('removeAllIncludedShareWindow');
    }
    return Future.value();
  }

  /// Get sound effect management class `TXAudioEffectManager`, which is used to set the background music, short sound effects and life effects.
  ///
  /// **Platform not supported：**
  /// - web
  TXAudioEffectManager getAudioEffectManager() {
    if (_audioEffectManager == null) {
      _cloudChannel!.invokeMethod('getAudioEffectManager');
      if (listener == null) {
        listener = TRTCCloudListenerWrapper(_cloudChannel!);
      }
      _audioEffectManager = new TXAudioEffectManager(_cloudChannel!, listener);
    }
    return _audioEffectManager!;
  }

  /// Send a customized message to all users in the room using a UDP channel
  ///
  /// This API can be used to broadcast your custom data to other users in the room though the audio/video data channel. Due to reuse of this channel, please strictly control the frequency of sending custom messages and message size; otherwise, the quality control logic of the audio/video data will be affected, causing uncertain issues.
  ///
  /// **Parameters:**
  ///
  /// `cmdID` Message ID. Value range: `1`–`10`.
  ///
  /// `data` Message to be sent, which can contain up to 1 KB (1,000 bytes) of data
  ///
  /// `reliable` Whether reliable sending is enabled; if so, the recipient needs to temporarily store the data of a certain period to wait for re-sending, which will cause certain delay
  ///
  /// `ordered` Whether orderly sending is enabled, i.e., whether the data should be received in the same order in which it is sent; if so, the recipient needs to temporarily store and sort messages, which will cause certain delay.
  ///
  /// **Returned value**:
  ///
  /// `true`: sent the message successfully; `false`: failed to send the message.
  ///
  /// This API has the following restrictions:
  ///
  /// * Up to 30 messages can be sent per second to all users in the room (this is not supported for web and mini program currently).
  ///
  /// * A packet can contain up to 1 KB of data; if the threshold is exceeded, the packet is very likely to be discarded by the intermediate router or server.
  ///
  /// * A client can send up to 8 KB of data in total per second.
  ///
  /// * `reliable` and `ordered` must be set to the same value (`true` or `false`) and cannot be set to different values currently.
  ///
  /// * We strongly recommend you use different `cmdID` values for messages of different types. This can reduce message delay when orderly sending is required.
  ///
  /// **Platform not supported：**
  /// - web
  Future<bool?> sendCustomCmdMsg(
      int cmdID, String data, bool reliable, bool ordered) {
    return _cloudChannel!.invokeMethod('sendCustomCmdMsg', {
      "cmdID": cmdID,
      "data": data,
      "reliable": reliable,
      "ordered": ordered,
    });
  }

  /// Use SEI channel to send custom message to all users in room
  ///
  /// Different from how [sendCustomCmdMsg] works, [sendSEIMsg] directly inserts data into the video data header. Therefore, even if the video frames are relayed to CSS CDN, the data will always exist. As the data needs to be embedded in the video frames, we recommend you keep the data size under several bytes.
  ///
  /// The most common use is to embed the custom timestamp into video frames through `sendSEIMsg`. The biggest benefit of this scheme is that it can implement a perfect alignment between messages and video image.
  ///
  /// **Parameters:**
  ///
  /// `data` Data to be sent, which can contain up to 1 KB (1,000 bytes) of data
  ///
  /// `repeatCount` Data sending count
  ///
  /// **Returned value**:
  ///
  /// `true`: the message is allowed and will be sent to subsequent video frames; `false`: the message is not allowed to be sent
  ///
  /// This API has the following restrictions:
  ///
  /// The data will not be instantly sent after this API is called; instead, it will be inserted into the next video frame after the API call.
  ///
  /// Up to 30 messages can be sent per second to all users in the room (this limit is shared with [sendCustomCmdMsg]).
  ///
  /// Each packet can be up to 1 KB (this limit is shared with [sendCustomCmdMsg]). If a large amount of data is sent, the video bitrate will increase, which may reduce the video quality or even cause lagging.
  ///
  /// Each client can send up to 8 KB of data in total per second (this limit is shared with [sendCustomCmdMsg]).
  ///
  /// If multiple times of sending is required (i.e., `repeatCount` > 1), the data will be inserted into subsequent `repeatCount` video frames in a row for sending, which will increase the video bitrate.
  ///
  /// If `repeatCount` is greater than 1, the data will be sent for multiple times, and the same message may be received multiple times in the [TRTCCloudListener.onRecvSEIMsg]  callback; therefore, deduplication is required.
  ///
  /// **Platform not supported：**
  /// - web
  /// - Windows
  Future<bool?> sendSEIMsg(String data, int repeatCount) {
    return _cloudChannel!
        .invokeMethod('sendSEIMsg', {"data": data, "repeatCount": repeatCount});
  }

  /// @nodoc
  @Deprecated("This interface is deprecated. It is recommended to use the startSpeedTestWithParams interface.")
  Future<void> startSpeedTest(
      int sdkAppId, // Application ID
      String userId, // User ID
      String userSig // User signature
      ) {
    return _cloudChannel!.invokeMethod('startSpeedTest', {
      "sdkAppId": sdkAppId,
      "userId": userId,
      "userSig": userSig,
    });
  }

  /// Start a speed test (recommended before entering the room)
  ///
  /// **Note:**
  /// - the speed test will incur small basic service fees. For more information, please see [Billing Overview](https://trtc.io/document/34610?lang=en&pg=#basic-services).
  /// - Please perform the Network speed test before room entry, because if performed after room entry, the test will affect the normal audio/video transfer, and its result will be inaccurate due to interference in the room.
  /// - Only one network speed test task is allowed to run at the same time.
  ///
  /// **Parameters:**
  ///
  /// `params` Speed test options
  ///
  /// **Return value:**
  ///
  /// interface call result, <0: failure
  Future<int?> startSpeedTestWithParams(TRTCSpeedTestParams params) {
    return _cloudChannel!.invokeMethod('startSpeedTestWithParams', {
      "params": params.toJson(),
    });
  }

  /// Stop server speed test
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> stopSpeedTest() {
    return _cloudChannel!.invokeMethod('stopSpeedTest');
  }

  /// Get SDK version information
  Future<String?> getSDKVersion() {
    return _cloudChannel!.invokeMethod('getSDKVersion');
  }

  /// Set log output level
  ///
  /// **Parameters:**
  ///
  /// `level` For more information, please see `TRTC_LOG_LEVEL_`. Default value: [TRTCCloudDef.TRTC_LOG_LEVEL_NULL]
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setLogLevel(
      int level // For more information, please see `TRTC_LOG_LEVEL`. Default value: TRTCCloudDef.TRTC_LOG_LEVEL_NULL
      ) {
    return _cloudChannel!.invokeMethod('setLogLevel', {"level": level});
  }

  /// Enable or disable console log printing
  ///
  /// **Parameters:**
  ///
  /// `enabled` Specify whether to enable it, which is disabled by default
  Future<void> setConsoleEnabled(bool enabled // Whether to enable
      ) {
    return _cloudChannel!.invokeMethod('setConsoleEnabled', {
      "enabled": enabled,
    });
  }

  /// Enable or disable local log compression
  ///
  /// If compression is enabled, the log size will significantly reduce, but logs can be read only after being decompressed by the Python script provided by Tencent Cloud. If compression is disabled, logs will be stored in plaintext and can be read directly in Notepad, but will take up more storage capacity.
  ///
  /// **Parameters:**
  ///
  /// `enabled` Specify whether to enable it, which is enabled by default
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setLogCompressEnabled(bool enabled // Whether to enable
      ) {
    return _cloudChannel!.invokeMethod('setLogCompressEnabled', {
      "enabled": enabled,
    });
  }

  /// Modify log storage path
  ///
  /// The log files are stored in `/app directory/files/log/tencent/liteav/` by default. To change the path, call this API before calling other methods and make sure that the directory exists and the application has read/write access to the directory.
  ///
  /// **Parameters:**
  ///
  /// `path`   Log storage path
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> setLogDirPath(String path // Whether to enable
      ) {
    return _cloudChannel!.invokeMethod('setLogDirPath', {
      "path": path,
    });
  }

  /// Display debug information floats (can display audio/video information and event information)
  ///
  /// The dashboard is a floating view for status statistics and event notifications to facilitate debugging.
  ///
  /// **Parameters:**
  ///
  /// `showType` `0`: does not display; `1`: displays lite edition; `2`: displays full edition. Default value: `0`
  ///
  /// **Platform not supported：**
  /// - web
  /// - Windows
  Future<void> showDebugView(
      int showType // 0: does not display; 1: displays lite edition; 2: displays full edition. Default value: 0
      ) {
    return _cloudChannel!.invokeMethod('showDebugView', {
      "mode": showType,
    });
  }

  /// Call experimental APIs
  ///
  /// **Note:** this API is used to call some experimental features.
  ///
  /// **Parameters:**
  ///
  /// `jsonStr` JSON string of API and parameter descriptions
  ///
  /// **Platform not supported：**
  /// - web
  Future<void> callExperimentalAPI(String jsonStr) {
    return _cloudChannel!.invokeMethod('callExperimentalAPI', {
      "jsonStr": jsonStr,
    });
  }

  /// Enable/DisEnable Custom Video Process
  ///
  ///【default】: `false`
  /// @return
  /// - `V2TXLIVE_OK`: success
  /// - `V2TXLIVE_ERROR_NOT_SUPPORTED`: Unsupported format
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<int?> enableCustomVideoProcess(bool enable) async {
    return _cloudChannel!
        .invokeMethod('enableCustomVideoProcess', {"enable": enable});
  }

  /// Set the volume of system audio capturing
  ///
  /// `volume` Set volume. Value range: `[0, 150]`. Default value: `100`
  ///
  /// **Platform not supported：**
  /// - Android
  /// - web
  Future<void> setSystemAudioLoopbackVolume(int volume) {
    return _cloudChannel!
        .invokeMethod('setSystemAudioLoopbackVolume', {'volume': volume});
  }

  /// Publish a stream. After this API is called, the TRTC server will relay the stream of the local user to a CDN (after transcoding or without transcoding), or transcode and publish the stream to a TRTC room.
  ///
  /// `target`, The On-Cloud MixTranscoding settings
  ///
  /// `param`, The encoding settings
  ///
  /// `config`, The publishing destination
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> startPublishMediaStream(
      {required TRTCPublishTarget target,
      TRTCStreamEncoderParam? params,
      TRTCStreamMixingConfig? config}) async {
    return _cloudChannel!.invokeMethod('startPublishMediaStream', {
      'target': target.toJson(),
      'param': params?.toJson(),
      'config': config?.toJson()
    });
  }

  /// Modify publishing parameters. You can use this API to change the parameters of a publishing task initiated by [startPublishMediaStream]
  ///
  /// `config`, The On-Cloud MixTranscoding settings
  ///
  /// `params`, The encoding settings
  ///
  /// `target`, The publishing destination
  ///
  /// `taskId`, The task ID returned to you via the `onStartPublishMediaStream` callback
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> updatePublishMediaStream(
      {required String taskId,
      required TRTCPublishTarget target,
      TRTCStreamEncoderParam? encoderParam,
      TRTCStreamMixingConfig? mixingConfig}) async {
    return _cloudChannel!.invokeMethod('updatePublishMediaStream', {
      'taskId': taskId,
      'target': target.toJson(),
      'encoderParam': encoderParam?.toJson(),
      'mixingConfig': mixingConfig?.toJson()
    });
  }

  /// Stop a task initiated by [startPublishMediaStream]
  ///
  /// `taskId`, The task ID returned to you via the `onStartPublishMediaStream` callback
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> stopPublishMediaStream(String taskId) async {
    return _cloudChannel!.invokeMethod('stopPublishMediaStream', {'taskId': taskId});
  }

  /// Set custom audio data callback
  ///
  /// After this callback is set, the SDK will internally call back the audio data (in PCM format), including:
  ///
  /// - `onCapturedAudioFrame`: callback of the audio data captured by the local mic
  ///
  /// **Note:** Setting the callback to null indicates to stop the custom audio callback, while setting it to a non-null value indicates to start the custom audio callback.
  ///
  /// **Platform not supported：**
  /// - web
  /// - macOS
  /// - Windows
  Future<void> setAudioFrameListener(TRTCAudioFrameListener? listener) async {
    if (_audioFrameListener == null) {
      _audioFrameListener = TRTCAudioFrameListenerPlatformMethod(_cloudChannel!.name);
    }
    _audioFrameListener!.setAudioFrameListener(listener);
    return _cloudChannel!.invokeMethod(
        'setAudioFrameListener', {'isNullListener': listener == null});
  }
}
