// Copyright (c) 2023 Tencent. All rights reserved.
// Author: felixyyan

#ifndef API_TRTC_C_TRTCCLOUD_CALLBACK_H_  // NOLINT(build/header_guard)
#define API_TRTC_C_TRTCCLOUD_CALLBACK_H_

#include <stdbool.h>
#include <stdint.h>

#include "trtc_cloud_type.h"

#ifdef __cplusplus
extern "C" {
#endif

// 1.1
typedef void (*trtc_cloud_callback_on_error_handler)(trtc_cloud instance,
                                                     int err_code,
                                                     const char* err_msg,
                                                     void* extra_info,
                                                     const void* user_data);
// 1.2
typedef void (*trtc_cloud_callback_on_warning_handler)(trtc_cloud instance,
                                                       int warning_code,
                                                       const char* warning_msg,
                                                       void* extra_info,
                                                       const void* user_data);
// 2.1
typedef void (*trtc_cloud_callback_on_enter_room_handler)(trtc_cloud instance,
                                                          int result,
                                                          const void* user_data);
// 2.2
typedef void (*trtc_cloud_callback_on_exit_room_handler)(trtc_cloud instance,
                                                         int reason,
                                                         const void* user_data);
// 2.3
typedef void (*trtc_cloud_callback_on_switch_role_handler)(trtc_cloud instance,
                                                           int err_code,
                                                           const char* err_msg,
                                                           const void* user_data);
// 2.4
typedef void (*trtc_cloud_callback_on_switch_room_handler)(trtc_cloud instance,
                                                           int err_code,
                                                           const char* err_msg,
                                                           const void* user_data);
// 2.5
typedef void (*trtc_cloud_callback_on_connect_other_room_handler)(trtc_cloud instance,
                                                                  const char* user_id,
                                                                  int err_code,
                                                                  const char* err_msg,
                                                                  const void* user_data);
// 2.6
typedef void (*trtc_cloud_callback_on_disconnect_other_room_handler)(trtc_cloud instance,
                                                                     int err_code,
                                                                     const char* err_msg,
                                                                     const void* user_data);
// 2.7
typedef void (*trtc_cloud_callback_on_update_other_room_forward_mode_handler)(
    trtc_cloud instance,
    int err_code,
    const char* err_msg,
    const void* user_data);
// 3.1
typedef void (*trtc_cloud_callback_on_remote_user_enter_room_handler)(trtc_cloud instance,
                                                                      const char* user_id,
                                                                      const void* user_data);
// 3.2
typedef void (*trtc_cloud_callback_on_remote_user_leave_room_handler)(trtc_cloud instance,
                                                                      const char* user_id,
                                                                      int reason,
                                                                      const void* user_data);
// 3.3
typedef void (*trtc_cloud_callback_on_user_video_available_handler)(trtc_cloud instance,
                                                                    const char* user_id,
                                                                    bool available,
                                                                    const void* user_data);
// 3.4
typedef void (*trtc_cloud_callback_on_user_sub_stream_available_handler)(trtc_cloud instance,
                                                                         const char* user_id,
                                                                         bool available,
                                                                         const void* user_data);
// 3.5
typedef void (*trtc_cloud_callback_on_user_audio_available_handler)(trtc_cloud instance,
                                                                    const char* user_id,
                                                                    bool available,
                                                                    const void* user_data);
// 3.6
typedef void (*trtc_cloud_callback_on_first_video_frame_handler)(trtc_cloud instance,
                                                                 const char* user_id,
                                                                 const int stream_type,
                                                                 const int width,
                                                                 const int height,
                                                                 const void* user_data);
// 3.7
typedef void (*trtc_cloud_callback_on_first_audio_frame_handler)(trtc_cloud instance,
                                                                 const char* user_id,
                                                                 const void* user_data);

// 3.8
typedef void (*trtc_cloud_callback_on_send_first_local_video_frame_handler)(trtc_cloud instance,
                                                                            int stream_type,
                                                                            const void* user_data);

// 3.9
typedef void (*trtc_cloud_callback_on_send_first_local_audio_frame_handler)(trtc_cloud instance,
                                                                            const void* user_data);
//  3.10
typedef void (*trtc_cloud_callback_on_remote_video_status_updated_handler)(trtc_cloud instance,
                                                                           const char* user_id,
                                                                           int stream_type,
                                                                           int status_type,
                                                                           int change_reason,
                                                                           void* extra_info,
                                                                           const void* user_data);
// 3.11
typedef void (*trtc_cloud_callback_on_remote_audio_status_updated_handler)(trtc_cloud instance,
                                                                           const char* user_id,
                                                                           int status_type,
                                                                           int change_reason,
                                                                           void* extra_info,
                                                                           const void* user_data);
// 3.12
typedef void (*trtc_cloud_callback_on_user_video_size_changed_handler)(trtc_cloud instance,
                                                                       const char* user_id,
                                                                       int stream_type,
                                                                       int new_width,
                                                                       int new_height,
                                                                       const void* user_data);
// 4.1
typedef void (*trtc_cloud_callback_on_network_quality_handler)(trtc_cloud instance,
                                                               const char* local_quality,
                                                               const char* remote_quality,
                                                               const void* user_data);
// 4.2
typedef void (*trtc_cloud_callback_on_statistics_handler)(trtc_cloud instance,
                                                          const char* statistics,
                                                          const void* user_data);
// 4.3
typedef void (*trtc_cloud_callback_on_speed_test_result_handler)(trtc_cloud instance,
                                                                 const char* result,
                                                                 const void* user_data);
// 5.1
typedef void (*trtc_cloud_callback_on_connection_lost_handler)(trtc_cloud instance,
                                                               const void* user_data);
// 5.2
typedef void (*trtc_cloud_callback_on_try_to_reconnect_handler)(trtc_cloud instance,
                                                                const void* user_data);
// 5.3
typedef void (*trtc_cloud_callback_on_connection_recovery_handler)(trtc_cloud instance,
                                                                   const void* user_data);

// 6.1
typedef void (*trtc_cloud_callback_on_camera_did_ready_handler)(trtc_cloud instance,
                                                                const void* user_data);
// 6.2
typedef void (*trtc_cloud_callback_on_mic_did_ready_handler)(trtc_cloud instance,
                                                             const void* user_data);
// 6.3
typedef void (*trtc_cloud_callback_on_audio_route_changed_handler)(trtc_cloud instance,
                                                                   trtc_audio_route new_route,
                                                                   trtc_audio_route old_route,
                                                                   const void* user_data);

// 6.4
typedef void (*trtc_cloud_callback_on_user_voice_volume_handler)(trtc_cloud instance,
                                                                 const char* user_volumes,
                                                                 uint32_t total_volume,
                                                                 const void* user_data);
// 6.5
typedef void (*trtc_cloud_callback_on_device_change_handler)(trtc_cloud instance,
                                                             const char* device_id,
                                                             int devive_type,
                                                             int device_state,
                                                             const void* user_data);
// 6.6
typedef void (*trtc_cloud_callback_on_audio_device_capture_volume_changed_handler)(
    trtc_cloud instance,
    uint32_t volume,
    bool muted,
    const void* user_data);
// 6.7
typedef void (*trtc_cloud_callback_on_audio_device_playout_volume_changed_handler)(
    trtc_cloud instance,
    uint32_t volume,
    bool muted,
    const void* user_data);
// 6.8
typedef void (*trtc_cloud_callback_on_system_audio_loopback_error_handler)(trtc_cloud instance,
                                                                           int err_code,
                                                                           const void* user_data);
// 6.9
typedef void (*trtc_cloud_callback_on_test_mic_volume_handler)(trtc_cloud instance,
                                                               uint32_t volume,
                                                               const void* user_data);

typedef void (*trtc_cloud_callback_on_test_speaker_volume_handler)(trtc_cloud instance,
                                                                   uint32_t volume,
                                                                   const void* user_data);

// 7.1
typedef void (*trtc_cloud_callback_on_recv_custom_cmd_msg_handler)(trtc_cloud instance,
                                                                   const char* user_id,
                                                                   int32_t cmd_id,
                                                                   uint32_t seq,
                                                                   const uint8_t* message,
                                                                   uint32_t message_size,
                                                                   const void* user_data);

// 7.2
typedef void (*trtc_cloud_callback_on_miss_custom_cmd_msg_handler)(trtc_cloud instance,
                                                                   const char* user_id,
                                                                   int32_t cmd_id,
                                                                   int32_t err_code,
                                                                   int32_t missed,
                                                                   const void* user_data);
// 7.3
typedef void (*trtc_cloud_callback_on_recv_sei_msg_handler)(trtc_cloud instance,
                                                            const char* user_id,
                                                            const uint8_t* message,
                                                            uint32_t message_size,
                                                            const void* user_data);

//  8.1
typedef void (*trtc_cloud_callback_on_start_publishing_handler)(trtc_cloud instance,
                                                                int er_code,
                                                                const char* err_msg,
                                                                const void* user_data);
// 8.2
typedef void (*trtc_cloud_callback_on_stop_publishing_handler)(trtc_cloud instance,
                                                               int err_code,
                                                               const char* err_msg,
                                                               const void* user_data);
// 8.5
typedef void (*trtc_cloud_callback_on_set_mix_transcoding_config_handler)(trtc_cloud instance,
                                                                          int err,
                                                                          const char* err_msg,
                                                                          const void* user_data);

// 8.6
typedef void (*trtc_cloud_callback_on_start_publish_media_stream_handler)(trtc_cloud instance,
                                                                          const char* task_id,
                                                                          int code,
                                                                          const char* message,
                                                                          const char* extra_info,
                                                                          const void* user_data);
// 8.7
typedef void (*trtc_cloud_callback_on_update_publish_media_stream_handler)(trtc_cloud instance,
                                                                           const char* task_id,
                                                                           int code,
                                                                           const char* message,
                                                                           const char* extra_info,
                                                                           const void* user_data);
// 8.8
typedef void (*trtc_cloud_callback_on_stop_publish_media_stream_handler)(trtc_cloud instance,
                                                                         const char* task_id,
                                                                         int code,
                                                                         const char* message,
                                                                         const char* extra_info,
                                                                         const void* user_data);
// 8.9
typedef void (*trtc_cloud_callback_on_cdn_stream_state_changed_handler)(trtc_cloud instance,
                                                                        const char* cdn_url,
                                                                        int status,
                                                                        int code,
                                                                        const char* msg,
                                                                        const char* extra_info,
                                                                        const void* user_data);
// 9.1
typedef void (*trtc_cloud_callback_on_screen_capture_started_handler)(trtc_cloud instance,
                                                                      const void* user_data);
// 9.2
typedef void (*trtc_cloud_callback_on_screen_capture_paused_handler)(trtc_cloud instance,
                                                                     int reason,
                                                                     const void* user_data);
// 9.3
typedef void (*trtc_cloud_callback_on_screen_capture_resumed_handler)(trtc_cloud instance,
                                                                      int reason,
                                                                      const void* user_data);
// 9.4
typedef void (*trtc_cloud_callback_on_screen_capture_stoped_handler)(trtc_cloud instance,
                                                                     int reason,
                                                                     const void* user_data);
// 9.5
typedef void (*trtc_cloud_callback_on_screen_capture_covered_handler)(trtc_cloud instance,
                                                                      const void* user_data);

// 10.1
typedef void (*trtc_cloud_callback_on_local_record_begin_handler)(trtc_cloud instance,
                                                                  int err_code,
                                                                  const char* storage_path,
                                                                  const void* user_data);
// 10.2
typedef void (*trtc_cloud_callback_on_local_recording_handler)(trtc_cloud instance,
                                                               int64_t duration,
                                                               const char* storage_path,
                                                               const void* user_data);
// 10.3
typedef void (*trtc_cloud_callback_on_local_record_fragment_handler)(trtc_cloud instance,
                                                                     const char* storage_path,
                                                                     const void* user_data);
// 10.4
typedef void (*trtc_cloud_callback_on_local_record_complete_handler)(trtc_cloud instance,
                                                                     int err_code,
                                                                     const char* storage_path,
                                                                     const void* user_data);
// 10.5
typedef void (*trtc_cloud_callback_on_snapshot_complete_handler)(trtc_cloud instance,
                                                                 const char* user_id,
                                                                 int stream_type,
                                                                 char* data,
                                                                 uint32_t length,
                                                                 uint32_t width,
                                                                 uint32_t height,
                                                                 int pixel_format,
                                                                 const void* user_data);

// main_handler
trtc_c_api void trtc_cloud_set_on_error_handler(trtc_cloud instance,
                                                trtc_cloud_callback_on_error_handler on_error,
                                                const void* user_data);

trtc_c_api void trtc_cloud_set_on_warning_handler(trtc_cloud instance,
                                                  trtc_cloud_callback_on_warning_handler on_warning,
                                                  const void* user_data);

// room_handler
trtc_c_api void trtc_cloud_set_on_enter_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_enter_room_handler on_enter_room,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_exit_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_exit_room_handler on_exit_room,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_switch_role_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_switch_role_handler on_switch_role,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_switch_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_switch_room_handler on_switch_room,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_connect_other_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_connect_other_room_handler on_connect_other_room,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_disconnect_other_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_disconnect_other_room_handler on_disconnect_other_room,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_update_other_room_forward_mode_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_update_other_room_forward_mode_handler on_update_other_room_forward_mode,
    const void* user_data);

