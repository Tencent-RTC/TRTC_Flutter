// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

/// The render  view
class V2TXLiveRenderView {
  static const String renderViewType = 'v2_live_view_factory';
}

/// Support Protocols
enum V2TXLiveMode {
  /// RTMP Protocol
  v2TXLiveModeRTMP,

  /// TRTC Protocols
  v2TXLiveModeRTC,
}

/// Video resolution
enum V2TXLiveVideoResolution {
  /// Resolution 160*160, Bitrate range: 100Kbps ~ 150Kbps, fps: 15fps
  v2TXLiveVideoResolution160x160,

  /// Resolution 270*270, Bitrate range: 200Kbps ~ 300Kbps, fps: 15fps
  v2TXLiveVideoResolution270x270,

  /// Resolution 480*480, Bitrate range: 350Kbps ~ 525Kbps, fps: 15fps
  v2TXLiveVideoResolution480x480,

  /// Resolution 320*240, Bitrate range: 250Kbps ~ 375Kbps, fps: 15fps
  v2TXLiveVideoResolution320x240,

  /// Resolution 480*360, Bitrate range: 400Kbps ~ 600Kbps, fps: 15fps
  v2TXLiveVideoResolution480x360,

  /// Resolution 640*480, Bitrate range: 600Kbps ~ 900Kbps, fps: 15fps
  v2TXLiveVideoResolution640x480,

  /// Resolution 320*180, Bitrate range: 250Kbps ~ 400Kbps, fps: 15fps
  v2TXLiveVideoResolution320x180,

  /// Resolution 480*270, Bitrate range: 350Kbps ~ 550Kbps, fps: 15fps
  v2TXLiveVideoResolution480x270,

  /// Resolution 640*360, Bitrate range: 500Kbps ~ 900Kbps, fps: 15fps
  v2TXLiveVideoResolution640x360,

  /// Resolution 960*540, Bitrate range: 800Kbps ~ 1500Kbps, fps: 15fps
  v2TXLiveVideoResolution960x540,

  /// Resolution 1280*720, Bitrate range: 1000Kbps ~ 1800Kbps, fps: 15fps
  v2TXLiveVideoResolution1280x720,

  /// Resolution 1920*1080, Bitrate range: 2500Kbps ~ 3000Kbps, fps: 15fps
  v2TXLiveVideoResolution1920x1080,
}

/// Video aspect ratio mode
/// note
/// - Resolution in landscape mode: V2TXLiveVideoResolution640_360 + V2TXLiveVideoResolutionModeLandscape = 640x360
/// - Resolution in portrait mode:   V2TXLiveVideoResolution640_360 + V2TXLiveVideoResolutionModePortrait = 360x640
enum V2TXLiveVideoResolutionMode {
  /// Landscape mode
  v2TXLiveVideoResolutionModeLandscape,

  /// Portrait mode
  v2TXLiveVideoResolutionModePortrait,
}

/// Video encoding parameters
class V2TXLiveVideoEncoderParam {
  /// Field Meaning: Video resolution
  ///
  /// Special note: To use portrait resolution, specify videoResolutionMode as Portrait, for example: 640 × 360 + Portrait = 360 × 640.
  /// Recommended values
  /// - Desktop platform (Win + Mac): It is recommended to select 640 × 360 resolution or above, and select Landscape for videoResolutionMode.
  V2TXLiveVideoResolution videoResolution;

  /// Field Meaning: Resolution mode (landscape resolution or portrait resolution)
  ///
  /// Recommended values: For desktop platforms (Windows and Mac), we recommend that you select Landscape.
  ///
  /// Special note: If you want to use portrait resolution, specify resMode as Portrait, for example: 640 × 360 + Portrait = 360 × 640.
  V2TXLiveVideoResolutionMode videoResolutionMode;

  /// Field Meaning: The frame rate of video capture
  ///
  /// Recommended value: 15fps or 20fps. Below 5fps, the feeling of stuttering is obvious. Below 10fps, there will be a slight stuttering sensation. Above 20fps, bandwidth is wasted (the frame rate for movies is 24fps).
  int videoFps;

