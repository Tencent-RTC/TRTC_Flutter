import 'dart:typed_data';

import 'package:tencent_trtc_cloud/trtc_cloud.dart';

/// Key class definition variable
class TRTCCloudDef {
  // @name 1.1. Video resolution
  // Here, only the landscape resolution is defined. If the portrait resolution (e.g., 360x640) needs to be used, `Portrait` must be selected for `TRTCVideoResolutionMode`.

  // Aspect ratio: 1:1
  /// Recommended bitrate: VideoCall: 80 Kbps, LIVE: 120 Kbps
  static final int TRTC_VIDEO_RESOLUTION_120_120 = 1;

  /// Recommended bitrate: VideoCall: 100 Kbps, LIVE: 150 Kbps
  static final int TRTC_VIDEO_RESOLUTION_160_160 = 3;

  /// Recommended bitrate: VideoCall: 200 Kbps, LIVE: 120 Kbps
  static final int TRTC_VIDEO_RESOLUTION_270_270 = 5;

  /// Recommended bitrate: VideoCall: 350 Kbps, LIVE: 120 Kbps
  static final int TRTC_VIDEO_RESOLUTION_480_480 = 7;

  // Aspect ratio: 4:3
  /// Recommended bitrate: VideoCall: 100 Kbps, LIVE: 150 Kbps
  static final int TRTC_VIDEO_RESOLUTION_160_120 = 50;

  /// Recommended bitrate: VideoCall: 150 Kbps, LIVE: 225 Kbps
  static final int TRTC_VIDEO_RESOLUTION_240_180 = 52;

  /// Recommended bitrate: VideoCall: 200 Kbps, LIVE: 300 Kbps
  static final int TRTC_VIDEO_RESOLUTION_280_210 = 54;

  /// Recommended bitrate: VideoCall: 250 Kbps, LIVE: 375 Kbps
  static final int TRTC_VIDEO_RESOLUTION_320_240 = 56;

  /// Recommended bitrate: VideoCall: 300 Kbps, LIVE: 450 Kbps
  static final int TRTC_VIDEO_RESOLUTION_400_300 = 58;

  /// Recommended bitrate: VideoCall: 400 Kbps, LIVE: 600 Kbps
  static final int TRTC_VIDEO_RESOLUTION_480_360 = 60;

  /// Recommended bitrate: VideoCall: 600 Kbps, LIVE: 900 Kbps
  static final int TRTC_VIDEO_RESOLUTION_640_480 = 62;

  /// Recommended bitrate: VideoCall: 1000 Kbps, LIVE: 1500 Kbps
  static final int TRTC_VIDEO_RESOLUTION_960_720 = 64;

  // Aspect ratio: 16:9
  /// Recommended bitrate: VideoCall: 150 Kbps, LIVE: 250 Kbps
  static final int TRTC_VIDEO_RESOLUTION_160_90 = 100;

  /// Recommended bitrate: VideoCall: 200 Kbps, LIVE: 300 Kbps
  static final int TRTC_VIDEO_RESOLUTION_256_144 = 102;

  /// Recommended bitrate: VideoCall: 250 Kbps, LIVE: 400 Kbps
  static final int TRTC_VIDEO_RESOLUTION_320_180 = 104;

  /// Recommended bitrate: VideoCall: 350 Kbps, LIVE: 550 Kbps
  static final int TRTC_VIDEO_RESOLUTION_480_270 = 106;

  /// Recommended bitrate: VideoCall: 550 Kbps, LIVE: 900 Kbps
  static final int TRTC_VIDEO_RESOLUTION_640_360 = 108;

  /// Recommended bitrate: VideoCall: 850 Kbps, LIVE: 1300 Kbps
  static final int TRTC_VIDEO_RESOLUTION_960_540 = 110;

  /// Recommended bitrate: VideoCall: 1200 Kbps, LIVE: 1800 Kbps
  static final int TRTC_VIDEO_RESOLUTION_1280_720 = 112;

  /// Recommended bitrate: VideoCall: 2000 Kbps, LIVE: 3000 Kbps
  static final int TRTC_VIDEO_RESOLUTION_1920_1080 = 114;

  /**
    *  @name 1.2. Video aspect ratio mode
	  *
    * - Landscape resolution: TRTCVideoResolution_640_360 + TRTCVideoResolutionModeLandscape = 640x360
    * - Portrait resolution: TRTCVideoResolution_640_360 + TRTCVideoResolutionModePortrait = 360x640
    * 
    * 
    */
  /// Landscape resolution
  static final int TRTC_VIDEO_RESOLUTION_MODE_LANDSCAPE = 0;

  /// Portrait resolution
  static final int TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT = 1;

  /** 
   * @name 1.3. Video stream type
   *
   * TRTC provides three different audio/video streams, including:
   * - Primary image: the most used channel, which is generally used to transfer video data from the camera.
   * - Small image: it is similar to the primary image, but with lower resolution and bitrate.
   * - Substream image: it is generally used for screen sharing and remote video playback (for example, a teacher plays back a video to students).
   *
   * @note 
   * - If the upstream network and performance of the anchor is good, the big and small images can be sent at the same time. 
   * - The SDK does not support enabling only the small image, which must be enabled together with the primary image.
   *
   */
  /// Primary image video stream
  static const int TRTC_VIDEO_STREAM_TYPE_BIG = 0;

  /// Small image video stream
  static final int TRTC_VIDEO_STREAM_TYPE_SMALL = 1;

  /// Substream (screen sharing)
  static final int TRTC_VIDEO_STREAM_TYPE_SUB = 2;

  /**
     * @name 1.4. Video (or Network) Quality Constant Definition
     *The TRTC SDK defines six levels of image quality, among which "Excellent" stands for the best quality, and "Down" indicates that the image quality is unavailable.
     */
  /// Undefined
  static final int TRTC_QUALITY_UNKNOWN = 0;

  /// Excellent
  static final int TRTC_QUALITY_Excellent = 1;

  /// Good
  static final int TRTC_QUALITY_Good = 2;

  /// Poor
  static final int TRTC_QUALITY_Poor = 3;

  /// Bad
  static final int TRTC_QUALITY_Bad = 4;

  /// Very bad
  static final int TRTC_QUALITY_Vbad = 5;

  /// Unavailable
  static final int TRTC_QUALITY_Down = 6;

  /**
   * @name 1.5. Video image fill mode
   * If the video image's display resolution is different from its original resolution, the fill mode needs to be set as follows:
   * - TRTCVideoFillMode_Fill: the entire screen will be covered by the image, where parts that exceed the screen will be cropped, and the displayed image may be incomplete.
   * - TRTCVideoFillMode_Fit: the long side of the image will fit the screen, while the short side will be proportionally scaled with unmatched areas being filled with black color blocks. The displayed image is complete.
   */
  /// The entire screen will be covered by the image, where parts that exceed the screen will be cropped
  static const int TRTC_VIDEO_RENDER_MODE_FILL = 0;

  /// The long side of the image will fit the screen, while the short side will be proportionally scaled with unmatched areas being filled with black color blocks
  static const int TRTC_VIDEO_RENDER_MODE_FIT = 1;

  /// Scale-to-fill mode: This means that regardless of the aspect ratio of the image, it will be stretched or compressed to completely fill the display area. In this mode, the aspect ratio of the image may be altered, leading to distortion in the
  /// rendered image.
  static const int TRTC_VIDEO_RENDER_MODE_SCALE_FILL = 2;

  /**
   * @name 1.6. Video image rotation direction
   * The TRTC SDK provides rotation angle setting APIs for local and remote images. The following rotation angles are all clockwise.
   */
  /// No rotation
  static const int TRTC_VIDEO_ROTATION_0 = 0;

  /// Rotate 90 degrees clockwise
  static final int TRTC_VIDEO_ROTATION_90 = 1;

  /// Rotate 180 degrees clockwise
  static final int TRTC_VIDEO_ROTATION_180 = 2;

  /// Rotate 270 degrees clockwise
  static final int TRTC_VIDEO_ROTATION_270 = 3;

  /**
   * @name 1.7. Beauty (skin smoothing) filter algorithm
   * 
   * The TRTC SDK has multiple built-in skin smoothing algorithms. You can select the one most suitable for your product needs.
   * 
   */
  /// Smooth style, which is suitable for shows since it has more obvious effect.
  static final int TRTC_BEAUTY_STYLE_SMOOTH = 0;

  /// Natural style, which retains more facial details and seems more natural subjectively.
  static final int TRTC_BEAUTY_STYLE_NATURE = 1;

  /// Pitu style, which is more natural and retains more skin details than the smooth style.
  static final int TRTC_BEAUTY_STYLE_PITU = 2;

  /**
   * @name 1.8. Video pixel format
   * 
   * The TRTC SDK provides custom video capturing and rendering features. For the custom capturing feature, you can use the following enumerated values to describe the pixel format of the video you capture.
   * For the custom rendering feature, you can specify the pixel format of the video you expect the SDK to call back.
   * 
   */
  /// Unknown
  static final int TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN = 0;

  /// YUV I420
  static final int TRTC_VIDEO_PIXEL_FORMAT_I420 = 1;

  /// OpenGL 2D texture
  static final int TRTC_VIDEO_PIXEL_FORMAT_Texture_2D = 2;

  /// OES external texture format (for Android platform)
  static final int TRTC_VIDEO_PIXEL_FORMAT_TEXTURE_EXTERNAL_OES = 3;
  
  /// NV21 texture
  static final int TRTC_VIDEO_PIXEL_FORMAT_NV21 = 4;

  /**
   * @name 1.9. Mirror type for local video image preview
   *
   * The TRTC SDK provides a mirror setting feature for the local preview image. The default mirror type is `AUTO`.
   */
  /// The SDK determines the mirror type: mirroring the front camera's image bur not the rear camera's image
  static const int TRTC_VIDEO_MIRROR_TYPE_AUTO = 0;

  /// Mirror the images of both the front and rear cameras
  static final int TRTC_VIDEO_MIRROR_TYPE_ENABLE = 1;

  /// Do not mirror the images of both the front and rear cameras
  static final int TRTC_VIDEO_MIRROR_TYPE_DISABLE = 2;

  /** 
     * @name 2.1. Use cases
     * TRTC can be used in various application scenarios such as videoconferencing and video live streaming. The TRTC SDK provides different optimized configurations for different scenarios.
     * - TRTC_APP_SCENE_VIDEOCALL: video call scenario. Use cases: [one-to-one video call], [video conferencing with up to 300 participants], [online medical diagnosis], [video chat], [video interview], etc.              
     * - TRTC_APP_SCENE_LIVE: interactive video live streaming scenario. Use cases: [low-latency video live streaming], [interactive classroom for up to 100,000 participants], [live video competition], [video dating room], [remote training], [large-scale conferencing], etc.
     * - TRTC_APP_SCENE_AUDIOCALL: audio call scenario. Use cases: [one-to-one audio call], [audio conferencing with up to 300 participants], [voice chat], [online Werewolf], etc.
     * - TRTC_APP_SCENE_VOICE_CHATROOM: interactive audio live streaming scenario. Use cases: [low-latency audio live streaming], [live audio co-anchoring], [voice chat room], [karaoke room], [FM radio], etc.
     */
  /// In the video call scenario, 720p and 1080p HD image quality is supported. A single room can sustain up to 300 concurrent online users, and up to 50 of them can speak simultaneously.
  ///
  /// Use cases: \[one-to-one video call], \[video conferencing with up to 300 participants], \[online medical diagnosis], \[video chat], \[video interview], etc.
  static final int TRTC_APP_SCENE_VIDEOCALL = 0;

