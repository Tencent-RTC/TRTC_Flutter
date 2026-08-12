// ignore_for_file: unintended_html_in_doc_comment
// ignore_for_file: comment_references
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_listener.dart';
part 'trtc_cloud_def.g.dart';

/// Use cases
///
/// TRTC features targeted optimizations for common audio/video
/// application scenarios to meet the differentiated requirements
/// in various verticals. The main scenarios can be divided into
/// the following two categories:
///
/// - **Live streaming scenario (LIVE)**:
///   - Includes `LIVE` (audio + video) and `VoiceChatRoom` (pure audio).
///
///   In the live streaming scenario, users are divided into two
///   roles: "anchor" and "audience". A single room can sustain
///   up to 100,000 concurrent online users. This is suitable for
///   live streaming to a large audience.
///
/// - **Real-Time scenario (RTC)**:
///   - Includes `VideoCall` (audio + video) and `AudioCall` (pure audio).
///
///   In the real-time scenario, there is no role difference between
///   users, but a single room can sustain only up to 300 concurrent
///   online users. This is suitable for small-scale real-time
///   communication.
@JsonEnum(alwaysCreate: true)
enum TRTCAppScene {
  /// - In the video call scenario, 720p and 1080p HD image quality is supported. A single room can sustain up to 300 concurrent online users, and up to 50 of them can speak simultaneously.
  /// - Use cases: \[one-to-one video call], \[video conferencing with up to 300 participants], \[online medical diagnosis], \[video chat], \[video interview], etc.
  @JsonValue(0)
  videoCall,

  /// - In the interactive video live streaming scenario, mic can be turned on/off smoothly without waiting for switchover, and the anchor latency is as low as less than 300 ms. Live streaming to hundreds of thousands of concurrent audience users is supported with the playback latency down to 1,000 ms.
  /// - Use cases: \[low-latency video live streaming], \[interactive classroom for up to 100,000 participants], \[live video competition], \[video dating room], \[remote training], \[large-scale conferencing], etc.
  /// - **Note:** in this scenario, you must use the `role` field in [TRTCParams] to specify the role of the current user.
  @JsonValue(1)
  live,

  /// - In the audio call scenario, 48 kHz dual-channel audio call is supported. A single room can sustain up to 300 concurrent online users, and up to 50 of them can speak simultaneously.
  /// - Use cases: \[one-to-one audio call], \[audio conferencing with up to 300 participants], \[voice chat], \[online Werewolf], etc.
  @JsonValue(2)
  audioCall,

  /// - In the interactive audio live streaming scenario, mic can be turned on/off smoothly without waiting for switchover, and the anchor latency is as low as less than 300 ms. Live streaming to hundreds of thousands of concurrent audience users is supported with the playback latency down to 1,000 ms.
  /// - Use cases: \[low-latency audio live streaming], \[live audio co-anchoring], \[voice chat room], \[karaoke room], \[FM radio], etc.
  /// - **Note:** in this scenario, you must use the `role` field in [TRTCParams] to specify the role of the current user.
  @JsonValue(3)
  voiceChatRoom,
}

/// @nodoc
extension TRTCAppSceneExt on TRTCAppScene {
  /// @nodoc
  static TRTCAppScene fromValue(int value) {
    return $enumDecode(_$TRTCAppSceneEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAppSceneEnumMap[this]!;
  }
}

/// Role
///
/// The role is applicable only to live streaming scenarios ([TRTCAppScene.live] and [TRTCAppScene.voiceChatRoom]).
/// Users are divided into two roles:
///
/// - **Anchor**:
///   - Can publish their audio/video streams.
///   - There is a limit on the number of anchors. Up to 50 anchors are allowed to publish streams at the same time in one room.
///
/// - **Audience**:
///   - Can only listen to or watch audio/video streams of anchors in the room.
///   - If they want to publish their streams, they need to switch to the "anchor" role first through [switchRole].
///   - One room can sustain up to 100,000 concurrent online users in the audience role.
@JsonEnum(alwaysCreate: true)
enum TRTCRoleType {
  /// - An anchor can publish their audio/video streams. There is a limit on the number of anchors.
  /// - Up to 50 anchors are allowed to publish streams at the same time in one room.
  @JsonValue(20)
  anchor,

  /// - Audience can only listen to or watch audio/video streams of anchors in the room.
  /// - If they want to publish their streams, they need to switch to the "anchor" role first through [switchRole] .
  /// - One room can sustain up to 100,000 concurrent online users in the audience role.
  @JsonValue(21)
  audience,
}

/// @nodoc
extension TRTCRoleTypeExt on TRTCRoleType {
  /// @nodoc
  static TRTCRoleType fromValue(int value) {
    return $enumDecode(_$TRTCRoleTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCRoleTypeEnumMap[this]!;
  }
}

/// Video resolution
///
/// Here, only the landscape resolution (e.g., 640x360) is defined. If the portrait resolution (e.g., 360x640) needs to be used,  portrait  must be selected for  [TRTCVideoResolutionMode] .
@JsonEnum(alwaysCreate: true)
enum TRTCVideoResolution {
  /// - Aspect ratio: 1:1; resolution: 120x120; recommended bitrate (VideoCall): 80 Kbps; recommended bitrate (LIVE): 120 Kbps.
  @JsonValue(1)
  res_120_120,

  /// - Aspect ratio: 1:1; resolution: 160x160; recommended bitrate (VideoCall): 100 Kbps; recommended bitrate (LIVE): 150 Kbps.
  @JsonValue(3)
  res_160_160,

  /// - Aspect ratio: 1:1; resolution: 270x270; recommended bitrate (VideoCall): 200 Kbps; recommended bitrate (LIVE): 300 Kbps.
  @JsonValue(5)
  res_270_270,

  /// - Aspect ratio: 1:1; resolution: 480x480; recommended bitrate (VideoCall): 350 Kbps; recommended bitrate (LIVE): 500 Kbps.
  @JsonValue(7)
  res_480_480,

  /// - Aspect ratio: 4:3; resolution: 160x120; recommended bitrate (VideoCall): 100 Kbps; recommended bitrate (LIVE): 150 Kbps.
  @JsonValue(50)
  res_160_120,

  /// - Aspect ratio: 4:3; resolution: 240x180; recommended bitrate (VideoCall): 150 Kbps; recommended bitrate (LIVE): 250 Kbps.
  @JsonValue(52)
  res_240_180,

  /// - Aspect ratio: 4:3; resolution: 280x210; recommended bitrate (VideoCall): 200 Kbps; recommended bitrate (LIVE): 300 Kbps.
  @JsonValue(54)
  res_280_210,

  /// - Aspect ratio: 4:3; resolution: 320x240; recommended bitrate (VideoCall): 250 Kbps; recommended bitrate (LIVE): 375 Kbps.
  @JsonValue(56)
  res_320_240,

  /// - Aspect ratio: 4:3; resolution: 400x300; recommended bitrate (VideoCall): 300 Kbps; recommended bitrate (LIVE): 450 Kbps.
  @JsonValue(58)
  res_400_300,

  /// - Aspect ratio: 4:3; resolution: 480x360; recommended bitrate (VideoCall): 400 Kbps; recommended bitrate (LIVE): 600 Kbps.
  @JsonValue(60)
  res_480_360,

  /// - Aspect ratio: 4:3; resolution: 640x480; recommended bitrate (VideoCall): 600 Kbps; recommended bitrate (LIVE): 900 Kbps.
  @JsonValue(62)
  res_640_480,

  /// - Aspect ratio: 4:3; resolution: 960x720; recommended bitrate (VideoCall): 1000kbps; recommended bitrate (LIVE): 1500kbps。
  @JsonValue(64)
  res_960_720,

  /// - Aspect ratio: 16:9; resolution: 160x90; recommended bitrate (VideoCall): 150 Kbps; recommended bitrate (LIVE): 250 Kbps.
  @JsonValue(100)
  res_160_90,

  /// - Aspect ratio: 16:9; resolution: 256x144; recommended bitrate (VideoCall): 200 Kbps; recommended bitrate (LIVE): 300 Kbps.
  @JsonValue(102)
  res_256_144,

  /// - Aspect ratio: 16:9; resolution: 320x180; recommended bitrate (VideoCall): 250 Kbps; recommended bitrate (LIVE): 400 Kbps.
  @JsonValue(104)
  res_320_180,

  /// - Aspect ratio: 16:9; resolution: 480x270; recommended bitrate (VideoCall): 350 Kbps; recommended bitrate (LIVE): 550 Kbps.
  @JsonValue(106)
  res_480_270,

  /// - Aspect ratio: 16:9; resolution: 640x360; recommended bitrate (VideoCall): 500 Kbps; recommended bitrate (LIVE): 900 Kbps.
  @JsonValue(108)
  res_640_360,

  /// - Aspect ratio: 16:9; resolution: 960x540; recommended bitrate (VideoCall): 850 Kbps; recommended bitrate (LIVE): 1300 Kbps.
  @JsonValue(110)
  res_960_540,

  /// - Aspect ratio: 16:9; resolution: 1280x720; recommended bitrate (VideoCall): 1200 Kbps; recommended bitrate (LIVE): 1800 Kbps.
  @JsonValue(112)
  res_1280_720,

  /// - Aspect ratio: 16:9; resolution: 1920x1080; recommended bitrate (VideoCall): 2000 Kbps; recommended bitrate (LIVE): 3000 Kbps.
  @JsonValue(114)
  res_1920_1080,
}

/// @nodoc
extension TRTCVideoResolutionExt on TRTCVideoResolution {
  /// @nodoc
  static TRTCVideoResolution fromValue(int value) {
    return $enumDecode(_$TRTCVideoResolutionEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoResolutionEnumMap[this]!;
  }
}

/// Video aspect ratio mode
@JsonEnum(alwaysCreate: true)
enum TRTCVideoResolutionMode {
  /// - Landscape resolution
  @JsonValue(0)
  landscape,

  /// - Portrait resolution
  @JsonValue(1)
  portrait,
}

/// @nodoc
extension TRTCVideoResolutionModeExt on TRTCVideoResolutionMode {
  /// @nodoc
  static TRTCVideoResolutionMode fromValue(int value) {
    return $enumDecode(_$TRTCVideoResolutionModeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoResolutionModeEnumMap[this]!;
  }
}

/// Video stream type
@JsonEnum(alwaysCreate: true)
enum TRTCVideoStreamType {
  /// - HD big image
  /// - it is generally used to transfer video data from the camera.
  @JsonValue(0)
  big,

  /// - Smooth small image
  /// - it has the same content as the big image, but with lower resolution and bitrate and thus lower definition.
  @JsonValue(1)
  small,

  /// - Substream image
  /// - it is generally used for screen sharing.
  /// - Only one user in the room is allowed to publish the substream video image at any time,
  /// - while other users must wait for this user to close the substream before they can publish their own substream.
  @JsonValue(2)
  sub,
}

/// @nodoc
extension TRTCVideoStreamTypeExt on TRTCVideoStreamType {
  /// @nodoc
  static TRTCVideoStreamType fromValue(int value) {
    return $enumDecode(_$TRTCVideoStreamTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoStreamTypeEnumMap[this]!;
  }
}

/// Video image fill mode
///
/// If the aspect ratio of the video display area is not equal to that of the video image, you need to specify the fill mode
@JsonEnum(alwaysCreate: true)
enum TRTCVideoFillMode {
  /// - Fill mode
  /// - The video image will be centered and scaled to fill the entire display area, where parts that exceed the area will be cropped.
  /// - The displayed image may be incomplete in this mode.
  @JsonValue(0)
  fill,

  /// - Fit mode
  /// - The video image will be scaled based on its long side to fit the display area,
  /// - where the short side will be filled with black bars. The displayed image is complete in this mode, but there may be black bars.
  @JsonValue(1)
  fit,

