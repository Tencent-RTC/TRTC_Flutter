#include "include/tencent_trtc_cloud/tencent_trtc_cloud_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <string>
#include <map>
#include <memory>

#include "include/TRTC/ITRTCCloud.h"
#include "include/TRTC/TRTCCloudDef.h"

#include "src/trtc_cloud.h"

using trtc_sdk_flutter::SDKManager;

namespace {

class TencentTrtcCloudPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TencentTrtcCloudPlugin();

  virtual ~TencentTrtcCloudPlugin();
  
  private:
    SP<SDKManager> sdk_manager_;
};

// static
void TencentTrtcCloudPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto plugin = std::make_unique<TencentTrtcCloudPlugin>();
  plugin->sdk_manager_ = SDKManager::createMain(std::string("trtcCloudChannel"), registrar);

  registrar->AddPlugin(std::move(plugin));
}

TencentTrtcCloudPlugin::TencentTrtcCloudPlugin() {}

TencentTrtcCloudPlugin::~TencentTrtcCloudPlugin() {}

}  // namespace

void TencentTrtcCloudPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  TencentTrtcCloudPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