// user_handler
trtc_c_api void trtc_cloud_set_on_remote_user_enter_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_remote_user_enter_room_handler on_remote_user_enter_room,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_remote_user_leave_room_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_remote_user_leave_room_handler on_remote_user_leave_room,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_user_video_available_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_user_video_available_handler on_user_video_available,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_user_sub_stream_available_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_user_sub_stream_available_handler on_user_sub_stream_available,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_user_audio_available_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_user_audio_available_handler on_user_audio_available,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_first_video_frame_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_first_video_frame_handler on_first_video_frame,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_first_audio_frame_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_first_audio_frame_handler on_first_audio_frame,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_send_first_local_video_frame_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_send_first_local_video_frame_handler on_send_first_local_video_frame,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_send_first_local_audio_frame_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_send_first_local_audio_frame_handler on_send_first_local_audio_frame,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_remote_video_status_updated_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_remote_video_status_updated_handler on_remote_video_status_updated,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_remote_audio_status_updated_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_remote_audio_status_updated_handler on_remote_audio_status_updated,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_user_video_size_changed_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_user_video_size_changed_handler on_user_video_size_changed,
    const void* user_data);

// net_stat_handler
trtc_c_api void trtc_cloud_set_on_network_quality_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_network_quality_handler on_network_quality,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_statistics_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_statistics_handler on_statistics,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_speed_test_result_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_speed_test_result_handler on_speed_test_result,
    const void* user_data);

