// Copyright (c) 2025 Tencent. All rights reserved.
// Author: carolsuo

#ifndef SDK_COMMON_FLUTTER_LIVE_PUSHER_DART_ADAPTER_H_  // NOLINT(build/header_guard)
#define SDK_COMMON_FLUTTER_LIVE_PUSHER_DART_ADAPTER_H_

#include "live_dart_def.h"
#include "v2tx_live_def.h"
#include "v2tx_live_pusher.h"

LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIRegisterPusherListener(Dart_Port sendPort, v2tx_live_pusher pusher);
LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIUnRegisterPusherListener(v2tx_live_pusher pusher);

LITEAV_DART_API LITEAV_FFI_EXPORT int LiteavFFIRegisterMusicPreloadObserver(Dart_Port sendPort,
    tx_audio_effect_manager instance);
LITEAV_DART_API LITEAV_FFI_EXPORT int LiteavFFIUnRegisterMusicPreloadObserver(Dart_Port sendPort,
    tx_audio_effect_manager instance);
LITEAV_DART_API LITEAV_FFI_EXPORT int LiteavFFIRegisterMusicPlayObserver(Dart_Port sendPort,
    tx_audio_effect_manager instance, char* param);
LITEAV_DART_API LITEAV_FFI_EXPORT int LiteavFFIUnRegisterMusicPlayObserver(Dart_Port sendPort,
    tx_audio_effect_manager instance, char* param);

LITEAV_DART_API LITEAV_FFI_EXPORT int LiteavFFIRegisterDeviceChangeObserver(Dart_Port sendPort,
    tx_device_manager instance);
LITEAV_DART_API LITEAV_FFI_EXPORT int LiteavFFIUnRegisterDeviceChangeObserver(Dart_Port sendPort,
    tx_device_manager instance);

LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIRegisterPusherPreprocessListener(v2tx_live_pusher pusher,
                                                                                 uint64_t listener);
LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIUnRegisterPusherPreprocessListener(v2tx_live_pusher pusher);

#endif  // SDK_COMMON_FLUTTER_LIVE_PUSHER_DART_ADAPTER_H_  // NOLINT(build/header_guard)
