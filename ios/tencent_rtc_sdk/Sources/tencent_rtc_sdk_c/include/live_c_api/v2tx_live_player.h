// Copyright (c) 2023 Tencent. All rights reserved.
// Author: bluedang

#ifndef SDK_API_LIVE_C_V2TX_LIVE_PLAYER_H_  // NOLINT(build/header_guard)
#define SDK_API_LIVE_C_V2TX_LIVE_PLAYER_H_

#include "v2tx_live_def.h"

#ifdef __cplusplus
extern "C" {
#endif

v2tx_live_c_api v2tx_live_player create_v2tx_live_player();
v2tx_live_c_api v2tx_live_player create_v2tx_live_player_by_identifier(const char *identifier);
v2tx_live_c_api void release_v2tx_live_player(v2tx_live_player instance);

v2tx_live_c_api int32_t v2tx_live_player_start_play(v2tx_live_player instance, const char* url);
v2tx_live_c_api int32_t v2tx_live_player_stop_play(v2tx_live_player instance);
v2tx_live_c_api int32_t v2tx_live_player_is_playing(v2tx_live_player instance);
v2tx_live_c_api int32_t v2tx_live_player_pause_audio(v2tx_live_player instance);
v2tx_live_c_api int32_t v2tx_live_player_resume_audio(v2tx_live_player instance);
v2tx_live_c_api int32_t v2tx_live_player_pause_video(v2tx_live_player instance);
v2tx_live_c_api int32_t v2tx_live_player_resume_video(v2tx_live_player instance);

v2tx_live_c_api int32_t v2tx_live_player_switch_stream(v2tx_live_player instance, const char* url);

v2tx_live_c_api int32_t v2tx_live_player_set_render_view(v2tx_live_player instance, void* view);

v2tx_live_c_api int32_t v2tx_live_player_set_playout_volume(v2tx_live_player instance,
                                                            int32_t volume);
v2tx_live_c_api int32_t v2tx_live_player_set_cache_params(v2tx_live_player instance,
                                                          float minTime,
                                                          float maxTime);
v2tx_live_c_api int32_t v2tx_live_player_set_render_rotation(v2tx_live_player instance,
                                                             v2tx_live_rotation_e rotation);
v2tx_live_c_api int32_t v2tx_live_player_set_render_fill_mode(v2tx_live_player instance,
                                                              v2tx_live_fill_mode_e mode);

v2tx_live_c_api int32_t v2tx_live_player_set_property(v2tx_live_player instance,
                                                      const char* key,
                                                      const void* value);

v2tx_live_c_api int32_t v2tx_live_player_enable_receive_sei_message(v2tx_live_player instance,
                                                                    bool enable,
                                                                    int payloadType);

v2tx_live_c_api int32_t v2tx_live_player_enable_volume_evaluation(v2tx_live_player instance,
                                                                  int32_t intervalMs);

v2tx_live_c_api int32_t
v2tx_live_player_enable_observer_video_frame(v2tx_live_player instance,
                                             bool enable,
                                             v2tx_live_pixel_format_e pixel_format,
                                             v2tx_live_buffer_type_e buffer_type);

v2tx_live_c_api int32_t v2tx_live_player_show_debug_view(v2tx_live_player instance, int is_show);

v2tx_live_c_api int32_t v2tx_live_player_snapshot(v2tx_live_player instance);
v2tx_live_c_api int32_t v2tx_live_player_enable_picture_in_picture(v2tx_live_player instance, bool enable);

v2tx_live_c_api int32_t v2tx_live_player_start_local_recording(v2tx_live_player instance,
                                                               const char* filePath,
                                                               int32_t recordType,
                                                               int32_t interval);
v2tx_live_c_api int32_t v2tx_live_player_stop_local_recording(v2tx_live_player instance);

#ifdef __cplusplus
}
#endif

#endif  // SDK_API_LIVE_C_V2TX_LIVE_PLAYER_H_  // NOLINT(build/header_guard)
