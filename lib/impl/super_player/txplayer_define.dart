// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: constant_identifier_names
// ignore_for_file: provide_deprecation_message
// ignore_for_file: unnecessary_this
part of 'super_player.dart';

const _kFTXPlayerRenderViewType = "FTXRenderViewType";
const _kFTXAndroidRenderTypeKey = "renderViewType";

class TXPlayerValue {
  final TXPlayerState state;

  // The rotation angle of the current video texture.
  final int degree;

  TXPlayerValue.uninitialized() : this();

  TXPlayerValue({
    this.state = TXPlayerState.stopped,
    this.degree = 0,
  });

  TXPlayerValue copyWith({
    TXPlayerState? state,
    int? degree,
  }) {
    return TXPlayerValue(
        state: state ?? this.state, degree: degree ?? this.degree);
  }
}

/// DRM playback information.
class TXPlayerDrmBuilder {
  /// URL to play media.
  String licenseUrl;

  /// Decrypt key url.
  String playUrl;

  /// Certificate provider url.
  String? deviceCertificateUrl;
  TXPlayerDrmBuilder(this.licenseUrl, this.playUrl,
      {this.deviceCertificateUrl});

  /// Serialize to a Map for MethodChannel transport.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'licenseUrl': licenseUrl,
      'playUrl': playUrl,
      'deviceCertificateUrl': deviceCertificateUrl,
    };
  }
}

///
/// Live stream type.
///
abstract class TXPlayType {
  ///
  /// see: https://cloud.tencent.com/document/product/454/7886
  ///
  static const LIVE_RTMP = 0;
  static const LIVE_FLV = 1;
  static const LIVE_RTMP_ACC = 5;

  /// must depend on professional sdk
  static const VOD_HLS = 7;
}

abstract class TXVodPlayEvent {
  // Invalid license, call failed.
  static const PLAY_EVT_ERROR_INVALID_LICENSE = -5;
  // Connected to server.
  static const PLAY_EVT_CONNECT_SUCC = 2001;
  // Connected to server, start pulling stream (only for playing RTMP address).
  static const PLAY_EVT_RTMP_STREAM_BEGIN = 2002;
  // Received the first frame of data, the faster you receive this message, the better the link quality.
  static const PLAY_EVT_RCV_FIRST_I_FRAME = 2003;
  // Video playback starts, if you make your own loading, you will need it.
  static const PLAY_EVT_PLAY_BEGIN = 2004;
  // Video playback progress.
  static const PLAY_EVT_PLAY_PROGRESS = 2005;
  // Video playback ends.
  static const PLAY_EVT_PLAY_END = 2006;
  // Video playback enters buffering state, and there will be a PLAY_BEGIN event after buffering ends.
  static const PLAY_EVT_PLAY_LOADING = 2007;
  // Video decoder starts to work (added after version 2.0).
  static const PLAY_EVT_START_VIDEO_DECODER = 2008;
  // Video resolution changes (resolution is in the EVT_PARAM parameter).
  static const PLAY_EVT_CHANGE_RESOLUTION = 2009;
  // Successfully obtained on-demand file information.
  static const PLAY_EVT_GET_PLAYINFO_SUCC = 2010;
  // Video rotation change event.
  static const PLAY_EVT_CHANGE_ROTATION = 2011;
  // Get custom SEI message embedded in video stream, message sending needs to use TXLivePusher.
  static const PLAY_EVT_GET_MESSAGE = 2012;
  // Video loading completed (VOD).
  static const PLAY_EVT_VOD_PLAY_PREPARED = 2013;
  // Loading ends (VOD).
  static const PLAY_EVT_VOD_LOADING_END = 2014;
  // Live streaming switch completed.
  static const PLAY_EVT_STREAM_SWITCH_SUCC = 2015;
  // View rendering first frame time.
  static const PLAY_EVT_RENDER_FIRST_FRAME_ON_VIEW = 2033;
  // Network disconnected and cannot be restored after multiple reconnections.
  // Please restart the playback by yourself if you want to try again.
  static const PLAY_ERR_NET_DISCONNECT = -2301;
  // Failed to get accelerated streaming address.
  static const PLAY_ERR_GET_RTMP_ACC_URL_FAIL = -2302;
  // File does not exist.
  static const PLAY_ERR_FILE_NOT_FOUND = -2303;
  // H.265 decoding failed.
  static const PLAY_ERR_HEVC_DECODE_FAIL = -2304;
  // Failed to obtain HLS decryption key.
  static const PLAY_ERR_HLS_KEY = -2305;
  // Failed to get VOD file information.
  static const PLAY_ERR_GET_PLAYINFO_FAIL = -2306;
  // Live streaming quality switch failed.
  static const PLAY_ERR_STREAM_SWITCH_FAIL = -2307;
  // Current video frame decoding failed.
  static const PLAY_WARNING_VIDEO_DECODE_FAIL = 2101;
  // Current audio frame decoding failed.
  static const PLAY_WARNING_AUDIO_DECODE_FAIL = 2102;
  // Network disconnected, and automatic reconnection has been started
  // (if reconnection exceeds three times, PLAY_ERR_NET_DISCONNECT will be thrown directly).
  static const PLAY_WARNING_RECONNECT = 2103;
  // Network packet is unstable: it may be due to insufficient downstream bandwidth, or uneven flow from the anchor end.
  static const PLAY_WARNING_RECV_DATA_LAG = 2104;
  // Current video playback is stuck.
  static const PLAY_WARNING_VIDEO_PLAY_LAG = 2105;
  // Hardware decoding failed, using software decoding.
  static const PLAY_WARNING_HW_ACCELERATION_FAIL = 2106;
  // Current video frame is not continuous, may have dropped frames.
  static const PLAY_WARNING_VIDEO_DISCONTINUITY = 2107;
  // RTMP-DNS resolution failed (only for playing RTMP address).
  static const PLAY_WARNING_DNS_FAIL = 3001;
  // RTMP server connection failed (only for playing RTMP address).
  static const PLAY_WARNING_SEVER_CONN_FAIL = 3002;
  // RTMP server handshake failed (only for playing RTMP address).
  static const PLAY_WARNING_SHAKE_FAIL = 3003;
  // RTMP read/write failed.
  static const PLAY_WARNING_READ_WRITE_FAIL = 3005;
  // Playback device exception.
  static const PLAY_WARNING_SPEAKER_DEVICE_ABNORMAL = 1205;
  // Receive the first frame data packet event, supported since version 12.0.
  static const VOD_PLAY_EVT_VOD_PLAY_FIRST_VIDEO_PACKET = 2017;
  // Seek completed.
  static const VOD_PLAY_EVT_SEEK_COMPLETE = 2019;
  // Video SEI frame information, Player Premium version 11.6 starts to support.
  static const VOD_PLAY_EVT_VIDEO_SEI = 2030;
  // HEVC downgrade playback, Player Premium version 12.0 starts to support.
  static const VOD_PLAY_EVT_HEVC_DOWNGRADE_PLAYBACK = 2031;
  // Video loop once complete.
  static const VOD_PLAY_EVT_LOOP_ONCE_COMPLETE = 6001;

