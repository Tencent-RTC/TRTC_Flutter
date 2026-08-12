// Copyright (c) Tencent. All rights reserved.
//
// tx_cloud_video_view_channel.cpp
//

#include "view/tx_cloud_video_view_channel.h"

#include <string>
#include <utility>

#include "view/texture_view_factory.h"

TXCloudVideoViewChannel::TXCloudVideoViewChannel(flutter::PluginRegistrarWindows* registrar,
    trtc_sdk_flutter::MainThreadDispatcher* main_thread_dispatcher)
    : registrar_(registrar), main_thread_dispatcher_(main_thread_dispatcher) {
  method_channel_ = MK_SP<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar_->messenger(), "TXCloudVideoViewChannel", &flutter::StandardMethodCodec::GetInstance());
  method_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        HandleMethodCall(call, std::move(result));
      });
}

TXCloudVideoViewChannel::~TXCloudVideoViewChannel() {
  if (method_channel_) {
    method_channel_->SetMethodCallHandler(nullptr);
  }
  for (auto& pair : texture_map_) {
    if (render_will_dispose_callback_) {
      render_will_dispose_callback_(pair.second.get());
    }
    pair.second->Dispose();
  }
  texture_map_.clear();
}

TextureRenderer* TXCloudVideoViewChannel::getTextureRenderer(int64_t texture_id) {
  auto it = texture_map_.find(texture_id);
  if (it == texture_map_.end()) {
    return nullptr;
  }
  return it->second.get();
}

void TXCloudVideoViewChannel::setRenderWillDisposeCallback(std::function<void(TextureRenderer*)> callback) {
  render_will_dispose_callback_ = std::move(callback);
}

void TXCloudVideoViewChannel::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string method_name = method_call.method_name();
  if (method_name.compare("createTextureView") == 0) {
    result->Success(flutter::EncodableValue(createTextureView()));
  } else if (method_name.compare("disposeTextureView") == 0) {
    auto method_params = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto texture_id = std::get<int64_t>(method_params[flutter::EncodableValue("textureId")]);
    disposeTextureView(texture_id);
    result->Success(nullptr);
  } else if (method_name.compare("getTextureId") == 0) {
    getTextureId(method_call, std::move(result));
  } else if (method_name.compare("getSurfaceId") == 0) {
    result->Success(nullptr);
  } else if (method_name.compare("unregisterTexture") == 0) {
    unregisterTexture(method_call, std::move(result));
  } else if (method_name.compare("setRenderSize") == 0) {
    result->Success(nullptr);
  } else {
    result->NotImplemented();
  }
}

int64_t TXCloudVideoViewChannel::createTextureView() {
  SP<TextureRenderer> texture_renderer = MK_SP<TextureRenderer>(registrar_, main_thread_dispatcher_);
  int64_t texture_id = texture_renderer->texture_id();
  texture_map_[texture_id] = texture_renderer;
  return texture_id;
}

void TXCloudVideoViewChannel::disposeTextureView(int64_t texture_id) {
  auto it = texture_map_.find(texture_id);
  if (it == texture_map_.end()) {
    return;
  }
  TextureRenderer* render_ptr = it->second.get();
  if (render_will_dispose_callback_) {
    render_will_dispose_callback_(render_ptr);
  }
  it->second->Dispose();
  texture_map_.erase(it);
}

void TXCloudVideoViewChannel::getTextureId(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  result->Success(flutter::EncodableValue(createTextureView()));
}

void TXCloudVideoViewChannel::unregisterTexture(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto texture_id = std::get<int64_t>(arguments[flutter::EncodableValue("textureId")]);
  disposeTextureView(texture_id);
  result->Success(nullptr);
}
