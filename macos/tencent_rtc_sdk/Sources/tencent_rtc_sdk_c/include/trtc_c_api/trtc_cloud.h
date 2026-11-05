// Copyright (c) 2023 Tencent. All rights reserved.
// Author: felixyyan

#ifndef SDK_TRTC_C_TRTC_CLOUD_H_
#define SDK_TRTC_C_TRTC_CLOUD_H_

#include <stdbool.h>
#include <stdint.h>

#include "trtc_cloud_type.h"
#include "tx_audio_effect_manager.h"
#include "tx_device_manager.h"

#ifdef __cplusplus
extern "C" {
#endif

// 1.1
trtc_c_api trtc_cloud trtc_cloud_get_instance(void* context);

// 1.2
trtc_c_api int trtc_cloud_destroy_instance(trtc_cloud instance);

// 2.1
trtc_c_api int trtc_cloud_enter_room(trtc_cloud instance, trtc_params_t param, int scene);

// 2.2
trtc_c_api int trtc_cloud_exit_room(trtc_cloud instance);

// 2.3
trtc_c_api int trtc_cloud_switch_role(trtc_cloud instance, int role);

// 2.5
trtc_c_api int trtc_cloud_switch_room(trtc_cloud instance, trtc_switch_room_config_t config);

// 2.6
trtc_c_api int trtc_cloud_connect_other_room(trtc_cloud instance, const char* json_params);

// 2.7
trtc_c_api int trtc_cloud_disconnect_other_room(trtc_cloud instance);

// 2.8
trtc_c_api int trtc_cloud_set_default_stream_recv_mode(trtc_cloud instance,
                                                       bool auto_recv_audio,
                                                       bool auto_recv_video);

// 2.9
trtc_c_api trtc_cloud trtc_cloud_create_sub_cloud(trtc_cloud instance);

// 2.10
trtc_c_api int trtc_cloud_destroy_sub_cloud(trtc_cloud instance, trtc_cloud sub_cloud);

// 2.11
trtc_c_api int trtc_cloud_update_other_room_forward_mode(trtc_cloud instance,
                                                         const char* json_params);

// 3.1
trtc_c_api int trtc_cloud_start_publishing(trtc_cloud instance,
                                           const char* stream_id,
                                           int stream_type);

// 3.2
trtc_c_api int trtc_cloud_stop_publishing(trtc_cloud instance);

// 3.5
trtc_c_api int trtc_cloud_set_mix_transcoding_config(trtc_cloud instance,
                                                     trtc_transcoding_config_t* config);

// 3.6
trtc_c_api int trtc_cloud_start_publish_media_stream(trtc_cloud instance,
                                                     trtc_publish_target_t* target,
                                                     trtc_stream_encoder_param_t* params,
                                                     trtc_stream_mixing_config_t* config);

// 3.7
trtc_c_api int trtc_cloud_update_publish_media_stream(trtc_cloud instance,
                                                      const char* task_id,
                                                      trtc_publish_target_t* target,
                                                      trtc_stream_encoder_param_t* params,
                                                      trtc_stream_mixing_config_t* config);

// 3.8
trtc_c_api int trtc_cloud_stop_publish_media_stream(trtc_cloud instance, const char* taskId);

// 4.1 4.2  front_camera
trtc_c_api int trtc_cloud_start_local_preview(trtc_cloud instance, bool front_camera, tx_view view);

// 4.3
trtc_c_api int trtc_cloud_update_local_view(trtc_cloud instance, tx_view view);

// 4.4
trtc_c_api int trtc_cloud_stop_local_preview(trtc_cloud instance);

// 4.5
trtc_c_api int trtc_cloud_mute_local_video(trtc_cloud instance, int stream_type, bool mute);

// 4.6
trtc_c_api int trtc_cloud_set_video_mute_image(trtc_cloud instance,
                                               trtc_image_buffer_t* image,
                                               int fps);

// 4.7
trtc_c_api int trtc_cloud_start_remote_view(trtc_cloud instance,
                                            const char* user_id,
                                            int stream_type,
                                            tx_view view);

// 4.8
trtc_c_api int trtc_cloud_update_remote_view(trtc_cloud instance,
                                             const char* user_id,
                                             int stream_type,
                                             tx_view view);

// 4.9
trtc_c_api int trtc_cloud_stop_remote_view(trtc_cloud instance,
                                           const char* user_id,
                                           int stream_type);

// 4.10
trtc_c_api int trtc_cloud_stop_all_remote_view(trtc_cloud instance);

// 4.12
trtc_c_api int trtc_cloud_mute_all_remote_video_streams(trtc_cloud instance, bool mute);

// 4.13
trtc_c_api int trtc_cloud_set_video_encoder_param(trtc_cloud instance,
                                                  trtc_video_enc_param_t param);

// 4.14
trtc_c_api int trtc_cloud_set_network_qos_param(trtc_cloud instance,
                                                trtc_network_qos_param_t param);

// 4.15
trtc_c_api int trtc_cloud_set_local_render_params(trtc_cloud instance,
                                                  int video_rotation,
                                                  int fill_mode,
                                                  int mirror_type);

// 4.16
trtc_c_api int trtc_cloud_set_remote_render_params(trtc_cloud instance,
                                                   const char* user_id,
                                                   int stream_type,
                                                   trtc_render_params_t param);

// 4.17
trtc_c_api int trtc_cloud_set_video_encoder_rotation(trtc_cloud instance, int rotation);

// 4.18
trtc_c_api int trtc_cloud_set_video_encoder_mirror(trtc_cloud instance, bool mirror);

// 4.20
trtc_c_api int trtc_cloud_enable_small_video_stream(trtc_cloud instance,
                                                    bool enable,
                                                    trtc_video_enc_param_t param);

// 4.21
trtc_c_api int trtc_cloud_set_remote_video_stream_type(trtc_cloud instance,
                                                       const char* user_id,
                                                       int type);

// 4.22
trtc_c_api int trtc_cloud_mute_remote_video_stream(trtc_cloud instance,
                                                   const char* user_id,
                                                   int stream_type,
                                                   bool mute);

// 4.23
trtc_c_api int trtc_cloud_snapshot_video(trtc_cloud instance,
                                         const char* user_id,
                                         int stream_type,
                                         int source_type);

// 5.1
trtc_c_api int trtc_cloud_start_local_audio(trtc_cloud instance, int quality);

// 5.2
trtc_c_api int trtc_cloud_stop_local_audio(trtc_cloud instance);

// 5.3
trtc_c_api int trtc_cloud_mute_local_audio(trtc_cloud instance, bool mute);

// 5.4
trtc_c_api int trtc_cloud_mute_remote_audio(trtc_cloud instance, const char* user_id, bool mute);

// 5.5
trtc_c_api int trtc_cloud_mute_all_remote_audio(trtc_cloud instance, bool mute);

// 5.7
trtc_c_api int trtc_cloud_set_remote_audio_volume(trtc_cloud instance,
                                                  const char* user_id,
                                                  int volume);

// 5.8
trtc_c_api int trtc_cloud_set_audio_capture_volume(trtc_cloud instance, int volume);

// 5.9
trtc_c_api int trtc_cloud_get_audio_capture_volume(trtc_cloud instance);

// 5.10
trtc_c_api int trtc_cloud_set_audio_playout_volume(trtc_cloud instance, int volume);

// 5.11
trtc_c_api int trtc_cloud_get_audio_playout_volume(trtc_cloud instance);

// 5.12
trtc_c_api int trtc_cloud_enable_audio_volume_evaluation(
    trtc_cloud instance,
    bool enable,
    trtc_audio_volume_evaluate_params_t params);

// 5.15
trtc_c_api int trtc_cloud_start_local_recording(trtc_cloud instance,
                                                trtc_local_recording_params_t params);

// 5.16
trtc_c_api int trtc_cloud_stop_local_recording(trtc_cloud instance);

// 5.17
trtc_c_api int trtc_cloud_set_gravity_sensor_adaptive_mode(trtc_cloud instance, int mode);

// 6.1
trtc_c_api tx_device_manager trtc_cloud_get_device_manager(trtc_cloud instance);

// 7.1
trtc_c_api int trtc_cloud_set_beauty_style(trtc_cloud instance,
                                           int style,
                                           uint32_t beauty,
                                           uint32_t white,
                                           uint32_t ruddiness);

// 7.2
trtc_c_api int trtc_cloud_set_water_mark(trtc_cloud instance,
                                         int stream_type,
                                         const char* src_data,
                                         int src_type,
                                         uint32_t width,
                                         uint32_t height,
                                         float x_offset,
                                         float y_offset,
                                         float f_width_ratio,
                                         bool is_visible_on_local_preview);

// 8.1
trtc_c_api tx_audio_effect_manager trtc_cloud_get_audio_effect_manager(trtc_cloud instance);

// 8.2 TARGET_PLATFORM_DESKTOP || __ANDROID__
trtc_c_api int trtc_cloud_start_system_audio_loopback(trtc_cloud instance, const char* device_name);

// 8.3 TARGET_PLATFORM_DESKTOP || __ANDROID__
trtc_c_api int trtc_cloud_stop_system_audio_loopback(trtc_cloud instance);

// 8.4
trtc_c_api int trtc_cloud_set_system_audio_loopback_volume(trtc_cloud instance, uint32_t volume);

// 9.1
trtc_c_api int trtc_cloud_start_screen_capture(trtc_cloud instance,
                                               tx_view view,
                                               int type,
                                               trtc_video_enc_param_t* param);

// 9.2
trtc_c_api int trtc_cloud_stop_screen_capture(trtc_cloud instance);

// 9.3
trtc_c_api int trtc_cloud_pause_screen_capture(trtc_cloud instance);

// 9.4
trtc_c_api int trtc_cloud_resume_screen_capture(trtc_cloud instance);

// 9.5 TARGET_PLATFORM_DESKTOP
trtc_c_api int trtc_cloud_get_screen_capture_source_list(
    trtc_cloud instance,
    trtc_size_t thumbnail,
    trtc_size_t icon,
    trtc_screen_capture_source_list* source_list,
    int* count);

trtc_c_api int trtc_cloud_get_screen_capture_sources_info(
    trtc_screen_capture_source_list source_list,
    int index,
    trtc_screen_capture_source_info_t* source_info);

trtc_c_api void trtc_cloud_release_screen_capture_sources_list(
    trtc_screen_capture_source_list source_list);

// 9.6 TARGET_PLATFORM_DESKTOP
trtc_c_api int trtc_cloud_select_screen_capture_target(trtc_cloud instance,
                                                       trtc_screen_capture_source_info_t source,
                                                       trtc_rect_t capture_rect,
                                                       trtc_screen_capture_property_t property);

// 9.7
trtc_c_api int trtc_cloud_set_sub_stream_encoder_param(trtc_cloud instance,
                                                       int video_resolution,
                                                       int res_mode,
                                                       uint32_t video_fps,
                                                       uint32_t video_bitrate,
                                                       uint32_t min_video_bitrate,
                                                       bool enable_adjust_res);

// 9.8
trtc_c_api int trtc_cloud_set_sub_stream_mix_volume(trtc_cloud instance, uint32_t volume);

// 9.9
trtc_c_api int trtc_cloud_add_excluded_share_window(trtc_cloud instance, tx_view window_id);

// 9.10
trtc_c_api int trtc_cloud_remove_excluded_share_window(trtc_cloud instance, tx_view window_id);

// 9.11
trtc_c_api int trtc_cloud_remove_all_excluded_share_windows(trtc_cloud instance);

// 9.12
trtc_c_api int trtc_cloud_add_included_share_window(trtc_cloud instance, tx_view window_id);

// 9.13
trtc_c_api int trtc_cloud_remove_included_share_window(trtc_cloud instance, tx_view window_id);

// 9.14
trtc_c_api int trtc_cloud_remove_all_included_share_windows(trtc_cloud instance);

// 10.1
trtc_c_api int trtc_cloud_enable_custom_video_capture(trtc_cloud instance,
                                                      int stream_ype,
                                                      bool enable);

// 10.2
trtc_c_api int trtc_cloud_send_custom_video_data(trtc_cloud instance,
                                                 int stream_type,
                                                 trtc_video_frame_t frame);

// 10.3
trtc_c_api int trtc_cloud_enable_custom_audio_capture(trtc_cloud instance, bool enable);

// 10.4
trtc_c_api int trtc_cloud_send_custom_audio_data(trtc_cloud instance, trtc_audio_frame_t frame);

// 10.5
trtc_c_api int trtc_cloud_enable_mix_external_audio_frame(trtc_cloud instance,
                                                          bool enable_publish,
                                                          bool enable_playout);

// 10.8
trtc_c_api uint64_t trtc_cloud_generate_custom_pts(trtc_cloud instance);

// 10.9.1
trtc_c_api int trtc_cloud_enable_local_video_custom_process(trtc_cloud instance,
                                                            bool enable,
                                                            int pixel_format,
                                                            int buffer_type);

// 10.9.2
trtc_c_api int trtc_cloud_set_local_video_custom_process_callback(
    trtc_cloud instance,
    trtc_video_frame_callback callback);

// 10.10
trtc_c_api int trtc_cloud_set_local_video_render_callback(trtc_cloud instance,
                                                          int pixel_format,
                                                          int buffer_type,
                                                          trtc_video_frame_callback callback);
// 10.11
trtc_c_api int trtc_cloud_set_remote_video_render_callback(trtc_cloud instance,
                                                           const char* user_id,
                                                           int pixel_format,
                                                           int buffer_type,
                                                           trtc_video_render_callback callback);

// 10.12
trtc_c_api int trtc_cloud_set_audio_frame_callback(trtc_cloud instance,
                                                   trtc_audio_frame_callback callback);

// 10.13
trtc_c_api int trtc_cloud_set_captured_audio_frame_callback_format(
    trtc_cloud instance,
    trtc_audio_frame_callback_format_t format);

// 10.14
trtc_c_api int trtc_cloud_set_local_processed_audio_frame_callback_format(
    trtc_cloud instance,
    trtc_audio_frame_callback_format_t format);

// 10.15
trtc_c_api int trtc_cloud_set_mixed_play_audio_frame_callback_format(
    trtc_cloud instance,
    trtc_audio_frame_callback_format_t format);

// 11.1
trtc_c_api int trtc_cloud_send_sustom_cmd_msg(trtc_cloud instance,
                                              int cmd_id,
                                              const uint8_t* data,
                                              int data_size,
                                              bool reliable,
                                              bool ordered);

// 11.2
trtc_c_api int trtc_cloud_send_sei_msg(trtc_cloud instance,
                                       const uint8_t* data,
                                       int data_size,
                                       int repeat_count);

// 12.1
trtc_c_api int trtc_cloud_start_speed_test(trtc_cloud instance, trtc_speed_test_params_t params);

// 12.2
trtc_c_api int trtc_cloud_stop_speed_test(trtc_cloud instance);

// 13.1
trtc_c_api const char* trtc_cloud_get_sdk_version(trtc_cloud instance);

// 13.2 - 13.5
trtc_c_api int trtc_cloud_set_log_param(trtc_cloud instance, trtc_log_param_t param);

// 13.6
trtc_c_api int trtc_cloud_set_log_callback(trtc_cloud instance, trtc_log_callback callback);

// 13.7
trtc_c_api int trtc_cloud_show_debug_view(trtc_cloud instance, int show_type);

// 13.9
trtc_c_api const char* trtc_cloud_call_experimental_api(trtc_cloud instance, const char* json_str);

trtc_c_api void* trtc_cloud_copy_native_memery(void* dst, void* src, int size);

trtc_c_api void trtc_cloud_write_log(trtc_log_write_level log_write_level,
                                     const char* log_file_line,
                                     const char* log_tag,
                                     const char* log_message);

#ifdef __cplusplus
}
#endif

#endif  // SDK_TRTC_C_TRTC_CLOUD_H_
