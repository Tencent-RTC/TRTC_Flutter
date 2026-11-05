// Copyright (c) 2023 Tencent. All rights reserved.
// Author: bluedang

#ifndef SDK_API_LIVE_C_V2TX_LIVE_TYPE_H_  // NOLINT(build/header_guard)
#define SDK_API_LIVE_C_V2TX_LIVE_TYPE_H_

#include <stdint.h>

#ifndef v2tx_live_c_api
#ifdef _WIN32
#include <windows.h>
#ifdef v2tx_live_exports
#define v2tx_live_c_api __declspec(dllexport)
#else
#define v2tx_live_c_api __declspec(dllimport)
#endif
#elif __APPLE__
#include <TargetConditionals.h>
#define v2tx_live_c_api __attribute__((visibility("default")))
#elif __ANDROID__ || __linux__
#define v2tx_live_c_api __attribute__((visibility("default")))
#else
#define v2tx_live_c_api
#endif
#endif

typedef void* v2tx_live_player;
typedef void* v2tx_live_pusher;

typedef enum {
  v2tx_live_mode_rtmp,
  v2tx_live_mode_rtc,
} v2tx_live_mode_e;

typedef enum {
  v2tx_live_video_resolution_160x160,
  v2tx_live_video_resolution_270x270,
  v2tx_live_video_resolution_480x480,
  v2tx_live_video_resolution_320x240,
  v2tx_live_video_resolution_480x360,
  v2tx_live_video_resolution_640x480,
  v2tx_live_video_resolution_320x180,
  v2tx_live_video_resolution_480x270,
  v2tx_live_video_resolution_640x360,
  v2tx_live_video_resolution_960x540,
  v2tx_live_video_resolution_1280x720,
  v2tx_live_video_resolution_1920x1080,
} v2tx_live_video_resolution_e;

typedef enum {
  v2tx_live_video_resolution_mode_landscape,
  v2tx_live_video_resolution_mode_portrait,
} v2tx_live_video_resolution_mode_e;

typedef struct {
  v2tx_live_video_resolution_e video_resolution;
  v2tx_live_video_resolution_mode_e video_resolution_mode;
  uint32_t video_fps;
  uint32_t video_bitrate;
  uint32_t min_video_bitrate;
} v2tx_live_video_encoder_param_t;

typedef enum {
  v2tx_live_mirror_type_auto,
  v2tx_live_mirror_type_enable,
  v2tx_live_mirror_type_disable,
} v2tx_live_mirror_type_e;

typedef enum {
  v2tx_live_rotation0,
  v2tx_live_rotation90,
  v2tx_live_rotation180,
  v2tx_live_rotation270,
} v2tx_live_rotation_e;

typedef enum {
  v2tx_live_fill_mode_fill,
  v2tx_live_fill_mode_fit,
  v2tx_live_fill_mode_scale_fill,
} v2tx_live_fill_mode_e;

typedef enum {
  v2tx_live_pixel_format_unknown,
  v2tx_live_pixel_format_i420,
  v2tx_live_pixel_format_bgra32,
  v2tx_live_pixel_format_rgba32,
} v2tx_live_pixel_format_e;

typedef enum {
  v2tx_live_buffer_type_unknown,
  v2tx_live_buffer_type_byte_buffer,
} v2tx_live_buffer_type_e;

typedef enum {
  v2tx_live_beauty_style_smooth,
  v2tx_live_beauty_style_nature,
} v2tx_live_beauty_style_e;

typedef struct {
  v2tx_live_pixel_format_e pixel_format;
  v2tx_live_buffer_type_e buffer_type;
  char* data;
  int32_t length;
  int32_t width;
  int32_t height;
  v2tx_live_rotation_e rotation;
} v2tx_live_video_frame_t;

typedef enum {
  v2tx_live_audio_quality_speech,
  v2tx_live_audio_quality_default,
  v2tx_live_audio_quality_music,
} v2tx_live_audio_quality_e;

typedef struct {
  char* data;
  uint32_t length;
  uint32_t sampleRate;
  uint32_t channel;
} v2tx_live_audio_frame_t;

typedef struct {
  int32_t app_cpu;
  int32_t system_cpu;
  int32_t width;
  int32_t height;
  int32_t fps;
  int32_t video_bitrate;
  int32_t audio_bitrate;
  int32_t rtt;
  int32_t net_speed;
} v2tx_live_pusher_statistics_t;

typedef struct {
  int32_t app_cpu;
  int32_t system_cpu;
  int32_t width;
  int32_t height;
  int32_t fps;
  int32_t video_bitrate;
  int32_t audio_bitrate;
  int32_t audio_packet_loss;
  int32_t video_packet_loss;
  int32_t jitter_buffer_delay;
  int32_t audio_total_block_time;
  int32_t audio_block_rate;
  int32_t video_total_block_time;
  int32_t video_block_rate;
  int32_t rtt;
  int32_t net_speed;
} v2tx_live_player_statistics_t;

typedef enum {
  v2tx_live_pusher_status_disconnected,
  v2tx_live_pusher_status_connecting,
  v2tx_live_pusher_status_connect_success,
  v2tx_live_pusher_status_reconnecting,
} v2tx_live_pusher_status_e;

typedef enum {
  v2tx_live_mix_input_type_audio_video,
  v2tx_live_mix_input_type_pure_video,
  v2tx_live_mix_input_type_pure_audio
} v2tx_live_mix_input_type_e;

typedef struct {
  const char* user_id;
  const char* stream_id;
  uint32_t x;
  uint32_t y;
  uint32_t width;
  uint32_t height;
  uint32_t z_order;
  v2tx_live_mix_input_type_e input_type;
} v2tx_live_mix_stream_t;

typedef struct {
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
  v2tx_live_mix_stream_t* mix_streams_array;
  uint32_t mix_stream_size;
  const char* output_stream_id;
} v2tx_live_transcoding_config_t;

typedef enum {
  v2tx_live_log_level_all,
  v2tx_live_log_level_debug,
  v2tx_live_log_level_info,
  v2tx_live_log_level_warning,
  v2tx_live_log_level_error,
  v2tx_live_log_level_fatal,
  v2tx_live_log_level_null,
} v2tx_live_log_level_e;

typedef struct {
  v2tx_live_log_level_e log_level;
  int enable_observer;
  int enable_console;
  int enable_log_file;
  const char* log_path;
} v2tx_live_log_config_t;

typedef enum {
  v2tx_live_image_type_file,
  v2tx_live_image_type_bgra32,
  v2tx_live_image_type_rgba32,
} v2tx_live_image_type_e;

typedef struct {
  const char* image_src;
  v2tx_live_image_type_e image_type;
  uint32_t image_width;
  uint32_t image_height;
  uint32_t image_length;
} v2tx_live_image_t;

#endif  // SDK_API_LIVE_C_V2TX_LIVE_TYPE_H_  // NOLINT(build/header_guard)