  /// In the interactive video live streaming scenario, mic can be turned on/off smoothly without waiting for switchover, and the anchor latency is as low as less than 300 ms. Live streaming to hundreds of thousands of concurrent audience users is supported with the playback latency down to 1,000 ms.
  ///
  /// Use cases: \[low-latency video live streaming], \[interactive classroom for up to 100,000 participants], \[live video competition], \[video dating room], \[remote training], \[large-scale conferencing], etc.
  ///
  /// **Note:** in this scenario, you must use the `role` field in `TRTCParams` to specify the role of the current user.
  static final int TRTC_APP_SCENE_LIVE = 1;

  /// In the audio call scenario, 48 kHz dual-channel audio call is supported. A single room can sustain up to 300 concurrent online users, and up to 50 of them can speak simultaneously.
  ///
  /// Use cases: \[one-to-one audio call], \[audio conferencing with up to 300 participants], \[voice chat], \[online Werewolf], etc.
  static final int TRTC_APP_SCENE_AUDIOCALL = 2;

  /// In the interactive audio live streaming scenario, mic can be turned on/off smoothly without waiting for switchover, and the anchor latency is as low as less than 300 ms. Live streaming to hundreds of thousands of concurrent audience users is supported with the playback latency down to 1,000 ms.
  ///
  /// Use cases: \[low-latency audio live streaming], \[live audio co-anchoring], \[voice chat room], \[karaoke room], \[FM radio], etc.
  ///
  /// **Note:** in this scenario, you must use the `role` field in [TRTCParams] to specify the role of the current user.
  static final int TRTC_APP_SCENE_VOICE_CHATROOM = 3;

  /*
    * @name 2.2. Role (applicable only to the live streaming scenarios `TRTC_APP_SCENE_LIVE` and `TRTC_APP_SCENE_VOICE_CHATROOM`)
    *
    * In the live streaming scenario, most users are audience, and only several users are anchors. The differentiation in roles can help TRTC implement better and more specific optimization.
    *
    * - Anchor: anchor, who can upstream video and audio. Up to 50 anchors are allowed to upstream videos at the same time in one room.
    * - Audience: audience, who can only watch the video but cannot upstream video or audio. There is no upper limit for the number of audience users in one room.
    */
  /// Anchor
  static const int TRTCRoleAnchor = 20;

  /// Audience
  static const int TRTCRoleAudience = 21;

  /*
     * @name 2.3. Bandwidth limit mode
     *
     * The TRTC SDK needs to adjust the internal codecs and network module based on the network conditions in real time to respond to network changes.
     * To support fast algorithm upgrade, the SDK provides two network bandwidth limit modes:
     * - ModeServer: on-cloud control, which is the default and recommended mode.
     * - ModeClient: client-based control, which is for internal debugging of SDK and should not be used.
     *
     * @note We recommend you use on-cloud control, so that when the QoS algorithm is upgraded, you do not need to upgrade the SDK to get a better experience.
     *
     */
  /// Client-based control (which is for internal debugging of the SDK and should not be used)
  static final int VIDEO_QOS_CONTROL_CLIENT = 0;

  /// On-cloud control (default value)
  static final int VIDEO_QOS_CONTROL_SERVER = 1;

  /*
  * @name 2.4. Image quality preference
  *
  * This specifies whether to "ensure smoothness" or "ensure definition" when the TRTC SDK is used on a weak network. Both modes will give priority to the transfer of audio data.
  *
  * - Smooth: this mode ensures smoothness on a weak network. If the user's network connection is poor, the video image will become blurry.
  * - Clear: this mode (default value) ensures definition on a weak network. If the user's network connection is poor, the video image may lag, but the definition will not drop significantly.
  *
  */
  /// Ensure smoothness on a weak network
  static final int TRTC_VIDEO_QOS_PREFERENCE_SMOOTH = 1;

  /// Ensure definition on a weak network (default value)
  static final int TRTC_VIDEO_QOS_PREFERENCE_CLEAR = 2;

  /*
     * @name 3.1. Audio sample rate
     *
     * The audio sample rate is used to measure the audio fidelity. A higher sample rate indicates higher fidelity. If there is music in the use case, `TRTCAudioSampleRate48000` is recommended.
     */
  /// 16 kHz sample rate
  static final int TRTCAudioSampleRate16000 = 16000;

  /// 32 kHz sample rate
  static final int TRTCAudioSampleRate32000 = 32000;

  /// 44.1 kHz sample rate
  static final int TRTCAudioSampleRate44100 = 44100;

  /// 48 kHz sample rate
  static final int TRTCAudioSampleRate48000 = 48000;

  /**
     * @name 3.2. Sound quality
     *
     * Sound quality is used to measure the fidelity of the sound.
     */
  /// Smooth: sample rate: 16 kHz; mono channel; audio bitrate: 16 Kbps. This is suitable for audio call scenarios, such as online meeting and audio call.
  static final int TRTC_AUDIO_QUALITY_SPEECH = 1;

  /// Default: sample rate: 48 kHz; mono channel; audio bitrate: 50 Kbps. This is the default sound quality of the SDK and recommended if there are no special requirements.
  static final int TRTC_AUDIO_QUALITY_DEFAULT = 2;

  /// HD: sample rate: 48 kHz; dual channel + full band; audio bitrate: 128 Kbps. This is suitable for scenarios where Hi-Fi music transfer is required, such as karaoke and music live streaming.
  static final int TRTC_AUDIO_QUALITY_MUSIC = 3;

  /*
     * @name 3.3. Audio playback mode (audio routing)
     *
     * Both the video call features in WeChat and Mobile QQ have a hands-free mode during call. This mode is implemented based on audio routing.
     * Generally, a mobile phone has two speakers, and the purpose of setting audio routing is to determine which speaker will be used:
     * - Speakerphone: speaker at the bottom of a phone, which has high volume and is suitable for playing back music.
     * - Earpiece: receiver at the top of a phone, which has low volume and is suitable for calls.
     */
  /// Speaker
  static final int TRTC_AUDIO_ROUTE_SPEAKER = 0;

  /// Headphones
  static final int TRTC_AUDIO_ROUTE_EARPIECE = 1;

  /// WiredHeadset
  static final int TRTC_AUDIO_ROUTE_WIREDHEADSET = 2;

  /// BluetoothHeadset
  static final int TRTC_AUDIO_ROUTE_BLUETOOTHHEADSET = 3;

  /// SoundCard
  static final int TRTC_AUDIO_ROUTE_SOUNDCARD = 4;

  /*
     * @name 3.4. Audio reverb mode
     */
  /// Disable reverb
  static final int TRTC_REVERB_TYPE_0 = 0;

  /// KTV
  static final int TRTC_REVERB_TYPE_1 = 1;

  /// Small room
  static final int TRTC_REVERB_TYPE_2 = 2;

  /// Big hall
  static final int TRTC_REVERB_TYPE_3 = 3;

  /// Deep
  static final int TRTC_REVERB_TYPE_4 = 4;

  /// Resonant
  static final int TRTC_REVERB_TYPE_5 = 5;

  /// Metallic
  static final int TRTC_REVERB_TYPE_6 = 6;

  /// Husky
  static final int TRTC_REVERB_TYPE_7 = 7;

  /*
    * @name 3.5. Voice changing type
    */
  /// Disable voice changing
  static final int TRTC_VOICE_CHANGER_TYPE_0 = 0;

  /// Naughty boy
  static final int TRTC_VOICE_CHANGER_TYPE_1 = 1;

  /// Young girl
  static final int TRTC_VOICE_CHANGER_TYPE_2 = 2;

  /// Middle-Aged man
  static final int TRTC_VOICE_CHANGER_TYPE_3 = 3;

  /// Heavy metal
  static final int TRTC_VOICE_CHANGER_TYPE_4 = 4;

  /// Cold
  static final int TRTC_VOICE_CHANGER_TYPE_5 = 5;

  /// Punk
  static final int TRTC_VOICE_CHANGER_TYPE_6 = 6;

  /// Furious animal
  static final int TRTC_VOICE_CHANGER_TYPE_7 = 7;

  /// Chubby
  static final int TRTC_VOICE_CHANGER_TYPE_8 = 8;

  /// Strong electric current
  static final int TRTC_VOICE_CHANGER_TYPE_9 = 9;

  /// Robot
  static final int TRTC_VOICE_CHANGER_TYPE_10 = 10;

  /// Ethereal
  static final int TRTC_VOICE_CHANGER_TYPE_11 = 11;

  /*
    * @name 3.6. Audio frame format
    */
  /// PCM
  static final int TRTC_AUDIO_FRAME_FORMAT_PCM = 1;

  /*
     * @name 3.7. System volume type
     *
     * Smartphones usually have two system volume types, i.e., call volume and media volume.
     * - Call volume is specially designed for call scenarios on mobile phones. It uses the acoustic echo cancellation (AEC) feature built in phones and has a lower sound quality than media volume.
	 *             Its volume cannot be adjusted to 0 with volume buttons, but it supports mics on Bluetooth earphones.
     *
     * - Media volume is specially designed for music scenarios on mobile phones. It has a higher sound quality than call volume, and its volume can be adjusted to 0 with volume buttons.
	 *             When using it, if you want to enable the AEC feature, the SDK will enable its built-in acoustic processing algorithms to further process the audio.
	 *             With media volume, only the mics on phones instead of those on Bluetooth earphones can be used to capture audio.
     *
     * Currently, the SDK provides three control modes of system volume types, including:
     * - Auto: "call volume with mic and media volume without mic", i.e., the call volume mode will be used when the anchor mics on, while the media volume mode will be used when the audience user mics off. This is suitable for live streaming scenarios.
	 *         If the scenario you select during `enterRoom` is `TRTC_APP_SCENE_LIVE` or `TRTC_APP_SCENE_VOICE_CHATROOM`, the SDK will automatically select this mode.
	 *
	 * - VOIP: the call volume mode will be always used, which is suitable for conferencing scenarios.
	 *         If the scenario you select during `enterRoom` is `TRTC_APP_SCENE_VIDEOCALL` or `TRTC_APP_SCENE_AUDIOCALL`, the SDK will automatically select this mode.
     *
     * - Media: the media volume mode is used throughout the call. This is not common and is suitable for scenarios with special requirements (for example, the anchor has an external sound card).
     *
     * @{
     */
  /// "Call volume with mic and media volume without mic", i.e., the call volume mode will be used when the anchor mics on, while the media volume mode will be used when the audience user mics off. This is suitable for live streaming scenarios.
  ///
  /// If the scenario you select during `enterRoom` is [TRTC_APP_SCENE_LIVE] or [TRTC_APP_SCENE_VOICE_CHATROOM], the SDK will automatically select this mode.
  static final int TRTCSystemVolumeTypeAuto = 0;

