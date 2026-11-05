// Copyright (c) 2023 Tencent. All rights reserved.
// Author: felixyyan

#ifndef API_TX_C_AUDIOEFFECTMANAGER_H_  // NOLINT(build/header_guard)
#define API_TX_C_AUDIOEFFECTMANAGER_H_

#include <stdint.h>
#include "tx_device_manager.h"

typedef void* tx_audio_effect_manager;
typedef void* tx_music_play_observer;
typedef void* tx_music_preload_observer;

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  tx_voice_reverb_type_0 = 0,
  tx_voice_reverb_type_1 = 1,
  tx_voice_reverb_type_2 = 2,
  tx_voice_reverb_type_3 = 3,
  tx_voice_reverb_type_4 = 4,
  tx_voice_reverb_type_5 = 5,
  tx_voice_reverb_type_6 = 6,
  tx_voice_reverb_type_7 = 7,
  tx_voice_reverb_type_8 = 8,
  tx_voice_reverb_type_9 = 9,
  tx_voice_reverb_type_10 = 10,
  tx_voice_reverb_type_11 = 11,
} tx_voice_reverb_type_e;

typedef enum {
  tx_voice_changer_type_0 = 0,
  tx_voice_changer_type_1 = 1,
  tx_voice_changer_type_2 = 2,
  tx_voice_changer_type_3 = 3,
  tx_voice_changer_type_4 = 4,
  tx_voice_changer_type_5 = 5,
  tx_voice_changer_type_6 = 6,
  tx_voice_changer_type_7 = 7,
  tx_voice_changer_type_8 = 8,
  tx_voice_changer_type_9 = 9,
  tx_voice_changer_type_10 = 10,
  tx_voice_changer_type_11 = 11,
} tx_voice_changer_type_e;

typedef struct {
  int id;
  const char* path;
  int loop_count;
  int publish;        // bool->int
  int is_short_file;  // bool->int
  int start_time_ms;
  int end_time_ms;
} tx_audio_music_param_t;

typedef void (*tx_music_play_observer_on_start_handler)(tx_audio_effect_manager instance,
                                                        int music_id,
                                                        int err_code);
typedef void (*tx_music_play_observer_on_play_progress_handler)(tx_audio_effect_manager instance,
                                                                int music_id,
                                                                int64_t cur_pts_ms,
                                                                int64_t duration_ms);

typedef void (*tx_music_play_observer_on_complete_handler)(tx_audio_effect_manager instance,
                                                           int music_id,
                                                           int err_code);

liteav_c_api tx_music_play_observer tx_audio_effect_manager_create_music_play_observer(
    tx_audio_effect_manager instance,
    tx_music_play_observer_on_start_handler on_start_handler,
    tx_music_play_observer_on_play_progress_handler on_play_progress_handler,
    tx_music_play_observer_on_complete_handler on_complete_handler);

liteav_c_api void tx_audio_effect_manager_destroy_music_play_observer(
    tx_music_play_observer observer);

typedef void (*tx_music_preload_observer_on_load_progress_handler)(tx_audio_effect_manager instance,
                                                                   int music_id,
                                                                   int progress);
typedef void (*tx_music_preload_observer_on_load_error_handler)(tx_audio_effect_manager instance,
                                                                int music_id,
                                                                int error_code);

liteav_c_api tx_music_preload_observer tx_audio_effect_manager_create_music_preload_observer(
    tx_audio_effect_manager instance,
    tx_music_preload_observer_on_load_progress_handler on_load_progress,
    tx_music_preload_observer_on_load_error_handler on_load_error);

liteav_c_api void tx_audio_effect_manager_destroy_music_preload_observer(
    tx_music_preload_observer observer);

// 1.1
liteav_c_api int tx_audio_effect_manager_enable_voice_ear_monitor(tx_audio_effect_manager instance,
                                                                  bool enable);

// 1.2
liteav_c_api int tx_audio_effect_manager_set_voice_ear_monitor_volume(
    tx_audio_effect_manager instance,
    int volume);