  /// Field Meaning: The SDK will encode the target video bitrate according to the target bitrate, and will actively reduce the video bitrate only in a weak network environment.
  ///
  /// Recommended values: Please refer to V2TXLiveVideoResolution for the optimal bitrate annotation of each level, or you can increase it appropriately on this basis.
  /// - For example, V2TXLiveVideoResolution1280x720 corresponds to a target bitrate of 1200kbps, and you can also set it to 1500kbps for better viewing and clarity.
  ///
  /// Note: You can set two parameters, videoBitrate and minVideoBitrate, to constrain the SDK to adjust the video bitrate:
  /// - If you set videoBitrate and minVideoBitrate to the same value, it is equivalent to disabling the SDK's ability to adapt to the video bitrate.
  int videoBitrate;

  /// Field Meaning: Minimum video bitrate, the SDK will actively reduce the video bitrate to maintain smoothness when the network is poor, and the minimum will drop to the value set by minVideoBitrate.
  ///
  /// Recommended values: You can set two parameters, videoBitrate and minVideoBitrate, to constrain the SDK to adjust the video bitrate:
  /// - If you set videoBitrate and minVideoBitrate to the same value, it is equivalent to disabling the SDK's ability to adapt to the video bitrate.
  int minVideoBitrate;

  V2TXLiveVideoEncoderParam({
    this.videoResolution =
        V2TXLiveVideoResolution.v2TXLiveVideoResolution960x540,
    this.videoResolutionMode =
        V2TXLiveVideoResolutionMode.v2TXLiveVideoResolutionModePortrait,
    this.videoFps = 15,
    this.videoBitrate = 1500,
    this.minVideoBitrate = 800,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['videoResolution'] = videoResolution.index;
    data['videoResolutionMode'] = videoResolutionMode.index;
    data['videoFps'] = videoFps;
    data['videoBitrate'] = videoBitrate;
    data['minVideoBitrate'] = minVideoBitrate;
    return data;
  }
}

/// Local video preview image type
enum V2TXLiveMirrorType {
  /// The default mirror type of the system is that the front camera is mirrored, and the rear camera is not mirrored
  v2TXLiveMirrorTypeAuto,

  /// Both the front and rear cameras are switched to mirror mode
  v2TXLiveMirrorTypeEnable,

  /// Both the front and rear cameras are switched to non-mirror mode
  v2TXLiveMirrorTypeDisable,
}

/// Video fill mode
enum V2TXLiveFillMode {
  /// Images fill the screen, and the portion of the video that extends beyond the display window will be cropped and the screen display may be incomplete
  v2TXLiveFillModeFill,

  /// The long side of the image fills the screen, and the short side area is filled with black, leaving the content of the picture complete
  v2TXLiveFillModeFit,

  v2TXLiveFillModeScaleFill,
}

/// Rotate the angle of the video screen clockwise
enum V2TXLiveRotation {
  /// Does not rotate
  v2TXLiveRotation0,

  /// Rotate 90 degrees clockwise
  v2TXLiveRotation90,

  /// Rotate 180 degrees clockwise
  v2TXLiveRotation180,

  /// Rotate 270 degrees clockwise
  v2TXLiveRotation270,
}

/// The pixel format of the video frame
enum V2TXLivePixelFormat {
  /// Unknown
  v2TXLivePixelFormatUnknown,

  /// YUV420P I420
  v2TXLivePixelFormatI420,

  /// YUV420SP NV12
  v2TXLivePixelFormatNV12,

  /// BGRA8888
  v2TXLivePixelFormatBGRA32,

  /// OpenGL 2D Texture
  v2TXLivePixelFormatTexture2D,
}

/// Video data packaging format
enum V2TXLiveBufferType {
  /// Unknown
  v2TXLiveBufferTypeUnknown,

  /// DirectBuffer, which mounts buffers such as I420, is used at the native layer
  ///
  /// Not at this time
  v2TXLiveBufferTypeByteBuffer,

  /// byte[], Load buffers such as I420 and use them at the Java layer
  v2TXLiveBufferTypeByteArray,

  /// Manipulate texture IDs directly for the best performance and minimal loss of image quality
  v2TXLiveBufferTypeTexture,
}

/// Video frame information
class V2TXLiveVideoFrame {
  /// Field Meaning: The pixel format of the video frame
  ///
  /// Recommended values: V2TXLivePixelFormatNV12
  V2TXLivePixelFormat pixelFormat;