  // UTC time.
  static const EVT_UTC_TIME = "EVT_UTC_TIME";
  // Stuttering time.
  static const EVT_BLOCK_DURATION = "EVT_BLOCK_DURATION";
  // Event occurrence time.
  static const EVT_TIME = "EVT_TIME";
  // Event description.
  static const EVT_DESCRIPTION = "EVT_MSG";
  // Event parameter 1.
  static const EVT_PARAM1 = "EVT_PARAM1";
  // Event parameter 2.
  static const EVT_PARAM2 = "EVT_PARAM2";
  // Width of resolution.
  static const EVT_VIDEO_WIDTH = "EVT_WIDTH";
  // Height of resolution.
  static const EVT_VIDEO_HEIGHT = "EVT_HEIGHT";
  // Message content, use this field to get the message content when receiving PLAY_EVT_GET_MESSAGE event.
  static const EVT_GET_MSG = "EVT_GET_MSG";
  // Video cover.
  static const EVT_PLAY_COVER_URL = "EVT_PLAY_COVER_URL";
  // Video address.
  static const EVT_PLAY_URL = "EVT_PLAY_URL";
  // Video name.
  static const EVT_PLAY_NAME = "EVT_PLAY_NAME";
  // Video introduction.
  static const EVT_PLAY_DESCRIPTION = "EVT_PLAY_DESCRIPTION";
  // Playback progress (in milliseconds).
  static const EVT_PLAY_PROGRESS_MS = "EVT_PLAY_PROGRESS_MS";
  // Total playback time (in milliseconds).
  static const EVT_PLAY_DURATION_MS = "EVT_PLAY_DURATION_MS";
  // Playback progress.
  static const EVT_PLAY_PROGRESS = "EVT_PLAY_PROGRESS";
  // Total playback time.
  static const EVT_PLAY_DURATION = "EVT_PLAY_DURATION";
  // Playable duration of VOD (in milliseconds).
  static const EVT_PLAYABLE_DURATION_MS = "EVT_PLAYABLE_DURATION_MS";
  // Playable duration of VOD.
  static const EVT_PLAYABLE_DURATION = "EVT_PLAYABLE_DURATION";
  // Playback rate.
  static const EVT_PLAYABLE_RATE = "EVT_PLAYABLE_RATE";
  // Web VTT description file download URL of sprite map.
  static const EVT_IMAGESPRIT_WEBVTTURL = "EVT_IMAGESPRIT_WEBVTTURL";
  // Download URL of sprite map image.
  static const EVT_IMAGESPRIT_IMAGEURL_LIST = "EVT_IMAGESPRIT_IMAGEURL_LIST";
  // Encryption type.
  static const EVT_DRM_TYPE = "EVT_DRM_TYPE";
  // Ghost watermark text (supported since version 11.5).
  static const EVT_KEY_WATER_MARK_TEXT = "EVT_KEY_WATER_MARK_TEXT";
  // SEI data type.
  static const EVT_KEY_SEI_TYPE = "EVT_KEY_SEI_TYPE";
  // SEI data size.
  static const EVT_KEY_SEI_SIZE = "EVT_KEY_SEI_SIZE";
  // SEI data.
  static const EVT_KEY_SEI_DATA = "EVT_KEY_SEI_DATA";
  // Play PDT time, Player Premium version 11.6 starts to support.
  static const EVT_PLAY_PDT_TIME_MS = "EVT_PLAY_PDT_TIME_MS";

