// Copyright (c) 2025 Tencent. All rights reserved.

#ifndef SDK_TRTC_C_CHORUS_MUSIC_PLAYER_H_  // NOLINT(build/header_guard)
#define SDK_TRTC_C_CHORUS_MUSIC_PLAYER_H_

#include "chorus_music_player_type.h"
#include "trtc_cloud.h"

#ifdef __cplusplus
extern "C" {
#endif

// Create a chorus music player instance
trtc_c_api chorus_music_player chorus_music_player_create(trtc_cloud cloud, const char* room_id);

// Destroy a chorus music player instance
trtc_c_api void chorus_music_player_destroy(chorus_music_player player);

// Set chorus role
trtc_c_api void chorus_music_player_set_chorus_role(chorus_music_player player,
                                                    int role,
                                                    trtc_params_t* trtc_params);

// Load external music
trtc_c_api void chorus_music_player_load_external_music(chorus_music_player player,
                                                        chorus_external_music_params_t params);

// Start playback
trtc_c_api void chorus_music_player_start(chorus_music_player player);

// Stop playback
trtc_c_api void chorus_music_player_stop(chorus_music_player player);

// Pause playback
trtc_c_api void chorus_music_player_pause(chorus_music_player player);

// Resume playback
trtc_c_api void chorus_music_player_resume(chorus_music_player player);

// Seek to position
trtc_c_api void chorus_music_player_seek(chorus_music_player player, int64_t timestamp_ms);

// Switch music track
trtc_c_api void chorus_music_player_switch_music_track(chorus_music_player player, int track);

// Set playout volume
trtc_c_api void chorus_music_player_set_playout_volume(chorus_music_player player, int32_t volume);

// Set publish volume
trtc_c_api void chorus_music_player_set_publish_volume(chorus_music_player player, int32_t volume);

// Set music pitch
trtc_c_api void chorus_music_player_set_music_pitch(chorus_music_player player, float pitch);

// Call experimental API
trtc_c_api void chorus_music_player_call_experimental_api(chorus_music_player player,
                                                          const char* json_str);

#ifdef __cplusplus
}
#endif

#endif  // SDK_TRTC_C_CHORUS_MUSIC_PLAYER_H_  // NOLINT(build/header_guard)
