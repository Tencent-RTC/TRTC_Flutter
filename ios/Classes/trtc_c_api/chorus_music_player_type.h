// Copyright (c) 2025 Tencent. All rights reserved.

#ifndef SDK_TRTC_C_CHORUS_MUSIC_PLAYER_TYPE_H_  // NOLINT(build/header_guard)
#define SDK_TRTC_C_CHORUS_MUSIC_PLAYER_TYPE_H_

#include "trtc_cloud_type.h"

typedef void* chorus_music_player;

typedef struct {
  const char* music_id;
  const char* music_url;
  const char* accompany_url;
} chorus_external_music_params_t;

#endif  // SDK_TRTC_C_CHORUS_MUSIC_PLAYER_TYPE_H_  // NOLINT(build/header_guard)