  /// - Scale to fill mode
  /// - Regardless of the aspect ratio of the image, it will be stretched or compressed to completely fill the display area.
  /// - In this mode, the aspect ratio of the image may be changed, resulting in distortion of the rendered image.
  @JsonValue(2)
  scaleFill,
}

/// @nodoc
extension TRTCVideoFillModeExt on TRTCVideoFillMode {
  /// @nodoc
  static TRTCVideoFillMode fromValue(int value) {
    return $enumDecode(_$TRTCVideoFillModeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoFillModeEnumMap[this]!;
  }
}

/// Video image rotation direction
@JsonEnum(alwaysCreate: true)
enum TRTCVideoRotation {
  /// - No rotation
  @JsonValue(0)
  rotation0,

  /// - Clockwise rotation by 90 degrees
  @JsonValue(1)
  rotation90,

  /// - Clockwise rotation by 180 degrees
  @JsonValue(2)
  rotation180,

  /// - Clockwise rotation by 270 degrees
  @JsonValue(3)
  rotation270,
}

/// @nodoc
extension TRTCVideoRotationExt on TRTCVideoRotation {
  /// @nodoc
  static TRTCVideoRotation fromValue(int value) {
    return $enumDecode(_$TRTCVideoRotationEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoRotationEnumMap[this]!;
  }
}

/// Video mirror type
@JsonEnum(alwaysCreate: true)
enum TRTCVideoMirrorType {
  /// - Auto mode: mirror the front camera's image but not the rear camera's image (for mobile devices only).
  @JsonValue(0)
  auto,

  /// - Mirror the images of both the front and rear cameras.
  @JsonValue(1)
  enable,

  /// - Disable mirroring for both the front and rear cameras.
  @JsonValue(2)
  disable,
}

/// @nodoc
extension TRTCVideoMirrorTypeExt on TRTCVideoMirrorType {
  /// @nodoc
  static TRTCVideoMirrorType fromValue(int value) {
    return $enumDecode(_$TRTCVideoMirrorTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoMirrorTypeEnumMap[this]!;
  }
}

/// Data Source of Local Video Screenshot
///
/// The SDK can take screenshots from the following two data sources and save them as local files:
///
/// 1. **Video Stream**:
///    - The SDK screencaptures the native video content from the video stream.
///    - The screenshots are not controlled by the display of the rendering control.
///
/// 2. **Rendering Layer**:
///    - The SDK screencaptures the displayed video content from the rendering control,
///      which can achieve the effect of WYSIWYG (What You See Is What You Get).
///    - However, if the display area is too small, the screenshots will also be very small.
@JsonEnum(alwaysCreate: true)
enum TRTCSnapshotSourceType {
  /// - The SDK screencaptures the native video content from the video stream. The screenshots are not controlled by the display of the rendering control.
  @JsonValue(0)
  stream,

  /// - The SDK screencaptures the displayed video content from the rendering control, which can achieve the effect of WYSIWYG,
  /// but if the display area is too small, the screenshots will also be very small.
  @JsonValue(1)
  view,

  /// - The SDK screencaptures the capture video content from the capture control, which can capture the captured high-definition screenshots.
  @JsonValue(2)
  capture,
}

/// @nodoc
extension TRTCSnapshotSourceTypeExt on TRTCSnapshotSourceType {
  /// @nodoc
  static TRTCSnapshotSourceType fromValue(int value) {
    return $enumDecode(_$TRTCSnapshotSourceTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCSnapshotSourceTypeEnumMap[this]!;
  }
}

/// Network quality
///
/// TRTC evaluates the current network quality once every two seconds.
/// The evaluation results are divided into six levels:  excellent  indicates the best, and  Down  indicates the worst.
@JsonEnum(alwaysCreate: true)
enum TRTCQuality {
  /// - Undefined
  @JsonValue(0)
  unknown,

  /// - The current network is excellent
  @JsonValue(1)
  excellent,

  /// - The current network is good
  @JsonValue(2)
  good,

  /// - The current network is fair
  @JsonValue(3)
  poor,

  /// - The current network is bad
  @JsonValue(4)
  bad,

  /// - The current network is very bad
  @JsonValue(5)
  vBad,

  /// - The current network cannot meet the minimum requirements of TRTC
  @JsonValue(6)
  down,
}

/// @nodoc
extension TRTCQualityExt on TRTCQuality {
  /// @nodoc
  static TRTCQuality fromValue(int value) {
    return $enumDecode(_$TRTCQualityEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCQualityEnumMap[this]!;
  }
}

/// Audio/Video Playback Status
///
/// This enumerated type is used in the audio status changed API [TRTCCloudListener.onRemoteAudioStatusUpdated]
/// and the video status changed API [TRTCCloudListener.onRemoteVideoStatusUpdated] to specify the current audio/video status.
@JsonEnum(alwaysCreate: true)
enum TRTCAVStatusType {
  /// - Stopped
  @JsonValue(0)
  stopped,

  /// - Playing
  @JsonValue(1)
  playing,

  /// - Loading
  @JsonValue(2)
  loading,
}

/// @nodoc
extension TRTCAVStatusTypeExt on TRTCAVStatusType {
  /// @nodoc
  static TRTCAVStatusType fromValue(int value) {
    return $enumDecode(_$TRTCAVStatusTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAVStatusTypeEnumMap[this]!;
  }
}

/// Reasons for Playback Status Changes
///
/// This enumerated type is used in the audio status changed API [TRTCCloudListener.onRemoteAudioStatusUpdated]
/// and the video status changed API [TRTCCloudListener.onRemoteVideoStatusUpdated] to specify the reason for the
/// current audio/video status change.
@JsonEnum(alwaysCreate: true)
enum TRTCAVStatusChangeReason {
  /// - Default value
  @JsonValue(0)
  internal,

  /// - The stream enters the  Loading  state due to network congestion
  @JsonValue(1)
  bufferingBegin,

  /// - The stream enters the  Playing  state after network recovery
  @JsonValue(2)
  bufferingEnd,

  /// - As a start-related API was directly called locally, the stream enters the  Playing  state
  @JsonValue(3)
  localStarted,

  /// - As a stop-related API was directly called locally, the stream enters the  Stopped  state
  @JsonValue(4)
  localStopped,

  /// - As the remote user started (or resumed) publishing the audio or video stream, the stream enters the  Loading  or  Playing  state
  @JsonValue(5)
  remoteStarted,

  /// - As the remote user stopped (or paused) publishing the audio or video stream, the stream enters the "Stopped" state
  @JsonValue(6)
  remoteStopped,
}

/// @nodoc
extension TRTCAVStatusChangeReasonExt on TRTCAVStatusChangeReason {
  /// @nodoc
  static TRTCAVStatusChangeReason fromValue(int value) {
    return $enumDecode(_$TRTCAVStatusChangeReasonEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAVStatusChangeReasonEnumMap[this]!;
  }
}

/// G-sensor switch (for mobile devices only)
@JsonEnum(alwaysCreate: true)
enum TRTCGSensorMode {
  /// - Do not adapt to G-sensor orientation
  /// - This mode is the default value for desktop platforms.
  /// - In this mode, the video image published by the current user is not affected by the change of the G-sensor orientation.
  @JsonValue(0)
  disable,

  /// - Adapt to G-sensor orientation
  /// - This mode is the default value on mobile platforms.
  /// - In this mode, the video image published by the current user is adjusted according to the G-sensor orientation,
  /// while the orientation of the local preview image remains unchanged.
  /// - One of the adaptation modes currently supported by the SDK is as follows:
  /// when the phone or tablet is upside down, in order to ensure that the screen orientation seen by the remote user is normal,
  /// the SDK will automatically rotate the published video image by 180 degrees.
  /// - If the UI layer of your application has enabled G-sensor adaption, we recommend you use the  [uiFixLayout]  mode.
  @JsonValue(1)
  uiAutoLayout,

  /// - Adapt to G-sensor orientation
  /// - In this mode, the video image published by the current user is adjusted according to the G-sensor orientation,
  /// and the local preview image will also be rotated accordingly.
  /// - One of the features currently supported is as follows:
  /// when the phone or tablet is upside down, in order to ensure that the screen orientation seen by the remote user is normal,
  /// the SDK will automatically rotate the published video image by 180 degrees.
  @JsonValue(2)
  uiFixLayout,
}

/// @nodoc
extension TRTCGSensorModeExt on TRTCGSensorMode {
  /// @nodoc
  static TRTCGSensorMode fromValue(int value) {
    return $enumDecode(_$TRTCGSensorModeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCGSensorModeEnumMap[this]!;
  }
}

/// Sound Quality
///
/// TRTC provides three well-tuned modes to meet the differentiated requirements for sound quality in various verticals.
@JsonEnum(alwaysCreate: true)
enum TRTCAudioQuality {
  /// - Speech mode: sample rate: 16 kHz; mono channel; bitrate: 16 Kbps.
  /// - This mode has the best resistance among all modes and is suitable for audio call scenarios, such as online meeting and audio call.
  /// - In this mode, the audio transfer is more resistant, and TRTC uses various voice processing technologies
  /// to ensure optimal smoothness even in weak network environments.
  @JsonValue(1)
  speech,

  /// - Default mode: sample rate: 48 kHz; mono channel; bitrate: 50 Kbps.
  /// - This mode is between the speech mode and the music mode as the default mode in the SDK and is recommended.
  /// - The reproduction of music is better than that in `Speech` mode, and the amount of transferred data
  /// is much lower than that in `Music` mode; therefore, this mode has good adaptability to various scenarios.
  @JsonValue(2)
  defaultMode,

  /// - Music mode: sample rate: 48 kHz; full-band stereo; bitrate: 128 Kbps.
  /// - This mode is suitable for scenarios where Hi-Fi music transfer is required, such as online karaoke and music live streaming.
  /// - In this mode, the amount of transferred audio data is very large, and TRTC uses various technologies
  /// to ensure that the high-fidelity details of music signals can be restored in each frequency band.
  @JsonValue(3)
  music,
}

/// @nodoc
extension TRTCAudioQualityExt on TRTCAudioQuality {
  /// @nodoc
  static TRTCAudioQuality fromValue(int value) {
    return $enumDecode(_$TRTCAudioQualityEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAudioQualityEnumMap[this]!;
  }
}

/// Image quality preference
///
/// TRTC has two control modes in weak network environments: "ensuring clarity" and "ensuring smoothness". Both modes will give priority to the transfer of audio data.
@JsonEnum(alwaysCreate: true)
enum TRTCVideoQosPreference {
  /// - Ensuring smoothness
  /// - In this mode, when the current network is unable to transfer a clear and smooth video image,
  /// the smoothness of the image will be given priority, but there will be blurs.
  @JsonValue(1)
  smooth,

  /// - Ensuring clarity (default value)
  /// - In this mode, when the current network is unable to transfer a clear and smooth video image,
  /// the clarity of the image will be given priority, but there will be lags.
  @JsonValue(2)
  clear,
}

/// @nodoc
extension TRTCVideoQosPreferenceExt on TRTCVideoQosPreference {
  /// @nodoc
  static TRTCVideoQosPreference fromValue(int value) {
    return $enumDecode(_$TRTCVideoQosPreferenceEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoQosPreferenceEnumMap[this]!;
  }
}

/// Audio recording content type
///
/// This enumerated type is used in the audio recording API [startAudioRecording] to specify the content of the recorded audio.
@JsonEnum(alwaysCreate: true)
enum TRTCAudioRecordingContent {
  /// - Record both local and remote audio
  @JsonValue(0)
  all,

  /// - Record local audio only
  @JsonValue(1)
  local,

  /// - Record remote audio only.
  @JsonValue(2)
  remote,
}

extension TRTCAudioRecordingContentExt on TRTCAudioRecordingContent {
  /// @nodoc
  static TRTCAudioRecordingContent fromValue(int value) {
    return $enumDecode(_$TRTCAudioRecordingContentEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAudioRecordingContentEnumMap[this]!;
  }
}

/// The Publishing Mode
///
/// This enum type is used by the publishing API [startPublishMediaStream].
///
/// TRTC can mix multiple streams in a room and publish the mixed stream to a CDN or to a TRTC room.
/// It can also publish the stream of the local user to Tencent Cloud or a third-party CDN.
@JsonEnum(alwaysCreate: true)
enum TRTCPublishMode {
  /// - Undefined
  @JsonValue(0)
  unknown,

