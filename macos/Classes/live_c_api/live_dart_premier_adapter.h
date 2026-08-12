// Copyright (c) 2024 Tencent. All rights reserved.
// Author: borryzhang

#ifndef SDK_COMMON_FLUTTER_LIVE_DART_PREMIER_ADAPTER_H_  // NOLINT(build/header_guard)
#define SDK_COMMON_FLUTTER_LIVE_DART_PREMIER_ADAPTER_H_

#include "live_dart_def.h"
#include "v2tx_live_def.h"
#include "v2tx_live_premier.h"

LITEAV_DART_API LITEAV_FFI_EXPORT intptr_t LiteavFFIInitApiDL(void* data);
LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIRegisterPremierListener(Dart_Port sendPort);
LITEAV_DART_API LITEAV_FFI_EXPORT void LiteavFFIUnRegisterPremierListener();

#endif  // SDK_COMMON_FLUTTER_LIVE_DART_PREMIER_ADAPTER_H_  // NOLINT(build/header_guard)