// 1.3
liteav_c_api int tx_audio_effect_manager_set_voice_reverb_type(tx_audio_effect_manager instance,
                                                               tx_voice_reverb_type_e type);

// 1.4
liteav_c_api int tx_audio_effect_manager_set_voice_changer_type(tx_audio_effect_manager instance,
                                                                tx_voice_changer_type_e type);

// 1.5
liteav_c_api int tx_audio_effect_manager_set_voice_capture_volume(tx_audio_effect_manager instance,
                                                                  int volume);

// 1.6
liteav_c_api int tx_audio_effect_manager_set_voice_pitch(tx_audio_effect_manager instance,
                                                         double pitch);

// 2.0
liteav_c_api int tx_audio_effect_manager_set_music_observer(tx_audio_effect_manager instance,
                                                            int musicId,
                                                            tx_music_play_observer play_observer);

// 2.1
liteav_c_api int tx_audio_effect_manager_start_play_music(tx_audio_effect_manager instance,
                                                          tx_audio_music_param_t param);

// 2.2
liteav_c_api int tx_audio_effect_manager_stop_play_music(tx_audio_effect_manager instance,
                                                         int music_id);

// 2.3
liteav_c_api int tx_audio_effect_manager_pause_play_music(tx_audio_effect_manager instance,
                                                          int music_id);

// 2.4
liteav_c_api int tx_audio_effect_manager_resume_play_music(tx_audio_effect_manager instance,
                                                           int music_id);

// 2.5
liteav_c_api int tx_audio_effect_manager_set_all_music_volume(tx_audio_effect_manager instance,
                                                              int volume);

// 2.6
liteav_c_api int tx_audio_effect_manager_set_music_publish_volume(tx_audio_effect_manager instance,
                                                                  int music_id,
                                                                  int volume);

// 2.7
liteav_c_api int tx_audio_effect_manager_set_music_playout_volume(tx_audio_effect_manager instance,
                                                                  int music_id,
                                                                  int volume);

// 2.8
liteav_c_api int tx_audio_effect_manager_set_music_pitch(tx_audio_effect_manager instance,
                                                         int music_id,
                                                         float pitch);

// 2.9
liteav_c_api int tx_audio_effect_manager_set_music_speed_rate(tx_audio_effect_manager instance,
                                                              int music_id,
                                                              float speed_rate);

// 2.10
liteav_c_api int64_t tx_audio_effect_manager_get_current_pos_in_ms(tx_audio_effect_manager instance,
                                                                   int music_id);

// 2.11
liteav_c_api int64_t
tx_audio_effect_manager_get_music_duration_in_ms(tx_audio_effect_manager instance, char* path);

// 2.12
liteav_c_api int tx_audio_effect_manager_seek_music_to_pos_in_time(tx_audio_effect_manager instance,
                                                                   int music_id,
                                                                   int pts);

// 2.13
liteav_c_api int tx_audio_effect_manager_set_music_scratch_speed_rate(
    tx_audio_effect_manager instance,
    int music_id,
    float scratch_speed_rate);

// 2.14
liteav_c_api int tx_audio_effect_manager_set_preload_observer(tx_audio_effect_manager instance,
                                                              tx_music_preload_observer observer);

// 2.15
liteav_c_api int tx_audio_effect_manager_preload_music(tx_audio_effect_manager instance,
                                                       tx_audio_music_param_t param);

// 2.16
liteav_c_api int64_t tx_audio_effect_manager_get_music_track_count(tx_audio_effect_manager instance,
                                                                   int music_id);

// 2.17
liteav_c_api int tx_audio_effect_manager_set_music_track(tx_audio_effect_manager instance,
                                                         int music_id,
                                                         int track_index);

#ifdef __cplusplus
}
#endif

#endif  // API_TX_C_AUDIOEFFECTMANAGER_H_  // NOLINT(build/header_guard)