  /// The media volume mode is used throughout the call. This is not common and is suitable for scenarios with special requirements (for example, the anchor has an external sound card).
  static final int TRTCSystemVolumeTypeMedia = 1;

  /// The call volume mode will be always used, which is suitable for conferencing scenarios.
  ///
  /// If the scenario you select during `enterRoom` is [TRTC_APP_SCENE_VIDEOCALL] or [TRTC_APP_SCENE_AUDIOCALL], the SDK will automatically select this mode.
  static final int TRTCSystemVolumeTypeVOIP = 2;

  /*
    * @name 4.1. UI debugging log
    */
  /// The UI doesn't display logs
  static final int TRTC_DEBUG_VIEW_LEVEL_GONE = 0;

  /// The upper part of the UI displays the status logs
  static final int TRTC_DEBUG_VIEW_LEVEL_STATUS = 1;

  /// The upper part of the UI displays the status logs, and the lower part displays the key events
  static final int TRTC_DEBUG_VIEW_LEVEL_ALL = 2;

  /*
     * @name 4.2. Log level
     *
     * Different log levels indicate different levels of details and number of logs. We recommend you set the log level to `TRTC_LOG_LEVEL_INFO` generally.
     */
  /// Output logs at all levels
  static final int TRTC_LOG_LEVEL_VERBOSE = 0;

  /// Output logs at the DEBUG, INFO, WARNING, ERROR, and FATAL levels
  static final int TRTC_LOG_LEVEL_DEBUG = 1;

  /// Output logs at the INFO, WARNING, ERROR, and FATAL levels
  static final int TRTC_LOG_LEVEL_INFO = 2;

  /// Output logs at the WARNING, ERROR, and FATAL levels
  static final int TRTC_LOG_LEVEL_WARN = 3;

  /// Output logs at the ERROR and FATAL levels
  static final int TRTC_LOG_LEVEL_ERROR = 4;

  /// Output logs at the FATAL level
  static final int TRTC_LOG_LEVEL_FATAL = 5;

  /// Do not output any SDK logs
  static final int TRTC_LOG_LEVEL_NULL = 6;

  /**
   * @name 4.3. G-sensor switch
   *
   * This configuration item applies to mobile devices such as phones and tablets.
   *
   * - Disable: the upstreamed video image (i.e., the image of the current user seen by other users in the room) will not be adjusted automatically following the orientation of G-sensor.
   * - UIAutoLayout: the upstreamed video image (i.e., the image of the current user seen by other users in the room) will be automatically adjusted following the orientation of the status bar on the current UI. This is the default value.
   * - UIFixLayout: this is to be disused and equivalent to `UIAutoLayout`.
   */
  ///  Disable G-sensor
  static final int TRTC_GSENSOR_MODE_DISABLE = 0;

  ///  Enable G-sensor (default value).
  static final int TRTC_GSENSOR_MODE_UIAUTOLAYOUT = 1;

  ///  This is to be disused and equivalent to `UIAutoLayout`.
  static final int TRTC_GSENSOR_MODE_UIFIXLAYOUT = 2;

  /**
     * @name 4.4. Mixtranscoding parameter configuration mode
     *
     */
  /// Invalid value
  static const int TRTC_TranscodingConfigMode_Unknown = 0;

  /// Manual mode. It is most flexible and can implement various mixtranscoding schemes through free combinations, but it is most difficult to use.
  ///
  /// In this mode, you need to enter all the parameters in [TRTCTranscodingConfig] and listen on the `onUserVideoAvailable()` and `onUserAudioAvailable()` callbacks in `TRTCCloudDelegate`
  ///
  /// so as to constantly adjust the `mixUsers` parameter according to the audio/video status of each user with mic on in the current room; otherwise, mixtranscoding will fail.
  static final int TRTC_TranscodingConfigMode_Manual = 1;

  /// PureAudio mode. It is suitable for pure audio scenarios such as audio call (AudioCall) and voice chat room (VoiceChatRoom).
  ///
  /// You only need to set it once through the `setMixTranscodingConfig()` API after room entry, and then the SDK will automatically mix the audios of all mic-on users in the room into the current user's live stream.
  ///
  /// In this mode, you don't need to set the `mixUsers` parameter in [TRTCTranscodingConfig]; instead, you only need to set the `audioSampleRate`, `audioBitrate` and `audioChannels` parameters.
  static final int TRTC_TranscodingConfigMode_Template_PureAudio = 2;

  /// Preset layout mode, where the layout of each channel of image is arranged in advance through placeholders.
  ///
  /// In this mode, you still need to set the `mixUsers` parameter, but you can set `userId` as a placeholder. Placeholder values include:
  ///
  /// - "$PLACE_HOLDER_REMOTE$": image of remote user. Multiple images can be set.
  /// - "$PLACE_HOLDER_LOCAL_MAIN$": local camera image. Only one image can be set.
  /// - "$PLACE_HOLDER_LOCAL_SUB$": local screen sharing image. Only one image can be set.
  ///
  /// However, you don't need to listen on the `onUserVideoAvailable()` and `onUserAudioAvailable()` callbacks in `TRTCCloudDelegate` to make real-time adjustments.
  ///
  /// Instead, you only need to call `setMixTranscodingConfig()` once after successful room entry. Then, the SDK will automatically populate the placeholders you set with real `userId` values.
  static final int TRTC_TranscodingConfigMode_Template_PresetLayout = 3;

  /// Screen sharing mode, which is suitable for screen sharing-based use cases such as online education and supported only by the SDKs for Windows and macOS.
  ///
  /// The SDK will first build a canvas according to the target resolution you set (through the `videoWidth` and `videoHeight` parameters).
  /// Before the teacher enables screen sharing, the SDK will scale up the camera image proportionally and draw it onto the canvas. After the teacher enables screen sharing, the SDK will draw the video image shared on the screen onto the same canvas.
  /// The purpose of this procedure is to ensure consistency in the output resolution of the mixtranscoding module and avoid problems with blurred screen during course replay and webpage playback (web players don't support adjustable resolution).
  /// Meanwhile, the audios of mic-on students will be mixed into the teacher's audio/video stream by default.
  ///
  /// Video content is primarily the shared screen in teaching mode, and it is a waste of bandwidth to transfer camera image and screen image at the same time.
  /// Therefore, the recommended practice is to directly draw the camera image onto the current screen through the `setLocalVideoRenderCallback` API.
  /// In this mode, you don't need to set the `mixUsers` parameter in [TRTCTranscodingConfig], and the SDK will not mix students' images so as not to interfere with the screen sharing effect.
  ///
  /// You can set width x height in [TRTCTranscodingConfig] to 0 px x 0 px, and the SDK will automatically calculate a suitable resolution based on the aspect ratio of the user's current screen.
  /// - If the teacher's current screen width is less than or equal to 1920 px, the SDK will use the actual resolution of the teacher's current screen.
  /// - If the teacher's current screen width is greater than 1920 px, the SDK will select one of the three resolutions of 1920x1080 (16:9), 1920x1200 (16:10), and 1920x1440 (4:3) according to the current screen aspect ratio.
  static final int TRTC_TranscodingConfigMode_Template_ScreenSharing = 4;

  /// Platformview rendering.Use `TextureView` for Android video rendering
  static final String TRTC_VideoView_TextureView = 'trtcCloudChannelView';

  /// Platformview rendering.Use `SurfaceView` for Android video rendering
  static final String TRTC_VideoView_SurfaceView =
      'trtcCloudChannelSurfaceView';

  /// Texture rendering. By default, the push-pull flow will start, and the onviewcreated callback will not be triggered. MacOS and Windows only support this kind of rendering
  // ignore: non_constant_identifier_names
  static final String TRTC_VideoView_Texture = 'Texture';

  /// Android video rendering uses virtual display mode, which is used by default. This parameter is only valid for Android
  // ignore: non_constant_identifier_names
  static final String TRTC_VideoView_Model_Virtual = 'virtual';

  /// Android video rendering uses mixed integration mode, which is only valid for Android
  // ignore: non_constant_identifier_names
  static final String TRTC_VideoView_Model_Hybrid = 'hybrid';

  /// Unknown type
  static final int TXMediaDeviceTypeUnknown = -1;

  /// Mic
  static final int TXMediaDeviceTypeMic = 0;

  /// Speaker or receiver
  static final int TXMediaDeviceTypeSpeaker = 1;

  /// Camera
  static final int TXMediaDeviceTypeCamera = 2;

  /// Record audio only
  static final int TRTCRecordTypeAudio = 0;

  /// Record video only
  static final int TRTCRecordTypeVideo = 1;

  /// Record both audio and video
  static final int TRTCRecordTypeBoth = 2;
}

/// Speed test scene
enum TRTCSpeedTestScene {
  /// Latency testing.
  delayTesting,

  /// Latency and bandwidth testing.
  delayBandwidthTesting,

  /// Online choir test.
  onlineChorusTesting
}

/// @nodoc
final speedTestSceneMap = {
  TRTCSpeedTestScene.delayTesting: 1,
  TRTCSpeedTestScene.delayBandwidthTesting: 2,
  TRTCSpeedTestScene.onlineChorusTesting: 3,
};


/// Room entry parameters
///
/// As the room entry parameters in the TRTC SDK, only if these parameters are correctly set can the user successfully enter the audio/video room specified by `roomId`.
class TRTCParams {
  /// **Field description**: application ID, which is required. Tencent Video Cloud generates bills based on `sdkAppId`.
  ///
  /// **Recommended value:** the ID can be obtained on the account information page in the TRTC console after the corresponding application is created.
  int sdkAppId;

  /// **Field description**: user ID, which is required. It is the `userId` of the local user and acts as the username.
  ///
  /// **Recommended value:** it can contain up to 32 bytes of letters (a–z and A–Z), digits (0–9), underscores, and hyphens.
  String userId; // User ID

  /// **Field description:** user signature, which is required. It is the authentication signature corresponding to the current `userId` and acts as the login password for Tencent Cloud services.
  ///
  /// **Recommended value:** for the calculation method, please see [UserSig](https://cloud.tencent.com/document/product/647/17275).
  String userSig; // User signature

  /// **Field description:** room ID, which is required. Users (userId) in the same room can see one another and make video calls.
  ///
  /// **Recommended value:** value range: `1`–`4294967294`.
  int roomId; // Room ID

  /// String-type room ID. Users (userId) in the same room can see one another and make video calls.
  ///
  /// **Recommended value:** the length limit is 64 bytes. The following 89 characters are supported: letters (a–z and A–Z), digits (0–9), space, "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "\[", "\]", "^", "_", "{", "}", "|", "~", and ",".
  ///
  /// Either `roomId` or `strRoomId` must be entered. If you decide to use `strRoomId`, then `roomId` should be entered as 0. If both are entered, `roomId` will prevail. Please note that when the same `sdkAppId` is used for interconnection, please be sure to use the same room ID type to avoid affecting the interconnection.
  String strRoomId; // Room ID

  /// **Field description**: role in the live streaming scenario. The SDK uses this parameter to determine whether the user is an anchor or an audience user. This parameter is required in the live streaming scenario and optional in the call scenario.
  ///
  /// **Note:** this parameter is applicable only to the live streaming scenario ([TRTCCloudDef.TRTC_APP_SCENE_LIVE] or [TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM]) and doesn't take effect in the call scenario (`AUDIOCALL` or `VIDEOCALL`).
  ///
  /// **Recommended value:** default value: anchor (TRTCRoleAnchor)
  int role; // Role

