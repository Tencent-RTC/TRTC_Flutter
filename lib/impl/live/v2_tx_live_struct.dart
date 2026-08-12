// ignore_for_file: avoid_print
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/v2_tx_live_def.dart';

Pointer<Uint8> convertUint8ListToPointer(Uint8List? data) {
  if (data == null || data.isEmpty) return nullptr;

  final ptr = calloc.allocate<Uint8>(data.length);
  ptr.asTypedList(data.length).setAll(0, data);
  return ptr;
}

class V2TXLiveLogConfigStruct extends Struct {
  @Int32()
  external int log_level;

  @Int32()
  external int enable_observer;

  @Int32()
  external int enable_console;

  @Int32()
  external int enable_log_file;

  external Pointer<Int8> log_path;

  static Pointer<V2TXLiveLogConfigStruct> convert(V2TXLiveLogConfig config) {
    String logPath = config.logPath ?? '';
    print(
      "convertlog, logLevel:" +
          config.logLevel.index.toString() +
          ", enableObserver:" +
          config.enableObserver.toString() +
          ", enableConsole:" +
          config.enableConsole.toString() +
          ", enableLogFile:" +
          config.enableLogFile.toString() +
          ", logPath:" +
          logPath,
    );

    final configPointer = calloc<V2TXLiveLogConfigStruct>();
    configPointer.ref
      ..log_level = config.logLevel.index
      ..enable_observer = config.enableObserver ? 1 : 0
      ..enable_console = config.enableConsole ? 1 : 0
      ..enable_log_file = config.enableLogFile ? 1 : 0
      ..log_path = logPath.toNativeUtf8().cast<Int8>();

    return configPointer;
  }

  static freeStruct(Pointer<V2TXLiveLogConfigStruct> pointer) {
    calloc.free(pointer.ref.log_path);

    calloc.free(pointer);
  }
}

class V2TXLiveVideoEncoderParamStruct extends Struct {
  @Int32()
  external int videoResolution;

  @Int32()
  external int videoResolutionMode;

  @Int32()
  external int videoFps;

  @Int32()
  external int videoBitrate;

  @Int32()
  external int minVideoBitrate;

  static Pointer<V2TXLiveVideoEncoderParamStruct> convert(
      V2TXLiveVideoEncoderParam param) {
    final paramPointer = calloc<V2TXLiveVideoEncoderParamStruct>();
    paramPointer.ref
      ..videoResolution = param.videoResolution.index
      ..videoResolutionMode = param.videoResolutionMode.index
      ..videoFps = param.videoFps
      ..videoBitrate = param.videoBitrate
      ..minVideoBitrate = param.minVideoBitrate;

    return paramPointer;
  }
}

class V2TXLiveVideoFrameStruct extends Struct {
  @Int32()
  external int pixel_format;

  @Int32()
  external int buffer_type;

  external Pointer<Uint8> data;

  @Uint32()
  external int width;

  @Uint32()
  external int height;

  @Int32()
  external int rotation;

  static Pointer<V2TXLiveVideoFrameStruct> convert(V2TXLiveVideoFrame frame) {
    final framePointer = calloc<V2TXLiveVideoFrameStruct>();
    framePointer.ref
      ..pixel_format = frame.pixelFormat.index
      ..buffer_type = frame.bufferType.index
      ..data = convertUint8ListToPointer(frame.data)
      ..width = frame.width
      ..height = frame.height
      ..rotation = frame.rotation.index;
    return framePointer;
  }

  static freeStruct(Pointer<V2TXLiveVideoFrameStruct> pointer) {
    if (pointer.ref.data != nullptr) {
      calloc.free(pointer.ref.data);
    }

    calloc.free(pointer);
  }
}

class V2TXLiveAudioFrameStruct extends Struct {
  external Pointer<Uint8> data;

  @Uint32()
  external int length;

  @Uint32()
  external int sampleRate;

  @Uint32()
  external int channel;

  static Pointer<V2TXLiveAudioFrameStruct> convert(V2TXLiveAudioFrame frame) {
    final framePointer = calloc<V2TXLiveAudioFrameStruct>();
    framePointer.ref
      ..data = convertUint8ListToPointer(frame.data)
      ..length = frame.data.length
      ..sampleRate = frame.sampleRate
      ..channel = frame.channel;
    return framePointer;
  }

  static freeStruct(Pointer<V2TXLiveAudioFrameStruct> pointer) {
    if (pointer.ref.data != nullptr) {
      calloc.free(pointer.ref.data);
    }

    calloc.free(pointer);
  }
}

class V2TXLiveMixStreamStruct extends Struct {
  external Pointer<Char> user_id;
  external Pointer<Char> stream_id;
  @Uint32()
  external int x;
  @Uint32()
  external int y;
  @Uint32()
  external int width;
  @Uint32()
  external int height;
  @Uint32()
  external int z_order;
  @Int32()
  external int input_type;