// connect_handler
trtc_c_api void trtc_cloud_set_on_connection_lost_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_connection_lost_handler on_connection_lost,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_try_to_reconnect_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_try_to_reconnect_handler on_try_to_reconnect,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_connection_recovery_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_connection_recovery_handler on_connection_recovery,
    const void* user_data);

// hardware_handler
trtc_c_api void trtc_cloud_set_on_camera_did_ready_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_camera_did_ready_handler on_camera_did_ready,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_mic_did_ready_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_mic_did_ready_handler on_mic_did_ready,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_audio_route_changed_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_audio_route_changed_handler on_audio_route_changed,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_user_voice_volume_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_user_voice_volume_handler on_user_voice_volume,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_device_change_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_device_change_handler on_device_change,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_audio_device_capture_volume_changed_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_audio_device_capture_volume_changed_handler
        on_audio_device_capture_volume_changed,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_audio_device_playout_volume_changed_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_audio_device_playout_volume_changed_handler
        on_audio_device_playout_volume_changed,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_system_audio_loopback_error_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_system_audio_loopback_error_handler on_system_audio_loopback_error,
    const void* user_data);

trtc_c_api void trtc_cloud_set_on_test_mic_volume_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_test_mic_volume_handler on_test_mic_volume,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_test_speaker_volume_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_test_speaker_volume_handler on_test_speaker_volume,
    const void* user_data);