  /// - Use this parameter to publish the primary stream ([TRTCVideoStreamType.big]) in the room to Tencent Cloud or a third-party CDN (only RTMP is supported).
  @JsonValue(1)
  bigStreamToCdn,

  /// - Use this parameter to publish the sub-stream ([TRTCVideoStreamType.sub]) in the room to Tencent Cloud or a third-party CDN (only RTMP is supported).
  @JsonValue(2)
  subStreamToCdn,

  /// - Use this parameter together with the encoding parameter [TRTCStreamEncoderParam] and
  /// On-Cloud MixTranscoding parameter [TRTCStreamMixingConfig] to transcode the streams you specify and
  /// publish the mixed stream to Tencent Cloud or a third-party CDN (only RTMP is supported).
  @JsonValue(3)
  mixStreamToCdn,

  /// - Use this parameter together with the encoding parameter [TRTCStreamEncoderParam] and
  /// On-Cloud MixTranscoding parameter [TRTCStreamMixingConfig] to transcode the streams you specify and
  /// publish the mixed stream to the room you specify.
  ///   - Use [TRTCUser] in [TRTCPublishTarget] to specify the robot that publishes the transcoded stream to a TRTC room.
  @JsonValue(4)
  mixStreamToRoom,
}

/// @nodoc
extension TRTCPublishModeExt on TRTCPublishMode {
  /// @nodoc
  static TRTCPublishMode fromValue(int value) {
    return $enumDecode(_$TRTCPublishModeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCPublishModeEnumMap[this]!;
  }
}

/// Media Recording Type
///
/// This enumerated type is used in the local media recording API [startLocalRecording]
/// to specify whether to record audio/video files or pure audio files.
@JsonEnum(alwaysCreate: true)
enum TRTCBeautyStyle {
  @JsonValue(0)
  smooth,

  @JsonValue(1)
  nature,
}

extension TRTCBeautyStyleExt on TRTCBeautyStyle {
  /// @nodoc
  static TRTCBeautyStyle fromValue(int value) {
    return $enumDecode(_$TRTCBeautyStyleEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCBeautyStyleEnumMap[this]!;
  }
}

@JsonEnum(alwaysCreate: true)
enum TRTCLocalRecordType {
  /// - Record audio only
  @JsonValue(0)
  audio,

  /// - Record video only
  @JsonValue(1)
  video,

  /// - Record both audio and video
  @JsonValue(2)
  both,
}

/// @nodoc
extension TRTCLocalRecordTypeExt on TRTCLocalRecordType {
  /// @nodoc
  static TRTCLocalRecordType fromValue(int value) {
    return $enumDecode(_$TRTCLocalRecordTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCLocalRecordTypeEnumMap[this]!;
  }
}

/// Watermark image source type
@JsonEnum(alwaysCreate: true)
enum TRTCWaterMarkSrcType {
  /// - Path of the image file, which can be in BMP, GIF, JPEG, PNG, TIFF, Exif, WMF, or EMF format
  @JsonValue(0)
  file,

  /// - Memory block in BGRA32 format
  @JsonValue(1)
  bgra32,

  /// - Memory block in RGBA32 format
  @JsonValue(2)
  rgba32,
}

/// @nodoc
extension TRTCWaterMarkSrcTypeExt on TRTCWaterMarkSrcType {
  /// @nodoc
  static TRTCWaterMarkSrcType fromValue(int value) {
    return $enumDecode(_$TRTCWaterMarkSrcTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCWaterMarkSrcTypeEnumMap[this]!;
  }
}

/// Video Pixel Format
///
/// TRTC provides custom video capturing and rendering features.
///
/// - For the custom capturing feature, you can use the following enumerated values
///   to describe the pixel format of the video you capture.
///
/// - For the custom rendering feature, you can specify the pixel format of the video
///   you expect the SDK to call back.
@JsonEnum(alwaysCreate: true)
enum TRTCVideoPixelFormat {
  /// - Undefined format
  @JsonValue(0)
  unknown,

  /// - YUV420P (I420) format
  @JsonValue(1)
  i420,

  /// - OpenGL 2D texture format
  @JsonValue(2)
  texture2D,

  /// - BGRA32 format
  @JsonValue(3)
  bgra32,

  /// - NV21 format
  @JsonValue(4)
  nv21,

  /// - RGBA format
  @JsonValue(5)
  rgba32,
}

/// @nodoc
extension TRTCVideoPixelFormatExt on TRTCVideoPixelFormat {
  /// @nodoc
  static TRTCVideoPixelFormat fromValue(int value) {
    return $enumDecode(_$TRTCVideoPixelFormatEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoPixelFormatEnumMap[this]!;
  }
}

/// Screen sharing target type (for desktops only)
@JsonEnum(alwaysCreate: true)
enum TRTCScreenCaptureSourceType {
  /// - Undefined
  @JsonValue(-1)
  unknown,

  /// - The screen sharing target is the window of an application
  @JsonValue(0)
  window,

  /// - The screen sharing target is the entire screen
  @JsonValue(1)
  screen,

  /// - The screen sharing target is a user-defined data source
  @JsonValue(2)
  custom,
}

/// @nodoc
extension TRTCScreenCaptureSourceTypeExt on TRTCScreenCaptureSourceType {
  /// @nodoc
  static TRTCScreenCaptureSourceType fromValue(int value) {
    return $enumDecode(_$TRTCScreenCaptureSourceTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCScreenCaptureSourceTypeEnumMap[this]!;
  }
}

/// Video Data Transfer Method
///
/// For custom capturing and rendering features, you need to use the following
/// enumerated values to specify the method of transferring video data:
///
/// - Method 1: This method uses a memory buffer to transfer video data.
///   It is efficient on iOS but inefficient on Android.
///   It is the only method currently supported on Windows.
///
/// - Method 2: This method uses texture to transfer video data.
///   It is efficient on both iOS and Android but is not supported on Windows.
///   To use this method, you should have a general familiarity with OpenGL programming.
@JsonEnum(alwaysCreate: true)
enum TRTCVideoBufferType {
  /// - Undefined transfer method
  @JsonValue(0)
  unknown,

  /// - Use memory buffer to transfer video data. iOS:  PixelBuffer ; Android:  Direct Buffer  for JNI layer; Windows: memory data block.
  @JsonValue(1)
  buffer,

  /// - Use OpenGL texture to transfer video data
  @JsonValue(3)
  texture,

  /// - Use D3D11 texture to transfer video data
  @JsonValue(4)
  textureD3D11,
}

/// @nodoc
extension TRTCVideoBufferTypeExt on TRTCVideoBufferType {
  /// @nodoc
  static TRTCVideoBufferType fromValue(int value) {
    return $enumDecode(_$TRTCVideoBufferTypeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCVideoBufferTypeEnumMap[this]!;
  }
}

/// Audio frame content format
@JsonEnum(alwaysCreate: true)
enum TRTCAudioFrameFormat {
  /// - None
  @JsonValue(0)
  none,

  /// - Audio data in PCM format
  @JsonValue(1)
  pcm,
}

/// @nodoc
extension TRTCAudioFrameFormatExt on TRTCAudioFrameFormat {
  /// @nodoc
  static TRTCAudioFrameFormat fromValue(int value) {
    return $enumDecode(_$TRTCAudioFrameFormatEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAudioFrameFormatEnumMap[this]!;
  }
}

/// Speed Test Scene
///
/// This enumeration type is used for speed test scene selection.
@JsonEnum(alwaysCreate: true)
enum TRTCSpeedTestScene {
  /// - Delay testing.
  @JsonValue(1)
  delayTesting,

  /// - Delay and bandwidth testing.
  @JsonValue(2)
  delayAndBandwidthTesting,

  /// - Online chorus testing.
  @JsonValue(3)
  onlineChorusTesting,
}

/// @nodoc
extension TRTCSpeedTestSceneExt on TRTCSpeedTestScene {
  /// @nodoc
  static TRTCSpeedTestScene fromValue(int value) {
    return $enumDecode(_$TRTCSpeedTestSceneEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCSpeedTestSceneEnumMap[this]!;
  }
}

/// Audio Callback Data Operation Mode
@JsonEnum(alwaysCreate: true)
enum TRTCAudioFrameOperationMode {
  /// - Read-write mode: You can get and modify the audio data of the callback, the default mode.
  @JsonValue(0)
  readWrite,

  /// - Read-only mode: Get audio data from callback only.
  @JsonValue(1)
  readOnly,
}

/// @nodoc
extension TRTCAudioFrameOperationModeExt on TRTCAudioFrameOperationMode {
  /// @nodoc
  static TRTCAudioFrameOperationMode fromValue(int value) {
    return $enumDecode(_$TRTCAudioFrameOperationModeEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCAudioFrameOperationModeEnumMap[this]!;
  }
}

/// Log level
@JsonEnum(alwaysCreate: true)
enum TRTCLogLevel {
  /// - Output logs at all levels
  @JsonValue(0)
  verbose,

  /// - Output logs at the DEBUG, INFO, WARNING, ERROR, and FATAL levels
  @JsonValue(1)
  debug,

  /// - Output logs at the INFO, WARNING, ERROR, and FATAL levels
  @JsonValue(2)
  info,

  /// - Output logs at the WARNING, ERROR, and FATAL levels
  @JsonValue(3)
  warning,

  /// - Output logs at the ERROR and FATAL levels
  @JsonValue(4)
  error,

  /// - Output logs at the FATAL level
  @JsonValue(5)
  fatal,

  /// - Do not output any SDK logs
  @JsonValue(6)
  none,
}

/// @nodoc
extension TRTCLogLevelExt on TRTCLogLevel {
  /// @nodoc
  static TRTCLogLevel fromValue(int value) {
    return $enumDecode(_$TRTCLogLevelEnumMap, value);
  }

  /// @nodoc
  int value() {
    return _$TRTCLogLevelEnumMap[this]!;
  }
}

class TRTCRect {
  int left;
  int top;
  int right;
  int bottom;

  TRTCRect({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });
}

class TRTCSize {
  int width;
  int height;

  TRTCSize({
    this.width = 0,
    this.height = 0,
  });
}

/// Room entry parameters
///
/// As the room entry parameters in the TRTC SDK, these parameters must be correctly set so that the user can successfully enter the audio/video room specified by  roomId  or  strRoomId .
///
/// For historical reasons, TRTC supports two types of room IDs:  roomId  and  strRoomId .
///
/// Note: do not mix  roomId  and  strRoomId , because they are not interchangeable. For example, the number  123  and the string  123  are two completely different rooms in TRTC.
class TRTCParams {
  /// - **Field description**: application ID, which is required. Tencent Cloud generates bills based on  sdkAppId .
  /// - **Recommended value**: the ID can be obtained on the account information page in the [TRTC console](https://console.trtc.io) after the corresponding application is created.
  int sdkAppId;

  /// **Field description**: user ID, which is required. It is the  userId  of the local user in UTF-8 encoding and acts as the username.
  /// **Recommended value**: if the ID of a user in your account system is "mike",  userId  can be set to "mike".
  String userId;

  /// **Field description**: user signature, which is required. It is the authentication signature corresponding to the current  userId  and acts as the login password for Tencent Cloud services.
  /// **Recommended value**: for the calculation method, please see [UserSig](https://trtc.io/document/35166).
  String userSig;

  /// - **Field description**: numeric room ID. Users (userId) in the same room can see one another and make audio/video calls.
  /// - **Recommended value**: value range: 1–4294967294.
  /// - **Note**:
  ///   - roomId  and  strRoomId  are mutually exclusive. If you decide to use  strRoomId , then  roomId  should be entered as 0. If both are entered,  roomId  will be used.
  ///   - do not mix  roomId  and  strRoomId , because they are not interchangeable. For example, the number  123  and the string  123  are two completely different rooms in TRTC.
  int roomId;