  /// External subtitle file in SRT format.
  static const VOD_PLAY_MIMETYPE_TEXT_SRT = "text/x-subrip";

  /// External subtitle file in VTT format.
  static const VOD_PLAY_MIMETYPE_TEXT_VTT = "text/vtt";
  // AUTO type (default value, adaptive bit rate playback is not supported yet).
  static const MEDIA_TYPE_AUTO = 0;
  // HLS on-demand media assets.
  static const MEDIA_TYPE_HLS_VOD = 1;
  // HLS Live Media Assets.
  static const MEDIA_TYPE_HLS_LIVE = 2;
  // MP4 and other general file on-demand media assets.
  static const MEDIA_TYPE_FILE_VOD = 3;
  // DASH on-demand media assets.
  static const MEDIA_TYPE_DASH_VOD = 4;

  /// superplayer plugin event
  // Volume change.
  static const EVENT_VOLUME_CHANGED = 1;
  // Loss of volume output playback focus (only for Android).
  static const EVENT_AUDIO_FOCUS_PAUSE = 2;
  // Gain of volume output focus (only for Android).
  static const EVENT_AUDIO_FOCUS_PLAY = 3;
  // Brightness change.
  static const EVENT_BRIGHTNESS_CHANGED = 4;

  /// pip event
  // Entered picture-in-picture mode.
  static const EVENT_PIP_MODE_ALREADY_ENTER = 1;
  // Exited picture-in-picture mode.
  static const EVENT_PIP_MODE_ALREADY_EXIT = 2;
  // Start requesting to enter picture-in-picture mode.
  static const EVENT_PIP_MODE_REQUEST_START = 3;
  // PIP UI status changed (only support Android > 31).
  static const EVENT_PIP_MODE_UI_STATE_CHANGED = 4;
  // Reset UI, restore from PIP window.
  static const EVENT_IOS_PIP_MODE_RESTORE_UI = 5;
  static const EVENT_PIP_MODE_RESTORE_UI = EVENT_IOS_PIP_MODE_RESTORE_UI;
  // Will exit picture-in-picture mode (only support iOS).
  static const EVENT_IOS_PIP_MODE_WILL_EXIT = 6;

  // Screen rotation.
  static const EVENT_ORIENTATION_CHANGED = 401;
  // Screen rotation direction.
  static const EXTRA_NAME_ORIENTATION = "orientation";
  // Portrait, top on top.
  static const ORIENTATION_PORTRAIT_UP = 411;
  // Landscape, top on left, bottom on right.
  static const ORIENTATION_LANDSCAPE_RIGHT = 412;
  // Portrait, top on bottom.
  static const ORIENTATION_PORTRAIT_DOWN = 413;
  // Landscape, top on right, bottom on left.
  static const ORIENTATION_LANDSCAPE_LEFT = 414;

