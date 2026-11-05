// Copyright (c) 2025 Tencent. All rights reserved.
// Author: carolsuo

#ifndef SDK_LIVE_C_V2TX_LIVE_PUSHER_H_  // NOLINT(build/header_guard)
#define SDK_LIVE_C_V2TX_LIVE_PUSHER_H_

#include "tx_audio_effect_manager.h"
#include "tx_device_manager.h"
#include "v2tx_live_def.h"

#ifdef __cplusplus
extern "C" {
#endif

v2tx_live_c_api v2tx_live_pusher create_v2tx_live_pusher(v2tx_live_mode_e mode);
v2tx_live_c_api void release_v2tx_live_pusher(v2tx_live_pusher instance);

v2tx_live_c_api int32_t v2tx_live_pusher_set_render_view(v2tx_live_pusher instance, void* view);
v2tx_live_c_api int32_t v2tx_live_pusher_set_render_mirror(v2tx_live_pusher instance,
                                                           v2tx_live_mirror_type_e mirror_type);
v2tx_live_c_api int32_t v2tx_live_pusher_set_encoder_mirror(v2tx_live_pusher instance, bool mirror);
v2tx_live_c_api int32_t v2tx_live_pusher_set_render_rotation(v2tx_live_pusher instance,
                                                             v2tx_live_rotation_e rotation);
v2tx_live_c_api int32_t v2tx_live_pusher_set_render_fill_mode(v2tx_live_pusher instance,
                                                              v2tx_live_fill_mode_e mode);

v2tx_live_c_api int32_t v2tx_live_pusher_start_camera(v2tx_live_pusher instance, bool front_camera);
v2tx_live_c_api int32_t v2tx_live_pusher_stop_camera(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_start_microphone(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_stop_microphone(v2tx_live_pusher instance);

v2tx_live_c_api int32_t v2tx_live_pusher_start_virtual_camera(v2tx_live_pusher instance,
                                                              const v2tx_live_image_t* image);
v2tx_live_c_api int32_t v2tx_live_pusher_stop_virtual_camera(v2tx_live_pusher instance);

v2tx_live_c_api int32_t v2tx_live_pusher_pause_audio(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_resume_audio(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_pause_video(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_resume_video(v2tx_live_pusher instance);

v2tx_live_c_api int32_t v2tx_live_pusher_start_push(v2tx_live_pusher instance, const char* url);
v2tx_live_c_api int32_t v2tx_live_pusher_stop_push(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_is_pushing(v2tx_live_pusher instance);

v2tx_live_c_api int32_t v2tx_live_pusher_set_audio_quality(v2tx_live_pusher instance,
                                                           v2tx_live_audio_quality_e quality);
v2tx_live_c_api int32_t
v2tx_live_pusher_set_video_quality(v2tx_live_pusher instance,
                                   const v2tx_live_video_encoder_param_t* param);
v2tx_live_c_api tx_audio_effect_manager
v2tx_live_pusher_get_audio_effect_manager(v2tx_live_pusher instance);
v2tx_live_c_api tx_device_manager v2tx_live_pusher_get_device_manager(v2tx_live_pusher instance);
v2tx_live_c_api void v2tx_live_pusher_set_beauty_style(v2tx_live_pusher instance,
                                                       v2tx_live_beauty_style_e style,
                                                       uint32_t beauty,
                                                       uint32_t white,
                                                       uint32_t ruddiness);
v2tx_live_c_api int32_t v2tx_live_pusher_enable_sharpness_enhancement(v2tx_live_pusher instance,
                                                                      bool enable);
v2tx_live_c_api int32_t v2tx_live_pusher_set_lut_color_filter(v2tx_live_pusher instance,
                                                              const char *file_path);
v2tx_live_c_api int32_t v2tx_live_pusher_set_lut_color_filter_strength(v2tx_live_pusher instance,
                                                                       float strength);

v2tx_live_c_api int32_t v2tx_live_pusher_snapshot(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_set_watermark(v2tx_live_pusher instance,
                                                       const char* watermark_path,
                                                       float x,
                                                       float y,
                                                       float scale);

v2tx_live_c_api int32_t v2tx_live_pusher_enable_volume_evaluation(v2tx_live_pusher instance,
                                                                  int32_t interval_ms);

v2tx_live_c_api int32_t
v2tx_live_pusher_enable_custom_video_render(v2tx_live_pusher instance,
                                            bool enable,
                                            v2tx_live_pixel_format_e pixel_format,
                                            v2tx_live_buffer_type_e buffer_type);
v2tx_live_c_api int32_t
v2tx_live_pusher_enable_custom_video_process(v2tx_live_pusher instance,
                                             bool enable,
                                             v2tx_live_pixel_format_e pixel_format,
                                             v2tx_live_buffer_type_e buffer_type);
v2tx_live_c_api int32_t v2tx_live_pusher_enable_custom_video_capture(v2tx_live_pusher instance,
                                                                     bool enable);
v2tx_live_c_api int32_t
v2tx_live_pusher_send_custom_video_frame(v2tx_live_pusher instance,
                                         const v2tx_live_video_frame_t* video_frame);
v2tx_live_c_api int32_t v2tx_live_pusher_enable_custom_audio_capture(v2tx_live_pusher instance,
                                                                     bool enable);
v2tx_live_c_api int32_t
v2tx_live_pusher_send_custom_audio_frame(v2tx_live_pusher instance,
                                         const v2tx_live_audio_frame_t* audio_frame);

v2tx_live_c_api int32_t v2tx_live_pusher_send_sei_message(v2tx_live_pusher instance,
                                                          int payload_type,
                                                          const uint8_t* data,
                                                          uint32_t data_size);

                                                          v2tx_live_c_api int32_t
v2tx_live_pusher_start_system_audio_loopback(v2tx_live_pusher instance,
                                             const char* device_name);
v2tx_live_c_api int32_t v2tx_live_pusher_stop_system_audio_loopback(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_set_system_audio_loopback_volume(v2tx_live_pusher instance,
                                                                          uint32_t volume);

v2tx_live_c_api int32_t v2tx_live_pusher_start_screen_capture(v2tx_live_pusher instance);
v2tx_live_c_api int32_t v2tx_live_pusher_stop_screen_capture(v2tx_live_pusher instance);

v2tx_live_c_api void v2tx_live_pusher_show_debug_view(v2tx_live_pusher instance, bool is_show);
v2tx_live_c_api int32_t v2tx_live_pusher_set_property(v2tx_live_pusher instance,
                                                      const char* key,
                                                      const void* value);
v2tx_live_c_api const char* v2tx_live_pusher_get_property(v2tx_live_pusher instance,
                                                          const char* key);

v2tx_live_c_api int32_t
v2tx_live_pusher_set_mix_transcoding_config(v2tx_live_pusher instance,
                                            const v2tx_live_transcoding_config_t* config);

#ifdef __cplusplus
}
#endif

#endif  // SDK_LIVE_C_V2TX_LIVE_PUSHER_H_  // NOLINT(build/header_guard)