  /// Field Meaning: The format of the video data package
  ///
  /// Recommended values: V2TXLiveBufferTypePixelBuffer
  V2TXLiveBufferType bufferType;

  /// Field Meaning: Video data when bufferType is V2TXLiveBufferTypeNSData
  Uint8List? data;

  /// Field Meaning: The width of the video
  int width;

  /// Field Meaning: The height of the video
  int height;

  /// Field Meaning: The clockwise rotation angle of the video frame
  V2TXLiveRotation rotation;

  /// Field Meaning: The ID of the video texture
  int? textureId;

  V2TXLiveVideoFrame({
    required this.pixelFormat,
    required this.bufferType,
    required this.width,
    required this.height,
    this.rotation = V2TXLiveRotation.v2TXLiveRotation0,
    this.data,
    this.textureId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['pixelFormat'] = pixelFormat;
    jsonData['bufferType'] = bufferType;
    jsonData['width'] = width;
    jsonData['height'] = height;
    jsonData['rotation'] = rotation.index;
    if (data != null) {
      jsonData['data'] = data;
    }
    if (textureId != null) {
      jsonData['textureId'] = textureId;
    }
    return jsonData;
  }
}

/// Sound sound quality
enum V2TXLiveAudioQuality {
  ///  Voice Quality: Sample Rate: 16k; Mono; Audio bitrate: 16kbps; It is suitable for scenarios where voice calls are the mainstay, such as online meetings and voice calls
  v2TXLiveAudioQualitySpeech,

  /// Default Sound Quality: Sample Rate: 48k; Mono; Audio bitrate: 50kbps; The default audio quality of the SDK is recommended if you do not have special requirements
  v2TXLiveAudioQualityDefault,

  /// Music Sound Quality: Sample Rate: 48K; Dual channel + full band; Audio bitrate: 128kbps; It is suitable for scenarios that require high-fidelity music transmission, such as karaoke, live music, etc
  v2TXLiveAudioQualityMusic,
}

/// Audio frame information
class V2TXLiveAudioFrame {
  /// Field Meaning: Audio data
  Uint8List data;

  /// Field Meaning: Sampling rate
  int sampleRate;

  /// Field Meaning: The number of channels
  int channel;

  V2TXLiveAudioFrame(
      {required this.data, required this.sampleRate, required this.channel});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonData = <String, dynamic>{};
    jsonData['data'] = data;
    jsonData['sampleRate'] = sampleRate;
    jsonData['channel'] = channel;
    return jsonData;
  }
}

/// Configure the input type of mixed stream
enum V2TXLiveMixInputType {
  /// Mix in audio and video
  v2TXLiveMixInputTypeAudioVideo,

  /// Only the video is mixed in
  v2TXLiveMixInputTypePureVideo,

  /// Only the audio is mixed in
  v2TXLiveMixInputTypePureAudio,
}

/// The location of each sprite in the cloud mixed stream
class V2TXLiveMixStream {
  /// Field Meaning: The userId of the person participating in the mixing
  String userId;

  /// Field Meaning: The streamId of the userId participating in stream mixing is the corresponding streamId, nil indicates the current streamId of the stream
  String? streamId;

  /// Field Meaning: Layer Position x Coordinate (Absolute Pixel Value)
  int x;

  /// Field Meaning: Layer Position y Coordinate (Absolute Pixel Value)
  int y;

  /// Field Meaning: Layer position width (absolute pixel value)
  int width;

  /// Field Meaning: Layer Position Height (Absolute Pixel Value)
  int height;

  /// Field Meaning: The layer level (1 - 15) cannot be repeated
  int zOrder;

  /// Field Meaning: The input type of the live stream
  V2TXLiveMixInputType inputType;

  V2TXLiveMixStream({
    required this.userId,
    this.x = 0,
    this.y = 0,
    this.width = 360,
    this.height = 640,
    this.zOrder = 1,
    this.inputType = V2TXLiveMixInputType.v2TXLiveMixInputTypeAudioVideo,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['streamId'] = streamId ?? "";
    data['x'] = x;
    data['y'] = y;
    data['width'] = width;
    data['height'] = height;
    data['zOrder'] = zOrder;
    data['inputType'] = inputType.index;
    return data;
  }
}

/// Configure cloud stream mixing (transcoding).
class V2TXLiveTranscodingConfig {
  /// Field Meaning: The width of the final transcoded video resolution
  ///
  /// Recommended value: 360px, if you are streaming audio-only, please set width × height to 0px × 0px, otherwise it will carry a video stream with a canvas background after mixing
  int videoWidth;