  /// - **Field description**: string-type room ID. Users (userId) in the same room can see one another and make audio/video calls.
  /// - **Recommended value**: the length limit is 64 bytes. The following 89 characters are supported: letters (a–z and A–Z), digits (0–9), space, "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "\[", "\]", "^", "_", "{", "}", "|", "~", and ",".
  /// - Either `roomId` or `strRoomId` must be entered. If you decide to use `strRoomId`, then `roomId` should be entered as 0. If both are entered, `roomId` will prevail. Please note that when the same `sdkAppId` is used for interconnection, please be sure to use the same room ID type to avoid affecting the interconnection.
  String strRoomId;

  /// - **Field description**: role in the live streaming scenario. The SDK uses this parameter to determine whether the user is an anchor or an audience user. This parameter is required in the live streaming scenario and optional in the call scenario.
  /// - **Note:** this parameter is applicable only to the live streaming scenario ([TRTCAppScene.live] or [TRTCAppScene.voiceChatRoom]) and doesn't take effect in the call scenario (`AUDIOCALL` or `VIDEOCALL`).
  /// - **Recommended value:** default value: anchor
  TRTCRoleType role;

  /// - **Field description:** bound Tencent Cloud CSS CDN stream ID, which is optional. After setting this field, you can play back the user's audio/video stream on Tencent Cloud Live CDN through a standard live streaming scheme (FLV or HLS).
  /// - **Recommended value:** this parameter can contain up to 64 bytes and can be left empty. We recommend you use `sdkappid_roomid_userid_main` as the `streamid`, which is easier to identify and will not cause conflicts in your multiple applications.
  /// - **Note:** to use Tencent Cloud CSS CDN, you need to enable the relayed live streaming feature on the "Function Configuration" page in the console first.
  String streamId;

  /// - **Field description:** on-cloud recording switch, which is used to specify whether to record the user's audio/video stream into a file in the specified format in the cloud.
  /// - **Recommended value:** it can contain up to 64 bytes of letters (a–z and A–Z), digits (0–9), underscores, and hyphens.
  String userDefineRecordId;

  /// - **Field description:** room signature, which is optional. If you want only users with the specified `userIds` to enter a room, you need to use `privateMapKey` to restrict the permission.
  /// - **Recommended value:** we recommend you use this parameter only if you have high security requirements. For more information, please see [Enabling Advanced Permission Control](https://trtc.io/document/35157).
  String privateMapKey;

  /// - **Field description:** business data, which is optional. This field applies only to some uncommon special requirements.
  /// - **Recommended value:** we recommend you not use this field
  String businessInfo;

  TRTCParams(
      {this.sdkAppId = 0,
      this.userId = "",
      this.userSig = "",
      this.roomId = 0,
      this.strRoomId = "",
      this.role = TRTCRoleType.anchor,
      this.streamId = "",
      this.userDefineRecordId = "",
      this.privateMapKey = "",
      this.businessInfo = ""});
}

/// Room switch parameter
class TRTCSwitchRoomConfig {
  /// - **Field description**: user signature, which is required. It is the authentication signature corresponding to the current  userId  and acts as the login password for Tencent Cloud services.
  /// - **Recommended value**: for the calculation method, please see [UserSig](https://trtc.io/document/35166).
  String userSig;

  /// - **Field description**: numeric room ID. Users (userId) in the same room can see one another and make audio/video calls.
  /// - **Recommended value**: value range: 1–4294967294.
  /// - **Note**:
  ///   - roomId  and  strRoomId  are mutually exclusive. If you decide to use  strRoomId , then  roomId  should be entered as 0. If both are entered,  roomId  will be used.
  ///   - do not mix  roomId  and  strRoomId , because they are not interchangeable. For example, the number  123  and the string  123  are two completely different rooms in TRTC.
  int roomId;

  /// - **Field description**: string-type room ID. Users (userId) in the same room can see one another and make audio/video calls.
  /// - **Recommended value**: the length limit is 64 bytes. The following 89 characters are supported: letters (a–z and A–Z), digits (0–9), space, "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "\[", "\]", "^", "_", "{", "}", "|", "~", and ",".
  /// - Either `roomId` or `strRoomId` must be entered. If you decide to use `strRoomId`, then `roomId` should be entered as 0. If both are entered, `roomId` will prevail. Please note that when the same `sdkAppId` is used for interconnection, please be sure to use the same room ID type to avoid affecting the interconnection.
  String strRoomId;

  /// - **Field description:** room signature, which is optional. If you want only users with the specified `userIds` to enter a room, you need to use `privateMapKey` to restrict the permission.
  /// - **Recommended value:** we recommend you use this parameter only if you have high security requirements. For more information, please see [Enabling Advanced Permission Control](https://trtc.io/document/35157).
  String privateMapKey;

  TRTCSwitchRoomConfig(
      {required this.userSig,
      this.roomId = 0,
      this.privateMapKey = "",
      this.strRoomId = ""});
}

/// Rendering parameters of video image
class TRTCRenderParams {
  /// - **Field description:** clockwise image rotation angle
  /// - **Note**
  ///   - [TRTCVideoRotation.rotation0] : no rotation (default value)
  ///   - [TRTCVideoRotation.rotation90] : clockwise rotation by 90 degrees
  ///   - [TRTCVideoRotation.rotation180] : clockwise rotation by 180 degrees
  ///   - [TRTCVideoRotation.rotation270] : clockwise rotation by 270 degrees
  TRTCVideoRotation rotation;

  /// - **Field description:** image rendering mode
  /// - **Note**
  ///   - Fill (the image may be stretched or cropped) or fit (there may be black color in unmatched areas).
  /// - Default value: [TRTCVideoFillMode.fill]
  TRTCVideoFillMode fillMode;

  /// - **Field description:** mirror mode
  /// - **Note**
  ///   - [TRTCVideoMirrorType.auto] : mirror the front camera's image but not the rear camera's image (default value).
  ///   - [TRTCVideoMirrorType.enable] : mirror the images of both the front and rear cameras.
  ///   - [TRTCVideoMirrorType.disable] : do not mirror the images of both the front and rear cameras.
  TRTCVideoMirrorType mirrorType;

  TRTCRenderParams({
    this.rotation = TRTCVideoRotation.rotation0,
    this.fillMode = TRTCVideoFillMode.fill,
    this.mirrorType = TRTCVideoMirrorType.auto,
  });
}

/// Volume evaluation and other related parameter settings.
class TRTCAudioVolumeEvaluateParams {
  /// - **Field description:** Whether to enable local vocal frequency calculation.
  bool enablePitchCalculation;

  /// - **Field description:** Whether to enable sound spectrum calculation.。
  bool enableSpectrumCalculation;

  /// - **Field description:** Whether to enable local voice detection.。
  /// - Note: Call before startLocalAudio
  bool enableVadDetection;

  /// - **Field description:** Set the trigger interval of the onUserVoiceVolume callback, the unit is milliseconds, the minimum interval is 100ms, if it is less than or equal to 0, the callback will be closed.
  /// - **Value:** Recommended value: 300, in milliseconds.
  /// - When the interval is greater than 0, the volume prompt will be enabled by default, no additional setting is required.
  int interval;

  TRTCAudioVolumeEvaluateParams({
    this.enablePitchCalculation = false,
    this.enableSpectrumCalculation = false,
    this.enableVadDetection = false,
    this.interval = 300,
  });
}

/// Video encoding parameters
///
/// These settings determine the quality of image viewed by remote users as well as the image quality of recorded video files in the cloud.
class TRTCVideoEncParam {
  /// - **Field description:** video resolution
  /// - **Recommended value**
  ///    - For video call, we recommend you select a resolution of 360x640 or below and select `Portrait` for `resMode`.
  ///    - For mobile live streaming, we recommend you select a resolution of 540x960 and select `Portrait` for `resMode`.
  ///    - For Windows and macOS, we recommend you select a resolution of 640x360 or above and select `Landscape` for `resMode`.
  /// - **Note**
  ///    - `TRTCVideoResolution` supports only the landscape resolution by default, such as 640x360.
  ///    - To use a portrait resolution, please specify `resMode` as `Portrait`; for example, when used together with `Portrait`, 640x360 will become 360x640.
  /// - Default value:  [TRTCVideoResolution.res_480_360]
  TRTCVideoResolution videoResolution;

  /// - **Field description:** resolution mode (landscape/portrait)
  /// - **Recommended value:** for mobile live streaming, `Portrait` is recommended; for Windows and macOS, `Landscape` is recommended.
  /// - **Note:** if 640x360 resolution is selected for `videoResolution` and `Portrait` is selected for `resMode`, then the final output resolution after encoding will be 360x640.
  /// - Default value:  [TRTCVideoResolutionMode.portrait]
  TRTCVideoResolutionMode videoResolutionMode;

  /// - **Field description:** video capturing frame rate
  /// - **Recommended value:** 15 or 20 fps. If the frame rate is lower than 5 fps, there will be obvious lagging; if lower than 10 fps but higher than 5 fps, there will be slight lagging; if higher than 20 fps, too many resources will be wasted (the frame rate of movies is generally 24 fps).
  /// - **Note:** the front cameras on many Android phones do not support a capturing frame rate higher than 15 fps. For some Android phones that focus too much on beautification features, the capturing frame rate of the front cameras may be lower than 10 fps.
  int videoFps;

  /// - **Field description:** target video bitrate. The SDK encodes streams at the target video bitrate and will actively reduce the bitrate only if the network conditions are poor.
  /// - **Recommended value:** please see the optimal bitrate for each specification in [TRTCVideoResolution]. You can also slightly increase the optimal bitrate.
  /// For example, [TRTCVideoResolution.res_1280_720] corresponds to the target bitrate of 1,200 Kbps. You can also set the bitrate to 1,500 Kbps for higher definition.
  /// - **Note:** the SDK does its best to encode streams at the bitrate specified by `videoBitrate` and will actively reduce the bitrate to as low as the value specified by `minVideoBitrate` only if the network conditions are poor.
  ///   - If you want to "ensure definition while allowing lag", you can set `minVideoBitrate` to 60% of `videoBitrate`.
  ///   - If you want to "ensure smoothness while allowing blur", you can set `minVideoBitrate` to 200 Kbps.
  ///   - If you set `videoBitrate` and `minVideoBitrate` to the same value, it is equivalent to disabling the adaptive adjustment capability of the SDK.
  int videoBitrate;

  /// - **Field description:** minimum video bitrate. The SDK will reduce the bitrate to as low as the value specified by `minVideoBitrate` only if the network conditions are poor.
  /// - **Recommended value**
  ///     - If you want to "ensure definition while allowing lag", you can set `minVideoBitrate` to 60% of `videoBitrate`.
  ///     - If you want to "ensure smoothness while allowing blur", you can set `minVideoBitrate` to 200 Kbps.
  ///     - If you set `videoBitrate` and `minVideoBitrate` to the same value, it is equivalent to disabling the adaptive adjustment capability of the SDK.
  ///     - Default value: `0`, indicating that the lowest bitrate will be automatically set by the SDK according to the resolution.
  /// - **Note**
  ///     - If you set the resolution to a high value, it is not suitable to set `minVideoBitrate` too low; otherwise, the video image will become blurry and heavily pixelated.
  ///     - For example, if the resolution is set to 720p and the bitrate is set to 200 Kbps, then the encoded video image will be heavily pixelated.
  int minVideoBitrate;

  /// - **Field description:** whether resolution adjustment is allowed
  /// - **Recommended value**
  ///     - For mobile live streaming, `false` is recommended.
  ///     - For video call, if smoothness is of higher priority, `true` is recommended. In this case, if the network bandwidth is limited, the SDK will automatically reduce the resolution to ensure better smoothness (only valid for `TRTCVideoStreamTypeBig`).
  ///     - Default value: `false`.
  /// - **Note:** when recording is needed, if `true` is selected, please make sure that the resolution adjustment will not affect the recording effect during the call.
  bool enableAdjustRes;