// custom_msg_handler
trtc_c_api void trtc_cloud_set_on_recv_custom_cmd_msg_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_recv_custom_cmd_msg_handler on_recv_custom_cmd_msg,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_miss_custom_cmd_msg_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_miss_custom_cmd_msg_handler on_miss_custom_cmd_msg,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_recv_sei_msg_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_recv_sei_msg_handler on_recv_sei_msg,
    const void* user_data);

// cdn_handler
trtc_c_api void trtc_cloud_set_on_start_publishing_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_start_publishing_handler on_start_publishing,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_stop_publishing_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_stop_publishing_handler on_stop_publishing,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_set_mix_transcoding_config_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_set_mix_transcoding_config_handler on_set_mix_transcoding_config,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_start_publish_media_stream_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_start_publish_media_stream_handler on_start_publish_media_stream,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_update_publish_media_stream_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_update_publish_media_stream_handler on_update_publish_media_stream,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_stop_publish_media_stream_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_stop_publish_media_stream_handler on_stop_publish_media_stream,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_cdn_stream_state_changed_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_cdn_stream_state_changed_handler on_cdn_stream_state_changed,
    const void* user_data);

// screen_share_handler
trtc_c_api void trtc_cloud_set_on_screen_capture_started_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_screen_capture_started_handler on_screen_capture_started,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_screen_capture_paused_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_screen_capture_paused_handler on_screen_capture_paused,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_screen_capture_resumed_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_screen_capture_resumed_handler on_screen_capture_resumed,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_screen_capture_stoped_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_screen_capture_stoped_handler on_screen_capture_stoped,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_screen_capture_covered_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_screen_capture_covered_handler on_screen_capture_covered,
    const void* user_data);

