// Copyright (c) 2022 Tencent. All rights reserved.
// ignore_for_file: constant_identifier_names
part of 'super_player.dart';

/// TXVodPlayer config
class FTXVodPlayConfig {
  // Player reconnection count.
  int connectRetryCount = 3;

  // Player reconnection interval.
  int connectRetryInterval = 3;

  // Player connection timeout.
  int timeout = 10;

  // Effective only on iOS platform [PlayerType].
  int playerType = PlayerType.THUMB_PLAYER;

  // Custom HTTP headers.
  Map<String, String> headers = {};

  // Whether to perform accurate seek, default true.
  bool enableAccurateSeek = true;

  // When playing MP4 files, if set to true, the player will automatically rotate according to the rotation angle in the file,
  // which can be obtained in the PLAY_EVT_CHANGE_ROTATION event. Default true.
  bool autoRotate = true;

  // Smooth switching of multiple bitrates for HLS, default false. When set to false,
  // the speed of opening multiple bitrate addresses can be improved; when set to true,
  // the bitrate can be smoothly switched when IDR is aligned.
  bool smoothSwitchBitrate = false;

  // Extension name for caching MP4 files, default mp4.
  String cacheMp4ExtName = "mp4";

  // Set the progress callback interval. If not set, the SDK will callback every 0.5 seconds by default, in milliseconds.
  int progressInterval = 0;

  // Maximum playback buffer size, in MB. This setting will affect playableDuration.
  // The larger the setting, the more data will be cached in advance.
  double maxBufferSize = 10;

  // Maximum preloading buffer size, in MB.
  double maxPreloadSize = 1;

  // Duration of data to be loaded for the first buffering, in milliseconds. The default value is 100ms.
  int firstStartPlayBufferTime = 0;

  // During buffering (secondary buffering caused by insufficient buffered data or dragging buffering caused by seek),
  // how much data needs to be cached at least to end buffering, in milliseconds. The default value is 250ms.
  int nextStartPlayBufferTime = 0;

  // HLS security reinforcement and decryption key.
  String overlayKey = "";

  // HLS security reinforcement and decryption IV.
  String overlayIv = "";

  // Set some special configurations that are not widely known.
  Map<String, Object> extInfoMap = {};

  // Whether to allow loading and rendering post-processing services, default is enabled,
  // and if super-resolution plug-ins exist, they will be loaded by default.
  bool enableRenderProcess = true;

  // Preferred resolution for playback, preferredResolution = width * height.
  int preferredResolution = 720 * 1280;

  /// Media asset type, default auto type, refer to value see[TXVodPlayEvent]
  int mediaType = TXVodPlayEvent.MEDIA_TYPE_AUTO;

  int encryptedMp4Level = TXVodPlayEvent.MP4_ENCRYPTION_LEVEL_NONE;

  String? preferAudioTrack;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json["connectRetryCount"] = connectRetryCount;
    json["connectRetryInterval"] = connectRetryInterval;
    json["timeout"] = timeout;
    json["headers"] = headers;
    json["playerType"] = playerType;
    json["enableAccurateSeek"] = enableAccurateSeek;
    json["autoRotate"] = autoRotate;
    json["smoothSwitchBitrate"] = smoothSwitchBitrate;
    json["cacheMp4ExtName"] = cacheMp4ExtName;
    json["progressInterval"] = progressInterval;
    json["maxBufferSize"] = maxBufferSize;
    json["maxPreloadSize"] = maxPreloadSize;
    json["firstStartPlayBufferTime"] = firstStartPlayBufferTime;
    json["nextStartPlayBufferTime"] = nextStartPlayBufferTime;
    json["overlayKey"] = overlayKey;
    json["overlayIv"] = overlayIv;
    json["extInfoMap"] = extInfoMap;
    json["enableRenderProcess"] = enableRenderProcess;
    json["preferredResolution"] = preferredResolution.toString();
    json["mediaType"] = mediaType.toString();
    json["encryptedMp4Level"] = encryptedMp4Level.toString();
    json["preferAudioTrack"] = preferAudioTrack?.toString();
    return json;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'connectRetryCount': connectRetryCount,
      'connectRetryInterval': connectRetryInterval,
      'timeout': timeout,
      'playerType': playerType,
      'headers': headers,
      'enableAccurateSeek': enableAccurateSeek,
      'autoRotate': autoRotate,
      'smoothSwitchBitrate': smoothSwitchBitrate,
      'cacheMp4ExtName': cacheMp4ExtName,
      'progressInterval': progressInterval,
      'maxBufferSize': maxBufferSize,
      'maxPreloadSize': maxPreloadSize,
      'firstStartPlayBufferTime': firstStartPlayBufferTime,
      'nextStartPlayBufferTime': nextStartPlayBufferTime,
      'overlayKey': overlayKey,
      'overlayIv': overlayIv,
      'extInfoMap': extInfoMap,
      'enableRenderProcess': enableRenderProcess,
      'preferredResolution': preferredResolution,
      'mediaType': mediaType,
      'encryptedMp4Level': encryptedMp4Level,
      'preferAudioTrack': preferAudioTrack,
    };
  }
}

/// Effective only on iOS platform.
class PlayerType {
  // System player.
  static const int AVPLAYER = 0;
  // ThumbPlayer player.
  static const int THUMB_PLAYER = 1;
}
