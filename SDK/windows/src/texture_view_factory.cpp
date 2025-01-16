#include "texture_view_factory.h"
#include "winsock2.h"
#include <functional>

using namespace flutter;
using std::string;

TextureRenderer::TextureRenderer(flutter::TextureRegistrar* texture_registrar, SP<flutter::MethodChannel<>> channel, TRTCVideoStreamType stream_type, std::string userId)
    : texture_registrar_(texture_registrar) {
      method_channel_ = channel;
  texture_ =
      std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
          [=](size_t width, size_t height) -> const FlutterDesktopPixelBuffer* {
            const std::lock_guard<std::mutex> lock(mutex_);
            return &flutter_pixel_buffer_;
          }));
  texture_id_ = texture_registrar_->RegisterTexture(texture_.get());
  stream_type_ = stream_type;
  userId_ = userId;
}

TextureRenderer::~TextureRenderer() {
  texture_registrar_->UnregisterTexture(texture_id_);
}

void TextureRenderer::unRegisterTexture() {
  texture_registrar_->UnregisterTexture(texture_id_);
}

void TextureRenderer::onRenderVideoFrame(const char* user_id, TRTCVideoStreamType stream_type, TRTCVideoFrame* video_frame) {
  // std::cout << "Value of user_id1 is : " << user_id << std::endl;
  if(stream_type != stream_type_) {
    return;
  }
  std::lock_guard<std::mutex> lock_guard(mutex_);
  // BGRA TO RGBA
  uint32_t * rbga = (uint32_t *)video_frame->data;
  for (int i = 0; i < (int)video_frame->width * (int)video_frame->height; i++) {
    rbga[i] = ((rbga[i] & 0xFF000000)) |        // ______AA
            ((rbga[i] & 0x00FF0000) >> 16) | // RR______
            ((rbga[i] & 0x0000FF00)) |         // __GG____
            ((rbga[i] & 0x000000FF) << 16);  // ____BB__
  }
  // flutter_pixel_buffer_.buffer = (const uint8_t *)video_frame->data;
  flutter_pixel_buffer_.buffer = (uint8_t*)rbga;
  flutter_pixel_buffer_.width = video_frame->width;
  flutter_pixel_buffer_.height = video_frame->height;
  texture_registrar_->MarkTextureFrameAvailable(texture_id_);
}