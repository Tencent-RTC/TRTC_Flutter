// Copyright (c) 2024 Tencent. All rights reserved.
// Author: borryzhang

#ifndef SDK_COMMON_FLUTTER_LIVE_PLUGIN_DEF_H_  // NOLINT(build/header_guard)
#define SDK_COMMON_FLUTTER_LIVE_PLUGIN_DEF_H_

#ifndef LITEAV_FFI_EXPORT
#ifdef _WIN32
#include <windows.h>
#define LITEAV_FFI_EXPORT __declspec(dllexport)
#elif __APPLE__
#include <TargetConditionals.h>
#define LITEAV_FFI_EXPORT __attribute__((visibility("default")))
#elif __ANDROID__ || __linux__
#define LITEAV_FFI_EXPORT __attribute__((visibility("default")))
#else
#define LITEAV_FFI_EXPORT
#endif
#endif

#ifdef __cplusplus
#define LITEAV_DART_API extern "C"
extern "C" {}
#else
#define LITEAV_DART_API
#endif

typedef int64_t Dart_Port;

#endif  // SDK_COMMON_FLUTTER_LIVE_PLUGIN_DEF_H_  // NOLINT(build/header_guard)
