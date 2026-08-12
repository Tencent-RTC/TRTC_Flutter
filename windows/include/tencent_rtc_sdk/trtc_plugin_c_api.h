// Copyright (c) Tencent. All rights reserved.  // NOLINT(build/header_guard)
//
// trtc_plugin_c_api.h
//

#ifndef FLUTTER_PLUGIN_TRTC_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_TRTC_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void TrtcPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);
  // NOLINT(build/header_guard)
#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_TRTC_PLUGIN_C_API_H_