  /// **Field description:** bound Tencent Cloud CSS CDN stream ID, which is optional. After setting this field, you can play back the user's audio/video stream on Tencent Cloud Live CDN through a standard live streaming scheme (FLV or HLS).
  ///
  /// **Recommended value:** this parameter can contain up to 64 bytes and can be left empty. We recommend you use `sdkappid_roomid_userid_main` as the `streamid`, which is easier to identify and will not cause conflicts in your multiple applications.
  ///
  /// **Note:** to use Tencent Cloud CSS CDN, you need to enable the relayed live streaming feature on the "Function Configuration" page in the console first.
  ///
  /// For more information, please see [CDN Relayed Live Streaming](https://cloud.tencent.com/document/product/647/16826).
  String streamId; // Custom stream ID

  /// **Field description:** on-cloud recording switch, which is used to specify whether to record the user's audio/video stream into a file in the specified format in the cloud.
  ///
  /// **Recommended value:** it can contain up to 64 bytes of letters (a–z and A–Z), digits (0–9), underscores, and hyphens.
  ///
  /// For more information, please see [On-Cloud Recording and Playback](https://cloud.tencent.com/document/product/647/16823).
  String
      userDefineRecordId; // On-cloud recording switch, which is used to specify whether to record the user's audio/video stream into a file in the specified format in the cloud.

  /// **Field description:** room signature, which is optional. If you want only users with the specified `userIds` to enter a room, you need to use `privateMapKey` to restrict the permission.
  ///
  /// **Recommended value:** we recommend you use this parameter only if you have high security requirements. For more information, please see [Enabling Advanced Permission Control](https://cloud.tencent.com/document/product/647/32240).
  String
      privateMapKey; // Room signature, which is optional. If you want only users with the specified `userIds` to enter a room, you need to use `privateMapKey` to restrict the permission.

  /// **Field description:** business data, which is optional. This field applies only to some uncommon special requirements.
  ///
  /// **Recommended value:** we recommend you not use this field
  String
      businessInfo; // Business data, which is optional. This field applies only to some uncommon special requirements.

  TRTCParams(
      {this.sdkAppId = 0,
      this.userId = "",
      this.userSig = "",
      this.roomId = 0,
      this.strRoomId = "",
      this.role = TRTCCloudDef.TRTCRoleAnchor,
      this.streamId = "",
      this.userDefineRecordId = "",
      this.privateMapKey = "",
      this.businessInfo = ""});

  /// {@template toJson}
  /// Convert the current object to JSON.
  ///
  /// Returns a Map with key-value pairs representing the object's data. Each key corresponds to a property of the object.
  /// Each value is the value of that property. The values may be basic types (e.g. String, int, bool, etc.),
  /// Types that can be directly converted to JSON (e.g. List, Map), or objects that implement the `toJson` method.
  ///
  /// The Map can be converted directly to a JSON string.
  /// {@endtemplate}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sdkAppId'] = this.sdkAppId;
    data['userId'] = this.userId;
    data['userSig'] = this.userSig;
    data['roomId'] = this.roomId;
    data['strRoomId'] = this.strRoomId;
    data['role'] = this.role;
    data['streamId'] = this.streamId;
    data['userDefineRecordId'] = this.userDefineRecordId;
    data['privateMapKey'] = this.privateMapKey;
    data['businessInfo'] = this.businessInfo;
    return data;
  }
}

/// Room switch parameters
class TRTCSwitchRoomConfig {
  /// **Field description:** user signature, which is required. It is the authentication signature corresponding to the current `userId` and acts as the login password for Tencent Cloud services.
  ///
  /// **Recommended value:** for the calculation method, please see [UserSig](https://cloud.tencent.com/document/product/647/17275).
  String userSig; // User signature

  /// **Field description:** room ID, which is required. Users (userId) in the same room can see one another and make video calls.
  ///
  /// **Recommended value:** value range: `1`–`4294967294`.
  int roomId; // Room ID

  /// **Field description:** string-type room ID, which is optional. Users in the same room can see one another and make video calls.
  ///
  /// **Note:** either `roomId` or `strRoomId` must be entered. If both are entered, `roomId` will prevail.
  String strRoomId;

  /// **Field description:** room signature, which is optional. If you want only users with the specified `userIds` to enter a room, you need to use `privateMapKey` to restrict the permission.
  ///
  /// **Recommended value:** we recommend you use this parameter only if you have high security requirements. For more information, please see [Enabling Advanced Permission Control](https://cloud.tencent.com/document/product/647/32240).
  String
      privateMapKey; // Room signature, which is optional. If you want only users with the specified `userIds` to enter a room, you need to use `privateMapKey` to restrict the permission.

  TRTCSwitchRoomConfig(
      {required this.userSig,
      this.roomId = 0,
      this.privateMapKey = "",
      this.strRoomId = ""});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userSig'] = this.userSig;
    data['roomId'] = this.roomId;
    data['strRoomId'] = this.strRoomId;
    data['privateMapKey'] = this.privateMapKey;
    return data;
  }
}

/// Encoding parameters
///
/// **Parameters:** related to video encoder. These settings determine the quality of image viewed by remote users, which is also the image quality of recorded video files in the cloud.
class TRTCVideoEncParam {
  /// **Field description:** video resolution
  ///
  /// **Recommended value**
  ///    - For video call, we recommend you select a resolution of 360x640 or below and select `Portrait` for `resMode`.
  ///    - For mobile live streaming, we recommend you select a resolution of 540x960 and select `Portrait` for `resMode`.
  ///    - For Windows and macOS, we recommend you select a resolution of 640x360 or above and select `Landscape` for `resMode`.
  ///
  /// **Note**
  ///    `TRTCVideoResolution` supports only the landscape resolution by default, such as 640x360.
  ///    To use a portrait resolution, please specify `resMode` as `Portrait`; for example, when used together with `Portrait`, 640x360 will become 360x640.
  ///
  /// Default value:  [TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_360]
  int videoResolution;

  /// **Field description:** resolution mode (landscape/portrait)
  ///
  /// **Recommended value:** for mobile live streaming, `Portrait` is recommended; for Windows and macOS, `Landscape` is recommended.
  ///
  /// **Note:** if 640x360 resolution is selected for `videoResolution` and `Portrait` is selected for `resMode`, then the final output resolution after encoding will be 360x640.
  ///
  /// Default value:  [TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT]
  int videoResolutionMode;

  /// **Field description:** video capturing frame rate
  ///
  /// **Recommended value:** 15 or 20 fps. If the frame rate is lower than 5 fps, there will be obvious lagging; if lower than 10 fps but higher than 5 fps, there will be slight lagging; if higher than 20 fps, too many resources will be wasted (the frame rate of movies is generally 24 fps).
  ///
  /// **Note:** the front cameras on many Android phones do not support a capturing frame rate higher than 15 fps. For some Android phones that focus too much on beautification features, the capturing frame rate of the front cameras may be lower than 10 fps.
  int videoFps;

  /// **Field description:** target video bitrate. The SDK encodes streams at the target video bitrate and will actively reduce the bitrate only if the network conditions are poor.
  ///
  /// **Recommended value:** please see the optimal bitrate for each specification in `TRTCVideoResolution`. You can also slightly increase the optimal bitrate.
  ///
  ///            For example, [TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720] corresponds to the target bitrate of 1,200 Kbps. You can also set the bitrate to 1,500 Kbps for higher definition.
  ///
  /// **Note:** the SDK does its best to encode streams at the bitrate specified by `videoBitrate` and will actively reduce the bitrate to as low as the value specified by `minVideoBitrate` only if the network conditions are poor.
  ///            If you want to "ensure definition while allowing lag", you can set `minVideoBitrate` to 60% of `videoBitrate`.
  ///            If you want to "ensure smoothness while allowing blur", you can set `minVideoBitrate` to 200 Kbps.
  ///            If you set `videoBitrate` and `minVideoBitrate` to the same value, it is equivalent to disabling the adaptive adjustment capability of the SDK.
  int videoBitrate;

  /// **Field description:** minimum video bitrate. The SDK will reduce the bitrate to as low as the value specified by `minVideoBitrate` only if the network conditions are poor.
  ///
  /// **Recommended value**
  ///     - If you want to "ensure definition while allowing lag", you can set `minVideoBitrate` to 60% of `videoBitrate`.
  ///     - If you want to "ensure smoothness while allowing blur", you can set `minVideoBitrate` to 200 Kbps.
  ///     - If you set `videoBitrate` and `minVideoBitrate` to the same value, it is equivalent to disabling the adaptive adjustment capability of the SDK.
  ///     - Default value: `0`, indicating that the lowest bitrate will be automatically set by the SDK according to the resolution.
  ///
  /// **Note**
  ///     - If you set the resolution to a high value, it is not suitable to set `minVideoBitrate` too low; otherwise, the video image will become blurry and heavily pixelated.
  ///        For example, if the resolution is set to 720p and the bitrate is set to 200 Kbps, then the encoded video image will be heavily pixelated.
  int minVideoBitrate;

  /// **Field description:** whether resolution adjustment is allowed
  ///
  /// **Recommended value**
  ///     - For mobile live streaming, `false` is recommended.
  ///     - For video call, if smoothness is of higher priority, `true` is recommended. In this case, if the network bandwidth is limited, the SDK will automatically reduce the resolution to ensure better smoothness (only valid for `TRTCVideoStreamTypeBig`).
  ///     - Default value: `false`.
  ///
  /// **Note:** when recording is needed, if `true` is selected, please make sure that the resolution adjustment will not affect the recording effect during the call.
  bool enableAdjustRes;

  TRTCVideoEncParam(
      {this.videoBitrate = 200,
      this.videoResolution = 60, // TRTC_VIDEO_RESOLUTION_480_360
      this.videoResolutionMode = 1, // TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT
      this.videoFps = 10,
      this.minVideoBitrate = 200,
      this.enableAdjustRes = false});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoBitrate'] = this.videoBitrate;
    data['videoResolution'] = this.videoResolution;
    data['videoFps'] = this.videoFps;
    data['videoResolutionMode'] = this.videoResolutionMode;
    data['minVideoBitrate'] = this.minVideoBitrate;
    data['enableAdjustRes'] = this.enableAdjustRes;
    return data;
  }
}

/// Network bandwidth limit parameters
///
/// The settings determine the bandwidth limit practices of the SDK in various network conditions (e.g., whether to "ensure definition" or "ensure smoothness" on a weak network).
class TRTCNetworkQosParam {
  /// **Field description:** whether to "ensure definition" or "ensure smoothness" on a weak network
  ///
  /// **Note**
  ///   - Smoothness is ensured on a weak network, i.e., the video image will have a lot of blurs but can be smooth with no lagging.
  ///   - Definition is ensured on a weak network, i.e., the image will be as clear as possible but tend to lag.
  int preference;