  TRTCVideoEncParam(
      {this.videoBitrate = 1600,
      this.videoResolution = TRTCVideoResolution.res_1280_720,
      this.videoResolutionMode = TRTCVideoResolutionMode.portrait,
      this.videoFps = 10,
      this.minVideoBitrate = 0,
      this.enableAdjustRes = false});
}

/// Network bandwidth limit parameters
///
/// The settings determine the bandwidth limit practices of the SDK in various network conditions (e.g., whether to "ensure definition" or "ensure smoothness" on a weak network).
class TRTCNetworkQosParam {
  /// - **Field description:** whether to "ensure definition" or "ensure smoothness" on a weak network
  /// - **Note**
  ///   - Smoothness is ensured on a weak network, i.e., the video image will have a lot of blurs but can be smooth with no lagging.
  ///   - Definition is ensured on a weak network, i.e., the image will be as clear as possible but tend to lag.
  TRTCVideoQosPreference preference;

  TRTCNetworkQosParam({
    this.preference = TRTCVideoQosPreference.clear,
  });
}

/// Volume
///
/// This indicates the audio volume value. You can use it to display the volume of each user in the UI.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCVolumeInfo {
  /// -  userId  of the speaker. An empty value indicates the local user.
  @JsonKey(name: 'userId')
  String userId;

  /// - Volume of the speaker. Value range: 0–100.
  @JsonKey(name: 'volume')
  int volume;

  /// - Vad result of the local user. 0: not speech 1: speech.
  @JsonKey(name: 'vad')
  int vad;

  /// - The local user's vocal frequency (unit: Hz), the value range is \[0 - 4000]. For remote users, this value is always 0.
  @JsonKey(name: 'pitch')
  double pitch;

  /// - Audio spectrum data, which divides the sound frequency into 256 frequency domains, spectrumData records the energy value of each frequency domain,
  /// - The value range of each energy value is \[-300, 0] in dBFS.
  @JsonKey(name: 'spectrumData')
  List<double>? spectrumData;

  TRTCVolumeInfo({
    this.userId = "",
    this.volume = -1,
    this.vad = -1,
    this.pitch = -1,
    this.spectrumData,
  });

  factory TRTCVolumeInfo.fromJson(Map<String, dynamic> json) =>
      _$TRTCVolumeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCVolumeInfoToJson(this);
}

/// Network quality
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCQualityInfo {
  /// - User ID
  @JsonKey(name: 'userId')
  String userId;

  /// - Network quality
  @JsonKey(name: 'quality')
  TRTCQuality quality;

  TRTCQualityInfo({
    required this.userId,
    required this.quality,
  });

  factory TRTCQualityInfo.fromJson(Map<String, dynamic> json) =>
      _$TRTCQualityInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCQualityInfoToJson(this);
}

/// Local audio/video metrics
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCLocalStatistics {
  /// - Field description: local video width in px
  @JsonKey(name: 'width')
  int width;

  /// - Field description: local video height in px
  @JsonKey(name: 'height')
  int height;

  /// - Field description: local video frame rate in fps, i.e., how many video frames there are per second
  @JsonKey(name: 'frameRate')
  int frameRate;

  /// - Field description: local video bitrate in Kbps, i.e., how much video data is generated per second
  @JsonKey(name: 'videoBitrate')
  int videoBitrate;

  /// - Field description: local audio sample rate (Hz)
  @JsonKey(name: 'audioSampleRate')
  int audioSampleRate;

  /// - Field description: local audio bitrate in Kbps, i.e., how much audio data is generated per second
  @JsonKey(name: 'audioBitrate')
  int audioBitrate;

  /// - Field description: video stream type
  @JsonKey(name: 'streamType')
  TRTCVideoStreamType streamType;

  /// - Field description: Audio equipment collection status(0：Normal；1：Long silence detected；2：Broken sound detected；3：Abnormal intermittent sound detected;)
  @JsonKey(name: 'audioCaptureState')
  int audioCaptureState;

  TRTCLocalStatistics({
    this.width = -1,
    this.height = -1,
    this.frameRate = -1,
    this.videoBitrate = -1,
    this.audioSampleRate = -1,
    this.audioBitrate = -1,
    this.streamType = TRTCVideoStreamType.big,
    this.audioCaptureState = -1,
  });

  factory TRTCLocalStatistics.fromJson(Map<String, dynamic> json) =>
      _$TRTCLocalStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCLocalStatisticsToJson(this);
}

/// Remote audio/video metrics
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCRemoteStatistics {
  /// - Field description: user ID
  @JsonKey(name: 'userId')
  String userId;

  /// - Field description: total packet loss rate (%) of the audio stream
  /// - `audioPacketLoss` represents the packet loss rate eventually calculated on the audience side after the audio/video stream goes through the complete transfer linkage of "anchor -> cloud -> audience".
  /// - The smaller the `audioPacketLoss`, the better. The packet loss rate of 0 indicates that all data of the audio stream has entirely reached the audience.
  /// - If  downLoss  is  0  but  audioPacketLoss  isn't, there is no packet loss on the linkage of "cloud -> audience" for the audiostream, but there are unrecoverable packet losses on the linkage of "anchor -> cloud".
  @JsonKey(name: 'audioPacketLoss')
  int audioPacketLoss;

  /// - Field description: total packet loss rate (%) of the video stream
  /// -  videoPacketLoss  represents the packet loss rate eventually calculated on the audience side after the audio/video stream goes through the complete transfer linkage of "anchor -> cloud -> audience".
  /// - The smaller the  videoPacketLoss , the better. The packet loss rate of 0 indicates that all data of the video stream has entirely reached the audience.
  /// - If  downLoss  is  0  but  videoPacketLoss  isn't, there is no packet loss on the linkage of "cloud -> audience" for the video stream, but there are unrecoverable packet losses on the linkage of "anchor -> cloud".
  @JsonKey(name: 'videoPacketLoss')
  int videoPacketLoss;

  /// - Field description: remote video width in px
  @JsonKey(name: 'width')
  int width;

  /// - Field description: remote video height in px
  @JsonKey(name: 'height')
  int height;

  /// - Field description: remote video frame rate (fps)
  @JsonKey(name: 'frameRate')
  int frameRate;

  /// - Field description: remote video bitrate (Kbps)
  @JsonKey(name: 'videoBitrate')
  int videoBitrate;

  /// - Field description: local audio sample rate (Hz)
  @JsonKey(name: 'audioSampleRate')
  int audioSampleRate;

  /// - Field description: local audio bitrate (Kbps)
  @JsonKey(name: 'audioBitrate')
  int audioBitrate;

  /// - Field description: playback delay (ms)
  /// - In order to avoid audio/video lags caused by network jitters and network packet disorders,
  /// - TRTC maintains a playback buffer on the playback side to organize the received network data packets.
  /// - The size of the buffer is adaptively adjusted according to the current network quality and converted to the length of time in milliseconds, i.e.,  jitterBufferDelay .
  @JsonKey(name: 'jitterBufferDelay')
  int jitterBufferDelay;

  /// - Field description: end-to-end delay (ms)
  /// - point2PointDelay  represents the delay of "anchor -> cloud -> audience".
  /// - To be more precise, it represents the delay of the entire linkage of "collection -> encoding -> network transfer -> receiving -> buffering -> decoding -> playback".
  /// - point2PointDelay  works only if both the local and remote SDKs are on version 8.5 or above.
  /// - If the remote SDK is on a version below 8.5, this value will always be 0 and thus meaningless.
  @JsonKey(name: 'point2PointDelay')
  int point2PointDelay;

  /// - Field description: cumulative audio playback lag duration (ms)
  @JsonKey(name: 'audioTotalBlockTime')
  int audioTotalBlockTime;

  /// - Field description: audio playback lag rate (%)
  /// - Audio playback lag rate (audioBlockRate) = cumulative audio playback lag duration (audioTotalBlockTime)/total audio playback duration
  @JsonKey(name: 'audioBlockRate')
  int audioBlockRate;

  /// - Field description: cumulative video playback lag duration (ms)
  @JsonKey(name: 'videoTotalBlockTime')
  int videoTotalBlockTime;

  /// - Field description: video playback lag rate (%)
  /// - Video playback lag rate (videoBlockRate) = cumulative video playback lag duration (videoTotalBlockTime)/total video playback duration
  @JsonKey(name: 'videoBlockRate')
  int videoBlockRate;

  /// - Field description: total packet loss rate (%) of the audio/video stream
  /// - Deprecated, please use audioPacketLoss and [videoPacketLoss] instead.
  @JsonKey(name: 'finalLoss')
  int finalLoss;

  /// - Field description: upstream packet loss rate (%) from the SDK to cloud
  /// - The smaller the value, the better.
  /// - If  remoteNetworkUplinkLoss  is  0% , the upstream network quality is very good, and the data packets uploaded to the cloud are basically not lost.
  /// - If  remoteNetworkUplinkLoss  is  30% , 30% of the audio/video data packets sent to the cloud by the SDK are lost on the transfer linkage.
  @JsonKey(name: 'remoteNetworkUplinkLoss')
  int remoteNetworkUplinkLoss;

  /// - Field description: round-trip delay (ms) from the SDK to cloud
  /// - This value represents the total time it takes to send a network packet from the SDK to the cloud and then send a network packet back from the cloud to the SDK, i.e.,
  /// the total time it takes for a network packet to go through the linkage of "SDK -> cloud -> SDK".
  /// - The smaller the value, the better. If  remoteNetworkRTT  is below 50 ms, it means a short audio/video call delay;
  /// if  remoteNetworkRTT  is above 200 ms, it means a long audio/video call delay.
  /// - It should be explained that  remoteNetworkRTT  represents the total time spent on the linkage of "SDK -> cloud -> SDK";
  /// therefore, there is no need to distinguish between  remoteNetworkUpRTT  and  remoteNetworkDownRTT .
  @JsonKey(name: 'remoteNetworkRTT')
  int remoteNetworkRTT;

  /// - Field description: video stream type
  @JsonKey(name: 'streamType')
  TRTCVideoStreamType streamType;

  TRTCRemoteStatistics({
    this.userId = "",
    this.audioPacketLoss = -1,
    this.videoPacketLoss = -1,
    this.width = -1,
    this.height = -1,
    this.frameRate = -1,
    this.videoBitrate = -1,
    this.audioSampleRate = -1,
    this.audioBitrate = -1,
    this.jitterBufferDelay = -1,
    this.point2PointDelay = -1,
    this.audioTotalBlockTime = -1,
    this.audioBlockRate = -1,
    this.videoTotalBlockTime = -1,
    this.videoBlockRate = -1,
    this.finalLoss = -1,
    this.remoteNetworkUplinkLoss = -1,
    this.remoteNetworkRTT = -1,
    this.streamType = TRTCVideoStreamType.big,
  });

  factory TRTCRemoteStatistics.fromJson(Map<String, dynamic> json) =>
      _$TRTCRemoteStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCRemoteStatisticsToJson(this);
}

/// Network and performance metrics
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCStatistics {
  /// - Field description: CPU utilization (%) of the current application, Android 8.0 and above systems are not supported
  @JsonKey(name: 'appCpu')
  int appCpu;

  /// - Field description: CPU utilization (%) of the current system, Android 8.0 and above systems are not supported
  @JsonKey(name: 'systemCpu')
  int systemCpu;

  /// - Field description: CPU utilization (%) of the current system, Android 8.0 and above systems are not supported
  /// - The smaller the value, the better. If  upLoss  is  0% , the upstream network quality is very good, and the data packets uploaded to the cloud are basically not lost.
  /// - If  upLoss  is  30% , 30% of the audio/video data packets sent to the cloud by the SDK are lost on the transfer linkage.
  @JsonKey(name: 'upLoss')
  int upLoss;

  /// - Field description: downstream packet loss rate (%) from cloud to the SDK
  /// - The smaller the value, the better. If  downLoss  is  0% ,
  /// the downstream network quality is very good, and the data packets received from the cloud are basically not lost.
  /// - If  downLoss  is  30% , 30% of the audio/video data packets sent to the SDK by the cloud are lost on the transfer linkage.
  @JsonKey(name: 'downLoss')
  int downLoss;

  /// - Field description: round-trip delay (ms) from the SDK to cloud
  /// - This value represents the total time it takes to send a network packet from the SDK to the cloud and then send a network packet back from the cloud to the SDK, i.e.,
  /// the total time it takes for a network packet to go through the linkage of "SDK -> cloud -> SDK".
  /// - The smaller the value, the better. If  rtt  is below 50 ms, it means a short audio/video call delay; if  rtt  is above 200 ms, it means a long audio/video call delay.
  /// - It should be explained that  rtt  represents the total time spent on the linkage of "SDK -> cloud -> SDK"; therefore, there is no need to distinguish between  upRtt  and  downRtt .
  @JsonKey(name: 'rtt')
  int rtt;

  /// - Field description: round-trip delay (ms) from the SDK to gateway
  /// - This value represents the total time it takes to send a network packet from the SDK to the gateway and then send a network packet back from the gateway to the SDK, i.e.,
  /// the total time it takes for a network packet to go through the linkage of "SDK -> gateway -> SDK".
  /// - The smaller the value, the better. If  gatewayRtt  is below 50 ms, it means a short audio/video call delay; if  gatewayRtt  is above 200 ms,
  /// it means a long audio/video call delay.
  /// - It should be explained that  gatewayRtt  is invalid for cellular network.
  @JsonKey(name: 'gatewayRtt')
  int gatewayRtt;

  /// - Field description: total number of sent bytes (including signaling data and audio/video data)
  @JsonKey(name: 'sentBytes')
  int sentBytes;

  /// - Field description: total number of received bytes (including signaling data and audio/video data)
  @JsonKey(name: 'receivedBytes')
  int receivedBytes;

  /// - Field description: local audio/video statistics
  /// - As there may be three local audio/video streams (i.e., HD big image, smooth small image, and substream image), the local audio/video statistics are an array.
  @JsonKey(name: 'localStatisticsArray')
  List<TRTCLocalStatistics>? localStatisticsArray;

  /// - Field description: remote audio/video statistics
  /// - As there may be multiple concurrent remote users, and each of them may have multiple concurrent audio/video streams (i.e., HD big image, smooth small image, and substream image), the remote audio/video statistics are an array.
  @JsonKey(name: 'remoteStatisticsArray')
  List<TRTCRemoteStatistics>? remoteStatisticsArray;

  TRTCStatistics({
    this.appCpu = -1,
    this.systemCpu = -1,
    this.upLoss = -1,
    this.downLoss = -1,
    this.rtt = -1,
    this.gatewayRtt = -1,
    this.sentBytes = -1,
    this.receivedBytes = -1,
    this.localStatisticsArray,
    this.remoteStatisticsArray,
  });

  factory TRTCStatistics.fromJson(Map<String, dynamic> json) =>
      _$TRTCStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCStatisticsToJson(this);
}

/// The Users Whose Streams to Publish
///
/// You can use this parameter together with the publishing destination parameter
/// [TRTCPublishTarget] and On-Cloud MixTranscoding parameter
/// [TRTCStreamMixingConfig] to transcode the streams you specify and publish
/// the mixed stream to the destination you specify.
class TRTCUser {
  /// - Description: UTF-8-encoded user ID (required).
  /// - Value: For example, if the ID of a user in your account system is "mike", set it to `mike`.
  String userId;