  static const NO_ERROR = 0;
  // PIP error, Android version is too low.
  static const ERROR_PIP_LOWER_VERSION = -101;
  // PIP error, picture-in-picture permission is turned off.
  static const ERROR_PIP_DENIED_PERMISSION = -102;
  // PIP error, current interface has been destroyed.
  static const ERROR_PIP_ACTIVITY_DESTROYED = -103;
  // PIP error, device or system version not supported (PIP is only supported on iPad iOS9+ and android 24).
  static const ERROR_IOS_PIP_DEVICE_NOT_SUPPORT = -104;
  // PIP error, player does not support (only support iOS).
  static const ERROR_IOS_PIP_PLAYER_NOT_SUPPORT = -105;
  // PIP error, video does not support (only support iOS).
  static const ERROR_IOS_PIP_VIDEO_NOT_SUPPORT = -106;
  // PIP error, PIP controller is not available (only support iOS).
  static const ERROR_IOS_PIP_IS_NOT_POSSIBLE = -107;
  // PIP error, PIP controller error (only support iOS).
  static const ERROR_IOS_PIP_FROM_SYSTEM = -108;
  // PIP error, player object does not exist.
  static const ERROR_IOS_PIP_PLAYER_NOT_EXIST = -109;
  // PIP error, PIP function is already running.
  static const ERROR_IOS_PIP_IS_RUNNING = -110;
  // PIP error, PIP function is not started (only support iOS).
  static const ERROR_IOS_PIP_NOT_RUNNING = -111;
  // PIP start time out.
  static const ERROR_IOS_PIP_START_TIME_OUT = -112;
  // Insufficient permissions, currently only appears in Picture-in-Picture live streaming.
  static const ERROR_PIP_AUTH_DENIED = -201;
  // PIP error, currently unable to enter PIP mode, such as being in full screen mode.
  static const ERROR_PIP_CAN_NOT_ENTER = -120;

  /// Video download related events.
  // Video pre-download completed.
  static const EVENT_PREDOWNLOAD_ON_COMPLETE = 200;
  // Error occurred during video pre-download.
  static const EVENT_PREDOWNLOAD_ON_ERROR = 201;
  // fileId preload is start, callback url, taskId and other video info.
  static const EVENT_PREDOWNLOAD_ON_START = 202;

  // Video download started.
  static const EVENT_DOWNLOAD_START = 301;
  // Video download progress.
  static const EVENT_DOWNLOAD_PROGRESS = 302;
  // Video download stopped.
  static const EVENT_DOWNLOAD_STOP = 303;
  // Video download completed.
  static const EVENT_DOWNLOAD_FINISH = 304;
  // Error occurred during video download.
  static const EVENT_DOWNLOAD_ERROR = 305;

  // SDK event: onLicenceLoaded.
  static const EVENT_ON_LICENCE_LOADED = 503;

  static const EVENT_RESULT = "result";
  static const EVENT_REASON = "reason";

  /// Select track complete.
  static const VOD_PLAY_EVT_SELECT_TRACK_COMPLETE = 2020;

  /// Switched media track index.
  static const EVT_KEY_SELECT_TRACK_INDEX = "EVT_KEY_SELECT_TRACK_INDEX";

  /// Return error code for switching media tracks.
  static const EVT_KEY_SELECT_TRACK_ERROR_CODE =
      "EVT_KEY_SELECT_TRACK_ERROR_CODE";
  // Callback SubtitleData event id.
  static const EVENT_SUBTITLE_DATA = 601;
  // Callback SubtitleData event extra key.
  static const EXTRA_SUBTITLE_DATA = "subtitleData";
  static const EXTRA_SUBTITLE_START_POSITION_MS = "startPositionMs";
  static const EXTRA_SUBTITLE_DURATION_MS = "durationMs";
  static const EXTRA_SUBTITLE_TRACK_INDEX = "trackIndex";

  /// Alternative playback URL for HEVC downgrade playback, supported by the Advanced Player 12.0.
  static const VOD_KEY_BACKUP_URL = "VOD_KEY_BACKUP_URL";

  /// Main playback video codec type when HEVC downgrade playback.
  static const VOD_KEY_VIDEO_CODEC_TYPE = "VOD_KEY_VIDEO_CODEC_TYPE";

  /// MediaType of alternative playback URL resource during HEVC downgrade playback, supported by the Advanced Player 12.0.
  static const VOD_KEY_BACKUP_URL_MEDIA_TYPE = "VOD_KEY_BACKUP_URL_MEDIA_TYPE";

  /// HEVC format, supported by the player advanced version 12.0.
  static const VOD_PLAY_MIMETYPE_H265 = "video/hevc";

  /// MP4 encryption playback: No encryption. Supported since version 12.2.
  static const MP4_ENCRYPTION_LEVEL_NONE = 0;

  /// MP4 encrypted playback: MP4 local encrypted playback. Supported since version 12.2.
  static const MP4_ENCRYPTION_LEVEL_L2 = 2;
}