  /// **Field description:** video resolution (on-cloud control/client-based control)
  ///
  /// **Recommended value:** on-cloud control
  ///
  /// **Note**
  ///   - Server mode (default): on-cloud control. If there are no special needs, please use this mode directly
  ///   - Client mode: client-based control. It is for internal debugging of the SDK and should not be used
  int controlMode;

  TRTCNetworkQosParam({
    this.preference = 2,
    this.controlMode = 1,
  });

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['preference'] = this.preference;
    data['controlMode'] = this.controlMode;
    return data;
  }
}

/// Remote image parameters
class TRTCRenderParams {
  /// **Field description:** clockwise image rotation angle
  ///
  /// **Note**
  ///*   - [TRTCCloudDef.TRTC_VIDEO_ROTATION_0] : no rotation (default value)
  ///*   - [TRTCCloudDef.TRTC_VIDEO_ROTATION_90] : clockwise rotation by 90 degrees
  ///*   - [TRTCCloudDef.TRTC_VIDEO_ROTATION_180] : clockwise rotation by 180 degrees
  ///*   - [TRTCCloudDef.TRTC_VIDEO_ROTATION_270] : clockwise rotation by 270 degrees
  int rotation;

  /// **Field description:** image rendering mode
  ///
  /// **Note**
  ///   Fill (the image may be stretched or cropped) or fit (there may be black color in unmatched areas). Default value: [TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL]
  /// - [TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL] : the entire screen will be covered by the image, where parts that exceed the screen will be cropped, and the displayed image may be incomplete.
  /// - [TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT] : the long side of the image will fit the screen, while the short side will be proportionally scaled with unmatched areas being filled with black color blocks. The displayed image is complete.
  int fillMode;

  /// **Field description:** mirror mode
  ///
  /// **Note**
  /// - [TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO] : mirror the front camera's image but not the rear camera's image (default value).
  /// - [TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE] : mirror the images of both the front and rear cameras.
  /// - [TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE] : do not mirror the images of both the front and rear cameras.
  int mirrorType;

  TRTCRenderParams({
    this.rotation = TRTCCloudDef.TRTC_VIDEO_ROTATION_0,
    this.fillMode = TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL,
    this.mirrorType = TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_AUTO,
  });

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rotation'] = this.rotation;
    data['fillMode'] = this.fillMode;
    data['mirrorType'] = this.mirrorType;
    return data;
  }
}

/// Position information of each channel of subimage in On-Cloud MixTranscoding
///
/// `TRTCMixUser` is used to specify the detailed position of the video image of each channel (i.e., each `userId`).
class TRTCMixUser {
  /// `userId` that engages in mixtranscoding
  String userId;

  /// `roomId` of the `userId` that engages in mixtranscoding. The `null` value indicates the current room
  String roomId;

  /// X coordinate of the layer position (absolute pixel value)
  int x;

  /// Y coordinate of the layer position (absolute pixel value)
  int y;

  /// Width of the layer position (absolute pixel value)
  int width;

  /// Height of the layer position (absolute pixel value)
  int height;

  /// Layer number (1–15), which must be unique
  int zOrder;

  /// Whether the primary image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG], which is the default value) or screen sharing image ([TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB]) engages in mixtranscoding
  int streamType;

  /// Whether the user only enables audio
  bool pureAudio;

  /// Whether the user only enables audio or only enables video, 1-enables audio and video, 2-only video, 3-only audio
  int? inputType;
  TRTCMixUser(
      {this.userId = '',
      this.roomId = "",
      this.x = 0,
      this.y = 0,
      this.width = 0,
      this.height = 0,
      this.zOrder = 0,
      this.streamType = TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
      this.inputType = 0,
      this.pureAudio = false});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['roomId'] = this.roomId;
    data['x'] = this.x;
    data['y'] = this.y;
    data['width'] = this.width;
    data['height'] = this.height;
    data['zOrder'] = this.zOrder;
    data['streamType'] = this.streamType;
    data['pureAudio'] = this.pureAudio;
    data['inputType'] = this.inputType;
    return data;
  }
}

/// On-Cloud MixTranscoding configuration
///
/// This contains the final encoding quality and the positions of images of each channel.
class TRTCTranscodingConfig {
  /// **Field description:** Tencent Cloud CSS `AppID`
  ///
  /// **Recommended value:** please select a created application in the [TRTC console](https://console.cloud.tencent.com/trtc), click **Application Info**, and get it in "Relayed Live Streaming Info".
  int? appId;

  /// **Field description:** Tencent Cloud CSS `bizid`
  ///
  /// **Recommended value:** please select a created application in the [TRTC console](https://console.cloud.tencent.com/trtc), click **Application Info**, and get it in "Relayed Live Streaming Info".
  int? bizId;

  /// **Field description:** transcoding configuration mode
  int mode;

  /// **Field description:** width of video resolution after transcoding.
  ///
  /// **Recommended value:** 360 px. If you are pushing a pure audio stream, please set width x height to 0 px x 0 px; otherwise, a video stream with a canvas background will be carried after mixtranscoding.
  int videoWidth;

  /// **Field description:** height of video resolution after transcoding.
  ///
  /// **Recommended value:** 640 px. If you are pushing a pure audio stream, please set width x height to 0 px x 0 px; otherwise, a video stream with a canvas background will be carried after mixtranscoding.
  int videoHeight;

  /// **Field description:** bitrate of video resolution in Kbps after transcoding.
  ///
  /// **Recommended value:** if you enter 0, the backend will estimate the bitrate based on `videoWidth` and `videoHeight`. You can also refer to the comment on the enumeration definition of [TRTCCloudDef.TRTC_VIDEO_RESOLUTION_640_480].
  int videoBitrate;

  /// **Field description:** frame rate of video resolution in fps after transcoding.
  ///
  /// **Recommended value:** default value: `15` fps. Value range: `(0,30]`.
  int videoFramerate;

  /// **Field description:** keyframe interval (GOP) of video resolution after transcoding.
  ///
  /// **Recommended value:** default value: `2` (in seconds). Value range: `[1,8]`.
  int videoGOP;

  /// **Field description:** background color of the mixed video image. The default value is black, and the format is hex number; for example: "0x61B9F1" represents the RGB color (97,158,241).
  ///
  /// **Recommended value:** default value: `0x000000` (black)
  int backgroundColor;

  /// **Field description:** background image of the mixed video image.
  ///
  /// **Recommended value:** default value: `null`, indicating not to set the background image
  ///
  /// **Note:** you need to upload the background image in "Application Management" > "Function Configuration" > "Material Management" in the [console](https://console.cloud.tencent.com/trtc) in advance.
  ///
  ///            After the upload is successful, you can get the corresponding "image ID". Then, you need to convert it into a string and set it as `backgroundImage`.
  ///
  ///            For example, if the "image ID" is 63, you can set `backgroundImage = "63"`;
  String? backgroundImage;

  /// **Field description:** audio sample rate after transcoding.
  ///
  /// **Recommended value:** default value: 48000 Hz. Valid values: 12000 Hz, 16000 Hz, 22050 Hz, 24000 Hz, 32000 Hz, 44100 Hz, 48000 Hz.
  int audioSampleRate;

  /// **Field description:** audio bitrate after transcoding.
  ///
  /// **Recommended value:** default value: 64 Kbps. Value range: `[32,192]`.
  int audioBitrate;

  /// **Field description:** number of sound channels after transcoding.
  ///
  /// **Recommended value:** default value: `1`. Valid values: `1`, `2`.
  int audioChannels;

  /// **Field description:** position information of each channel of subimage
  List<TRTCMixUser>?
      mixUsers; // Position information of each channel of subimage

  /// **Field description:** ID of the live stream output to CDN
  ///         - If this parameter is not set, the SDK will execute the default logic, that is, it will mix the multiple streams in the room into the video stream of the caller of the API, i.e., A + B => A;
  ///         - If this parameter is set, the SDK will mix the multiple streams in the room into the live stream ID you specify, i.e., A + B => C.
  ///
  /// **Recommended value:** default value: `null`, that is, the multiple streams in the room will be mixed into the video stream of the caller of this API.
  String? streamId;
  TRTCTranscodingConfig(
      {this.appId,
      this.bizId,
      this.mode = TRTCCloudDef.TRTC_TranscodingConfigMode_Unknown,
      this.videoWidth = 0,
      this.videoHeight = 0,
      this.videoBitrate = 0,
      this.videoFramerate = 15,
      this.videoGOP = 2,
      this.backgroundColor = 0x000000,
      this.backgroundImage,
      this.audioSampleRate = 48000,
      this.audioBitrate = 64,
      this.audioChannels = 1,
      this.mixUsers,
      this.streamId});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appId'] = this.appId;
    data['bizId'] = this.bizId;
    data['mode'] = this.mode;
    data['videoWidth'] = this.videoWidth;
    data['videoHeight'] = this.videoHeight;
    data['videoBitrate'] = this.videoBitrate;
    data['videoFramerate'] = this.videoFramerate;
    data['videoGOP'] = this.videoGOP;
    data['backgroundColor'] = this.backgroundColor;
    data['backgroundImage'] = this.backgroundImage;
    data['audioSampleRate'] = this.audioSampleRate;
    data['audioBitrate'] = this.audioBitrate;
    data['audioChannels'] = this.audioChannels;
    data['mixUsers'] = this.mixUsers;
    data['streamId'] = this.streamId;
    return data;
  }
}

/// Voice changing type definition (young girl, middle-aged man, heavy metal, punk...)
class TXVoiceChangerType {
  /// Disable voice changing
  static int TXLiveVoiceChangerType_0 = 0;

  /// Naughty boy
  static int TXLiveVoiceChangerType_1 = 1;

  /// Young girl
  static int TXLiveVoiceChangerType_2 = 2;

  /// Middle-aged man
  static int TXLiveVoiceChangerType_3 = 3;

  /// Heavy metal
  static int TXLiveVoiceChangerType_4 = 4;

  /// Cold
  static int TXLiveVoiceChangerType_5 = 5;

  /// Punk
  static int TXLiveVoiceChangerType_6 = 6;

  /// Furious animal
  static int TXLiveVoiceChangerType_7 = 7;

  /// Chubby
  static int TXLiveVoiceChangerType_8 = 8;

  /// Strong electric current
  static int TXLiveVoiceChangerType_9 = 9;

  /// Robot
  static int TXLiveVoiceChangerType_10 = 10;

  /// Ethereal
  static int TXLiveVoiceChangerType_11 = 11;
}

/// Reverb effect type definition (karaoke room, small room, big hall, deep, resonant...)
class TXVoiceReverbType {
  /// Disable reverb
  static int TXLiveVoiceReverbType_0 = 0;

  /// KTV
  static int TXLiveVoiceReverbType_1 = 1;

  /// Small room
  static int TXLiveVoiceReverbType_2 = 2;

  /// Great hall
  static int TXLiveVoiceReverbType_3 = 3;

  /// Deep
  static int TXLiveVoiceReverbType_4 = 4;

  /// Loud voice
  static int TXLiveVoiceReverbType_5 = 5;

  /// Metallic
  static int TXLiveVoiceReverbType_6 = 6;

  /// Magnetic
  static int TXLiveVoiceReverbType_7 = 7;

  /// Ethereal
  static int TXLiveVoiceReverbType_8 = 8;

  /// Studio
  static int TXLiveVoiceReverbType_9 = 9;