  /// - Description: Numeric room ID. The room ID must be of the same type as that in [TRTCParams].
  /// - Value range: 1-4294967294
  /// - Note: You cannot use both `intRoomId` and `strRoomId`. If you specify `strRoomId`, you need to set `intRoomId` to `0`. If you set both, only `intRoomId` will be used.
  int intRoomId;

  /// - Description: String-type room ID. The room ID must be of the same type as that in [TRTCParams].
  /// - Note: You cannot use both `intRoomId` and `strRoomId`. If you specify `roomId`, you need to leave `strRoomId` empty. If you set both, only `intRoomId` will be used.
  /// - Value: 64 bytes or shorter; supports the following character set (89 characters):
  ///   - Uppercase and lowercase letters (a-z and A-Z)
  ///   - Numbers (0-9)
  ///   - Space, "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "\[", "\]", "^", "_", "{", "}", "|", "~", and ",".
  String strRoomId;

  TRTCUser({
    this.userId = '',
    this.intRoomId = 0,
    this.strRoomId = '',
  });
}

/// The destination URL when you publish to Tencent Cloud or a third-party CDN
///
/// This enum type is used by the publishing destination parameter [TRTCPublishTarget] of the publishing API [TRTCCloud.startPublishMediaStream] .
class TRTCPublishCdnUrl {
  /// - Description: The destination URL (RTMP) when you publish to Tencent Cloud or a third-party CDN.
  /// - Value: The URLs of different CDN providers may vary greatly in format. Please enter a valid URL as required by your service provider. TRTC's backend server will push audio/video streams in the standard format to the URL you provide.
  /// - Note: The URL must be in RTMP format. It must also meet the requirements of your service provider, or your service provider may reject push requests from the TRTC backend.
  String rtmpUrl;

  /// - Description: Whether to publish to Tencent Cloud.
  /// - Value: The default value is `true`.
  /// - Note: If the destination URL you set is provided by Tencent Cloud, set this parameter to `true`, and you will not be charged relaying fees.
  bool isInternalLine;

  TRTCPublishCdnUrl({
    this.rtmpUrl = '',
    this.isInternalLine = true,
  });
}

/// The Video Layout of the Transcoded Stream
///
/// This enum type is used by the On-Cloud MixTranscoding parameter
/// [TRTCStreamMixingConfig] of the publishing API
/// [startPublishMediaStream].
///
/// You can use this parameter to specify the position, size, layer, and
/// stream type of each video in the transcoded stream.
class TRTCVideoLayout {
  /// - Description: The coordinates (in pixels) of the video.
  TRTCRect rect;

  /// - Description: The layer of the video, which must be unique. Value range: 0-15.
  int zOrder;

  /// - Description: The rendering mode.
  /// - Value: The rendering mode may be fill (the image may be stretched or cropped) or fit (there may be black bars). Default value: [TRTCVideoFillMode.fill].
  TRTCVideoFillMode fillMode;

  /// - Description: The background color of the mixed stream.
  /// - Value: The value must be a hex number. For example, "0x61B9F1" represents the RGB color value (97,158,241). Default value: 0x000000 (black).
  int backgroundColor;

  /// - Description: The URL of the placeholder image. If a user sends only audio, the image specified by the URL will be mixed during On-Cloud MixTranscoding.
  /// - Value: This parameter is left empty by default, which means no placeholder image will be used.
  /// - Note:
  ///   - You need to specify the `userId` parameter in `fixedVideoUser`.
  ///   - The URL can be 512 bytes long at most, and the image must not exceed 2 MB.
  ///   - The image can be in PNG, JPG, JPEG, or BMP format. We recommend you use a semitransparent image in PNG format.
  Uint8List placeHolderImage;

  /// - Description: The users whose streams are transcoded.
  /// - Note: If you do not specify [TRTCUser] (`userId`, `intRoomId`, `strRoomId`),
  /// the TRTC backend will automatically mix the streams of anchors who are sending audio/video in the room according to the video layout you specify.
  TRTCUser fixedVideoUser;

  /// - Description: Whether the video is the primary stream ([TRTCVideoStreamType.big]) or substream (e [TRTCVideoStreamType.sub]).
  TRTCVideoStreamType fixedVideoStreamType;

  TRTCVideoLayout({
    this.zOrder = 0,
    this.fillMode = TRTCVideoFillMode.fill,
    this.backgroundColor = 0,
    this.fixedVideoStreamType = TRTCVideoStreamType.big,
    TRTCRect? rect,
    TRTCUser? fixedVideoUser,
    Uint8List? placeHolderImage,
  })  : rect = rect ?? TRTCRect(),
        fixedVideoUser = fixedVideoUser ?? TRTCUser(),
        placeHolderImage = placeHolderImage ?? Uint8List.fromList([]);
}

/// The Watermark Layout
///
/// This enum type is used by the On-Cloud MixTranscoding parameter
/// [TRTCStreamMixingConfig] of the publishing API [startPublishMediaStream].
class TRTCWatermark {
  /// - Description: The URL of the watermark image. The image specified by the URL will be mixed during On-Cloud MixTranscoding.
  /// - Note:
  ///   - The URL can be 512 bytes long at most, and the image must not exceed 2 MB.
  ///   - The image can be in PNG, JPG, JPEG, or BMP format. We recommend you use a semitransparent image in PNG format.
  String watermarkUrl;

  /// - Description: The coordinates (in pixels) of the watermark.
  TRTCRect rect;

  /// - Description: The layer of the watermark, which must be unique. Value range: 0-15.
  int zOrder;

  TRTCWatermark({
    this.watermarkUrl = "",
    this.zOrder = 0,
    TRTCRect? rect,
  }) : rect = rect ?? TRTCRect();
}

/// The publishing destination
class TRTCPublishTarget {
  /// - Description: The publishing mode.
  /// - Value: You can relay streams to a CDN, transcode streams, or publish streams to an RTC room. Select the mode that fits your needs.
  /// - Note: If you need to use more than one publishing mode,
  /// you can call `startPublishMediaStream` multiple times and set `TRTCPublishTarget` to a different value each time.
  /// You can use one mode each time you call the `startPublishMediaStream` API. To modify the configuration, call `updatePublishCDNStream`.
  TRTCPublishMode mode;

  /// - Description: The destination URLs (RTMP) when you publish to Tencent Cloud or third-party CDNs.
  /// - Note: You don’t need to set this parameter if you set the publishing mode to `TRTCPublishMixStreamToRoom`.
  List<TRTCPublishCdnUrl> cdnUrlList;

  /// - Description: The information of the robot that publishes the transcoded stream to a TRTC room.
  /// - Note:
  ///   - You need to set this parameter only if you set the publishing mode to `TRTCPublishMixStreamToRoom`.
  ///   - After you set this parameter, the stream will be pushed to the room you specify. We recommend you set it to a special user ID to distinguish the robot from the anchor who enters the room via the TRTC SDK.
  ///   - Users whose streams are transcoded cannot subscribe to the transcoded stream.
  ///   - If you set the subscription mode to manual before room entry, you need to manage the streams to receive by yourself
  ///   (normally, if you receive the transcoded stream, you need to unsubscribe from the streams that are transcoded).
  ///   - If you set the subscription mode to auto before room entry, users whose streams are not transcoded will receive the transcoded stream automatically and
  ///   will unsubscribe from the users whose streams are transcoded. You call `muteRemoteVideoStream` and `muteRemoteAudio` to unsubscribe from the transcoded stream.
  TRTCUser mixStreamIdentity;

  TRTCPublishTarget({
    this.mode = TRTCPublishMode.unknown,
    List<TRTCPublishCdnUrl>? cdnUrlList,
    TRTCUser? mixStreamIdentity,
  })  : cdnUrlList = cdnUrlList ?? const <TRTCPublishCdnUrl>[],
        mixStreamIdentity = mixStreamIdentity ?? TRTCUser();
}

/// The encoding parameters
class TRTCStreamEncoderParam {
  /// - Description: The resolution (width) of the stream to publish.
  /// - Value: Recommended value: 368. If you mix only audio streams, to avoid displaying a black video in the transcoded stream, set both `width` and `height` to `0`.
  int videoEncodedWidth;

  /// - Description: The resolution (height) of the stream to publish.
  /// - Value: Recommended value: 640. If you mix only audio streams, to avoid displaying a black video in the transcoded stream, set both `width` and `height` to `0`.
  int videoEncodedHeight;