  static Pointer<V2TXLiveMixStreamStruct> convert(V2TXLiveMixStream mixStream) {
    final pointer = calloc<V2TXLiveMixStreamStruct>();
    pointer.ref
      ..user_id = mixStream.userId.toNativeUtf8().cast<Char>()
      ..stream_id = mixStream.streamId?.toNativeUtf8().cast<Char>() ?? nullptr
      ..x = mixStream.x
      ..y = mixStream.y
      ..width = mixStream.width
      ..height = mixStream.height
      ..z_order = mixStream.zOrder
      ..input_type = mixStream.inputType.index;
    return pointer;
  }

  /// 释放结构体内存
  static void freeStruct(Pointer<V2TXLiveMixStreamStruct> pointer) {
    if (pointer.ref.user_id != nullptr) {
      calloc.free(pointer.ref.user_id);
    }
    if (pointer.ref.stream_id != nullptr) {
      calloc.free(pointer.ref.stream_id);
    }
    calloc.free(pointer);
  }
}

class V2TXLiveTranscodingConfigStruct extends Struct {
  @Uint32()
  external int video_width;

  @Uint32()
  external int video_height;

  @Uint32()
  external int video_bitrate;

  @Uint32()
  external int video_framerate;

  @Uint32()
  external int video_gop;

  @Uint32()
  external int background_color;

  external Pointer<Char> background_image;

  @Uint32()
  external int audio_sample_rate;

  @Uint32()
  external int audio_bitrate;

  @Uint32()
  external int audio_channels;

  external Pointer<V2TXLiveMixStreamStruct> mix_streams_array;

  @Uint32()
  external int mix_stream_size;

  external Pointer<Char> output_stream_id;

  static Pointer<V2TXLiveTranscodingConfigStruct> convert(
      V2TXLiveTranscodingConfig config) {
    final configPointer = calloc<V2TXLiveTranscodingConfigStruct>();

    configPointer.ref
      ..video_width = config.videoWidth
      ..video_height = config.videoHeight
      ..video_bitrate = config.videoBitrate
      ..video_framerate = config.videoFramerate
      ..video_gop = config.videoGOP
      ..background_color = config.backgroundColor
      ..audio_sample_rate = config.audioSampleRate
      ..audio_bitrate = config.audioBitrate
      ..audio_channels = config.audioChannels
      ..mix_stream_size = config.mixStreams.length;

    configPointer.ref
      ..background_image =
          config.backgroundImage?.toNativeUtf8().cast<Char>() ?? nullptr
      ..output_stream_id =
          config.outputStreamId?.toNativeUtf8().cast<Char>() ?? nullptr;

    if (config.mixStreams.isNotEmpty) {
      final mixStreamsPointer =
          calloc<V2TXLiveMixStreamStruct>(config.mixStreams.length);
      for (var i = 0; i < config.mixStreams.length; i++) {
        final mixStream = config.mixStreams[i];
        mixStreamsPointer[i]
          ..user_id = mixStream.userId.toNativeUtf8().cast<Char>()
          ..stream_id =
              mixStream.streamId?.toNativeUtf8().cast<Char>() ?? nullptr
          ..x = mixStream.x
          ..y = mixStream.y
          ..width = mixStream.width
          ..height = mixStream.height
          ..z_order = mixStream.zOrder
          ..input_type = mixStream.inputType.index;
      }
      configPointer.ref.mix_streams_array = mixStreamsPointer;
    }

    return configPointer;
  }

  static void freeStruct(Pointer<V2TXLiveTranscodingConfigStruct> pointer) {
    if (pointer.ref.background_image != nullptr) {
      calloc.free(pointer.ref.background_image);
    }
    if (pointer.ref.output_stream_id != nullptr) {
      calloc.free(pointer.ref.output_stream_id);
    }

    if (pointer.ref.mix_streams_array != nullptr &&
        pointer.ref.mix_stream_size > 0) {
      for (var i = 0; i < pointer.ref.mix_stream_size; i++) {
        final mixStream = pointer.ref.mix_streams_array[i];
        if (mixStream.user_id != nullptr) {
          calloc.free(mixStream.user_id);
        }
        if (mixStream.stream_id != nullptr) {
          calloc.free(mixStream.stream_id);
        }
      }
      calloc.free(pointer.ref.mix_streams_array);
    }

    calloc.free(pointer);
  }
}

class V2TXLiveImageStruct extends Struct {
  external Pointer<Int8> image_src;

  @Int32()
  external int image_type;

  @Uint32()
  external int image_width;

  @Uint32()
  external int image_height;

  @Uint32()
  external int image_length;

  static Pointer<V2TXLiveImageStruct> convert(V2TXLiveImage image) {
    final imagePointer = calloc<V2TXLiveImageStruct>();
    imagePointer.ref
      ..image_src = image.imageSrc?.toNativeUtf8().cast<Int8>() ?? nullptr
      ..image_type = image.imageType.index
      ..image_width = image.imageWidth
      ..image_height = image.imageHeight
      ..image_length = image.imageLength;
    return imagePointer;
  }

  static void freeStruct(Pointer<V2TXLiveImageStruct> pointer) {
    if (pointer.ref.image_src != nullptr) {
      calloc.free(pointer.ref.image_src);
    }
    calloc.free(pointer);
  }
}
