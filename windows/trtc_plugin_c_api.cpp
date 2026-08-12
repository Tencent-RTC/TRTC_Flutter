// Copyright (c) Tencent. All rights reserved.
//
// trtc_plugin_c_api.cpp
//

#include "include/tencent_rtc_sdk/trtc_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "trtc_plugin.h"  // NOLINT(build/include_subdir)

void TrtcPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  trtc::TrtcPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