  /// - Description: The frame rate (fps) of the stream to publish.
  /// - Value: Value range: (0,30]. Default: 20.
  int videoEncodedFPS;

  /// - Description: The keyframe interval (GOP) of the stream to publish.
  /// - Value: Value range: [1,5]. Default: 3 (seconds).
  int videoEncodedGOP;

  /// - Description: The video bitrate (Kbps) of the stream to publish.
  /// - Value: If you set this parameter to `0`, TRTC will work out a bitrate based on `videoWidth` and `videoHeight`. For details, refer to the recommended bitrates for the constants of the resolution enum type (see comment).
  int videoEncodedKbps;

  /// - Description: The audio sample rate of the stream to publish.
  /// - Value: Valid values: [48000, 44100, 32000, 24000, 16000, 8000]. Default: 48000 (Hz).
  int audioEncodedSampleRate;

  /// - Description: The sound channels of the stream to publish.
  /// - Value: Valid values: 1 (mono channel); 2 (dual-channel). Default: 1.
  int audioEncodedChannelNum;

  /// - Description: The audio bitrate (Kbps) of the stream to publish.
  /// - Value: Value range: [32,192]. Default: 50.
  int audioEncodedKbps;

  /// - Description: The audio codec of the stream to publish.
  /// - Value: Valid values: 0 (LC-AAC); 1 (HE-AAC); 2 (HE-AACv2). Default: 0.
  /// - Note:
  ///   - The audio sample rates supported by HE-AAC and HE-AACv2 are 48000, 44100, 32000, 24000, and 16000.
  ///   - When HE-AACv2 is used, the output stream can only be dual-channel.
  int audioEncodedCodecType;

  /// - Description: The video codec of the stream to publish.
  /// - Value: Valid values: 0 (H264); 1 (H265). Default: 0.
  int videoEncodedCodecType;

  /// - Description: SEI parameters. Default: null.
  /// - Note: The parameter is passed in the form of a JSON string. Here is an example to use it:
  /// ```json
  /// {
  ///   "payLoadContent":"xxx",
  ///   "payloadType":5,
  ///   "payloadUuid":"1234567890abcdef1234567890abcdef",
  ///   "interval":1000,
  ///   "followIdr":false
  /// }
  /// ```
  /// - The currently supported fields and their meanings are as follows:
  ///   - payloadContent: Required. The payload content of the passthrough SEI, which cannot be empty.
  ///   - payloadType: Required. The type of the SEI message, with a value range of 5 or an integer within the range of [100, 254] (excluding 244, which is an internally defined timestamp SEI).
  ///   - payloadUuid: Required when payloadType is 5, and ignored in other cases. The value must be a 32-digit hexadecimal number.
  ///   - interval: Optional, default is 1000. The sending interval of the SEI, in milliseconds.
  ///   - followIdr: Optional, default is false. When this value is true, the SEI will be ensured to be carried when sending a key frame, otherwise it is not guaranteed.
  String videoSeiParams;

  TRTCStreamEncoderParam({
    this.videoEncodedWidth = 0,
    this.videoEncodedHeight = 0,
    this.videoEncodedFPS = 0,
    this.videoEncodedGOP = 0,
    this.videoEncodedKbps = 0,
    this.audioEncodedSampleRate = 0,
    this.audioEncodedChannelNum = 0,
    this.audioEncodedKbps = 0,
    this.audioEncodedCodecType = 0,
    this.videoEncodedCodecType = 0,
    this.videoSeiParams = "",
  });
}

/// The Transcoding Parameters
///
/// This enum type is used by the publishing API
/// [startPublishMediaStream].
///
/// You can use this parameter to specify the video layout and input
/// audio information for On-Cloud MixTranscoding.
class TRTCStreamMixingConfig {
  /// - Description: The background color of the mixed stream.
  /// - Value: The value must be a hex number. For example, "0x61B9F1" represents the RGB color value (97,158,241). Default value: 0x000000 (black).
  int backgroundColor;

  /// - Description: The URL of the background image of the mixed stream. The image specified by the URL will be mixed during On-Cloud MixTranscoding.
  /// - Value: This parameter is left empty by default, which means no background image will be used.
  /// - Note:
  ///   - The URL can be 512 bytes long at most, and the image must not exceed 2 MB.
  ///   - The image can be in PNG, JPG, JPEG, or BMP format. We recommend you use a semitransparent image in PNG format.
  Uint8List backgroundImage;

  /// - Description: The position, size, layer, and stream type of each video in On-Cloud MixTranscoding.
  /// - Value: This parameter is an array. Each `TRTCVideoLayout` element in the array indicates the information of a video in On-Cloud MixTranscoding.
  List<TRTCVideoLayout> videoLayoutList;

  /// - Description: The information of each audio stream to mix.
  /// - Value: This parameter is an array. Each `TRTCUser` element in the array indicates the information of an audio stream.
  /// - Note: If you do not specify this array,
  /// the TRTC backend will automatically mix all streams of the anchors who are sending audio in the room according
  /// to the audio encode param [TRTCStreamEncoderParam] you specify (currently only supports up to 16 audio and video inputs).
  List<TRTCUser> audioMixUserList;

  /// - Description: The position, size, and layer of each watermark image in On-Cloud MixTranscoding.
  /// - Value: This parameter is an array. Each `TRTCWatermark` element in the array indicates the information of a watermark.
  List<TRTCWatermark> watermarkList;

  TRTCStreamMixingConfig({
    this.backgroundColor = 0,
    Uint8List? backgroundImage,
    List<TRTCVideoLayout>? videoLayoutList,
    List<TRTCUser>? audioMixUserList,
    List<TRTCWatermark>? watermarkList,
  })  : backgroundImage = backgroundImage ?? Uint8List.fromList([]),
        videoLayoutList = videoLayoutList ?? const <TRTCVideoLayout>[],
        audioMixUserList = audioMixUserList ?? const <TRTCUser>[],
        watermarkList = watermarkList ?? const <TRTCWatermark>[];
}

/// Local media file recording parameters
class TRTCLocalRecordingParams {
  /// - Field description: Address of the recording file, which is required.
  ///   Please ensure that the path is valid with read/write permissions; otherwise, the recording file cannot be generated.
  /// - Note: This path must be accurate to the file name and extension. The extension determines the format of the recording file.
  ///   Currently, only the MP4 format is supported.
  ///   For example, if you specify the path as `mypath/record/test.mp4`, it means that you want the SDK to generate a local video file in MP4 format.
  ///   Please specify a valid path with read/write permissions; otherwise, the recording file cannot be generated.
  String filePath;

  /// - Field description: Media recording type, which is `TRTCRecordTypeBoth` by default, indicating to record both audio and video.
  TRTCLocalRecordType recordType;

  /// - Field description: `interval` is the update frequency of the recording information in milliseconds.
  ///   Value range: 1000–10000. Default value: -1, indicating not to call back.
  int interval;

  /// - Field description: `maxDurationPerFile` is the max duration of each recorded file segment, in milliseconds,
  ///   with a minimum value of 10000. The default value is 0, indicating no segmentation.
  int maxDurationPerFile;

  TRTCLocalRecordingParams({
    this.filePath = '',
    this.recordType = TRTCLocalRecordType.both,
    this.interval = -1,
    this.maxDurationPerFile = 0,
  });
}

/// Format parameter of custom audio callback
class TRTCAudioFrameCallbackFormat {
  /// - Field description: Sample rate.
  /// - Recommended value: Default value: 48000 Hz.
  ///   Valid values: 16000, 32000, 44100, 48000.
  int sampleRate;

  /// - Field description: Number of sound channels.
  /// - Recommended value: Default value: 1, which means mono channel.
  ///   Valid values: 1: mono channel; 2: dual channel.
  int channel;

  /// - Field description: Number of sample points.
  /// - Recommended value: The value must be an integer multiple of sampleRate/100.
  int samplesPerCall;

  /// - Field description: Audio callback data operation mode.
  /// - Recommended value: TRTCAudioFrameOperationModeReadOnly, get audio data from callback only.
  ///   The modes that can be set are TRTCAudioFrameOperationModeReadOnly, TRTCAudioFrameOperationModeReadWrite.
  TRTCAudioFrameOperationMode mode;

  TRTCAudioFrameCallbackFormat({
    this.sampleRate = 0,
    this.channel = 0,
    this.samplesPerCall = 0,
    this.mode = TRTCAudioFrameOperationMode.readWrite,
  });
}

/// Structure for storing window thumbnails and icons.
class TRTCImageBuffer {
  /// - image content in BGRA format
  Uint8List? buffer;

  /// - buffer size
  int length;

  /// - image width
  int width;

  /// - image height
  int height;

  TRTCImageBuffer({
    this.buffer,
    this.length = 0,
    this.width = 0,
    this.height = 0,
  });
}

/// Target information for screen sharing (desktop only)
///
/// When users perform screen sharing, they can choose to capture the entire desktop or only the window of a certain program.
///
/// TRTCScreenCaptureSourceInfo is used to describe the information of the target to be shared,
/// including ID, name, thumbnail, etc. The field information in this structure is read-only.
class TRTCScreenCaptureSourceInfo {
  /// - Collection source type (share the entire screen? Or share a window?).
  TRTCScreenCaptureSourceType type;

  /// - The ID of the collection source.
  /// - For windows, this field represents the ID of the window;
  /// for screens, this field represents the ID of the monitor.
  int viewId;

  /// - Collection source name (encoded in UTF8).
  String sourceName;

  /// - A thumbnail image of the share window.
  TRTCImageBuffer thumbBGRA;

  /// - A icon image of the share window.
  TRTCImageBuffer iconBGRA;

  /// - Whether the window is minimized.
  bool isMinimizeWindow;

  /// - Whether it is the main display (applicable to multiple monitors).
  bool isMainScreen;

  /// - Screen/window x coordinate, unit: pixel.
  int x;

  /// - Screen/window y coordinate, unit: pixel.
  int y;

  /// - Screen/window width, unit: pixels.
  int width;

  /// - Screen/window height, unit: pixels.
  int height;

  TRTCScreenCaptureSourceInfo({
    this.type = TRTCScreenCaptureSourceType.unknown,
    this.viewId = 0,
    this.sourceName = '',
    this.isMinimizeWindow = false,
    this.isMainScreen = false,
    this.x = 0,
    this.y = 0,
    this.width = 0,
    this.height = 0,
    TRTCImageBuffer? thumbBGRA,
    TRTCImageBuffer? iconBGRA,
  })  : thumbBGRA = thumbBGRA ?? TRTCImageBuffer(),
        iconBGRA = iconBGRA ?? TRTCImageBuffer();
}

/// List of screen windows.
class TRTCScreenCaptureSourceList {
  /// - Number of windows
  int count;

  /// - List of screen windows.
  List<TRTCScreenCaptureSourceInfo> sourceList;

  TRTCScreenCaptureSourceList({
    this.count = 0,
    List<TRTCScreenCaptureSourceInfo>? sourceList,
  }) : sourceList = sourceList ?? <TRTCScreenCaptureSourceInfo>[];
}

/// Advanced control parameters for screen sharing
///
/// This parameter is used in the screen sharing related interface [TRTCCloud.selectScreenCaptureTarget] to set a series of advanced control parameters when specifying the sharing target.
///
/// For example: whether to collect the mouse, whether to collect the sub-window,
/// whether to draw a border around the shared target, etc.
class TRTCScreenCaptureProperty {
  /// - Whether to collect the mouse while collecting the target content, the default is true.
  bool enableCaptureMouse;

  /// Whether to highlight the window being shared (draw a border around the shared target), the default is true.
  bool enableHighLight;

  /// - Whether to enable high-performance mode (will only take effect when sharing the screen), the default is true.
  /// - When enabled, the screen capture performance is the best,
  /// but the anti-occlusion ability will be lost.
  /// - If you enable enableHighLight + enableHighPerformance at the same time,
  /// the remote user can see the highlighted border.
  bool enableHighPerformance;

