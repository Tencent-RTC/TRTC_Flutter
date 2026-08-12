// Copyright (c) Tencent. All rights reserved.
//
// trtc_plugin.h
//

#ifndef SDK_TRTC_V3_WINDOWS_TRTC_PLUGIN_H_
#define SDK_TRTC_V3_WINDOWS_TRTC_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <map>
#include <memory>
#include <string>

#include "include/macros.h"
#include "include/TRTC/ITRTCCloud.h"

class TextureRenderer;
class TXCloudVideoViewChannel;

namespace trtc_sdk_flutter {
class VideoFrameDispatcher;
class MainThreadDispatcher;
}

namespace trtc {

class TrtcPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TrtcPlugin(flutter::PluginRegistrarWindows *registrar, SP<flutter::MethodChannel<>> channel);

  virtual ~TrtcPlugin();

  // Disallow copy and assign.
  TrtcPlugin(const TrtcPlugin&) = delete;
  TrtcPlugin& operator=(const TrtcPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void removeTextureRenderFromDispatchers(TextureRenderer* render);

  // Dispatcher-pattern methods (aligned with Android/iOS)
  void setLocalTextureRender(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void setRemoteTextureRender(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void unsetLocalTextureRender(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void unsetRemoteTextureRender(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void startCameraDeviceTest(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void stopCameraDeviceTest(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  void getCustomVideoFrameListener(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void destroySharedInstance(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

 private:
  SP<flutter::MethodChannel<flutter::EncodableValue>> method_channel_;
  flutter::PluginRegistrarWindows *registrar_;
  std::unique_ptr<TXCloudVideoViewChannel> video_view_channel_;

  // Dispatcher pattern (aligned with Android/iOS)
  // Local dispatcher for local video streams
  SP<trtc_sdk_flutter::VideoFrameDispatcher> local_dispatcher_;
  // Remote dispatchers: userId -> dispatcher
  std::map<std::string, SP<trtc_sdk_flutter::VideoFrameDispatcher>> remote_dispatcher_map_;

  std::unique_ptr<trtc_sdk_flutter::MainThreadDispatcher> main_thread_dispatcher_;
};

}  // namespace trtc

#endif  // SDK_TRTC_V3_WINDOWS_TRTC_PLUGIN_H_
