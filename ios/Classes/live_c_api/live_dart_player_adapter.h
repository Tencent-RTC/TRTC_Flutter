// Copyright (c) 2024 Tencent. All rights reserved.
// Author: borryzhang

#ifndef SDK_COMMON_FLUTTER_LIVE_DART_PLAYER_ADAPTER_H_  // NOLINT(build/header_guard)
#define SDK_COMMON_FLUTTER_LIVE_DART_PLAYER_ADAPTER_H_

#include "live_dart_def.h"
#include "v2tx_live_def.h"
#include "v2tx_live_player.h"

LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIRegisterPlayerListener(
    Dart_Port sendPort,
    v2tx_live_player *v2tx_live_player_ptr);
LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIUnRegisterPlayerListener(
    v2tx_live_player *v2tx_live_player_ptr);

#endif  // SDK_COMMON_FLUTTER_LIVE_DART_PLAYER_ADAPTER_H_  // NOLINT(build/header_guard)