abstract class TXVodNetEvent {
  static const NET_STATUS_CPU_USAGE = "CPU_USAGE"; // CPU usage rate.
  static const NET_STATUS_VIDEO_WIDTH = "VIDEO_WIDTH"; // Width of resolution.
  static const NET_STATUS_VIDEO_HEIGHT =
      "VIDEO_HEIGHT"; // Height of resolution.
  // Current video frame rate, i.e. the number of frames produced by the video encoder.
  static const NET_STATUS_VIDEO_FPS = "VIDEO_FPS";
  // Current video GOP, i.e. the time interval between two key frames (I-frames), in seconds.
  static const NET_STATUS_VIDEO_GOP = "VIDEO_GOP";
  // Pushing: video data sending bit rate; pulling: video data receiving bit rate. Unit: kbps.
  static const NET_STATUS_VIDEO_BITRATE = "VIDEO_BITRATE";
  // Pushing: audio data sending bit rate; pulling: audio data receiving bit rate. Unit: kbps.
  static const NET_STATUS_AUDIO_BITRATE = "AUDIO_BITRATE";
  // Pushing: total bit rate of audio and video data sent; pulling: total bit rate of audio and video data received. Unit: kbps.
  static const NET_STATUS_NET_SPEED = "NET_SPEED";
  // Pushing: number of unsent audio frames in the sender buffer;
  // pulling: total duration of audio frames received but not played in the receiver.
  static const NET_STATUS_AUDIO_CACHE = "AUDIO_CACHE";
  // Pushing: number of unsent video frames in the sender buffer;
  // pulling: total duration of video frames received but not rendered in the receiver.
  static const NET_STATUS_VIDEO_CACHE = "VIDEO_CACHE";
  // Pushing: number of audio frames dropped by the sender (not used: no audio frame dropping logic in upstream);
  // pulling: number of audio frames dropped by the receiver (not used: audio acceleration in the player, no frame dropping).
  static const NET_STATUS_AUDIO_DROP = "AUDIO_DROP";
  // Pushing: number of video frames dropped by the sender (used: real-time pushing has frame dropping logic);
  // pulling: number of video frames dropped by the receiver (not used: video acceleration in the player, no frame dropping).
  static const NET_STATUS_VIDEO_DROP = "VIDEO_DROP";
  // Pulling only: number of video frames received but not rendered, including the JitterBuffer and decoder buffer.
  static const NET_STATUS_V_SUM_CACHE_SIZE = "V_SUM_CACHE_SIZE";
  // Pulling only: number of video frames cached in the decoder buffer.
  static const NET_STATUS_V_DEC_CACHE_SIZE = "V_DEC_CACHE_SIZE";
  // Pulling only: the difference between the timestamp of the current video rendering frame and the timestamp
  // of the current audio playing frame, indicating the synchronization status of audio and video at that time.
  static const NET_STATUS_AV_PLAY_INTERVAL = "AV_PLAY_INTERVAL";
  // Pulling only: the difference between the timestamp of the latest received video frame and the timestamp of the latest received
  // audio frame in the JitterBuffer, indicating the synchronization status of packet reception at that time.
  static const NET_STATUS_AV_RECV_INTERVAL = "AV_RECV_INTERVAL";
  // Pulling only: the threshold of audio cache duration in seconds. When the cached audio duration exceeds this threshold,
  // the JitterBuffer will accelerate the playback to ensure the playback delay.
  static const NET_STATUS_AUDIO_CACHE_THRESHOLD = "AUDIO_CACHE_THRESHOLD";
  // Pulling only: audio stuttering duration, in milliseconds.
  static const NET_STATUS_AUDIO_BLOCK_TIME = "AUDIO_BLOCK_TIME";
  // Current audio information of the stream, including sampling rate and number of channels.
  static const NET_STATUS_AUDIO_INFO = "AUDIO_PLAY_INFO";
  // Network jitter, the larger the value, the greater the jitter and the more unstable the network.
  static const NET_STATUS_NET_JITTER = "NET_JITTER";
  // IP address of the connected server.
  static const NET_STATUS_SERVER_IP = "SERVER_IP";
  // Current decoder output frame rate (VOD).
  static const NET_STATUS_VIDEO_DPS = "VIDEO_DPS";
  // Network quality: 0: undefined, 1: best, 2: good, 3: normal, 4: poor, 5: very poor, 6: unavailable.
  static const NET_STATUS_QUALITY_LEVEL = "NET_QUALITY_LEVEL";
}