  /// Melodious
  static int TXLiveVoiceReverbType_10 = 10;

  /// Studio2
  static int TXLiveVoiceReverbType_11 = 11;
}

/// Parameters of music and voice settings APIs
class AudioMusicParam {
  /// **Field meaning:** music track ID
  ///
  /// **Note:** the SDK allows you to play multiple music tracks, so music IDs are required for identification. These IDs are used to start/stop a music track, adjust the volume, and more.
  int id;

  /// **Field meaning:** absolute path of the music file
  String path;

  /// **Field meaning:** number of times the music file is played in a loop
  ///
  /// **Recommended value:** value range: 0 or any positive integer. Default value: 0. 0 indicates that the music file will be played once, 1 indicates that the music file will be played twice, and so on.
  int loopCount;

  /// **Field meaning:** whether to send the music track to remote users.
  ///
  /// **Recommended value:** YES: when the music is played locally, it will be uploaded to the cloud and can be heard by remote users. NO: the music track will not be uploaded to the cloud and can only be heard locally. Default value: NO.
  bool publish;

  /// **Field meaning:** whether the music file for playback is a short music file
  ///
  /// **Recommended value:** YES: short music file for loop playback. NO: normal music file. Default value: NO.
  bool isShortFile;

  /// **Field meaning:** the point in time in milliseconds for starting music playback
  int startTimeMS;

  /// **Field meaning:** the point in time in milliseconds for ending music playback. The value 0 or -1 indicates that playback lasts until the file ends.
  int endTimeMS;

  AudioMusicParam(
      {required this.path,
      required this.id,
      this.loopCount = 0,
      this.publish = false,
      this.isShortFile = false,
      this.startTimeMS = 0,
      this.endTimeMS = -1});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['id'] = this.id;
    data['loopCount'] = this.loopCount;
    data['publish'] = this.publish;
    data['isShortFile'] = this.isShortFile;
    data['startTimeMS'] = this.startTimeMS;
    data['endTimeMS'] = this.endTimeMS;
    return data;
  }
}

/// Audio recording parameters
///
/// **Field description:** file path (required), which is the storage path of the audio recording file. Please specify it by yourself and ensure that the specified path exists and is writable.
///
/// **Note:** this path must be accurate to the file name and extension. The extension determines the format of the audio recording file. Currently, supported formats include PCM, WAV, and AAC. For example, if the specified path is `path/to/audio.aac`, then an AAC file will be generated. Please specify a valid path with read/write permissions; otherwise, the audio recording file cannot be generated.
class TRTCAudioRecordingParams {
  String filePath;

  TRTCAudioRecordingParams({required this.filePath});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filePath'] = this.filePath;
    return data;
  }
}

/// Recording parameters
class TRTCLocalRecordingParams {
  /// **Field description:** address of the recording file, which is required. Please ensure that the path is valid with read/write permissions; otherwise, the recording file cannot be generated.
  ///
  /// **Note:** this path must be accurate to the file name and extension. The extension determines the format of the recording file. Currently, only the MP4 format is supported. For example, if you specify the path as `mypath/record/test.mp4`, it means that you want the SDK to generate a local video file in MP4 format. Please specify a valid path with read/write permissions; otherwise, the recording file cannot be generated.
  String filePath;

  /// **Field description:** media recording type, which is `TRTCRecordTypeBoth` by default, indicating to record both audio and video.
  int recordType;

  /// **Field description:** `interval` is the update frequency of the recording information in milliseconds. Value range: `1000`–`10000`. Default value: `-1`, indicating not to call back
  int interval = -1;

  /// **Field description:** The recording file segmentation duration, in milliseconds, with a minimum value of `10000`. The default value is `0`, which means no fragmentation.
  int maxDurationPerFile;

  TRTCLocalRecordingParams(
      {required this.filePath, required this.recordType, this.interval = -1,
        this.maxDurationPerFile = 0});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filePath'] = this.filePath;
    data['recordType'] = this.recordType;
    data['interval'] = this.interval;
    data['maxDurationPerFile'] = this.maxDurationPerFile;
    return data;
  }
}

/// CDN relaying parameters
class TRTCPublishCDNParam {
  /// Tencent Cloud `AppID`. Please select a created application in the [TRTC console](https://console.cloud.tencent.com/trtc), click **Application Info**, and get it in "Relayed Live Streaming Info".
  int appId;

  /// Tencent Cloud CSS `bizid`. Please select a created application in the [TRTC console](https://console.cloud.tencent.com/trtc), click **Application Info**, and get it in "Relayed Live Streaming Info".
  int bizId;

  /// Relayed push URL
  String url;

  TRTCPublishCDNParam(
      {required this.appId, required this.bizId, required this.url});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appId'] = this.appId;
    data['bizId'] = this.bizId;
    data['url'] = this.url;
    return data;
  }
}

/// Network speed testing parameters
///
/// You can test the network speed through the startSpeedTest: interface before the user enters the room (this API cannot be called during a call).
class TRTCSpeedTestParams {
  /// Application identification, please refer to the relevant instructions in [TRTCParams].
  int sdkAppId;

  /// User identification, please refer to the relevant instructions in [TRTCParams].
  String userId;

  /// User signature, please refer to the relevant instructions in [TRTCParams].
  String userSig;

  /// Expected downstream bandwidth (kbps, value range: 10 to 5000, no downlink bandwidth test when it is 0).
  ///
  /// **Note:** When the parameter `scene` is set to `TRTCSpeedTestScene_OnlineChorusTesting`, in order to obtain more accurate information such as rtt / jitter, the value range is limited to 10 ~ 1000.
  int expectedUpBandwidth;

  /// Expected upstream bandwidth (kbps, value range: 10 to 5000, no uplink bandwidth test when it is 0).
  ///
  /// **Note:** When the parameter `scene` is set to `TRTCSpeedTestScene_OnlineChorusTesting`, in order to obtain more accurate information such as rtt / jitter, the value range is limited to 10 ~ 1000.
  int expectedDownBandwidth;

  /// Speed test scene.
  TRTCSpeedTestScene scene;

  TRTCSpeedTestParams(
      {required this.sdkAppId,
      required this.userId,
      required this.userSig,
        this.expectedUpBandwidth = 0,
        this.expectedDownBandwidth = 0,
        this.scene = TRTCSpeedTestScene.delayTesting});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sdkAppId'] = this.sdkAppId;
    data['userId'] = this.userId;
    data['userSig'] = this.userSig;
    data['expectedUpBandwidth'] = this.expectedUpBandwidth;
    data['expectedDownBandwidth'] = this.expectedDownBandwidth;
    data['scene'] = speedTestSceneMap[this.scene];
    return data;
  }
}

/// Network speed test result
///
/// The startSpeedTest: API can be used to test the network speed before a user enters a room (this API cannot be called during a call).
class TRTCSpeedTestResult {
  /// Whether the network speed test is successful.
  bool success;

  /// Error message for network speed test.
  String errMsg;

  /// Server IP address.
  String ip;

  /// Network quality, which is tested and calculated based on the internal evaluation algorithm. For more information, please see TRTCCloudDef.TRTC_QUALITY_
  int quality;

  /// Upstream packet loss rate between 0 and 1.0. For example, 0.3 indicates that 3 data packets may be lost in every 10 packets sent to the server.
  double upLostRate;

  /// Downstream packet loss rate between 0 and 1.0.
  /// For example, 0.2 indicates that 2 data packets may be lost in every 10 packets received from the server.
  double downLostRate;

  /// Delay in milliseconds, which is the round-trip time between the current device and TRTC server. The smaller the value, the better. The normal value range is 10–100 ms.
  int rtt;

  /// Upstream bandwidth (in kbps, -1: invalid value).
  int availableUpBandwidth;

  /// Downstream bandwidth (in kbps, -1: invalid value).
  int availableDownBandwidth;

  /// Uplink data packet jitter (ms) refers to the stability of data communication in the user's current network environment.
  /// The smaller the value, the better. The normal value range is 0ms - 100ms. -1 means that the speed test failed to obtain an effective value.
  /// Generally, the Jitter of the WiFi network will be slightly larger than that of the 4G/5G environment.
  int upJitter;

  /// Downlink data packet jitter (ms) refers to the stability of data communication in the user's current network environment.
  /// The smaller the value, the better. The normal value range is 0ms - 100ms. -1 means that the speed test failed to obtain an effective value.
  /// Generally, the Jitter of the WiFi network will be slightly larger than that of the 4G/5G environment.
  int downJitter;

  TRTCSpeedTestResult(
      {required this.success,
      required this.errMsg,
      required this.ip,
      required this.quality,
      required this.upLostRate,
      required this.downLostRate,
      required this.rtt,
      required this.availableUpBandwidth,
      required this.availableDownBandwidth,
      required this.upJitter,
      required this.downJitter});

}

/// Parameters of local video rendering with external texture
class CustomLocalRender {
  /// User ID
  String userId;

  /// Whether it is the front camera
  bool isFront;

  /// Only [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG] and [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB] are supported.
  int streamType;

  /// Displayed video width
  int width;

  /// Displayed video height
  int height;

  CustomLocalRender(
      {required this.userId,
      required this.isFront,
      required this.streamType,
      required this.width,
      required this.height});
}

/// Parameters of remote video rendering with external texture
class CustomRemoteRender {
  /// User ID
  String userId;

  /// Only [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG] and [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB] are supported.
  int streamType;

  /// Displayed video width
  int width;

  /// Displayed video height
  int height;

  CustomRemoteRender(
      {required this.userId,
      required this.streamType,
      required this.width,
      required this.height});
}

/// Parameters of video rendering with external texture
class CustomRender {
  /// User ID
  String userId;

  /// Whether it is the front camera
  bool? isFront;

  /// Whether it is the local user
  bool isLocal;

  /// Only [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG] and [TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB] are supported.
  int streamType;

  /// Displayed video width
  int width;

  /// Displayed video height
  int height;

  CustomRender(
      {required this.userId,
      this.isFront,
      required this.isLocal,
      required this.streamType,
      required this.width,
      required this.height});
}

/// Media stream publishing mode, this enumeration type is used for the Media Stream Publishing interface [TRTCCloud.startPublishMediaStream].
///
/// TRTC's Media Stream Publishing service can publish multiple audio and video streams from a room to a CDN or push them back into the room.
/// It can also publish your current stream to Tencent or a third-party CDN, so you'll need to specify the publishing mode for that stream.
enum TRTCPublishMode {

  ///Undefined
  TRTCPublishModeUnknown,

  ///Use this parameter to publish the primary stream (TRTCVideoStreamTypeBig) in the room to Tencent Cloud or a third-party CDN (only RTMP is supported).
  TRTCPublishBigStreamToCdn,

  ///Use this parameter to publish the substream (TRTCVideoStreamTypeSub) in the room to Tencent Cloud or a third-party CDN (only RTMP is supported).
  TRTCPublishSubStreamToCdn,

  ///Use this parameter together with the encoding parameter TRTCStreamEncoderParam and On-Cloud MixTranscoding parameter TRTCStreamMixingConfig to transcode the streams you specify and publish the mixed stream to Tencent Cloud or a third-party CDN (only RTMP is supported).
  TRTCPublishMixStreamToCdn,

