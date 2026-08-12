// Copyright (c) 2023 Tencent. All rights reserved.
// Author: felixyyan

#ifndef SDK_TRTC_C_TRTC_CLOUD_TYPE_H_  // NOLINT(build/header_guard)
#define SDK_TRTC_C_TRTC_CLOUD_TYPE_H_

#include <stdint.h>
#include <string.h>

#ifdef _WIN32
#include <windows.h>
#ifdef trtc_c_exports
#define trtc_c_api __declspec(dllexport)
#else
#define trtc_c_api __declspec(dllimport)
#endif
#elif __APPLE__
#include <TargetConditionals.h>
#define trtc_c_api __attribute__((visibility("default")))
#elif __ANDROID__ || __linux__
#define trtc_c_api __attribute__((visibility("default")))
#else
#define trtc_c_api
#endif

#ifdef _WIN32
typedef HWND tx_view;
#else
typedef void* tx_view;
#endif

typedef void* trtc_cloud;
typedef void* trtc_cloud_callback;
typedef void* trtc_video_render_callback;
typedef void* trtc_video_frame_callback;
typedef void* trtc_audio_frame_callback;
typedef void* trtc_log_callback;

typedef void* trtc_screen_capture_source_list;

typedef struct {
  int left;
  int top;
  int right;
  int bottom;
} trtc_rect_t;

typedef struct {
  int64_t width;
  int64_t height;
} trtc_size_t;

// 3.3
typedef enum {
  trtc_audio_mode_unknown = -1,
  trtc_audio_mode_speakerphone = 0,
  trtc_audio_mode_earpiece = 1,
  trtc_audio_mode_wired_headset = 2,
  trtc_audio_mode_bluetooth_headset = 3,
  trtc_audio_mode_soundCard = 4,
} trtc_audio_route;

// 5.1
typedef struct {
  uint32_t sdk_app_id;
  const char* user_id;
  const char* user_sig;
  uint32_t room_id;
  const char* str_room_id;
  int role;  // 2.2 TRTCRoleType
  const char* stream_id;
  const char* user_define_record_id;
  const char* private_map_key;
  const char* business_info;
} trtc_params_t;

// 5.2
typedef struct {
  int video_resolution;  // 1.1 TRTCVideoResolution
  int res_mode;          // 1.2 TRTCVideoResolutionMode
  uint32_t video_fps;
  uint32_t video_bitrate;
  uint32_t min_video_bitrate;
  int enable_adjust_res;  // bool -> int
} trtc_video_enc_param_t;

// 5.3
typedef struct {
  int preference;    // 2.4 TRTCVideoQosPreference
  int control_mode;  // 2.3 TRTCQosControlMode（已废弃）
} trtc_network_qos_param_t;

// 5.4
typedef struct {
  int rotation;
  int fill_mode;    // 1.4 TRTCVideoFillMode
  int mirror_type;  // 1.9 TRTCVideoMirrorType
} trtc_render_params_t;

// 5.7
typedef struct {
  int sdk_app_id;
  const char* user_id;
  const char* user_sig;
  int expected_up_bandwidth;
  int expected_down_bandwidth;
  int scene;  // 4.14 TRTCSpeedTestScene
} trtc_speed_test_params_t;

// 5.9
typedef struct {
  int gl_texture_id;
  void* gl_context;
} trtc_texture_t;

// 5.10
typedef struct {
  int video_format;  // 1.7 TRTCVideoPixelFormat
  int buffer_type;   // 1.8 TRTCVideoBufferType
  trtc_texture_t* texture;
  char* data;
  uint32_t length;
  uint32_t width;
  uint32_t height;
  uint64_t timestamp;
  int rotation;  // 1.5 TRTCVideoRotation
} trtc_video_frame_t;

typedef struct {
  int audio_format;  // 3.7 TRTCAudioFrameFormat
  char* data;
  uint32_t length;
  uint32_t sample_rate;
  uint32_t channel;
  uint64_t timestamp;
  char* extra_data;
  uint32_t extra_data_length;
} trtc_audio_frame_t;

// 5.12
typedef struct {
  const char* user_id;
  const char* room_id;
  trtc_rect_t rect;
  int z_order;
  int stream_type;  // 1.3 TRTCVideoStreamType
  int pure_audio;   // bool -> int
  int input_type;   // 4.6 TRTCMixInputType
  uint32_t render_mode;
  uint32_t sound_level;
  const char* image;
} trtc_mix_user_t;

// 5.13
typedef struct {
  int mode;  // 4.4 TRTCTranscodingConfigMode
  uint32_t app_id;
  uint32_t biz_id;
  uint32_t video_width;
  uint32_t video_height;
  uint32_t video_bitrate;
  uint32_t video_framerate;
  uint32_t video_gop;
  uint32_t background_color;
  const char* background_image;
  uint32_t audio_sample_rate;
  uint32_t audio_bitrate;
  uint32_t audio_channels;
  uint32_t audio_codec;
  trtc_mix_user_t* mix_users_array;
  uint32_t mix_users_array_size;
  const char* stream_id;
  const char* video_sei_params;
} trtc_transcoding_config_t;