  /// Field Meaning: The height of the final transcoded video resolution
  ///
  /// Recommended value: 640px, if you are streaming audio-only, please set width × height to 0px × 0px, otherwise the video stream with a canvas background will be carried after mixing
  int videoHeight;

  /// Field Meaning: The bitrate of the final transcoded video resolution (kbps)
  ///
  /// If you set 0, the bitrate will be estimated based on videoWidth and videoHeight, and you can also refer to the annotation of the enumeration definition of V2TXLiveVideoResolution
  int videoBitrate;

  /// Field Meaning: Frame Rate (FPS) of the final transcoded video resolution
  ///
  /// Recommended value: Default value: 15fps, value range is (0,30]
  int videoFramerate;

  /// Field Meaning: The keyframe interval of the final transcoded video resolution (also known as GOP)
  ///
  /// Recommended values: Default value: 2, in seconds, and the value range is `[1,8]`
  int videoGOP;

  /// 【Field Meaning】The background color of the mixed screen is black by default, and the format is hexadecimal numbers, for example: "0x61B9F1" represents RGB (97,158,241)
  ///
  /// Recommended values: Default values: 0x000000, black
  int backgroundColor;

  /// Field Meaning: The background image of the blended screen
  ///
  /// Recommended value: The default value is nil, that is, no background image is set
  ///
  /// Special Note: You need to upload the background image to "[Console](https://console.cloud.tencent.com/trtc) => Application management => Functional configuration => Content management" in advance,
  ///            After the upload is successful, you can get the corresponding "Image ID", and then convert the "Image ID" to a string type and set it to backgroundImage.
  ///            For example, if the "Image ID" is 63, you can set backgroundImage = "63";
  String? backgroundImage;

  /// Field Meaning: The final transcoded audio sample rate
  ///
  /// Recommended values: Default values 48000Hz. Support 12000HZ、16000HZ、22050HZ、24000HZ、32000HZ、44100HZ、48000HZ
  int audioSampleRate;

  /// Field Meaning: The final transcoded audio bitrate
  ///
  /// Recommended values: The default value is 64 kbps, and the value range is `[32,192]`, unit: kbps
  int audioBitrate;

  /// Field Meaning: The number of audio channels after final transcoding
  ///
  /// Recommended value: Default value: 1. The value range is an integer in `[1,2]`
  int audioChannels;

  /// Field Meaning: The location information of each sprite
  List<V2TXLiveMixStream> mixStreams = <V2TXLiveMixStream>[];

  /// Field Meaning: The ID of the live stream output to the CDN
  ///  - If this parameter is not set, the SDK will execute the default logic, that is, the multi-stream in the room will be mixed with the video stream of the API caller, that is, A + B = > A;
  ///  - If you set this parameter, the SDK will mix the multiple streams in the room to the live stream ID that you specify, which is A + B = > C.
  ///
  /// Recommended value: Default value: nil, that is, the multiple streams in the room will be mixed with the video stream of the API caller.
  String? outputStreamId;

  V2TXLiveTranscodingConfig({
    this.videoWidth = 360,
    this.videoHeight = 640,
    this.videoBitrate = 0,
    this.videoFramerate = 15,
    this.videoGOP = 2,
    this.backgroundColor = 0x000000,
    this.audioSampleRate = 48000,
    this.audioBitrate = 64,
    this.audioChannels = 1,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['videoWidth'] = videoWidth;
    data['videoHeight'] = videoHeight;
    data['videoBitrate'] = videoBitrate;
    data['videoFramerate'] = videoFramerate;
    data['videoGOP'] = videoGOP;
    data['backgroundColor'] = backgroundColor;
    if (backgroundImage != null) {
      data['backgroundImage'] = backgroundImage ?? "";
    }
    data['audioSampleRate'] = audioSampleRate;
    data['audioBitrate'] = audioBitrate;
    data['audioChannels'] = audioChannels;
    if (outputStreamId != null) {
      data['outputStreamId'] = outputStreamId ?? "";
    }
    if (mixStreams.isNotEmpty) {
      List<Map> mixStreamsDatas = <Map>[];
      for (var item in mixStreams) {
        mixStreamsDatas.add(item.toJson());
      }
      data['mixStreams'] = mixStreamsDatas;
    }
    return data;
  }
}

/// Log-level enumeration values
enum V2TXLiveLogLevel {
  /// Outputs logs for all levels
  v2TXLiveLogLevelAll,