  ///Use this parameter together with the encoding parameter TRTCStreamEncoderParam and On-Cloud MixTranscoding parameter TRTCStreamMixingConfig to transcode the streams you specify and publish the mixed stream to the room you specify.
  TRTCPublishMixStreamToRoom,

}

/// Configure to publish real-time audio/video (TRTC) streams to Tencent Cloud or a third-party CDN.
class TRTCPublishCdnUrl {

  ///The destination URL (RTMP) when you publish to Tencent Cloud or a third-party CDN.
  String rtmpUrl = "";

  ///Whether to publish to Tencent Cloud. The default value is  `true`.
  bool isInternalLine = true;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rtmpUrl'] = this.rtmpUrl;
    data['isInternalLine'] = this.isInternalLine;
    return data;
  }
}

/// Information about the TRTC user, mainly containing the user ID and the room number of the user.
class TRTCUser {

  /// User ID
  String userId = "";

  /// Numeric room ID.
  int intRoomId = 0;

  /// Description: String-type room ID. The room ID must be of the same type as that in TRTCParams.
  ///
  /// **Note:** You cannot use both  intRoomId  and  strRoomId . If you specify  roomId , you need to leave  strRoomId  empty. If you set both, only  intRoomId  will be used.
  /// 
  /// Value: 64 bytes or shorter; supports the following character set (89 characters):
  ///
  /// Uppercase and lowercase letters (a-z and A-Z)
  ///
  ///  Numbers (0-9)
  ///
  ///  Space, "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "\[", "\]", "^", "_", "{", "}", "|", "~", ","
  String strRoomId = "";

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['intRoomId'] = this.intRoomId;
    data['strRoomId'] = this.strRoomId;
    return data;
  }
}

/// Configure the publication target for the TRTC stream
class TRTCPublishTarget {

  /// Description:  The publishing mode.
  ///
  ///  Value:  You can relay streams to a CDN, transcode streams, or publish streams to an RTC room. Select the mode that fits your needs.
  TRTCPublishMode mode = TRTCPublishMode.TRTCPublishModeUnknown;

  /// The destination URLs (RTMP) when you publish to Tencent Cloud or third-party CDNs.
  List<TRTCPublishCdnUrl> cdnUrlList = <TRTCPublishCdnUrl>[];

  /// The information of the robot that publishes the transcoded stream to a TRTC room.
  TRTCUser mixStreamIdentity = TRTCUser();

  /// Convert [cdnUrlList] to Json format
  List<Map<String, dynamic>> cdnUrlListToJson() {
    List<Map<String, dynamic>> listJson = [];
    if (this.cdnUrlList.isNotEmpty) {
      for (var url in this.cdnUrlList) {
        listJson.add(url.toJson());
      }
    }
    return listJson;
  }

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mode'] = this.mode.index;
    data['cdnUrlList'] = cdnUrlListToJson();
    data['mixStreamIdentity'] = this.mixStreamIdentity.toJson();
    return data;
  }
}

/// Encoding settings related to the published stream, including resolution, frame rate, keyframe interval, etc.
class TRTCStreamEncoderParam {

  ///  Description:  The resolution (width) of the stream to publish.
  ///
  ///  Value:  Recommended value: `368`. If you mix only audio streams, to avoid displaying a black video in the transcoded stream, set both  width  and  height  to  0 .
  int videoEncodedWidth = 0;

  ///Description:  The resolution (height) of the stream to publish.
  ///
  ///  Value:  Recommended value: `640`. If you mix only audio streams, to avoid displaying a black video in the transcoded stream, set both  width  and  height  to  0 .
  int videoEncodedHeight = 0;

  ///  Description:  The frame rate (fps) of the stream to publish.
  ///
  ///  Value:  Value range: `(0,30]`. Default: `20`.
  int videoEncodedFPS = 0;

  ///  Description:  The keyframe interval (GOP) of the stream to publish.
  ///
  ///  Value:  Value range: `[1,5]`. Default: `3` (seconds).
  int videoEncodedGOP = 0;

  ///  Description:  The video bitrate (Kbps) of the stream to publish.
  ///
  ///  Value:  If you set this parameter to  `0` , TRTC will work out a bitrate based on  videoWidth  and  videoHeight . For details, refer to the recommended bitrates for the constants of the resolution enum type (see comment).
  int videoEncodedKbps = 0;

  ///  Description:  The audio sample rate of the stream to publish.
  ///
  ///  Value:  Valid values: `[48000, 44100, 32000, 24000, 16000, 8000]`. Default: `48000` (Hz).
  int audioEncodedSampleRate = 0;

  /// Description:  The sound channels of the stream to publish.
  ///
  ///  Value:  Valid values: `1` (mono channel); `2` (dual-channel). Default: `1`.
  int audioEncodedChannelNum = 0;

  /// Description:  The audio bitrate (Kbps) of the stream to publish.
  ///
  ///  Value:  Value range: `[32,192]`. Default: `50`.
  int audioEncodedKbps = 0;

  /// Description:  The audio codec of the stream to publish.
  ///
  ///  Value:  Valid values: `0` (LC-AAC); `1` (HE-AAC); `2` (HE-AACv2). Default: `0`.
  int audioEncodedCodecType = 0;

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoEncodedWidth'] = this.videoEncodedWidth;
    data['videoEncodedHeight'] = this.videoEncodedHeight;
    data['videoEncodedFPS'] = this.videoEncodedFPS;
    data['videoEncodedGOP'] = this.videoEncodedGOP;
    data['videoEncodedKbps'] = this.videoEncodedKbps;
    data['audioEncodedSampleRate'] = this.audioEncodedSampleRate;
    data['audioEncodedChannelNum'] = this.audioEncodedChannelNum;
    data['audioEncodedKbps'] = this.audioEncodedKbps;
    data['audioEncodedCodecType'] = this.audioEncodedCodecType;
    return data;
  }
}

/// Coordinates used to describe some views
class Rect {

  /// The x-coordinate of the upper-left corner of the view.
  double originX;

  /// The y-coordinate of the upper-left corner of the view.
  double originY;

  /// Width of the view
  double sizeWidth;

  /// Height of the view
  double sizeHeight;

  Rect({required this.originX,
    required this.originY,
    required this.sizeWidth,
    required this.sizeHeight});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['originX'] = this.originX;
    data['originY'] = this.originY;
    data['sizeWidth'] = this.sizeWidth;
    data['sizeHeight'] = this.sizeHeight;
    return data;
  }
}

/// Enumeration of TRTC video view display modes, including fill mode and adaptation mode
enum TRTCVideoFillMode {

  /// Fill mode: the video image will be centered and scaled to fill the entire display area, where parts that exceed the area will be cropped. The displayed image may be incomplete in this mode.
  TRTCVideoFillMode_Fill,

  /// Fit mode: the video image will be scaled based on its long side to fit the display area, where the short side will be filled with black bars. The displayed image is complete in this mode, but there may be black bars.
  TRTCVideoFillMode_Fit,
}

/// The different types of video streams offered by the TRTC
enum TRTCVideoStreamType {

  /// HD big image: it is generally used to transfer video data from the camera.
  TRTCVideoStreamTypeBig,

  /// Smooth small image: it has the same content as the big image, but with lower resolution and bitrate and thus lower definition.
  TRTCVideoStreamTypeSmall,

  /// Substream image: it is generally used for screen sharing. Only one user in the room is allowed to publish the substream video image at any time, while other users must wait for this user to close the substream before they can publish their own substream.
  TRTCVideoStreamTypeSub,
}

/// Configuration of video layout properties for TRTC streaming, including position, size, layers, etc.
class TRTCVideoLayout {

  /// Description:  The coordinates (in pixels) of the video.
  Rect rect = Rect(originX: 0, originY: 0, sizeWidth: 0, sizeHeight: 0);

  ///  Description:  The layer of the video, which must be unique. Value range: `0`-`15`.
  int zOrder = 0;

  ///  Description:  The rendering mode.
  ///
  ///  Value:  The rendering mode may be fill (the image may be stretched or cropped) or fit (there may be black bars). Default value: `TRTCVideoFillMode_Fill`.
  TRTCVideoFillMode fillMode = TRTCVideoFillMode.TRTCVideoFillMode_Fill;

  ///  Description:  The background color of the mixed stream.
  ///
  ///  Value:  The value must be a hex number. For example, "0x61B9F1" represents the RGB color value (97,158,241). Default value: `0x000000` (black).
  int backgroundColor = 0;

  /// Description:  The URL of the placeholder image. If a user sends only audio, the image specified by the URL will be mixed during On-Cloud MixTranscoding.
  ///
  ///  Value:  This parameter is left empty by default, which means no placeholder image will be used.
  String placeHolderImage = "";

  ///  Description:  The users whose streams are transcoded.
  TRTCUser fixedVideoUser = TRTCUser();

  ///  Description:  Whether the video is the primary stream (TRTCVideoStreamTypeBig) or substream (e TRTCVideoStreamTypeSub).
  TRTCVideoStreamType fixedVideoStreamType = TRTCVideoStreamType.TRTCVideoStreamTypeBig;

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rect'] = this.rect.toJson();
    data['zOrder'] = this.zOrder;
    data['fillMode'] = this.fillMode.index;
    data['backgroundColor'] = this.backgroundColor;
    data['placeHolderImage'] = this.placeHolderImage;
    data['fixedVideoUser'] = this.fixedVideoUser.toJson();
    data['fixedVideoStreamType'] = this.fixedVideoStreamType.index;
    return data;
  }
}

/// Configuration of the properties of the TRTC watermarking function
class TRTCWatermark {

  ///  Description:  The URL of the watermark image. The image specified by the URL will be mixed during On-Cloud MixTranscoding.
  String watermarkUrl = "";

  /// Description:  The coordinates (in pixels) of the watermark.
  Rect rect = Rect(originX: 0, originY: 0, sizeWidth: 0, sizeHeight: 0);

  ///  Description:  The layer of the watermark, which must be unique. Value range: `0`-`15`.
  int zOrder = 0;

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['watermarkUrl'] = this.watermarkUrl;
    data['rect'] = this.rect.toJson();
    data['zOrder'] = this.zOrder;
    return data;
  }
}

/// Settings related to TRTC mixing and streaming, including background color, background image, information about all video and audio streams to be mixed, and watermark settings.
class TRTCStreamMixingConfig {

  ///  Description:  The background color of the mixed stream.
  ///
  ///  Value:  The value must be a hex number. For example, "0x61B9F1" represents the RGB color value (97,158,241). Default value: `0x000000` (black).
  int backgroundColor = 0;

  /// Description:  The URL of the background image of the mixed stream. The image specified by the URL will be mixed during On-Cloud MixTranscoding.
  ///
  ///  Value:  This parameter is left empty by default, which means no background image will be used.
  String backgroundImage = "";

  ///Description:  The information of each audio stream to mix.
  ///
  ///  Value:  This parameter is an array. Each [TRTCUser] element in the array indicates the information of an audio stream.
  List<TRTCVideoLayout> videoLayoutList = <TRTCVideoLayout>[];