  /// - Specify the color of the highlight border in RGB format.
  /// - When 0 is passed in, the default color is used. The default color is #FFE640.
  int highLightColor;

  /// - Specify the width of the highlight border. When 0 is passed in, the default stroke width is used.
  /// - The default width is 5px, and the maximum value you can set is 50.
  int highLightWidth;

  /// - Whether to collect sub-windows when collecting windows
  /// (the sub-window and the window being collected need to have Owner or Popup attributes), the default is false.
  bool enableCaptureChildWindow;

  TRTCScreenCaptureProperty({
    this.enableCaptureMouse = true,
    this.enableHighLight = true,
    this.enableHighPerformance = true,
    this.highLightColor = 0,
    this.highLightWidth = 0,
    this.enableCaptureChildWindow = false,
  });
}

/// Network speed test result
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCSpeedTestResult {
  /// - Field description: Whether the network speed test is successful.
  @JsonKey(name: 'success')
  bool success;

  /// - Field description: Error message for network speed test.
  @JsonKey(name: 'errMsg')
  String errMsg;

  /// - Field description: Server IP address.
  @JsonKey(name: 'ip')
  String ip;

  /// - Field description: Network quality, which is tested and calculated based on the internal evaluation algorithm.
  ///   For more information, please see [TRTCQuality].
  @JsonKey(name: 'quality')
  TRTCQuality quality;

  /// - Field description: Upstream packet loss rate between 0 and 1.0.
  ///   For example, 0.3 indicates that 3 data packets may be lost in every 10 packets sent to the server.
  @JsonKey(name: 'upLostRate')
  double upLostRate;

  /// - Field description: Downstream packet loss rate between 0 and 1.0.
  ///   For example, 0.2 indicates that 2 data packets may be lost in every 10 packets received from the server.
  @JsonKey(name: 'downLostRate')
  double downLostRate;

  /// - Field description: Delay in milliseconds, which is the round-trip time between the current device and TRTC server.
  ///   The smaller the value, the better. The normal value range is 10–100 ms.
  @JsonKey(name: 'rtt')
  int rtt;

  /// - Field description: Upstream bandwidth (in kbps, -1: invalid value).
  @JsonKey(name: 'availableUpBandwidth')
  int availableUpBandwidth;

  /// - Field description: Downstream bandwidth (in kbps, -1: invalid value).
  @JsonKey(name: 'availableDownBandwidth')
  int availableDownBandwidth;

  /// - Field description: Uplink data packet jitter (ms) refers to the stability of data communication in the user's current network environment.
  ///   The smaller the value, the better. The normal value range is 0ms - 100ms.
  ///   -1 means that the speed test failed to obtain an effective value.
  ///   Generally, the Jitter of the WiFi network will be slightly larger than that of the 4G/5G environment.
  @JsonKey(name: 'upJitter')
  int upJitter;

  /// - Field description: Downlink data packet jitter (ms) refers to the stability of data communication in the user's current network environment.
  ///   The smaller the value, the better. The normal value range is 0ms - 100ms.
  ///   -1 means that the speed test failed to obtain an effective value.
  ///   Generally, the Jitter of the WiFi network will be slightly larger than that of the 4G/5G environment.
  @JsonKey(name: 'downJitter')
  int downJitter;

  TRTCSpeedTestResult({
    this.success = false,
    this.errMsg = "",
    this.ip = "",
    this.quality = TRTCQuality.unknown,
    this.upLostRate = 0.0,
    this.downLostRate = 0.0,
    this.rtt = 0,
    this.availableUpBandwidth = 0,
    this.availableDownBandwidth = 0,
    this.upJitter = 0,
    this.downJitter = 0,
  });

  factory TRTCSpeedTestResult.fromJson(Map<String, dynamic> json) =>
      _$TRTCSpeedTestResultFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCSpeedTestResultToJson(this);
}

/// Video texture data
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCTexture {
  /// - Field description: Video texture ID.
  @JsonKey(name: 'glTextureId')
  int glTextureId;

  /// - Field description: The OpenGL context to which the texture corresponds, for Windows and Android.
  @JsonKey(name: 'glContext')
  int glContext;

  /// - Field description: The D3D11 texture, which is the pointer of ID3D11Texture2D, only for Windows.
  @JsonKey(name: 'd3d11TextureId')
  int d3d11TextureId;

  TRTCTexture({
    this.glTextureId = 0,
    this.glContext = 0,
    this.d3d11TextureId = 0,
  });

  factory TRTCTexture.fromJson(Map<String, dynamic> json) =>
      _$TRTCTextureFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCTextureToJson(this);
}

/// Video frame information
///
/// `TRTCVideoFrame` is used to describe the raw data of a frame of the video image, which is the image data before frame encoding or after frame decoding.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCVideoFrame {
  /// - Field description: Video pixel format.
  @JsonKey(name: 'videoFormat')
  TRTCVideoPixelFormat videoFormat;

  /// - Field description: Video data structure type.
  @JsonKey(name: 'bufferType')
  TRTCVideoBufferType bufferType;

  /// - Field description: Video data when `bufferType` is [TRTCVideoBufferType_Texture],
  ///   which carries the texture data used for OpenGL rendering.
  @JsonKey(name: 'texture')
  TRTCTexture? texture;

  /// - Field description: Video data when `bufferType` is [TRTCVideoBufferType_Buffer],
  ///   which carries the memory data blocks for the C++ layer.
  @JsonKey(name: 'data')
  @Uint8ListConverter()
  Uint8List data;

  /// - Field description: Video data length in bytes.
  ///   For I420, length = width * height * 3 / 2; for BGRA32, length = width * height * 4.
  @JsonKey(name: 'length')
  int length;

  /// - Field description: Video width.
  ///   Recommended value: please enter the width of the video data passed in.
  @JsonKey(name: 'width')
  int width;

  /// - Field description: Video height.
  ///   Recommended value: please enter the height of the video data passed in.
  @JsonKey(name: 'height')
  int height;

  /// - Field description: Video frame timestamp in milliseconds.
  ///   Recommended value: this parameter can be set to 0 for custom video capturing.
  ///   In this case, the SDK will automatically set the `timestamp` field.
  ///   However, please "evenly" set the calling interval of `sendCustomVideoData`.
  @JsonKey(name: 'timestamp')
  int timestamp;

  /// - Field description: Clockwise rotation angle of video pixels.
  @JsonKey(name: 'rotation')
  TRTCVideoRotation rotation;

  TRTCVideoFrame({
    this.videoFormat = TRTCVideoPixelFormat.unknown,
    this.bufferType = TRTCVideoBufferType.unknown,
    this.texture,
    this.length = 0,
    this.width = 640,
    this.height = 360,
    this.timestamp = 0,
    this.rotation = TRTCVideoRotation.rotation0,
    Uint8List? data,
  }) : data = data ?? Uint8List.fromList([]);

  factory TRTCVideoFrame.fromJson(Map<String, dynamic> json) =>
      _$TRTCVideoFrameFromJson(json);

  Map<String, dynamic> toJson() => _$TRTCVideoFrameToJson(this);
}

/// Audio frame data
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class TRTCAudioFrame {
  /// - Field description: Audio frame format.
  @JsonKey(name: 'audioFormat')
  TRTCAudioFrameFormat audioFormat;

  /// - Field description: Audio data.
  @JsonKey(name: 'data')
  @Uint8ListConverter()
  Uint8List data;

  /// - Field description: Audio data length.
  @JsonKey(name: 'length')
  int length;

  /// - Field description: Sample rate.
  @JsonKey(name: 'sampleRate')
  int sampleRate;

  /// - Field description: Number of sound channels.
  @JsonKey(name: 'channel')
  int channel;

  /// - Field description: Timestamp in ms.
  @JsonKey(name: 'timestamp')
  int timestamp;

  /// - Field description: Extra data in audio frame.
  ///   Message sent by remote users through `onLocalProcessedAudioFrame` that adds to audio frame will be callback through this field.
  @JsonKey(name: 'extraData')
  @Uint8ListConverter()
  Uint8List extraData;

  /// - Field description: Extra data length.
  @JsonKey(name: 'extraDataLength')
  int extraDataLength;

  TRTCAudioFrame({
    this.audioFormat = TRTCAudioFrameFormat.none,
    this.length = 0,
    this.sampleRate = 0,
    this.channel = 0,
    this.timestamp = 0,
    this.extraDataLength = 0,
    Uint8List? data,
    Uint8List? extraData,
  })  : data = data ?? Uint8List.fromList([]),
        extraData = extraData ?? Uint8List.fromList([]);

  factory TRTCAudioFrame.fromJson(Map<String, dynamic> json) =>
      _$TRTCAudioFrameFromJson(json);

  factory TRTCAudioFrame.fromJsonWithData(
      Map<String, dynamic> json, Uint8List audioData) {
    return TRTCAudioFrame(
      audioFormat: json['audioFormat'] != null
          ? TRTCAudioFrameFormat.values.firstWhere(
              (e) => e.index == json['audioFormat'],
              orElse: () => TRTCAudioFrameFormat.none,
            )
          : TRTCAudioFrameFormat.none,
      data: audioData,
      length: (json['length'] as num?)?.toInt() ?? audioData.length,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 0,
      channel: (json['channel'] as num?)?.toInt() ?? 0,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      extraData: json['extraData'] != null
          ? const Uint8ListConverter().fromJson(json['extraData'] as String)
          : Uint8List.fromList([]),
      extraDataLength: (json['extraDataLength'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$TRTCAudioFrameToJson(this);
}

/// Network speed testing parameters
class TRTCSpeedTestParams {
  /// - Field description: Application identification, please refer to the relevant instructions in [TRTCParams].
  int sdkAppId;

  /// - Field description: User identification, please refer to the relevant instructions in [TRTCParams].
  String userId;

  /// - Field description: User signature, please refer to the relevant instructions in [TRTCParams].
  String userSig;

  /// - Field description: Expected upstream bandwidth (kbps, value range: 10 to 5000, no uplink bandwidth test when it is 0).
  /// - **Note**: When the parameter `scene` is set to `TRTCSpeedTestScene_OnlineChorusTesting`,
  ///   in order to obtain more accurate information such as RTT/jitter, the value range is limited to 10 ~ 1000.
  int expectedUpBandwidth;

  /// - Field description: Expected downstream bandwidth (kbps, value range: 10 to 5000, no downlink bandwidth test when it is 0).
  /// - **Note**: When the parameter `scene` is set to `TRTCSpeedTestScene_OnlineChorusTesting`,
  ///   in order to obtain more accurate information such as RTT/jitter, the value range is limited to 10 ~ 1000.
  int expectedDownBandwidth;

  /// - Field description: Speed test scene.
  TRTCSpeedTestScene scene;

  TRTCSpeedTestParams({
    this.sdkAppId = 0,
    this.userId = "",
    this.userSig = "",
    this.expectedUpBandwidth = 0,
    this.expectedDownBandwidth = 0,
    this.scene = TRTCSpeedTestScene.delayAndBandwidthTesting,
  });
}

/// @nodoc
class TRTCLogParams {
  TRTCLogLevel level;

  bool consoleEnabled;

  bool compressEnabled;

  String filePath;

  TRTCLogParams({
    this.level = TRTCLogLevel.verbose,
    this.consoleEnabled = false,
    this.compressEnabled = true,
    this.filePath = "",
  });
}

/// @nodoc
class TRTCPlatform {
  static bool isAndroid = Platform.isAndroid;

  static bool isIOS = Platform.isIOS;

  static bool isMacOS = Platform.isMacOS;

  static bool isWindows = Platform.isWindows;

  static bool isLinux = Platform.isLinux;

  static bool isOhos = !(Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows ||
      Platform.isLinux);
}

/// @nodoc
class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) {
    List<int> list = json.codeUnits;
    return Uint8List.fromList(list);
  }

  @override
  String toJson(Uint8List object) {
    return String.fromCharCodes(object);
  }
}