// local_record_snapshot_handler
trtc_c_api void trtc_cloud_set_on_local_record_begin_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_local_record_begin_handler on_local_record_begin,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_local_recording_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_local_recording_handler on_local_recording,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_local_record_fragment_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_local_record_fragment_handler on_local_record_fragment,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_local_record_complete_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_local_record_complete_handler on_local_complete,
    const void* user_data);
trtc_c_api void trtc_cloud_set_on_snapshot_complete_handler(
    trtc_cloud instance,
    trtc_cloud_callback_on_snapshot_complete_handler on_snapshot_complete,
    const void* user_data);

trtc_c_api trtc_cloud_callback trtc_cloud_create_cloud_callback(trtc_cloud instance);

trtc_c_api void trtc_cloud_reset_all_handler(trtc_cloud instance);

trtc_c_api void trtc_cloud_destroy_cloud_callback(trtc_cloud_callback callback);

// VideoRender - 1
typedef void (*trtc_video_render_callback_on_render_video_frame_handler)(trtc_cloud instance,
                                                                         const char* user_id,
                                                                         int stream_type,
                                                                         trtc_video_frame_t* frame);

trtc_c_api trtc_video_render_callback trtc_cloud_create_video_render_callback(
    trtc_cloud instance,
    trtc_video_render_callback_on_render_video_frame_handler on_render_video_frame);