enum TXDrmProvisionEnv {
  // Using the Google COM domain certificate provider.
  DRM_PROVISION_ENV_COM,
  // Using the Google CN domain certificate provider.
  DRM_PROVISION_ENV_CN
}

enum TXPlayerState {
  // Playback paused.
  paused,
  // Playback failed.
  failed,
  // Buffering.
  buffering,
  // Playing.
  playing,
  // Playback stopped.
  stopped,
  // Control released.
  disposed
}

enum TXPlayerEvent {
  // Network interrupted, reconnecting automatically.
  reconnect,
  // Network interrupted, reconnection failed.
  disconnect,
  // RTMP-DNS resolution failed.
  dnsFail,
  // RTMP server connection failed.
  severConnFail,
  // RTMP server handshake failed.
  shakeFail,
  // Progress.
  progress
}

class TXLogLevel {
  // Output all levels of logs.
  static const LOG_LEVEL_VERBOSE = 0;
  // Output DEBUG, INFO, WARNING, ERROR, and FATAL level logs.
  static const LOG_LEVEL_DEBUG = 1;
  // Output INFO, WARNING, ERROR, and FATAL level logs.
  static const LOG_LEVEL_INFO = 2;
  // Output WARNING, ERROR, and FATAL level logs.
  static const LOG_LEVEL_WARN = 3;
  // Output ERROR and FATAL level logs.
  static const LOG_LEVEL_ERROR = 4;
  // Only output FATAL level logs.
  static const LOG_LEVEL_FATAL = 5;
  // Do not output any SDK logs.
  static const LOG_LEVEL_NULL = 6;
}

class DownloadQuality {
  @deprecated
  static const QUALITY_OD = 0;
  @deprecated
  static const QUALITY_FLU = 1;
  @deprecated
  static const QUALITY_SD = 2;
  @deprecated
  static const QUALITY_HD = 3;
  @deprecated
  static const QUALITY_FHD = 4;

  static const int QUALITY_2K = 5;
  static const int QUALITY_4K = 6;
  static const int QUALITY_UNK = 1000;
  static const int QUALITY_240P = 240;
  static const int QUALITY_360P = 360;
  static const int QUALITY_480P = 480;
  static const int QUALITY_540P = 540;
  static const int QUALITY_720P = 720;
  static const int QUALITY_1080P = 1080;
}

class TXPlayInfoParams {
  final int? appId; // Tencent Cloud video appId, required
  final String? fileId; // Tencent Cloud video fileId, required
  final String?
      psign; // Tencent cloud video encryption signature, required for encrypted video
  // video url, only applicable for preloading. When using it, you only need to fill in either the url or fileId.
  // The priority of the url is higher than that of the fileId.
  final String? url;
  // Custom httpHeader.
  final Map<String, String>? httpHeader;

  const TXPlayInfoParams.useFileId(
      {required this.appId,
      required this.fileId,
      this.psign = "",
      this.httpHeader})
      : this.url = "";
  const TXPlayInfoParams.useUrl({required this.url, this.httpHeader})
      : this.appId = 0,
        this.fileId = "",
        this.psign = "";

  const TXPlayInfoParams(
      {required this.appId,
      required this.fileId,
      this.psign = "",
      this.url = "",
      this.httpHeader});

  /// Serialize to a Map for MethodChannel transport.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appId': appId,
      'fileId': fileId,
      'psign': psign,
      'url': url,
      'httpHeader': httpHeader,
    };
  }

  /// Kept for backward compatibility; delegates to toMap.
  Map<String, dynamic> toJson() => toMap();
}

/// File ID storage.
class TXVodDownloadDataSource {
  /// App ID corresponding to the downloaded file, required for file ID download.
  int? appId;

  /// Downloaded file ID, required for fileId download.
  String? fileId;

  /// Encryption signature, required for encrypted video.
  String? pSign;

  /// Quality ID, required for file ID download, converted through [CommonUtils.getDownloadQualityBySize].
  int? quality;

  /// Encryption token.
  String? token;

  /// Account name, used to set the account name for URL download.
  /// It is not recommended to set a string that is too long,
  /// otherwise it may lead to unforeseen problems.
  String? userName;

  /// Serialize to a Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appId': appId,
      'fileId': fileId,
      'pSign': pSign,
      'quality': quality,
      'token': token,
      'userName': userName,
    };
  }

  /// Construct from a Map.
  static TXVodDownloadDataSource fromMap(Map map) {
    final ds = TXVodDownloadDataSource();
    ds.appId = map['appId'] as int?;
    ds.fileId = map['fileId'] as String?;
    ds.pSign = map['pSign'] as String?;
    ds.quality = map['quality'] as int?;
    ds.token = map['token'] as String?;
    ds.userName = map['userName'] as String?;
    return ds;
  }

  /// Kept for backward compatibility; delegates to toMap.
  Map<String, dynamic> toJson() => toMap();
}

