// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:tencent_rtc_sdk/trtc_cloud_def.dart';

class trtc_rect_t extends ffi.Struct {
  @ffi.Int()
  external int left;

  @ffi.Int()
  external int top;

  @ffi.Int()
  external int right;

  @ffi.Int()
  external int bottom;

  static ffi.Pointer<trtc_rect_t> fromParams(TRTCRect param) {
    final rect = calloc<trtc_rect_t>();
    rect.ref
      ..left = param.left
      ..top = param.top
      ..right = param.right
      ..bottom = param.bottom;
    return rect;
  }

  static freeStruct(ffi.Pointer<trtc_rect_t> pointer) {
    calloc.free(pointer);
  }
}

class trtc_size_t extends ffi.Struct {
  @ffi.Int64()
  external int width;

  @ffi.Int64()
  external int height;

  static ffi.Pointer<trtc_size_t> fromParams(TRTCSize param) {
    final size = calloc<trtc_size_t>();
    size.ref
      ..width = param.width
      ..height = param.height;
    return size;
  }

  static freeStruct(ffi.Pointer<trtc_size_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.1
class trtc_params_t extends ffi.Struct {
  @ffi.Uint32()
  external int sdk_app_id;

  external ffi.Pointer<ffi.Char> user_id;

  external ffi.Pointer<ffi.Char> user_sig;

  @ffi.Uint32()
  external int room_id;

  external ffi.Pointer<ffi.Char> str_room_id;

  // 2.2 TRTCRoleType
  @ffi.Int()
  external int role;

  external ffi.Pointer<ffi.Char> stream_id;

  external ffi.Pointer<ffi.Char> user_define_record_id;

  external ffi.Pointer<ffi.Char> private_map_key;

  external ffi.Pointer<ffi.Char> business_info;

  static ffi.Pointer<trtc_params_t> fromParams(TRTCParams param) {
    final params = calloc<trtc_params_t>();
    params.ref
      ..sdk_app_id = param.sdkAppId
      ..user_id = param.userId.toNativeUtf8().cast<ffi.Char>()
      ..user_sig = param.userSig.toNativeUtf8().cast<ffi.Char>()
      ..room_id = param.roomId
      ..str_room_id = param.strRoomId.toNativeUtf8().cast<ffi.Char>()
      ..role = param.role.value()
      ..stream_id = param.streamId.toNativeUtf8().cast<ffi.Char>()
      ..user_define_record_id =
          param.userDefineRecordId.toNativeUtf8().cast<ffi.Char>()
      ..private_map_key = param.privateMapKey.toNativeUtf8().cast<ffi.Char>()
      ..business_info = param.businessInfo.toNativeUtf8().cast<ffi.Char>();
    return params;
  }

  static freeStruct(ffi.Pointer<trtc_params_t> pointer) {
    calloc.free(pointer.ref.user_id);
    calloc.free(pointer.ref.user_sig);
    calloc.free(pointer.ref.str_room_id);
    calloc.free(pointer.ref.stream_id);
    calloc.free(pointer.ref.user_define_record_id);
    calloc.free(pointer.ref.private_map_key);
    calloc.free(pointer.ref.business_info);

    calloc.free(pointer);
  }
}

// 5.2
class trtc_video_enc_param_t extends ffi.Struct {
  // 1.1 TRTCVideoResolution
  @ffi.Int()
  external int video_resolution;

  // 1.2 TRTCVideoResolutionMode
  @ffi.Int()
  external int res_mode;

  @ffi.Uint32()
  external int video_fps;

  @ffi.Uint32()
  external int video_bitrate;

  @ffi.Uint32()
  external int min_video_bitrate;

  // bool -> int
  @ffi.Int()
  external int enable_adjust_res;

  static ffi.Pointer<trtc_video_enc_param_t> fromParams(
      TRTCVideoEncParam param) {
    final params = calloc<trtc_video_enc_param_t>();
    params.ref
      ..video_resolution = param.videoResolution.value()
      ..res_mode = param.videoResolutionMode.value()
      ..video_fps = param.videoFps
      ..video_bitrate = param.videoBitrate
      ..min_video_bitrate = param.minVideoBitrate
      ..enable_adjust_res = param.enableAdjustRes ? 1 : 0;
    return params;
  }

  static freeStruct(ffi.Pointer<trtc_video_enc_param_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.3
class trtc_network_qos_param_t extends ffi.Struct {
  // 2.4 TRTCVideoQosPreference
  @ffi.Int()
  external int preference;

  // 2.3 TRTCQosControlMode
  @ffi.Int()
  external int control_mode;

  static ffi.Pointer<trtc_network_qos_param_t> fromParams(
      TRTCNetworkQosParam param) {
    final params = calloc<trtc_network_qos_param_t>();
    params.ref
      ..preference = param.preference.value()
      ..control_mode = 1;
    return params;
  }

  static freeStruct(ffi.Pointer<trtc_network_qos_param_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.4
class trtc_render_params_t extends ffi.Struct {
  @ffi.Int()
  external int rotation;

  // 1.4 TRTCVideoFillMode
  @ffi.Int()
  external int fill_mode;

  // 1.9 TRTCVideoMirrorType
  @ffi.Int()
  external int mirror_type;

  static ffi.Pointer<trtc_render_params_t> fromParams(TRTCRenderParams param) {
    final params = calloc<trtc_render_params_t>();
    params.ref
      ..rotation = param.rotation.value()
      ..fill_mode = param.fillMode.value()
      ..mirror_type = param.mirrorType.value();
    return params;
  }

  static freeStruct(ffi.Pointer<trtc_render_params_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.7
class trtc_speed_test_params_t extends ffi.Struct {
  @ffi.Int()
  external int sdk_app_id;

  external ffi.Pointer<ffi.Char> user_id;

  external ffi.Pointer<ffi.Char> user_sig;

  @ffi.Int()
  external int expected_up_bandwidth;

  @ffi.Int()
  external int expected_down_bandwidth;

  // 4.14 TRTCSpeedTestScene
  @ffi.Int()
  external int scene;

  static ffi.Pointer<trtc_speed_test_params_t> fromParams(
      TRTCSpeedTestParams param) {
    final params = calloc<trtc_speed_test_params_t>();
    params.ref
      ..sdk_app_id = param.sdkAppId
      ..user_id = param.userId.toNativeUtf8().cast<ffi.Char>()
      ..user_sig = param.userSig.toNativeUtf8().cast<ffi.Char>()
      ..expected_up_bandwidth = param.expectedUpBandwidth
      ..expected_down_bandwidth = param.expectedDownBandwidth
      ..scene = param.scene.value();
    return params;
  }

  static freeStruct(ffi.Pointer<trtc_speed_test_params_t> pointer) {
    calloc.free(pointer.ref.user_id);
    calloc.free(pointer.ref.user_sig);

    calloc.free(pointer);
  }
}

// 5.9
class trtc_texture_t extends ffi.Struct {
  @ffi.Int()
  external int gl_texture_id;

  external ffi.Pointer<ffi.Void> gl_context;

  static ffi.Pointer<trtc_texture_t> fromParams(TRTCTexture param) {
    final texture = calloc<trtc_texture_t>();
    texture.ref
      ..gl_texture_id = param.glTextureId
      ..gl_context = ffi.Pointer<ffi.Void>.fromAddress(param.glContext);
    return texture;
  }

  static freeStruct(ffi.Pointer<trtc_texture_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.10
class trtc_video_frame_t extends ffi.Struct {
  // 1.7 TRTCVideoPixelFormat
  @ffi.Int()
  external int video_format;

  // 1.8 TRTCVideoBufferType
  @ffi.Int()
  external int buffer_type;

  external ffi.Pointer<trtc_texture_t> texture;

  external ffi.Pointer<ffi.Char> data;

  @ffi.Uint32()
  external int length;

  @ffi.Uint32()
  external int width;

  @ffi.Uint32()
  external int height;

  @ffi.Uint64()
  external int timestamp;

  // 1.5 TRTCVideoRotation
  @ffi.Int()
  external int rotation;

  static ffi.Pointer<trtc_video_frame_t> fromParams(TRTCVideoFrame param) {
    final frame = calloc<trtc_video_frame_t>();

    ffi.Pointer<ffi.Char> dataPointer = ffi.nullptr;
    if (param.data.isNotEmpty) {
      dataPointer = calloc<ffi.Uint8>(param.data.length).cast<ffi.Char>();
      final nativeData = dataPointer.cast<ffi.Uint8>();
      for (int i = 0; i < param.data.length; i++) {
        nativeData[i] = param.data[i];
      }
    }

    frame.ref
      ..video_format = param.videoFormat.value()
      ..buffer_type = param.bufferType.value()
      ..texture = param.texture != null
          ? trtc_texture_t.fromParams(param.texture!)
          : ffi.nullptr
      ..data = dataPointer
      ..length = param.length
      ..width = param.width
      ..height = param.height
      ..timestamp = param.timestamp
      ..rotation = param.rotation.value();
    return frame;
  }

  static freeStruct(ffi.Pointer<trtc_video_frame_t> pointer) {
    if (pointer.ref.texture != ffi.nullptr) {
      calloc.free(pointer.ref.texture);
    }
    if (pointer.ref.data != ffi.nullptr) {
      calloc.free(pointer.ref.data);
    }

    calloc.free(pointer);
  }
}

class trtc_audio_frame_t extends ffi.Struct {
  // 3.7 TRTCAudioFrameFormat
  @ffi.Int()
  external int audio_format;

  external ffi.Pointer<ffi.Char> data;

  @ffi.Uint32()
  external int length;

  @ffi.Uint32()
  external int sample_rate;

  @ffi.Uint32()
  external int channel;

  @ffi.Uint64()
  external int timestamp;

  external ffi.Pointer<ffi.Char> extra_data;

  @ffi.Uint32()
  external int extra_data_length;

  static ffi.Pointer<trtc_audio_frame_t> fromParams(TRTCAudioFrame param) {
    final frame = calloc<trtc_audio_frame_t>();

    ffi.Pointer<ffi.Char> dataPointer = ffi.nullptr;
    if (param.data.isNotEmpty) {
      dataPointer = calloc<ffi.Uint8>(param.data.length).cast<ffi.Char>();
      final nativeData = dataPointer.cast<ffi.Uint8>();
      for (int i = 0; i < param.data.length; i++) {
        nativeData[i] = param.data[i];
      }
    }

    ffi.Pointer<ffi.Char> extraDataPointer = ffi.nullptr;
    if (param.extraData.isNotEmpty) {
      extraDataPointer =
          calloc<ffi.Uint8>(param.extraData.length).cast<ffi.Char>();
      final nativeExtraData = extraDataPointer.cast<ffi.Uint8>();
      for (int i = 0; i < param.extraData.length; i++) {
        nativeExtraData[i] = param.extraData[i];
      }
    }

    frame.ref
      ..audio_format = param.audioFormat.value()
      ..data = dataPointer
      ..length = param.length
      ..sample_rate = param.sampleRate
      ..channel = param.channel
      ..timestamp = param.timestamp
      ..extra_data = extraDataPointer
      ..extra_data_length = param.extraDataLength;
    return frame;
  }

  static freeStruct(ffi.Pointer<trtc_audio_frame_t> pointer) {
    if (pointer.ref.data != ffi.nullptr) {
      calloc.free(pointer.ref.data);
    }
    if (pointer.ref.extra_data != ffi.nullptr) {
      calloc.free(pointer.ref.extra_data);
    }

    calloc.free(pointer);
  }
}

// 5.12
class trtc_mix_user_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> user_id;

  external ffi.Pointer<ffi.Char> room_id;

  external trtc_rect_t rect;

  @ffi.Int()
  external int z_order;

  // 1.3 TRTCVideoStreamType
  @ffi.Int()
  external int stream_type;

  // bool -> int
  @ffi.Int()
  external int pure_audio;

  // 4.6 TRTCMixInputType
  @ffi.Int()
  external int input_type;

  @ffi.Uint32()
  external int render_mode;

  @ffi.Uint32()
  external int sound_level;

  external ffi.Pointer<ffi.Char> image;
}

// 5.13
class trtc_transcoding_config_t extends ffi.Struct {
  // 4.4 TRTCTranscodingConfigMode
  @ffi.Int()
  external int mode;

  @ffi.Uint32()
  external int app_id;

  @ffi.Uint32()
  external int biz_id;

  @ffi.Uint32()
  external int video_width;

  @ffi.Uint32()
  external int video_height;

  @ffi.Uint32()
  external int video_bitrate;

  @ffi.Uint32()
  external int video_framerate;

  @ffi.Uint32()
  external int video_gop;

  @ffi.Uint32()
  external int background_color;

  external ffi.Pointer<ffi.Char> background_image;

  @ffi.Uint32()
  external int audio_sample_rate;

  @ffi.Uint32()
  external int audio_bitrate;

  @ffi.Uint32()
  external int audio_channels;

  @ffi.Uint32()
  external int audio_codec;

  external ffi.Pointer<trtc_mix_user_t> mix_users_array;

  @ffi.Uint32()
  external int mix_users_array_size;

  external ffi.Pointer<ffi.Char> stream_id;

  external ffi.Pointer<ffi.Char> video_sei_params;
}

// 5.14
class trtc_publish_cdn_param_t extends ffi.Struct {
  @ffi.Uint32()
  external int app_id;

  @ffi.Uint32()
  external int biz_id;

  external ffi.Pointer<ffi.Char> url;

  external ffi.Pointer<ffi.Char> stream_id;
}

// 5.16
class trtc_local_recording_params_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> file_path;

  // 4.5 TRTCLocalRecordType
  @ffi.Int()
  external int record_type;

  @ffi.Int()
  external int interval;

  @ffi.Int()
  external int max_duration_per_file;

  static ffi.Pointer<trtc_local_recording_params_t> fromParams(
      TRTCLocalRecordingParams params) {
    final paramsPointer = calloc<trtc_local_recording_params_t>();
    paramsPointer.ref
      ..file_path = params.filePath.toNativeUtf8().cast<ffi.Char>()
      ..record_type = params.recordType.value()
      ..interval = params.interval
      ..max_duration_per_file = params.maxDurationPerFile;
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_local_recording_params_t> pointer) {
    calloc.free(pointer.ref.file_path);

    calloc.free(pointer);
  }
}

// 5.18
class trtc_switch_room_config_t extends ffi.Struct {
  @ffi.Uint32()
  external int room_id;

  external ffi.Pointer<ffi.Char> str_room_id;

  external ffi.Pointer<ffi.Char> user_sig;

  external ffi.Pointer<ffi.Char> private_map_key;

  static ffi.Pointer<trtc_switch_room_config_t> fromParams(
      TRTCSwitchRoomConfig params) {
    final paramsPointer = calloc<trtc_switch_room_config_t>();
    paramsPointer.ref
      ..room_id = params.roomId
      ..str_room_id = params.strRoomId.toNativeUtf8().cast<ffi.Char>()
      ..user_sig = params.userSig.toNativeUtf8().cast<ffi.Char>()
      ..private_map_key = params.privateMapKey.toNativeUtf8().cast<ffi.Char>();
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_switch_room_config_t> pointer) {
    calloc.free(pointer.ref.str_room_id);
    calloc.free(pointer.ref.user_sig);
    calloc.free(pointer.ref.private_map_key);

    calloc.free(pointer);
  }
}

// 5.19
class trtc_audio_frame_callback_format_t extends ffi.Struct {
  @ffi.Int()
  external int sample_rate;

  @ffi.Int()
  external int channel;

  @ffi.Int()
  external int samples_per_call;

  // 3.9 TRTCAudioFrameOperationMode
  @ffi.Int()
  external int mode;

  static ffi.Pointer<trtc_audio_frame_callback_format_t> fromParams(
      TRTCAudioFrameCallbackFormat params) {
    final paramsPointer = calloc<trtc_audio_frame_callback_format_t>();
    paramsPointer.ref
      ..sample_rate = params.sampleRate
      ..channel = params.channel
      ..samples_per_call = params.samplesPerCall
      ..mode = params.mode.value();
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_audio_frame_callback_format_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.20
class trtc_image_buffer_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> buffer;

  @ffi.Uint32()
  external int length;

  @ffi.Uint32()
  external int width;

  @ffi.Uint32()
  external int height;

  static ffi.Pointer<trtc_image_buffer_t> fromParams(TRTCImageBuffer params) {
    final paramsPointer = calloc<trtc_image_buffer_t>();
    paramsPointer.ref
      ..buffer = params.buffer.toString().toNativeUtf8().cast<ffi.Char>()
      ..length = params.length
      ..width = params.width
      ..height = params.height;
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_image_buffer_t> pointer) {
    calloc.free(pointer.ref.buffer);

    calloc.free(pointer);
  }
}

// 5.21
class trtc_screen_capture_source_info_t extends ffi.Struct {
  // 4.3 TRTCScreenCaptureSourceType
  @ffi.Int()
  external int type;

  external tx_view source_id;

  external ffi.Pointer<ffi.Char> source_name;

  external trtc_image_buffer_t thumb_bgra;

  external trtc_image_buffer_t icon_bgra;

  // bool -> int
  @ffi.Int()
  external int is_minimize_window;

  // bool -> int
  @ffi.Int()
  external int is_main_screen;

  @ffi.Int32()
  external int x;

  @ffi.Int32()
  external int y;

  @ffi.Uint32()
  external int width;

  @ffi.Uint32()
  external int height;

  static ffi.Pointer<trtc_screen_capture_source_info_t> create(
      int thumbLength, int iconLength) {
    final paramsPointer = calloc<trtc_screen_capture_source_info_t>();
    paramsPointer.ref
      ..source_name = calloc<ffi.Char>(512)
      ..thumb_bgra.buffer = calloc<ffi.Char>(thumbLength)
      ..icon_bgra.buffer = calloc<ffi.Char>(iconLength);
    return paramsPointer;
  }

  static ffi.Pointer<trtc_screen_capture_source_info_t> fromParams(
      TRTCScreenCaptureSourceInfo params) {
    final paramsPointer = calloc<trtc_screen_capture_source_info_t>();
    paramsPointer.ref
      ..type = params.type.value()
      ..source_id = ffi.Pointer<ffi.Void>.fromAddress(params.viewId)
      ..source_name = params.sourceName.toNativeUtf8().cast<ffi.Char>()
      ..thumb_bgra.buffer =
          params.thumbBGRA.buffer.toString().toNativeUtf8().cast<ffi.Char>()
      ..thumb_bgra.length = params.thumbBGRA.length
      ..thumb_bgra.width = params.thumbBGRA.width
      ..thumb_bgra.height = params.thumbBGRA.height
      ..icon_bgra.buffer =
          params.iconBGRA.buffer.toString().toNativeUtf8().cast<ffi.Char>()
      ..icon_bgra.length = params.iconBGRA.length
      ..icon_bgra.width = params.iconBGRA.width
      ..icon_bgra.height = params.iconBGRA.height
      ..is_minimize_window = params.isMinimizeWindow ? 1 : 0
      ..is_main_screen = params.isMainScreen ? 1 : 0
      ..x = params.x
      ..y = params.y
      ..y = params.y
      ..width = params.width
      ..height = params.height;
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_screen_capture_source_info_t> pointer) {
    calloc.free(pointer.ref.source_name);
    calloc.free(pointer.ref.thumb_bgra.buffer);
    calloc.free(pointer.ref.icon_bgra.buffer);

    calloc.free(pointer);
  }
}

typedef tx_view = ffi.Pointer<ffi.Void>;

// 5.23
class trtc_screen_capture_property_t extends ffi.Struct {
  // bool -> int
  @ffi.Int()
  external int enable_capture_mouse;

  // bool -> int
  @ffi.Int()
  external int enable_high_light;

  // bool -> int
  @ffi.Int()
  external int enable_high_performance;

  @ffi.Int()
  external int high_light_color;

  @ffi.Int()
  external int high_light_width;

  // bool -> int
  @ffi.Int()
  external int enable_capture_child_window;

  static ffi.Pointer<trtc_screen_capture_property_t> fromParams(
      TRTCScreenCaptureProperty params) {
    final paramsPointer = calloc<trtc_screen_capture_property_t>();
    paramsPointer.ref
      ..enable_capture_mouse = params.enableCaptureMouse ? 1 : 0
      ..enable_high_light = params.enableHighLight ? 1 : 0
      ..enable_high_performance = params.enableHighPerformance ? 1 : 0
      ..high_light_color = params.highLightColor
      ..high_light_width = params.highLightWidth
      ..enable_capture_child_window = params.enableCaptureChildWindow ? 1 : 0;
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_screen_capture_property_t> pointer) {
    calloc.free(pointer);
  }
}

// 5.24
// class trtc_audio_parallel_params_t extends ffi.Struct {
//   @ffi.Uint32()
//   external int max_count;
//
//   external ffi.Pointer<ffi.Pointer<ffi.Char>> include_users;
//
//   @ffi.Uint32()
//   external int include_users_count;
//
//   static ffi.Pointer<ffi.Pointer<ffi.Char>> fromStringList(List<String> list) {
//     final listCount = list.length;
//     final ffi.Pointer<ffi.Pointer<ffi.Char>> pointerArray = calloc<ffi.Pointer<ffi.Char>>(listCount);
//
//     for (int i = 0; i < listCount; i++) {
//       final ffi.Pointer<ffi.Char> userPointer = list[i].toNativeUtf8().cast<ffi.Char>();
//       pointerArray[i] = userPointer;
//     }
//
//     return pointerArray;
//   }
//
//   static ffi.Pointer<trtc_audio_parallel_params_t> fromParams(TRTCAudioParallelParams params) {
//     final paramsPointer = calloc<trtc_audio_parallel_params_t>();
//     paramsPointer.ref
//       ..max_count = params.maxCount
//       ..include_users = fromStringList(params.includeUsers)
//       ..include_users_count = params.includeUsers.length;
//     return paramsPointer;
//   }
//
//   static freeStruct(ffi.Pointer<trtc_audio_parallel_params_t> pointer) {
//     int count = pointer.ref.include_users_count;
//     for (int i = 0; i < count; i++) {
//       calloc.free(pointer.ref.include_users[i]);
//     }
//     calloc.free(pointer.ref.include_users);
//
//     calloc.free(pointer);
//   }
// }

// 5.25
class trtc_user_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> user_id;

  @ffi.Uint32()
  external int int_room_id;

  external ffi.Pointer<ffi.Char> str_room_id;

  static ffi.Pointer<trtc_user_t> fromParams(TRTCUser params) {
    final paramsPointer = calloc<trtc_user_t>();
    paramsPointer.ref
      ..user_id = params.userId.toNativeUtf8().cast<ffi.Char>()
      ..int_room_id = params.intRoomId
      ..str_room_id = params.strRoomId.toNativeUtf8().cast<ffi.Char>();
    return paramsPointer;
  }

  static ffi.Pointer<trtc_user_t> setParamList(List<TRTCUser> userList) {
    final userCount = userList.length;
    final userListPointer = calloc<trtc_user_t>(userCount);

    for (int i = 0; i < userCount; i++) {
      userListPointer[i].user_id =
          userList[i].userId.toNativeUtf8().cast<ffi.Char>();
      userListPointer[i].int_room_id = userList[i].intRoomId;
      userListPointer[i].str_room_id =
          userList[i].strRoomId.toNativeUtf8().cast<ffi.Char>();
    }

    return userListPointer;
  }

  static freeStruct(ffi.Pointer<trtc_user_t> pointer) {
    calloc.free(pointer.ref.user_id);
    calloc.free(pointer.ref.str_room_id);

    calloc.free(pointer);
  }

  static freeStructList(ffi.Pointer<trtc_user_t> pointer, int length) {
    for (int i = 0; i < length; i++) {
      calloc.free(pointer[i].user_id);
      calloc.free(pointer[i].str_room_id);
    }
    calloc.free(pointer);
  }
}

// 5.26
class trtc_publish_cdn_url_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> rtmp_url;

  // bool -> int
  @ffi.Int()
  external int is_internal_line;

  static ffi.Pointer<trtc_publish_cdn_url_t> fromParams(
      TRTCPublishCdnUrl params) {
    final paramsPointer = calloc<trtc_publish_cdn_url_t>();
    paramsPointer.ref
      ..rtmp_url = params.rtmpUrl.toNativeUtf8().cast<ffi.Char>()
      ..is_internal_line = params.isInternalLine ? 1 : 0;
    return paramsPointer;
  }

  static ffi.Pointer<trtc_publish_cdn_url_t> setParamList(
      List<TRTCPublishCdnUrl> cdnUrlList) {
    final urlCount = cdnUrlList.length;
    final cdnUrlListPointer = calloc<trtc_publish_cdn_url_t>(urlCount);

    for (int i = 0; i < urlCount; i++) {
      cdnUrlListPointer[i].is_internal_line =
          cdnUrlList[i].isInternalLine ? 1 : 0;
      cdnUrlListPointer[i].rtmp_url =
          cdnUrlList[i].rtmpUrl.toNativeUtf8().cast<ffi.Char>();
    }

    return cdnUrlListPointer;
  }

  static freeStruct(ffi.Pointer<trtc_publish_cdn_url_t> pointer) {
    calloc.free(pointer.ref.rtmp_url);

    calloc.free(pointer);
  }

  static freeStructList(
      ffi.Pointer<trtc_publish_cdn_url_t> pointer, int length) {
    for (int i = 0; i < length; i++) {
      calloc.free(pointer[i].rtmp_url);
    }
    calloc.free(pointer);
  }
}

// 5.27
class trtc_publish_target_t extends ffi.Struct {
  // 4.12 TRTCPublishMode
  @ffi.Int()
  external int mode;

  external ffi.Pointer<trtc_publish_cdn_url_t> cdn_url_list;

  @ffi.Uint32()
  external int cdn_url_list_size;

  external ffi.Pointer<trtc_user_t> mix_stream_identity;

  static ffi.Pointer<trtc_publish_target_t> fromParams(
      TRTCPublishTarget params) {
    final paramsPointer = calloc<trtc_publish_target_t>();
    paramsPointer.ref
      ..mode = params.mode.value()
      ..cdn_url_list = trtc_publish_cdn_url_t.setParamList(params.cdnUrlList)
      ..cdn_url_list_size = params.cdnUrlList.length
      ..mix_stream_identity = trtc_user_t.fromParams(params.mixStreamIdentity);
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_publish_target_t> pointer) {
    trtc_publish_cdn_url_t.freeStructList(
        pointer.ref.cdn_url_list, pointer.ref.cdn_url_list_size);
    trtc_user_t.freeStruct(pointer.ref.mix_stream_identity);

    calloc.free(pointer);
  }
}

// 5.28
class trtc_video_layout_t extends ffi.Struct {
  external trtc_rect_t rect;

  @ffi.Int()
  external int z_order;

  // 1.4 TRTCVideoFillMode
  @ffi.Int()
  external int fill_mode;

  @ffi.Uint32()
  external int background_color;

  external ffi.Pointer<ffi.Char> place_holder_image;

  external ffi.Pointer<trtc_user_t> fixed_video_user;

  // 1.3 TRTCVideoStreamType
  @ffi.Int()
  external int fixed_video_stream_type;

  static ffi.Pointer<trtc_video_layout_t> fromParams(TRTCVideoLayout params) {
    final paramsPointer = calloc<trtc_video_layout_t>();
    paramsPointer.ref
      ..rect.left = params.rect.left
      ..rect.top = params.rect.top
      ..rect.right = params.rect.right
      ..rect.bottom = params.rect.bottom
      ..z_order = params.zOrder
      ..fill_mode = params.fillMode.value()
      ..background_color = params.backgroundColor
      ..place_holder_image =
          params.placeHolderImage.toString().toNativeUtf8().cast<ffi.Char>()
      ..fixed_video_user = trtc_user_t.fromParams(params.fixedVideoUser)
      ..fixed_video_stream_type = params.fixedVideoStreamType.value();
    return paramsPointer;
  }

  static ffi.Pointer<trtc_video_layout_t> setParamList(
      List<TRTCVideoLayout> list) {
    final paramsPointer = calloc<trtc_video_layout_t>(list.length);

    for (int i = 0; i < list.length; i++) {
      paramsPointer[i]
        ..rect.left = list[i].rect.left
        ..rect.top = list[i].rect.top
        ..rect.right = list[i].rect.right
        ..rect.bottom = list[i].rect.bottom
        ..z_order = list[i].zOrder
        ..fill_mode = list[i].fillMode.value()
        ..background_color = list[i].backgroundColor
        ..place_holder_image =
            list[i].placeHolderImage.toString().toNativeUtf8().cast<ffi.Char>()
        ..fixed_video_user = trtc_user_t.fromParams(list[i].fixedVideoUser)
        ..fixed_video_stream_type = list[i].fixedVideoStreamType.value();
    }
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_video_layout_t> pointer) {
    calloc.free(pointer.ref.place_holder_image);
    trtc_user_t.freeStruct(pointer.ref.fixed_video_user);

    calloc.free(pointer);
  }

  static freeStructList(ffi.Pointer<trtc_video_layout_t> pointer, int length) {
    for (int i = 0; i < length; i++) {
      calloc.free(pointer[i].place_holder_image);
      trtc_user_t.freeStruct(pointer[i].fixed_video_user);
    }

    calloc.free(pointer);
  }
}

// 5.29
class trtc_watermark_t extends ffi.Struct {
  external ffi.Pointer<ffi.Char> watermark_url;

  external trtc_rect_t rect;

  @ffi.Int()
  external int z_order;

  static ffi.Pointer<trtc_watermark_t> fromParams(TRTCWatermark params) {
    final paramsPointer = calloc<trtc_watermark_t>();
    paramsPointer.ref
      ..watermark_url = params.watermarkUrl.toNativeUtf8().cast<ffi.Char>()
      ..rect.left = params.rect.left
      ..rect.top = params.rect.top
      ..rect.right = params.rect.right
      ..rect.bottom = params.rect.bottom
      ..z_order = params.zOrder;
    return paramsPointer;
  }

  static ffi.Pointer<trtc_watermark_t> setParamList(List<TRTCWatermark> list) {
    final paramsPointer = calloc<trtc_watermark_t>(list.length);

    for (int i = 0; i < list.length; i++) {
      paramsPointer[i]
        ..watermark_url = list[i].watermarkUrl.toNativeUtf8().cast<ffi.Char>()
        ..rect.left = list[i].rect.left
        ..rect.top = list[i].rect.top
        ..rect.right = list[i].rect.right
        ..rect.bottom = list[i].rect.bottom
        ..z_order = list[i].zOrder;
    }
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_watermark_t> pointer) {
    calloc.free(pointer.ref.watermark_url);

    calloc.free(pointer);
  }

  static freeStructList(ffi.Pointer<trtc_watermark_t> pointer, int length) {
    for (int i = 0; i < length; i++) {
      calloc.free(pointer[i].watermark_url);
    }

    calloc.free(pointer);
  }
}

// 5.30
class trtc_stream_encoder_param_t extends ffi.Struct {
  @ffi.Uint32()
  external int video_encoded_width;

  @ffi.Uint32()
  external int video_encoded_height;

  @ffi.Uint32()
  external int video_encoded_fps;

  @ffi.Uint32()
  external int video_encoded_gop;

  @ffi.Uint32()
  external int video_encoded_kbps;

  @ffi.Uint32()
  external int audio_encoded_sample_rate;

  @ffi.Uint32()
  external int audio_encoded_channel_num;

  @ffi.Uint32()
  external int audio_encoded_kbps;

  @ffi.Uint32()
  external int audio_encoded_codec_type;

  @ffi.Uint32()
  external int video_encoded_codec_type;

  external ffi.Pointer<ffi.Char> video_sei_params;

  static ffi.Pointer<trtc_stream_encoder_param_t> fromParams(
      TRTCStreamEncoderParam params) {
    final paramsPointer = calloc<trtc_stream_encoder_param_t>();
    paramsPointer.ref
      ..video_encoded_width = params.videoEncodedWidth
      ..video_encoded_height = params.videoEncodedHeight
      ..video_encoded_fps = params.videoEncodedFPS
      ..video_encoded_gop = params.videoEncodedGOP
      ..video_encoded_kbps = params.videoEncodedKbps
      ..audio_encoded_sample_rate = params.audioEncodedSampleRate
      ..audio_encoded_channel_num = params.audioEncodedChannelNum
      ..audio_encoded_kbps = params.audioEncodedKbps
      ..audio_encoded_codec_type = params.audioEncodedCodecType
      ..video_encoded_codec_type = params.videoEncodedCodecType
      ..video_sei_params =
          params.videoSeiParams.toNativeUtf8().cast<ffi.Char>();
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_stream_encoder_param_t> pointer) {
    calloc.free(pointer.ref.video_sei_params);

    calloc.free(pointer);
  }
}

// 5.31
class trtc_stream_mixing_config_t extends ffi.Struct {
  @ffi.Uint32()
  external int background_color;

  external ffi.Pointer<ffi.Char> background_image;

  external ffi.Pointer<trtc_video_layout_t> video_layout_list;

  @ffi.Uint32()
  external int video_layout_list_size;

  external ffi.Pointer<trtc_user_t> audio_mix_user_list;

  @ffi.Uint32()
  external int audio_mix_user_list_size;

  external ffi.Pointer<trtc_watermark_t> watermark_list;

  @ffi.Uint32()
  external int watermark_list_size;

  static ffi.Pointer<trtc_stream_mixing_config_t> fromParams(
      TRTCStreamMixingConfig config) {
    final configPointer = calloc<trtc_stream_mixing_config_t>();
    configPointer.ref
      ..background_color = config.backgroundColor
      ..background_image =
          config.backgroundImage.toString().toNativeUtf8().cast<ffi.Char>()
      ..video_layout_list =
          trtc_video_layout_t.setParamList(config.videoLayoutList)
      ..video_layout_list_size = config.videoLayoutList.length
      ..audio_mix_user_list = trtc_user_t.setParamList(config.audioMixUserList)
      ..audio_mix_user_list_size = config.audioMixUserList.length
      ..watermark_list = trtc_watermark_t.setParamList(config.watermarkList)
      ..watermark_list_size = config.watermarkList.length;
    return configPointer;
  }

  static freeStruct(ffi.Pointer<trtc_stream_mixing_config_t> pointer) {
    calloc.free(pointer.ref.background_image);
    trtc_video_layout_t.freeStructList(
        pointer.ref.video_layout_list, pointer.ref.video_layout_list_size);
    trtc_user_t.freeStructList(
        pointer.ref.audio_mix_user_list, pointer.ref.audio_mix_user_list_size);
    trtc_watermark_t.freeStructList(
        pointer.ref.watermark_list, pointer.ref.watermark_list_size);

    calloc.free(pointer);
  }
}

// 5.33
class trtc_audio_volume_evaluate_params_t extends ffi.Struct {
  @ffi.Uint32()
  external int interval;

  // bool -> int
  @ffi.Int()
  external int enable_vad_detection;

  // bool -> int
  @ffi.Int()
  external int enable_pitch_calculation;

  // bool -> int
  @ffi.Int()
  external int enable_spectrum_calculation;

  static ffi.Pointer<trtc_audio_volume_evaluate_params_t> fromParams(
      TRTCAudioVolumeEvaluateParams params) {
    final paramsPointer = calloc<trtc_audio_volume_evaluate_params_t>();
    paramsPointer.ref
      ..interval = params.interval
      ..enable_vad_detection = params.enableVadDetection ? 1 : 0
      ..enable_pitch_calculation = params.enablePitchCalculation ? 1 : 0
      ..enable_spectrum_calculation = params.enableSpectrumCalculation ? 1 : 0;
    return paramsPointer;
  }

  static freeStruct(ffi.Pointer<trtc_audio_volume_evaluate_params_t> pointer) {
    calloc.free(pointer);
  }
}

// new
class trtc_log_param_t extends ffi.Struct {
  @ffi.Int()
  external int level;

  @ffi.Int()
  external int console_enabled;

  @ffi.Int()
  external int compress_enabled;

  external ffi.Pointer<ffi.Char> path;

  static ffi.Pointer<trtc_log_param_t> fromParams(TRTCLogParams param) {
    final paramPointer = calloc<trtc_log_param_t>();
    paramPointer.ref
      ..level = param.level.value()
      ..console_enabled = param.consoleEnabled ? 1 : 0
      ..compress_enabled = param.compressEnabled ? 1 : 0
      ..path = param.filePath.toNativeUtf8().cast<ffi.Char>();
    return paramPointer;
  }

  static freeStruct(ffi.Pointer<trtc_log_param_t> pointer) {
    calloc.free(pointer.ref.path);

    calloc.free(pointer);
  }
}

typedef trtc_cloud = ffi.Pointer<ffi.Void>;
typedef trtc_cloud_callback = ffi.Pointer<ffi.Void>;
typedef trtc_screen_capture_source_list = ffi.Pointer<ffi.Void>;
typedef trtc_video_frame_callback = ffi.Pointer<ffi.Void>;
typedef trtc_video_render_callback = ffi.Pointer<ffi.Void>;
typedef trtc_audio_frame_callback = ffi.Pointer<ffi.Void>;
typedef trtc_log_callback = ffi.Pointer<ffi.Void>;

abstract class trtc_log_write_level {
  static const int log_info = 0;
  static const int log_warning = 1;
  static const int log_error = 2;
  static const int log_fatal = 3;
}

class FFIConverter {
  static String getStringFromChar(ffi.Pointer<ffi.Char> charPointer) {
    ffi.Pointer<Utf8> utf8 = charPointer.cast<Utf8>();
    return utf8.toDartString();
  }
}