// 5.14
typedef struct {
  uint32_t app_id;
  uint32_t biz_id;
  const char* url;
  const char* stream_id;
} trtc_publish_cdn_param_t;

// 5.15
typedef struct {
  const char* file_path;
  int recording_content;  // 4.11 TRTCAudioRecordingContent
  int max_duration_per_file;
} trtc_audio_recording_params_t;

// 5.16
typedef struct {
  const char* file_path;
  int record_type;  // 4.5 TRTCLocalRecordType
  int interval;
  int max_duration_per_file;
} trtc_local_recording_params_t;

// 5.18
typedef struct {
  uint32_t room_id;
  const char* str_room_id;
  const char* user_sig;
  const char* private_map_key;
} trtc_switch_room_config_t;

// 5.19
typedef struct {
  int sample_rate;
  int channel;
  int samples_per_call;
  int mode;  // 3.9 TRTCAudioFrameOperationMode
} trtc_audio_frame_callback_format_t;

// 5.20
typedef struct {
  const char* buffer;
  uint32_t length;
  uint32_t width;
  uint32_t height;
} trtc_image_buffer_t;

// 5.21
typedef struct {
  int type;  // 4.3 TRTCScreenCaptureSourceType
  tx_view source_id;
  const char* source_name;
  trtc_image_buffer_t thumb_bgra;
  trtc_image_buffer_t icon_bgra;
  int is_minimize_window;  // bool -> int
  int is_main_screen;      // bool -> int
  int32_t x;
  int32_t y;
  uint32_t width;
  uint32_t height;
} trtc_screen_capture_source_info_t;

// 5.23
typedef struct {
  int enable_capture_mouse;     // bool -> int
  int enable_high_light;        // bool -> int
  int enable_high_performance;  // bool -> int
  int high_light_color;
  int high_light_width;
  int enable_capture_child_window;  // bool -> int
} trtc_screen_capture_property_t;

// 5.25
typedef struct {
  const char* user_id;
  uint32_t int_room_id;
  const char* str_room_id;
} trtc_user_t;

// 5.26
typedef struct {
  const char* rtmp_url;
  int is_internal_line;  // bool -> int
} trtc_publish_cdn_url_t;

// 5.27
typedef struct {
  int mode;  // 4.12 TRTCPublishMode
  trtc_publish_cdn_url_t* cdn_url_list;
  uint32_t cdn_url_list_size;
  trtc_user_t* mix_stream_identity;
} trtc_publish_target_t;

// 5.28
typedef struct {
  trtc_rect_t rect;
  int z_order;
  int fill_mode;  // 1.4 TRTCVideoFillMode
  uint32_t background_color;
  const char* place_holder_image;
  trtc_user_t* fixed_video_user;
  int fixed_video_stream_type;  // 1.3 TRTCVideoStreamType
} trtc_video_layout_t;

// 5.29
typedef struct {
  const char* watermark_url;
  trtc_rect_t rect;
  int z_order;
} trtc_watermark_t;

// 5.30
typedef struct {
  uint32_t video_encoded_width;
  uint32_t video_encoded_height;
  uint32_t video_encoded_fps;
  uint32_t video_encoded_gop;
  uint32_t video_encoded_kbps;
  uint32_t audio_encoded_sample_rate;
  uint32_t audio_encoded_channel_num;
  uint32_t audio_encoded_kbps;
  uint32_t audio_encoded_codec_type;
  uint32_t video_encoded_codec_type;
  const char* video_sei_params;
} trtc_stream_encoder_param_t;

// 5.31
typedef struct {
  uint32_t background_color;
  const char* background_image;
  trtc_video_layout_t* video_layout_list;
  uint32_t video_layout_list_size;
  trtc_user_t* audio_mix_user_list;
  uint32_t audio_mix_user_list_size;
  trtc_watermark_t* watermark_list;
  uint32_t watermark_list_size;
} trtc_stream_mixing_config_t;

// 5.33
typedef struct {
  uint32_t interval;
  int enable_vad_detection;         // bool -> int
  int enable_pitch_calculation;     // bool -> int
  int enable_spectrum_calculation;  // bool -> int
} trtc_audio_volume_evaluate_params_t;

// new
typedef struct {
  int level;
  int console_enabled;
  int compress_enabled;
  const char* path;
} trtc_log_param_t;

typedef enum {
  log_info = 0,
  log_warning = 1,
  log_error = 2,
  log_fatal = 3,
} trtc_log_write_level;

#endif  // SDK_TRTC_C_TRTC_CLOUD_TYPE_H_  // NOLINT(build/header_guard)