/// Video download information.
class TXVodDownloadMediaInfo {
  /// Cache address.
  String? playPath;

  /// Download progress.
  double? progress;

  /// Download status.
  int? downloadState;

  /// Account name, used to set the account name for URL download.
  /// It is not recommended to set a string that is too long,
  /// otherwise it may lead to unforeseen problems.
  String? userName;

  /// Total duration.
  int? duration;

  /// Downloaded playable duration.
  int? playableDuration;

  /// Total file size, in bytes.
  int? size;

  /// Downloaded size, in bytes.
  int? downloadSize;

  /// Video URL to be downloaded, required for URL download.
  String? url;

  /// Download speed, in KBytes/second.
  int? speed;

  /// Whether the resource is damaged, such as being deleted.
  bool? isResourceBroken;

  /// File ID storage.
  TXVodDownloadDataSource? dataSource;

  /// Serialize to a Map for MethodChannel transport.
  ///
  /// To align with the native `TXVodDownloadMediaMsg` fields, the `dataSource`
  /// entries are flattened to the root level; `userName` falls back to
  /// "default" when null.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (null != dataSource) {
      map['appId'] = dataSource!.appId;
      map['fileId'] = dataSource!.fileId;
      map['pSign'] = dataSource!.pSign;
      map['quality'] = dataSource!.quality;
      map['token'] = dataSource!.token;
      // Native side requires dataSource.userName to be non-null.
      map['userName'] = dataSource!.userName ?? 'default';
    }
    map['url'] = url;
    map['downloadState'] = downloadState;
    map['progress'] = progress;
    map['playPath'] = playPath;
    // Top-level userName falls back to "default" when null (aligned with native).
    map['userName'] = userName ?? 'default';
    map['duration'] = duration;
    map['playableDuration'] = playableDuration;
    map['size'] = size;
    map['downloadSize'] = downloadSize;
    map['speed'] = speed;
    map['isResourceBroken'] = isResourceBroken;
    return map;
  }

  /// Construct from the Map returned by MethodChannel.
  ///
  /// The Map structure returned by the native side is symmetric to `toMap()`:
  /// the `appId/fileId/pSign/quality/token` fields are extracted into the
  /// inner `dataSource`.
  static TXVodDownloadMediaInfo fromMap(Map map) {
    final info = TXVodDownloadMediaInfo();
    // When fileId-related fields are present, restore dataSource.
    if (map['appId'] != null || map['fileId'] != null) {
      final ds = TXVodDownloadDataSource();
      ds.appId = map['appId'] as int?;
      ds.fileId = map['fileId'] as String?;
      ds.pSign = map['pSign'] as String?;
      ds.quality = map['quality'] as int?;
      ds.token = map['token'] as String?;
      ds.userName = map['userName'] as String?;
      info.dataSource = ds;
    }
    info.url = map['url'] as String?;
    info.downloadState = map['downloadState'] as int?;
    final progress = map['progress'];
    info.progress = progress is num ? progress.toDouble() : null;
    info.playPath = map['playPath'] as String?;
    info.userName = map['userName'] as String?;
    info.duration = map['duration'] as int?;
    info.playableDuration = map['playableDuration'] as int?;
    info.size = map['size'] as int?;
    info.downloadSize = map['downloadSize'] as int?;
    info.speed = map['speed'] as int?;
    info.isResourceBroken = map['isResourceBroken'] as bool?;
    return info;
  }

  /// Kept for backward compatibility; delegates to toMap.
  Map<String, dynamic> toJson() => toMap();
}

/// Track details.
class TXTrackInfo {
  /// Unknown.
  static const TX_VOD_MEDIA_TRACK_TYPE_UNKNOW = 0;

  /// Video track.
  static const TX_VOD_MEDIA_TRACK_TYPE_VIDEO = 1;

  /// Audio track.
  static const TX_VOD_MEDIA_TRACK_TYPE_AUDIO = 2;

  /// Subtitle track.
  static const TX_VOD_MEDIA_TRACK_TYPE_SUBTITLE = 3;

  /// Track type.
  int trackType;

  /// Track index.
  int trackIndex;

  /// Track name.
  String name;

  /// Whether the current track is selected.
  bool isSelected = false;

  /// If true, only one track of this type can be selected at each time. If false, multiple tracks of this type can be selected at the same time.
  bool isExclusive = true;

