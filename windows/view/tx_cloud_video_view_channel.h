// Copyright (c) Tencent. All rights reserved.
//
// tx_cloud_video_view_channel.h
//

#ifndef SDK_TRTC_V3_WINDOWS_VIEW_TX_CLOUD_VIDEO_VIEW_CHANNEL_H_
#define SDK_TRTC_V3_WINDOWS_VIEW_TX_CLOUD_VIDEO_VIEW_CHANNEL_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <functional>
#include <map>
#include <memory>

#include "include/macros.h"

class TextureRenderer;

namespace trtc_sdk_flutter {
class MainThreadDispatcher;
}

class TXCloudVideoViewChannel {
 public:
  TXCloudVideoViewChannel(flutter::PluginRegistrarWindows* registrar,
      trtc_sdk_flutter::MainThreadDispatcher* main_thread_dispatcher);
  ~TXCloudVideoViewChannel();

  TextureRenderer* getTextureRenderer(int64_t texture_id);
  void setRenderWillDisposeCallback(std::function<void(TextureRenderer*)> callback);

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  int64_t createTextureView();
  void disposeTextureView(int64_t texture_id);
  void getTextureId(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void unregisterTexture(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  flutter::PluginRegistrarWindows* registrar_ = nullptr;
  trtc_sdk_flutter::MainThreadDispatcher* main_thread_dispatcher_ = nullptr;
  SP<flutter::MethodChannel<flutter::EncodableValue>> method_channel_;
  std::map<int64_t, SP<TextureRenderer>> texture_map_;
  std::function<void(TextureRenderer*)> render_will_dispose_callback_;
};

#endif  // SDK_TRTC_V3_WINDOWS_VIEW_TX_CLOUD_VIDEO_VIEW_CHANNEL_H_