trtc_c_api void trtc_cloud_reset_video_render_callback(trtc_video_render_callback callback);

trtc_c_api void trtc_cloud_destroy_video_render_callback(trtc_video_render_callback callback);

// VideoFrame - 1
typedef void (*trtc_video_frame_callback_on_gl_context_created_handler)(trtc_cloud instance);

// VideoFrame - 2
typedef int (*trtc_video_frame_callback_on_process_video_frame_handler)(
    trtc_cloud instance,
    trtc_video_frame_t* src_frame,
    trtc_video_frame_t* dst_frame);

// VideoFrame - 3
typedef void (*trtc_video_frame_callback_on_gl_context_destroy_handler)(trtc_cloud instance);

trtc_c_api trtc_video_frame_callback trtc_cloud_create_video_frame_callback(
    trtc_cloud instance,
    trtc_video_frame_callback_on_gl_context_created_handler on_gl_context_created,
    trtc_video_frame_callback_on_process_video_frame_handler on_process_video_frame,
    trtc_video_frame_callback_on_gl_context_destroy_handler on_gl_context_destroy);

trtc_c_api void trtc_cloud_reset_video_frame_callback(trtc_video_frame_callback callback);

trtc_c_api void trtc_cloud_destroy_video_frame_callback(trtc_video_frame_callback callback);

// AudioFrame - 1
typedef void (*trtc_audio_frame_callback_on_captured_audio_frame_handler)(
    trtc_cloud instance,
    trtc_audio_frame_t* frame);

// AudioFrame - 2
typedef void (*trtc_audio_frame_callback_on_local_processed_audio_frame_handler)(
    trtc_cloud instance,
    trtc_audio_frame_t* frame);

// AudioFrame - 3
typedef void (*trtc_audio_frame_callback_on_play_audio_frame_handler)(trtc_cloud instance,
                                                                      trtc_audio_frame_t* frame,
                                                                      const char* user_id);
// AudioFrame - 4
typedef void (*trtc_audio_frame_callback_on_mixed_play_audio_frame_handler)(
    trtc_cloud instance,
    trtc_audio_frame_t* frame);
// AudioFrame - 5
typedef void (*trtc_audio_frame_callback_on_mixed_all_audio_frame_handler)(
    trtc_cloud instance,
    trtc_audio_frame_t* frame);

trtc_c_api trtc_audio_frame_callback trtc_cloud_create_audio_frame_callback(
    trtc_cloud instance,
    trtc_audio_frame_callback_on_captured_audio_frame_handler on_captured_audio_frame,
    trtc_audio_frame_callback_on_local_processed_audio_frame_handler on_local_processed_audio_frame,
    trtc_audio_frame_callback_on_play_audio_frame_handler on_play_audio_frame,
    trtc_audio_frame_callback_on_mixed_play_audio_frame_handler on_mixed_play_audio_frame,
    trtc_audio_frame_callback_on_mixed_all_audio_frame_handler on_mixed_all_audio_frame);

trtc_c_api void trtc_cloud_reset_audio_frame_callback(trtc_audio_frame_callback callback);

trtc_c_api void trtc_cloud_destroy_audio_frame_callback(trtc_audio_frame_callback callback);

// Log - 1
typedef void (*trtc_log_callback_on_log_handler)(trtc_cloud instance,
                                                 const char* log,
                                                 int log_level,
                                                 const char* modle);

trtc_c_api trtc_log_callback
trtc_cloud_create_log_callback(trtc_cloud instance, trtc_log_callback_on_log_handler on_log);

trtc_c_api void trtc_cloud_reset_log_callback(trtc_log_callback callback);

trtc_c_api void trtc_cloud_destroy_log_callback(trtc_log_callback callback);

#ifdef __cplusplus
}
#endif

#endif  // API_TRTC_C_TRTCCLOUD_CALLBACK_H_  // NOLINT(build/header_guard)