  /// Whether the current track is the internal original track.
  bool isInternal = true;
  TXTrackInfo(this.name, this.trackIndex, this.trackType);

  /// Construct from the Map returned by MethodChannel.
  static TXTrackInfo fromMap(Map map) {
    final info = TXTrackInfo(
      (map['name'] as String?) ?? '',
      (map['trackIndex'] as int?) ?? -1,
      (map['trackType'] as int?) ?? TX_VOD_MEDIA_TRACK_TYPE_UNKNOW,
    );
    info.isSelected = (map['isSelected'] as bool?) ?? false;
    info.isExclusive = (map['isExclusive'] as bool?) ?? true;
    info.isInternal = (map['isInternal'] as bool?) ?? true;
    return info;
  }
}

class TXVodSubtitleData {
  /// Subtitle content.
  String? subtitleData;

  /// Subtitle duration, in milliseconds.
  int? startPositionMs;

  /// Subtitle start time, which is the position of the video, in milliseconds.
  int? durationMs;

  /// Track Index of the current subtitle track.
  int? trackIndex;

  TXVodSubtitleData(this.subtitleData, this.startPositionMs, this.durationMs,
      this.trackIndex);
}

class TXSubtitleRenderModel {
  /// fontSize.
  double? fontSize;

  /// Font color, ARGB format. If not set, the default is white opaque (0xFFFFFFFF).
  int? fontColor;

  /// Whether it is bold, the default is normal font.
  bool? isBondFontStyle;

  /// Stroke width. If not set, the default stroke width will be used internally.
  double? outlineWidth;

  /// Stroke color, ARGB format. If not set, the default is black opaque (0xFF000000).
  int? outlineColor;

  /// canvasWidth not support on Flutter platform
  int? canvasWidth;

  /// canvasHeight not support on Flutter platform
  int? canvasHeight;

  /// familyName not support on Flutter platform
  String? familyName;

  /// fontScale not support on Flutter platform
  double? fontScale;

  /// lineSpace not support on Flutter platform
  double? lineSpace;

  /// startMargin not support on Flutter platform
  double? startMargin;

  /// endMargin not support on Flutter platform
  double? endMargin;

  /// verticalMargin not support on Flutter platform
  double? verticalMargin;

  /// Serialize to a Map for MethodChannel transport.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'canvasWidth': canvasWidth,
      'canvasHeight': canvasHeight,
      'familyName': familyName,
      'fontSize': fontSize,
      'fontScale': fontScale,
      'fontColor': fontColor,
      'isBondFontStyle': isBondFontStyle,
      'outlineWidth': outlineWidth,
      'outlineColor': outlineColor,
      'lineSpace': lineSpace,
      'startMargin': startMargin,
      'endMargin': endMargin,
      'verticalMargin': verticalMargin,
    };
  }
}

class FSteamInfo {
  int? width;
  int? height;
  int? bitrate;
  int? frameRate;
  String? url;

  static FSteamInfo createFromMsg(Object obj) {
    FSteamInfo info = FSteamInfo();
    if (obj is Map) {
      info.width = obj["width"];
      info.height = obj["height"];
      info.bitrate = obj["bitrate"];
      info.frameRate = obj["framerate"];
      info.url = obj["url"];
    }
    return info;
  }
}

/// Player type.
abstract class TXPlayerType {
  static const VOD_PLAY = 0;
}

/// Render view type for Android.
/// If it is DRM playback, you may need to switch to SurfaceView mode. The default mode is TextureView.
enum FTXAndroidRenderViewType { TEXTURE_VIEW, SURFACE_VIEW, DRM_SURFACE_VIEW }

///
/// Tiling Mode.
///
enum FTXPlayerRenderMode {
  /// Display the video content fully according to the video aspect ratio.
  ADJUST_RESOLUTION,

  /// Fill the container completely according to the video aspect ratio, and crop the overflowing parts.
  FULL_FILL_CONTAINER
}

// Video pre-download event callback listener.
// onStartListener, just for fileId preload.
typedef FTXPredownlodOnStartListener = void Function(
    int taskId, String fileId, String url, Map<dynamic, dynamic> params);
typedef FTXPredownlodOnCompleteListener = void Function(int taskId, String url);
typedef FTXPredownlodOnErrorListener = void Function(
    int taskId, String url, int code, String msg);
// Video download time callback listener.
typedef FTXDownlodOnStateChangeListener = void Function(
    int event, TXVodDownloadMediaInfo info);
typedef FTXDownlodOnErrorListener = void Function(
    int errorCode, String errorMsg, TXVodDownloadMediaInfo info);

typedef FTXLicenceLoadedListener = void Function(int result, String reason);
