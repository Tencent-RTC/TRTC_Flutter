// Copyright (c) 2023 Tencent. All rights reserved.
// Author: felixyyan

#ifndef API_TX_C_DEVICEMANAGER_H_  // NOLINT(build/header_guard)
#define API_TX_C_DEVICEMANAGER_H_

#include <stdint.h>

#ifdef _WIN32
#include <windows.h>
#ifdef liteav_c_exports
#define liteav_c_api __declspec(dllexport)
#else
#define liteav_c_api __declspec(dllimport)
#endif
#elif __APPLE__
#include <TargetConditionals.h>
#define liteav_c_api __attribute__((visibility("default")))
#elif __ANDROID__ || __linux__
#define liteav_c_api __attribute__((visibility("default")))
#else
#define liteav_c_api
#endif

#ifndef tx_view
#ifdef _WIN32
typedef HWND tx_view;
#else
typedef void* tx_view;
#endif
#endif

typedef void* tx_device_manager;
typedef void* tx_device_observer;
typedef void* tx_video_render_callback;

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  tx_system_volume_type_auto = 0,
  tx_system_volume_type_media = 1,
  tx_system_volume_type_voip = 2
} tx_system_volume_type_e;

typedef enum {
  tx_audio_route_speakerphone = 0,
  tx_audio_route_earpiece = 1,
} tx_audio_route_e;

typedef enum {
  tx_media_device_type_unknown = -1,
  tx_media_device_type_mic = 0,
  tx_media_device_type_speaker = 1,
  tx_media_device_type_camera = 2,
} tx_media_device_type_e;

typedef enum {
  tx_camera_resolution_strategy_auto = 0,
  tx_camera_resolution_strategy_performance = 1,
  tx_camera_resolution_strategy_high_quality = 2,
  tx_camera_capture_manual = 3,
} tx_camera_capture_mode_e;

typedef enum {
  tx_media_device_state_add = 0,
  tx_media_device_state_remove = 1,
  tx_media_device_state_active = 2,
  tx_media_default_device_changed = 3,
} tx_media_device_state_e;

typedef struct {
  int mode;  // TXCameraCaptureMode;
  int width;
  int height;
} tx_camera_capture_param_t;

typedef struct {
  char* device_pid;
  char* device_name;
  char* device_properties;
  uint32_t device_pid_len;
  uint32_t device_name_len;
  uint32_t device_properties_len;
  // NOLINT(whitespace/blank_line)
} tx_device_info_t;

typedef void (*tx_device_observer_on_device_changed_handler)(tx_device_manager instance,
                                                             const char* device_id,
                                                             tx_media_device_type_e type,
                                                             tx_media_device_state_e state);

liteav_c_api tx_device_observer tx_device_manager_create_device_observer(
    tx_device_manager instance,
    tx_device_observer_on_device_changed_handler on_device_changed);

liteav_c_api void tx_device_manager_destroy_device_observer(tx_device_observer observer);

// 1.1
liteav_c_api int tx_device_manager_is_front_camera(tx_device_manager instance);

// 1.2
liteav_c_api int tx_device_manager_switch_camera(tx_device_manager instance, bool front_camera);

// 1.3
liteav_c_api float tx_device_manager_get_camera_zoom_max_ratio(tx_device_manager instance);

// 1.4
liteav_c_api int tx_device_manager_set_camera_zoom_ratio(tx_device_manager instance,
                                                         float zoom_ratio);

// 1.5
liteav_c_api int tx_device_manager_is_audio_focus_enabled(tx_device_manager instance);

// 1.6
liteav_c_api int tx_device_manager_enable_camera_auto_focus(tx_device_manager instance,
                                                            bool enabled);

// 1.7
liteav_c_api int tx_device_manager_set_camera_focus_position(tx_device_manager instance,
                                                             float x,
                                                             float y);

