// Copyright (c) Tencent. All rights reserved.
//
// texture_view_factory.cpp
//

#include "view/texture_view_factory.h"

#include <memory>
#include <string>
#include <utility>

#include "view/main_thread_dispatcher.h"

using flutter::TextureVariant;
using flutter::PixelBufferTexture;
using std::string;

TextureRenderer::TextureRenderer(flutter::PluginRegistrarWindows *registrar, trtc_sdk_flutter::
    MainThreadDispatcher* main_thread_dispatcher)
    : registrar_(registrar),
      main_thread_dispatcher_(main_thread_dispatcher),
      is_disposed_(false),
      is_frame_pending_(false) {
  texture_ =
      std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
          [this](size_t width, size_t height) -> const FlutterDesktopPixelBuffer* {
            return this->CopyPixelBuffer(width, height);
          }));
  texture_registrar_ = registrar_->texture_registrar();
  texture_id_ = texture_registrar_->RegisterTexture(texture_.get());
  method_channel_ = MK_SP<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "tencent_rtc_texture_" + std::to_string(texture_id_),
          &flutter::StandardMethodCodec::GetInstance());

  flutter_pixel_buffer_.release_callback = [](void* release_context) {
    if (release_context) {
      auto* mtx = reinterpret_cast<std::mutex*>(release_context);
      mtx->unlock();
    }
  };
  flutter_pixel_buffer_.release_context = nullptr;
}

TextureRenderer::~TextureRenderer() {
  Dispose();
}

void TextureRenderer::Dispose() {
  if (is_disposed_.exchange(true)) {
    return;
  }

  {
    const std::lock_guard<std::mutex> lock(mutex_);
    pixel_buffer_.clear();
    pixel_buffer_.shrink_to_fit();
  }

  if (texture_registrar_ && texture_id_ != -1) {
    texture_registrar_->UnregisterTexture(texture_id_);
    texture_registrar_ = nullptr;
    texture_id_ = -1;
  }
}

const FlutterDesktopPixelBuffer* TextureRenderer::CopyPixelBuffer(
    size_t width, size_t height) {
  std::unique_lock<std::mutex> buffer_lock(mutex_);

  is_frame_pending_ = false;

  if (is_disposed_) {
    return nullptr;
  }

  if (texture_width_ == 0 || texture_height_ == 0 || pixel_buffer_.empty()) {
    return nullptr;
  }

  flutter_pixel_buffer_.buffer = pixel_buffer_.data();
  flutter_pixel_buffer_.width = texture_width_;
  flutter_pixel_buffer_.height = texture_height_;

  // Transfer lock ownership to release_callback; Flutter engine will unlock after GPU consumption
  flutter_pixel_buffer_.release_context = buffer_lock.release();

  return &flutter_pixel_buffer_;
}

void TextureRenderer::NotifySizeChanged(uint32_t width, uint32_t height) {
  if (!main_thread_dispatcher_) {
    return;
  }
  auto channel = method_channel_;
  int32_t w = static_cast<int32_t>(width);
  int32_t h = static_cast<int32_t>(height);
  main_thread_dispatcher_->Post([channel, w, h]() {
    flutter::EncodableMap args;
    args[flutter::EncodableValue("width")] = flutter::EncodableValue(w);
    args[flutter::EncodableValue("height")] = flutter::EncodableValue(h);
    channel->InvokeMethod("updateVideoAspectRatio",
      std::make_unique<flutter::EncodableValue>(args));
  });
}

void TextureRenderer::ConvertAndMarkFrame(const char* src_data, uint32_t width, uint32_t height) {
  const uint32_t pixels_total = width * height;
  const size_t data_size = static_cast<size_t>(pixels_total) * 4;

  if (data_size == 0) {
    return;
  }

  if (pixel_buffer_.size() != data_size) {
    try {
      pixel_buffer_.resize(data_size);
    } catch (const std::bad_alloc&) {
      return;
    }
  }

  // BGRA -> RGBA
  const uint32_t* src = reinterpret_cast<const uint32_t*>(src_data);
  uint32_t* dst = reinterpret_cast<uint32_t*>(pixel_buffer_.data());

  for (uint32_t i = 0; i < pixels_total; ++i) {
    uint32_t pixel = src[i];
    dst[i] = (pixel & 0xFF00FF00) |          // A and G unchanged
             ((pixel & 0x00FF0000) >> 16) |   // B -> R
             ((pixel & 0x000000FF) << 16);    // R -> B
  }

  is_frame_pending_ = true;

  if (texture_registrar_ && texture_id_ != -1) {
    texture_registrar_->MarkTextureFrameAvailable(texture_id_);
  }
}

// Frame input from VideoFrameDispatcher (TRTC path)
void TextureRenderer::onVideoFrame(TRTCVideoFrame* video_frame) {
  if (!video_frame || !video_frame->data ||
      video_frame->width == 0 || video_frame->height == 0) {
    return;
  }

  if (is_disposed_) {
    return;
  }

  std::lock_guard<std::mutex> lock_guard(mutex_);

  if (is_disposed_) {
    return;
  }

  if (is_frame_pending_) {
    return;
  }

  bool size_changed = (video_frame->width != texture_width_ || video_frame->height != texture_height_);
  if (size_changed) {
    texture_width_ = video_frame->width;
    texture_height_ = video_frame->height;
    NotifySizeChanged(texture_width_, texture_height_);
  }

  ConvertAndMarkFrame(video_frame->data, video_frame->width, video_frame->height);
}

// V2TXLivePlayerObserver
void TextureRenderer::onRenderVideoFrame(
    liteav::V2TXLivePlayer* player,
    const liteav::V2TXLiveVideoFrame* videoFrame) {
  if (!videoFrame || !videoFrame->data || videoFrame->width <= 0 || videoFrame->height <= 0) {
    return;
  }

  if (is_disposed_) {
    return;
  }

  std::lock_guard<std::mutex> lock_guard(mutex_);

  if (is_disposed_) {
    return;
  }

  if (is_frame_pending_) {
    return;
  }

  uint32_t w = static_cast<uint32_t>(videoFrame->width);
  uint32_t h = static_cast<uint32_t>(videoFrame->height);

  bool size_changed = (w != texture_width_ || h != texture_height_);
  if (size_changed) {
    texture_width_ = w;
    texture_height_ = h;
    NotifySizeChanged(texture_width_, texture_height_);
  }

  ConvertAndMarkFrame(videoFrame->data, w, h);
}