  /// Outputs DEBUG，INFO，WARNING，ERROR and FATAL level log
  v2TXLiveLogLevelDebug,

  /// Outputs INFO，WARNING，ERROR and FATAL level log
  v2TXLiveLogLevelInfo,

  /// Outputs WARNING，ERROR and FATAL level log
  v2TXLiveLogLevelWarning,

  /// Outputs ERROR and FATAL level log
  v2TXLiveLogLevelError,

  /// Outputs FATAL level log
  v2TXLiveLogLevelFatal,

  /// No SDK log is output
  v2TXLiveLogLevelNULL,
}

/// Log configuration
class V2TXLiveLogConfig {
  /// Field Meaning: Set the log level
  ///
  /// Recommended values: Default value: V2TXLiveLogLevelAll
  V2TXLiveLogLevel logLevel;

  /// Field Meaning: Whether to receive the log information to be printed through [V2TXLivePremierObserver].
  ///
  /// Special Note: If you want to write logs by yourself, you can turn on this switch, and the log information will be called back to you through [V2TXLivePremierObserverType.onLog].
  ///
  /// Recommended value: Default value: false
  bool enableObserver;

  /// Field Meaning: Whether to allow the SDK to print logs on the console of the editor (XCoder, Android Studio, Visual Studio, etc.).
  ///
  /// Recommended value: Default value: false
  bool enableConsole;

  /// Field Meaning: Whether to enable local log files
  ///
  /// 【Special Note】If you do not need to do so, please do not close the local log file, otherwise the Tencent Cloud technical team will not be able to track and locate the problem when it occurs.
  ///
  /// Recommended value: Default value: true
  bool enableLogFile;

  /// Field Meaning: Set the storage directory of the local log
  ///
  /// Default log storage location:
  ///  * iOS & Mac: sandbox Documents/log
  ///  * Android:
  ///    * 6.7 or below: /sdcard/log/liteav
  ///    * 6.8 or above: /sdcard/Android/data/package name/files/log/liteav/
  String? logPath;

  V2TXLiveLogConfig({
    this.logLevel = V2TXLiveLogLevel.v2TXLiveLogLevelAll,
    this.enableObserver = false,
    this.enableConsole = false,
    this.enableLogFile = true,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['logLevel'] = logLevel.index;
    data['enableObserver'] = enableObserver;
    data['enableConsole'] = enableConsole;
    data['enableLogFile'] = enableLogFile;
    if (logPath != null) {
      data['logPath'] = logPath;
    }
    return data;
  }
}

/// Protocol configuration for the SOCKS5 proxy
class V2TXLiveSocks5ProxyConfig {
  /// Field Meaning: Whether https is supported.
  ///
  /// Recommended value: Default value: true.
  bool supportHttps;

  ///Field Meaning: Whether tcp is supported.
  ///
  /// Recommended value: Default value: true.
  bool supportTcp;

  ///Field Meaning: Whether udp is supported.
  ///
  /// Recommended value: Default value: true.
  bool supportUdp;

  V2TXLiveSocks5ProxyConfig(
      {this.supportHttps = true,
      this.supportTcp = true,
      this.supportUdp = true});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['supportHttps'] = supportHttps;
    data['supportTcp'] = supportTcp;
    data['supportUdp'] = supportUdp;
    return data;
  }
}

/// The control mode of the system volume type
class TXSystemVolumeType {
  /// Automatic mode switching
  static int TXSystemVolumeTypeAuto = 0;

  /// Full media volume
  static int TXSystemVolumeTypeMedia = 1;

