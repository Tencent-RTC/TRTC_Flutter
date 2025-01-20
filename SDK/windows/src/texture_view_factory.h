
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar.h>
#include <flutter/standard_method_codec.h>
#include <flutter/texture_registrar.h>
#include <map>
#include <mutex>
#include "include/TRTC/TRTCCloudCallback.h"
#include "include/macros.h"


class TextureRenderer : public ITRTCVideoRenderCallback {
public:
  TextureRenderer(flutter::TextureRegistrar *registrar, SP<flutter::MethodChannel<>> channel, TRTCVideoStreamType stream_type, std::string userId);
  ~TextureRenderer();

  int64_t texture_id() const { return texture_id_; }
  void TextureRenderer::unRegisterTexture();

  void onRenderVideoFrame(const char* user_id, TRTCVideoStreamType stream_type, TRTCVideoFrame* frame);

private:
  const FlutterDesktopPixelBuffer *CopyPixelBuffer(size_t width, size_t height);

public:
 SP<flutter::MethodChannel<>> method_channel_;
  flutter::TextureRegistrar *registrar_;
  std::unique_ptr<flutter::TextureVariant> texture_;
  int64_t texture_id_;
  std::unique_ptr<flutter::MethodCall<flutter::EncodableValue>> channel_;
  unsigned int uid_;
  std::string userId_;
  std::string channel_id_;
  mutable std::mutex mutex_;
  FlutterDesktopPixelBuffer *pixel_buffer_;
  TRTCVideoStreamType stream_type_;

  FlutterDesktopPixelBuffer flutter_pixel_buffer_{};
  flutter::TextureRegistrar* texture_registrar_ = nullptr;
};