  /// Description:  The position, size, layer, and stream type of each video in On-Cloud MixTranscoding.
  ///
  ///  Value:  This parameter is an array. Each [TRTCVideoLayout] element in the array indicates the information of a video in On-Cloud MixTranscoding
  List<TRTCUser> audioMixUserList = <TRTCUser>[];

  ///  Description:  The position, size, and layer of each watermark image in On-Cloud MixTranscoding.
  ///
  ///  Value:  This parameter is an array. Each [TRTCWatermark] element in the array indicates the information of a watermark.
  List<TRTCWatermark> watermarkList = <TRTCWatermark>[];

  /// Convert [videoLayoutList] to Json format
  List<Map<String, dynamic>> videoLayoutListToJson() {
    List<Map<String, dynamic>> listJson = [];
    if (this.videoLayoutList.isNotEmpty) {
      for (var url in this.videoLayoutList) {
        listJson.add(url.toJson());
      }
    }
    return listJson;
  }

  /// Convert [audioMixUserList] to Json format
  List<Map<String, dynamic>> audioMixUserListToJson() {
    List<Map<String, dynamic>> listJson = [];
    if (this.audioMixUserList.isNotEmpty) {
      for (var audioMixUser in this.audioMixUserList) {
        listJson.add(audioMixUser.toJson());
      }
    }
    return listJson;
  }

  /// Convert [watermarkList] to Json format
  List<Map<String, dynamic>> watermarkListToJson() {
    List<Map<String, dynamic>> listJson = [];
    if (this.watermarkList.isNotEmpty) {
      for (var watermark in this.watermarkList) {
        listJson.add(watermark.toJson());
      }
    }
    return listJson;
  }

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['backgroundColor'] = this.backgroundColor;
    data['backgroundImage'] = this.backgroundImage;
    data['videoLayoutList'] = videoLayoutListToJson();
    data['audioMixUserList'] = audioMixUserListToJson();
    data['watermarkList'] = watermarkListToJson();
    return data;
  }
}

/// Audio/video frame data class for processing and transmitting audio data.
class TRTCAudioFrame {

  /// Audio data
  Uint8List? data;

  /// Sample rate
  int? sampleRate;

  /// Number of sound channels
  int? channels;

  /// Timestamp in ms
  int? timestamp;

  /// Extra data in audio frame, message sent by remote users through  `onLocalProcessedAudioFrame`  that add to audio frame will be callback through this field.
  Uint8List? extraData;
}

/// List of screen windows.
class TRTCScreenCaptureSourceList {
  /// Number of windows
  int count = 0;

  /// List of screen windows.
  List<TRTCScreenCaptureSourceInfo> sourceInfo = [];

  TRTCScreenCaptureSourceList({
    required this.count,
    required this.sourceInfo,
  });

  /// Convert [TRTCScreenCaptureSourceList] to Json format
  List<Map<String, dynamic>> sourceInfoToJson() {
    List<Map<String, dynamic>> listJson = [];
    if (this.sourceInfo.isNotEmpty) {
      for (var sourceInfo in this.sourceInfo) {
        listJson.add(sourceInfo.toJson());
      }
    }
    return listJson;
  }

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['sourceInfo'] = sourceInfoToJson();
    return data;
  }

  /// Parse the corresponding structure from Json
  factory TRTCScreenCaptureSourceList.fromJson(Map<String?, dynamic> json) {
    return TRTCScreenCaptureSourceList(
      count: json['count'],
      sourceInfo: List<TRTCScreenCaptureSourceInfo>.from(
        json['sourceInfo'].map(
          (x) {
            Map<String, dynamic> xMap = (x as Map<Object?, Object?>).cast<String, dynamic>();
            return TRTCScreenCaptureSourceInfo.fromJson(xMap);
          },
        ),
      ),
    );
  }
}

/// Target information for screen sharing (desktop only)
/// 
/// When users perform screen sharing, they can choose to capture the entire desktop or only the window of a certain program.
/// 
/// TRTCScreenCaptureSourceInfo is used to describe the information of the target to be shared, 
/// including ID, name, thumbnail, etc. The field information in this structure is read-only.
class TRTCScreenCaptureSourceInfo {
  /// Collection source type (share the entire screen? Or share a window?).
  TRTCScreenCaptureSourceType? type;

  /// The ID of the collection source. 
  /// 
  /// For windows, this field represents the ID of the window; 
  /// for screens, this field represents the ID of the monitor.
  int? sourceId;

  /// Collection source name (encoded in UTF8).
  String? sourceName;

  /// A thumbnail image of the share window.
  TRTCImageBuffer? thumbBGRA;

  /// A icon image of the share window.
  TRTCImageBuffer? iconBGRA;

  /// Whether the window is minimized.
  bool? isMinimizeWindow;

  /// Whether it is the main display (applicable to multiple monitors).
  bool? isMainScreen;

  /// Screen/window x coordinate, unit: pixel.
  int? x;

  /// Screen/window y coordinate, unit: pixel.
  int? y;

  /// Screen/window width, unit: pixels.
  int? width;

  /// Screen/window height, unit: pixels.
  int? height;

  TRTCScreenCaptureSourceInfo({
    this.type,
    this.sourceId,
    this.sourceName,
    this.thumbBGRA,
    this.iconBGRA,
    this.isMinimizeWindow,
    this.isMainScreen,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = _fromEnumType(this.type!);
    data['sourceId'] = this.sourceId;
    data['sourceName'] = this.sourceName;
    data['thumbBGRA'] = this.thumbBGRA?.toJson();
    data['iconBGRA'] = this.iconBGRA?.toJson();
    data['isMinimizeWindow'] = this.isMinimizeWindow;
    data['isMainScreen'] = this.isMainScreen;
    data['x'] = this.x;
    data['y'] = this.y;
    data['width'] = this.width;
    data['height'] = this.height;
    return data;
  }

  /// Parse the corresponding structure from Json
  factory TRTCScreenCaptureSourceInfo.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> thumbBGRAJson;
    thumbBGRAJson = (json['thumbBGRA'] as Map<Object?, Object?>).cast<String, dynamic>();

    Map<String, dynamic> iconBGRAJson;
    iconBGRAJson = (json['iconBGRA'] as Map<Object?, Object?>).cast<String, dynamic>();
    
    return TRTCScreenCaptureSourceInfo(
      type: _fromInt(json['type']),
      sourceId: json['sourceId'],
      sourceName: json['sourceName'],
      thumbBGRA: TRTCImageBuffer.fromJson(thumbBGRAJson),
      iconBGRA: TRTCImageBuffer.fromJson(iconBGRAJson),
      isMinimizeWindow: json['isMinimizeWindow'],
      isMainScreen: json['isMainScreen'],
      x: json['x'],
      y: json['y'],
      width: json['width'],
      height: json['height'],
    );
  }

  static TRTCScreenCaptureSourceType _fromInt(int value) {
    if (value == 0) {
      return TRTCScreenCaptureSourceType.window;
    } else if (value == 1) {
      return TRTCScreenCaptureSourceType.screen;
    } else if (value == 2) {
      return TRTCScreenCaptureSourceType.custom;
    } else {
      return TRTCScreenCaptureSourceType.unknown;
    }
  }

  static int _fromEnumType(TRTCScreenCaptureSourceType type) {
    if (type == TRTCScreenCaptureSourceType.window) {
      return 0;
    } else if (type == TRTCScreenCaptureSourceType.screen) {
      return 1;
    } else if (type == TRTCScreenCaptureSourceType.custom) {
      return 2;
    } else if (type == TRTCScreenCaptureSourceType.unknown) {
      return -1;
    }
    return -1;
  }
}

/// Screen sharing target type (desktop only)
enum TRTCScreenCaptureSourceType {
  /// Not defined.
  unknown,

  /// The sharing target is a window of a certain application.
  window,

  /// The sharing target is the screen of a certain monitor.
  screen,

  /// The sharing target is a user-defined data source.
  custom,
}

/// TRTC screen sharing icon information and mute image shim
class TRTCImageBuffer {
  /// The size of the image data.
  int? length;

  /// The width of the image.
  int? width;

  /// The height of the image.
  int? height;

  /// The content of image storage is generally a BGRA structure.
  Uint8List? buffer;

  TRTCImageBuffer({this.buffer, this.length, this.width, this.height});

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    if (this.buffer != null) {
      data['buffer'] = this.buffer;
    }
    return data;
  }

  /// Parse the corresponding structure from Json
  factory TRTCImageBuffer.fromJson(Map<String, dynamic> json) {
    return TRTCImageBuffer(
      buffer: Uint8List.fromList(json['buffer'].cast<int>()),
      length: json['length'],
      width: json['width'],
      height: json['height'],
    );
  }
}

/// Advanced control parameters for screen sharing
/// 
/// This parameter is used in the screen sharing related interface [TRTCCloud.selectScreenCaptureTarget] to set a series of advanced control parameters when specifying the sharing target.
/// 
/// For example: whether to collect the mouse, whether to collect the sub-window, 
/// whether to draw a border around the shared target, etc.
class TRTCScreenCaptureProperty {
  /// Whether to collect the mouse while collecting the target content, the default is true.
  bool enableCaptureMouse;

  /// Whether to highlight the window being shared (draw a border around the shared target), the default is true.
  bool enableHighLight;

  /// Whether to enable high-performance mode (will only take effect when sharing the screen), the default is true.
  /// 
  /// When enabled, the screen capture performance is the best, 
  /// but the anti-occlusion ability will be lost. 
  /// If you enable enableHighLight + enableHighPerformance at the same time, 
  /// the remote user can see the highlighted border.
  bool enableHighPerformance;

  /// Specify the color of the highlight border in RGB format. 
  /// When 0 is passed in, the default color is used. The default color is #FFE640.
  int highLightColor;

  /// Specify the width of the highlight border. When 0 is passed in, the default stroke width is used.
  /// The default width is 5px, and the maximum value you can set is 50.
  int highLightWidth;

  /// Whether to collect sub-windows when collecting windows 
  /// (the sub-window and the window being collected need to have Owner or Popup attributes), 
  /// the default is false.
  bool enableCaptureChildWindow;

  TRTCScreenCaptureProperty({
    this.enableCaptureMouse = true,
    this.enableHighLight = true,
    this.enableHighPerformance = true,
    this.highLightColor = 0x000000,
    this.highLightWidth = 0,
    this.enableCaptureChildWindow = false,
  });

  /// {@macro toJson}
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['enableCaptureMouse'] = this.enableCaptureMouse;
    data['enableHighLight'] = this.enableHighLight;
    data['enableHighPerformance'] = this.enableHighPerformance;
    data['highLightColor'] = this.highLightColor;
    data['highLightWidth'] = this.highLightWidth;
    data['enableCaptureChildWindow'] = this.enableCaptureChildWindow;
    return data;
  }

  /// Parse the corresponding structure from Json
  factory TRTCScreenCaptureProperty.fromJson(Map<String, dynamic> json) {
    return TRTCScreenCaptureProperty(
      enableCaptureMouse: json['enableCaptureMouse'],
      enableHighLight: json['enableHighLight'],
      enableHighPerformance: json['enableHighPerformance'],
      highLightColor: json['highLightColor'],
      highLightWidth: json['highLightWidth'],
      enableCaptureChildWindow: json['enableCaptureChildWindow'],
    );
  }
}