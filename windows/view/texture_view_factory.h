// Copyright (c) Tencent. All rights reserved.
//
// texture_view_factory.h
//

#ifndef SDK_TRTC_V3_WINDOWS_VIEW_TEXTURE_VIEW_FACTORY_H_
#define SDK_TRTC_V3_WINDOWS_VIEW_TEXTURE_VIEW_FACTORY_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <atomic>
#include <map>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "include/TRTC/TRTCCloudCallback.h"
#include "include/macros.h"
#include "include/Live2/V2TXLivePlayerObserver.hpp"
#include "include/Live2/V2TXLivePlayer.hpp"
#include "include/Live2/V2TXLiveDef.hpp"

namespace trtc_sdk_flutter {
class MainThreadDispatcher;
}

class TextureRenderer : public liteav::V2TXLivePlayerObserver {
 public:
  TextureRenderer(flutter::PluginRegistrarWindows *registrar, trtc_sdk_flutter::
      MainThreadDispatcher* main_thread_dispatcher);
  ~TextureRenderer();

  int64_t texture_id() const { return texture_id_; }
  void Dispose();

  // Frame input from VideoFrameDispatcher (TRTC path).
  void onVideoFrame(TRTCVideoFrame* frame);
  // V2TXLivePlayerObserver (Live path).
  void onRenderVideoFrame(liteav::V2TXLivePlayer *player,
      const liteav::V2TXLiveVideoFrame *videoFrame) override;

 public:
  std::string user_id_;

 private:
  const FlutterDesktopPixelBuffer* CopyPixelBuffer(size_t width, size_t height);
  void NotifySizeChanged(uint32_t width, uint32_t height);
  void ConvertAndMarkFrame(const char* src_data, uint32_t width, uint32_t height);

  SP<flutter::MethodChannel<>> method_channel_;
  flutter::PluginRegistrarWindows *registrar_ = nullptr;
  trtc_sdk_flutter::MainThreadDispatcher* main_thread_dispatcher_ = nullptr;
  std::unique_ptr<flutter::TextureVariant> texture_;
  int64_t texture_id_ = -1;
  uint32_t texture_width_ = 0;
  uint32_t texture_height_ = 0;
  mutable std::mutex mutex_;
  FlutterDesktopPixelBuffer flutter_pixel_buffer_{};
  flutter::TextureRegistrar* texture_registrar_ = nullptr;
  std::vector<uint8_t> pixel_buffer_;
  std::atomic<bool> is_frame_pending_{false};
  std::atomic<bool> is_disposed_{false};
};

#endif  // SDK_TRTC_V3_WINDOWS_VIEW_TEXTURE_VIEW_FACTORY_H_