  /// The volume of the whole call
  static int TXSystemVolumeTypeVOIP = 2;
}

/// Audio routing (the playback mode of the sound)
class TXAudioRoute {
  /// Play with speakers ("hands-free"), which are located at the bottom of the phone and are on the louder side, making them suitable for playing music outside
  static int TXAudioRouteSpeakerphone = 0;

  /// Use the handset to play the handset, which is located on the top of the phone, and the sound is on the low side, which is suitable for call scenarios that need to protect privacy
  static int TXAudioRouteEarpiece = 1;
}

/// Reverb effects
class TXVoiceReverbType {
  /// Disable reverb
  static int TXVoiceReverbType_0 = 0;

  /// KTV
  static int TXVoiceReverbType_1 = 1;

  /// Small room
  static int TXVoiceReverbType_2 = 2;

  /// Big hall
  static int TXVoiceReverbType_3 = 3;

  /// Deep
  static int TXVoiceReverbType_4 = 4;

  /// Resonant
  static int TXVoiceReverbType_5 = 5;

  /// Metallic
  static int TXVoiceReverbType_6 = 6;

  /// Magnetic
  static int TXVoiceReverbType_7 = 7;

  /// Ethereal
  static int TXVoiceReverbType_8 = 8;

  /// Studio
  static int TXVoiceReverbType_9 = 9;

  /// Melodious
  static int TXVoiceReverbType_10 = 10;

  /// Studio2
  static int TXVoiceReverbType_11 = 11;
}

/// Voice-changing effects
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

/// Local recording type
enum V2TXLiveRecordType {
  /// Record both audio and video
  v2TXLiveRecordTypeBoth,
}

/// Local media file recording parameters
class V2TXLiveLocalRecordingParams {
  /// Field Meaning: Address of the recording file, which is required.
  ///
  /// Special Note: Please ensure that the path is valid with read/write permissions; otherwise, the recording file cannot be generated.
  /// This path must be accurate to the file name and extension. The extension determines the format of the recording file.
  /// Currently, only the MP4 format is supported.
  /// For example, if you specify the path as `mypath/record/test.mp4`, it means that you want the SDK to generate a local video file in MP4 format.
  String filePath;

  /// Field Meaning: Media recording type, which is `v2TXLiveRecordTypeBoth` by default, indicating to record both audio and video.
  V2TXLiveRecordType recordType;

  /// Field Meaning: The update frequency of the recording information in milliseconds.
  ///
  /// Value range: 1000–10000. Default value: -1, indicating not to call back.
  int interval;

  V2TXLiveLocalRecordingParams({
    this.filePath = '',
    this.recordType = V2TXLiveRecordType.v2TXLiveRecordTypeBoth,
    this.interval = -1,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filePath'] = filePath;
    data['recordType'] = recordType.index;
    data['interval'] = interval;
    return data;
  }
}

/// Image type for V2TXLiveImage
enum V2TXLiveImageType {
  /// Image file path
  v2TXLiveImageTypeFile,

  /// BGRA32 pixel format
  v2TXLiveImageTypeBGRA32,

  /// RGBA32 pixel format
  v2TXLiveImageTypeRGBA32,
}

/// Image information for live streaming
class V2TXLiveImage {
  /// Field Meaning: Image source
  /// - For V2TXLiveImageTypeFile: image file path
  /// - For other types: image content data
  String? imageSrc;

  /// Field Meaning: Image data type
  /// Default value: V2TXLiveImageTypeBGRA32
  V2TXLiveImageType imageType;

  /// Field Meaning: Image width
  /// Default value: 0 (ignored when imageType is V2TXLiveImageTypeFile)
  int imageWidth;

  /// Field Meaning: Image height
  /// Default value: 0 (ignored when imageType is V2TXLiveImageTypeFile)
  int imageHeight;

  /// Field Meaning: Image data length in bytes
  int imageLength;

  V2TXLiveImage({
    this.imageSrc,
    this.imageType = V2TXLiveImageType.v2TXLiveImageTypeBGRA32,
    this.imageWidth = 0,
    this.imageHeight = 0,
    this.imageLength = 0,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (imageSrc != null) {
      data['imageSrc'] = imageSrc;
    }
    data['imageType'] = imageType.index;
    data['imageWidth'] = imageWidth;
    data['imageHeight'] = imageHeight;
    data['imageLength'] = imageLength;
    return data;
  }
}