// 1.8
liteav_c_api int tx_device_manager_enable_camera_torch(tx_device_manager instance, bool enabled);

// 1.9
liteav_c_api int tx_device_manager_set_audio_route(tx_device_manager instance,
                                                   tx_audio_route_e route);

// 2.1
liteav_c_api int tx_device_manager_get_device_count(tx_device_manager instance,
                                                    tx_media_device_type_e type);

liteav_c_api int tx_device_manager_get_device_info(tx_device_manager instance,
                                                   tx_media_device_type_e type,
                                                   int index,
                                                   tx_device_info_t* device_info);

// 2.2
liteav_c_api int tx_device_manager_set_current_device(tx_device_manager instance,
                                                      tx_media_device_type_e type,
                                                      const char* device_id);

// 2.3
liteav_c_api int tx_device_manager_get_current_device(tx_device_manager instance,
                                                      tx_media_device_type_e type,
                                                      tx_device_info_t* device_info);

// 2.4
liteav_c_api int tx_device_manager_set_current_device_volume(tx_device_manager instance,
                                                             tx_media_device_type_e type,
                                                             uint32_t volume);

// 2.5
liteav_c_api int tx_device_manager_get_current_device_volume(tx_device_manager instance,
                                                             tx_media_device_type_e type);

// 2.6
liteav_c_api int tx_device_manager_set_current_device_mute(tx_device_manager instance,
                                                           tx_media_device_type_e type,
                                                           bool mute);

// 2.7
liteav_c_api int tx_device_manager_get_current_device_mute(tx_device_manager instance,
                                                           tx_media_device_type_e type);

// 2.8
liteav_c_api int tx_device_manager_enable_following_default_audio_device(
    tx_device_manager instance,
    tx_media_device_type_e type,
    bool enable);

// 2.9
liteav_c_api int tx_device_manager_start_camera_device_test(tx_device_manager instance,
                                                            tx_view view);

// 2.10
liteav_c_api int tx_device_manager_stop_camera_device_test(tx_device_manager instance);

// 2.11
liteav_c_api int tx_device_manager_start_mic_device_test(tx_device_manager instance,
                                                         uint32_t interval);

// 2.12
liteav_c_api int tx_device_manager_start_mic_device_test_and_playback(tx_device_manager instance,
                                                                      uint32_t interval,
                                                                      bool playback);
// 2.13
liteav_c_api int tx_device_manager_stop_mic_device_test(tx_device_manager instance);

// 2.14
liteav_c_api int tx_device_manager_start_speaker_device_test(tx_device_manager instance,
                                                             const char* file_path);

// 2.15
liteav_c_api int tx_device_manager_stop_speaker_device_test(tx_device_manager instance);

// 2.16
liteav_c_api int tx_device_manager_start_camera_device_test_and_callback(
    tx_device_manager instance,
    tx_video_render_callback callback);

// 2.18
liteav_c_api int tx_device_manager_set_application_play_volume(tx_device_manager instance,
                                                               int volume);

// 2.19
liteav_c_api int tx_device_manager_get_application_play_volume(tx_device_manager instance);

// 2.20
liteav_c_api int tx_device_manager_set_application_mute_state(tx_device_manager instance,
                                                              bool mute);

// 2.21
liteav_c_api int tx_device_manager_get_application_mute_state(tx_device_manager instance);

// 2.22
liteav_c_api int tx_device_manager_set_camera_capture_param(tx_device_manager instance,
                                                            tx_camera_capture_param_t params);

// 2.23
liteav_c_api int tx_device_manager_set_device_observer(tx_device_manager instance,
                                                       tx_device_observer observer);
// 2.24
liteav_c_api int tx_device_manager_set_system_volume_type(tx_device_manager instance,
                                                          tx_system_volume_type_e volume_type);

#ifdef __cplusplus
}
#endif

#endif  // API_TX_C_DEVICEMANAGER_H_  // NOLINT(build/header_guard)
