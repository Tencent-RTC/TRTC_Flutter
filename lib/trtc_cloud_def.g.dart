// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trtc_cloud_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TRTCVolumeInfo _$TRTCVolumeInfoFromJson(Map<String, dynamic> json) =>
    TRTCVolumeInfo(
      userId: json['userId'] as String? ?? "",
      volume: (json['volume'] as num?)?.toInt() ?? -1,
      vad: (json['vad'] as num?)?.toInt() ?? -1,
      pitch: (json['pitch'] as num?)?.toDouble() ?? -1,
      spectrumData: (json['spectrumData'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$TRTCVolumeInfoToJson(TRTCVolumeInfo instance) {
  final val = <String, dynamic>{
    'userId': instance.userId,
    'volume': instance.volume,
    'vad': instance.vad,
    'pitch': instance.pitch,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('spectrumData', instance.spectrumData);
  return val;
}

TRTCQualityInfo _$TRTCQualityInfoFromJson(Map<String, dynamic> json) =>
    TRTCQualityInfo(
      userId: json['userId'] as String,
      quality: $enumDecode(_$TRTCQualityEnumMap, json['quality']),
    );

Map<String, dynamic> _$TRTCQualityInfoToJson(TRTCQualityInfo instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'quality': _$TRTCQualityEnumMap[instance.quality]!,
    };

const _$TRTCQualityEnumMap = {
  TRTCQuality.unknown: 0,
  TRTCQuality.excellent: 1,
  TRTCQuality.good: 2,
  TRTCQuality.poor: 3,
  TRTCQuality.bad: 4,
  TRTCQuality.vBad: 5,
  TRTCQuality.down: 6,
};

TRTCLocalStatistics _$TRTCLocalStatisticsFromJson(Map<String, dynamic> json) =>
    TRTCLocalStatistics(
      width: (json['width'] as num?)?.toInt() ?? -1,
      height: (json['height'] as num?)?.toInt() ?? -1,
      frameRate: (json['frameRate'] as num?)?.toInt() ?? -1,
      videoBitrate: (json['videoBitrate'] as num?)?.toInt() ?? -1,
      audioSampleRate: (json['audioSampleRate'] as num?)?.toInt() ?? -1,
      audioBitrate: (json['audioBitrate'] as num?)?.toInt() ?? -1,
      streamType: $enumDecodeNullable(
              _$TRTCVideoStreamTypeEnumMap, json['streamType']) ??
          TRTCVideoStreamType.big,
      audioCaptureState: (json['audioCaptureState'] as num?)?.toInt() ?? -1,
    );

Map<String, dynamic> _$TRTCLocalStatisticsToJson(
        TRTCLocalStatistics instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'frameRate': instance.frameRate,
      'videoBitrate': instance.videoBitrate,
      'audioSampleRate': instance.audioSampleRate,
      'audioBitrate': instance.audioBitrate,
      'streamType': _$TRTCVideoStreamTypeEnumMap[instance.streamType]!,
      'audioCaptureState': instance.audioCaptureState,
    };

const _$TRTCVideoStreamTypeEnumMap = {
  TRTCVideoStreamType.big: 0,
  TRTCVideoStreamType.small: 1,
  TRTCVideoStreamType.sub: 2,
};

TRTCRemoteStatistics _$TRTCRemoteStatisticsFromJson(
        Map<String, dynamic> json) =>
    TRTCRemoteStatistics(
      userId: json['userId'] as String? ?? "",
      audioPacketLoss: (json['audioPacketLoss'] as num?)?.toInt() ?? -1,
      videoPacketLoss: (json['videoPacketLoss'] as num?)?.toInt() ?? -1,
      width: (json['width'] as num?)?.toInt() ?? -1,
      height: (json['height'] as num?)?.toInt() ?? -1,
      frameRate: (json['frameRate'] as num?)?.toInt() ?? -1,
      videoBitrate: (json['videoBitrate'] as num?)?.toInt() ?? -1,
      audioSampleRate: (json['audioSampleRate'] as num?)?.toInt() ?? -1,
      audioBitrate: (json['audioBitrate'] as num?)?.toInt() ?? -1,
      jitterBufferDelay: (json['jitterBufferDelay'] as num?)?.toInt() ?? -1,
      point2PointDelay: (json['point2PointDelay'] as num?)?.toInt() ?? -1,
      audioTotalBlockTime: (json['audioTotalBlockTime'] as num?)?.toInt() ?? -1,
      audioBlockRate: (json['audioBlockRate'] as num?)?.toInt() ?? -1,
      videoTotalBlockTime: (json['videoTotalBlockTime'] as num?)?.toInt() ?? -1,
      videoBlockRate: (json['videoBlockRate'] as num?)?.toInt() ?? -1,
      finalLoss: (json['finalLoss'] as num?)?.toInt() ?? -1,
      remoteNetworkUplinkLoss:
          (json['remoteNetworkUplinkLoss'] as num?)?.toInt() ?? -1,
      remoteNetworkRTT: (json['remoteNetworkRTT'] as num?)?.toInt() ?? -1,
      streamType: $enumDecodeNullable(
              _$TRTCVideoStreamTypeEnumMap, json['streamType']) ??
          TRTCVideoStreamType.big,
    );

Map<String, dynamic> _$TRTCRemoteStatisticsToJson(
        TRTCRemoteStatistics instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'audioPacketLoss': instance.audioPacketLoss,
      'videoPacketLoss': instance.videoPacketLoss,
      'width': instance.width,
      'height': instance.height,
      'frameRate': instance.frameRate,
      'videoBitrate': instance.videoBitrate,
      'audioSampleRate': instance.audioSampleRate,
      'audioBitrate': instance.audioBitrate,
      'jitterBufferDelay': instance.jitterBufferDelay,
      'point2PointDelay': instance.point2PointDelay,
      'audioTotalBlockTime': instance.audioTotalBlockTime,
      'audioBlockRate': instance.audioBlockRate,
      'videoTotalBlockTime': instance.videoTotalBlockTime,
      'videoBlockRate': instance.videoBlockRate,
      'finalLoss': instance.finalLoss,
      'remoteNetworkUplinkLoss': instance.remoteNetworkUplinkLoss,
      'remoteNetworkRTT': instance.remoteNetworkRTT,
      'streamType': _$TRTCVideoStreamTypeEnumMap[instance.streamType]!,
    };

TRTCStatistics _$TRTCStatisticsFromJson(Map<String, dynamic> json) =>
    TRTCStatistics(
      appCpu: (json['appCpu'] as num?)?.toInt() ?? -1,
      systemCpu: (json['systemCpu'] as num?)?.toInt() ?? -1,
      upLoss: (json['upLoss'] as num?)?.toInt() ?? -1,
      downLoss: (json['downLoss'] as num?)?.toInt() ?? -1,
      rtt: (json['rtt'] as num?)?.toInt() ?? -1,
      gatewayRtt: (json['gatewayRtt'] as num?)?.toInt() ?? -1,
      sentBytes: (json['sentBytes'] as num?)?.toInt() ?? -1,
      receivedBytes: (json['receivedBytes'] as num?)?.toInt() ?? -1,
      localStatisticsArray: (json['localStatisticsArray'] as List<dynamic>?)
          ?.map((e) => TRTCLocalStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
      remoteStatisticsArray: (json['remoteStatisticsArray'] as List<dynamic>?)
          ?.map((e) => TRTCRemoteStatistics.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TRTCStatisticsToJson(TRTCStatistics instance) {
  final val = <String, dynamic>{
    'appCpu': instance.appCpu,
    'systemCpu': instance.systemCpu,
    'upLoss': instance.upLoss,
    'downLoss': instance.downLoss,
    'rtt': instance.rtt,
    'gatewayRtt': instance.gatewayRtt,
    'sentBytes': instance.sentBytes,
    'receivedBytes': instance.receivedBytes,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('localStatisticsArray',
      instance.localStatisticsArray?.map((e) => e.toJson()).toList());
  writeNotNull('remoteStatisticsArray',
      instance.remoteStatisticsArray?.map((e) => e.toJson()).toList());
  return val;
}

TRTCSpeedTestResult _$TRTCSpeedTestResultFromJson(Map<String, dynamic> json) =>
    TRTCSpeedTestResult(
      success: json['success'] as bool? ?? false,
      errMsg: json['errMsg'] as String? ?? "",
      ip: json['ip'] as String? ?? "",
      quality: $enumDecodeNullable(_$TRTCQualityEnumMap, json['quality']) ??
          TRTCQuality.unknown,
      upLostRate: (json['upLostRate'] as num?)?.toDouble() ?? 0.0,
      downLostRate: (json['downLostRate'] as num?)?.toDouble() ?? 0.0,
      rtt: (json['rtt'] as num?)?.toInt() ?? 0,
      availableUpBandwidth:
          (json['availableUpBandwidth'] as num?)?.toInt() ?? 0,
      availableDownBandwidth:
          (json['availableDownBandwidth'] as num?)?.toInt() ?? 0,
      upJitter: (json['upJitter'] as num?)?.toInt() ?? 0,
      downJitter: (json['downJitter'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TRTCSpeedTestResultToJson(
        TRTCSpeedTestResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'errMsg': instance.errMsg,
      'ip': instance.ip,
      'quality': _$TRTCQualityEnumMap[instance.quality]!,
      'upLostRate': instance.upLostRate,
      'downLostRate': instance.downLostRate,
      'rtt': instance.rtt,
      'availableUpBandwidth': instance.availableUpBandwidth,
      'availableDownBandwidth': instance.availableDownBandwidth,
      'upJitter': instance.upJitter,
      'downJitter': instance.downJitter,
    };

TRTCTexture _$TRTCTextureFromJson(Map<String, dynamic> json) => TRTCTexture(
      glTextureId: (json['glTextureId'] as num?)?.toInt() ?? 0,
      glContext: (json['glContext'] as num?)?.toInt() ?? 0,
      d3d11TextureId: (json['d3d11TextureId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$TRTCTextureToJson(TRTCTexture instance) =>
    <String, dynamic>{
      'glTextureId': instance.glTextureId,
      'glContext': instance.glContext,
      'd3d11TextureId': instance.d3d11TextureId,
    };

TRTCVideoFrame _$TRTCVideoFrameFromJson(Map<String, dynamic> json) =>
    TRTCVideoFrame(
      videoFormat: $enumDecodeNullable(
              _$TRTCVideoPixelFormatEnumMap, json['videoFormat']) ??
          TRTCVideoPixelFormat.unknown,
      bufferType: $enumDecodeNullable(
              _$TRTCVideoBufferTypeEnumMap, json['bufferType']) ??
          TRTCVideoBufferType.unknown,
      texture: json['texture'] == null
          ? null
          : TRTCTexture.fromJson(json['texture'] as Map<String, dynamic>),
      length: (json['length'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 640,
      height: (json['height'] as num?)?.toInt() ?? 360,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      rotation:
          $enumDecodeNullable(_$TRTCVideoRotationEnumMap, json['rotation']) ??
              TRTCVideoRotation.rotation0,
      data: _$JsonConverterFromJson<String, Uint8List>(
          json['data'], const Uint8ListConverter().fromJson),
    );

Map<String, dynamic> _$TRTCVideoFrameToJson(TRTCVideoFrame instance) {
  final val = <String, dynamic>{
    'videoFormat': _$TRTCVideoPixelFormatEnumMap[instance.videoFormat]!,
    'bufferType': _$TRTCVideoBufferTypeEnumMap[instance.bufferType]!,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('texture', instance.texture?.toJson());
  val['data'] = const Uint8ListConverter().toJson(instance.data);
  val['length'] = instance.length;
  val['width'] = instance.width;
  val['height'] = instance.height;
  val['timestamp'] = instance.timestamp;
  val['rotation'] = _$TRTCVideoRotationEnumMap[instance.rotation]!;
  return val;
}

const _$TRTCVideoPixelFormatEnumMap = {
  TRTCVideoPixelFormat.unknown: 0,
  TRTCVideoPixelFormat.i420: 1,
  TRTCVideoPixelFormat.texture2D: 2,
  TRTCVideoPixelFormat.bgra32: 3,
  TRTCVideoPixelFormat.nv21: 4,
  TRTCVideoPixelFormat.rgba32: 5,
};

const _$TRTCVideoBufferTypeEnumMap = {
  TRTCVideoBufferType.unknown: 0,
  TRTCVideoBufferType.buffer: 1,
  TRTCVideoBufferType.texture: 3,
  TRTCVideoBufferType.textureD3D11: 4,
};

const _$TRTCVideoRotationEnumMap = {
  TRTCVideoRotation.rotation0: 0,
  TRTCVideoRotation.rotation90: 1,
  TRTCVideoRotation.rotation180: 2,
  TRTCVideoRotation.rotation270: 3,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

TRTCAudioFrame _$TRTCAudioFrameFromJson(Map<String, dynamic> json) =>
    TRTCAudioFrame(
      audioFormat: $enumDecodeNullable(
              _$TRTCAudioFrameFormatEnumMap, json['audioFormat']) ??
          TRTCAudioFrameFormat.none,
      length: (json['length'] as num?)?.toInt() ?? 0,
      sampleRate: (json['sampleRate'] as num?)?.toInt() ?? 0,
      channel: (json['channel'] as num?)?.toInt() ?? 0,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      extraDataLength: (json['extraDataLength'] as num?)?.toInt() ?? 0,
      data: _$JsonConverterFromJson<String, Uint8List>(
          json['data'], const Uint8ListConverter().fromJson),
      extraData: _$JsonConverterFromJson<String, Uint8List>(
          json['extraData'], const Uint8ListConverter().fromJson),
    );

Map<String, dynamic> _$TRTCAudioFrameToJson(TRTCAudioFrame instance) =>
    <String, dynamic>{
      'audioFormat': _$TRTCAudioFrameFormatEnumMap[instance.audioFormat]!,
      'data': const Uint8ListConverter().toJson(instance.data),
      'length': instance.length,
      'sampleRate': instance.sampleRate,
      'channel': instance.channel,
      'timestamp': instance.timestamp,
      'extraData': const Uint8ListConverter().toJson(instance.extraData),
      'extraDataLength': instance.extraDataLength,
    };

const _$TRTCAudioFrameFormatEnumMap = {
  TRTCAudioFrameFormat.none: 0,
  TRTCAudioFrameFormat.pcm: 1,
};

const _$TRTCAppSceneEnumMap = {
  TRTCAppScene.videoCall: 0,
  TRTCAppScene.live: 1,
  TRTCAppScene.audioCall: 2,
  TRTCAppScene.voiceChatRoom: 3,
};

const _$TRTCRoleTypeEnumMap = {
  TRTCRoleType.anchor: 20,
  TRTCRoleType.audience: 21,
};

const _$TRTCVideoResolutionEnumMap = {
  TRTCVideoResolution.res_120_120: 1,
  TRTCVideoResolution.res_160_160: 3,
  TRTCVideoResolution.res_270_270: 5,
  TRTCVideoResolution.res_480_480: 7,
  TRTCVideoResolution.res_160_120: 50,
  TRTCVideoResolution.res_240_180: 52,
  TRTCVideoResolution.res_280_210: 54,
  TRTCVideoResolution.res_320_240: 56,
  TRTCVideoResolution.res_400_300: 58,
  TRTCVideoResolution.res_480_360: 60,
  TRTCVideoResolution.res_640_480: 62,
  TRTCVideoResolution.res_960_720: 64,
  TRTCVideoResolution.res_160_90: 100,
  TRTCVideoResolution.res_256_144: 102,
  TRTCVideoResolution.res_320_180: 104,
  TRTCVideoResolution.res_480_270: 106,
  TRTCVideoResolution.res_640_360: 108,
  TRTCVideoResolution.res_960_540: 110,
  TRTCVideoResolution.res_1280_720: 112,
  TRTCVideoResolution.res_1920_1080: 114,
};

const _$TRTCVideoResolutionModeEnumMap = {
  TRTCVideoResolutionMode.landscape: 0,
  TRTCVideoResolutionMode.portrait: 1,
};

const _$TRTCVideoFillModeEnumMap = {
  TRTCVideoFillMode.fill: 0,
  TRTCVideoFillMode.fit: 1,
  TRTCVideoFillMode.scaleFill: 2,
};

const _$TRTCVideoMirrorTypeEnumMap = {
  TRTCVideoMirrorType.auto: 0,
  TRTCVideoMirrorType.enable: 1,
  TRTCVideoMirrorType.disable: 2,
};

const _$TRTCSnapshotSourceTypeEnumMap = {
  TRTCSnapshotSourceType.stream: 0,
  TRTCSnapshotSourceType.view: 1,
  TRTCSnapshotSourceType.capture: 2,
};

const _$TRTCAVStatusTypeEnumMap = {
  TRTCAVStatusType.stopped: 0,
  TRTCAVStatusType.playing: 1,
  TRTCAVStatusType.loading: 2,
};

const _$TRTCAVStatusChangeReasonEnumMap = {
  TRTCAVStatusChangeReason.internal: 0,
  TRTCAVStatusChangeReason.bufferingBegin: 1,
  TRTCAVStatusChangeReason.bufferingEnd: 2,
  TRTCAVStatusChangeReason.localStarted: 3,
  TRTCAVStatusChangeReason.localStopped: 4,
  TRTCAVStatusChangeReason.remoteStarted: 5,
  TRTCAVStatusChangeReason.remoteStopped: 6,
};

const _$TRTCGSensorModeEnumMap = {
  TRTCGSensorMode.disable: 0,
  TRTCGSensorMode.uiAutoLayout: 1,
  TRTCGSensorMode.uiFixLayout: 2,
};

const _$TRTCAudioQualityEnumMap = {
  TRTCAudioQuality.speech: 1,
  TRTCAudioQuality.defaultMode: 2,
  TRTCAudioQuality.music: 3,
};

const _$TRTCVideoQosPreferenceEnumMap = {
  TRTCVideoQosPreference.smooth: 1,
  TRTCVideoQosPreference.clear: 2,
};

const _$TRTCAudioRecordingContentEnumMap = {
  TRTCAudioRecordingContent.all: 0,
  TRTCAudioRecordingContent.local: 1,
  TRTCAudioRecordingContent.remote: 2,
};

const _$TRTCPublishModeEnumMap = {
  TRTCPublishMode.unknown: 0,
  TRTCPublishMode.bigStreamToCdn: 1,
  TRTCPublishMode.subStreamToCdn: 2,
  TRTCPublishMode.mixStreamToCdn: 3,
  TRTCPublishMode.mixStreamToRoom: 4,
};

const _$TRTCBeautyStyleEnumMap = {
  TRTCBeautyStyle.smooth: 0,
  TRTCBeautyStyle.nature: 1,
};

const _$TRTCLocalRecordTypeEnumMap = {
  TRTCLocalRecordType.audio: 0,
  TRTCLocalRecordType.video: 1,
  TRTCLocalRecordType.both: 2,
};

const _$TRTCWaterMarkSrcTypeEnumMap = {
  TRTCWaterMarkSrcType.file: 0,
  TRTCWaterMarkSrcType.bgra32: 1,
  TRTCWaterMarkSrcType.rgba32: 2,
};

const _$TRTCScreenCaptureSourceTypeEnumMap = {
  TRTCScreenCaptureSourceType.unknown: -1,
  TRTCScreenCaptureSourceType.window: 0,
  TRTCScreenCaptureSourceType.screen: 1,
  TRTCScreenCaptureSourceType.custom: 2,
};

const _$TRTCSpeedTestSceneEnumMap = {
  TRTCSpeedTestScene.delayTesting: 1,
  TRTCSpeedTestScene.delayAndBandwidthTesting: 2,
  TRTCSpeedTestScene.onlineChorusTesting: 3,
};

const _$TRTCAudioFrameOperationModeEnumMap = {
  TRTCAudioFrameOperationMode.readWrite: 0,
  TRTCAudioFrameOperationMode.readOnly: 1,
};

const _$TRTCLogLevelEnumMap = {
  TRTCLogLevel.verbose: 0,
  TRTCLogLevel.debug: 1,
  TRTCLogLevel.info: 2,
  TRTCLogLevel.warning: 3,
  TRTCLogLevel.error: 4,
  TRTCLogLevel.fatal: 5,
  TRTCLogLevel.none: 6,
};
