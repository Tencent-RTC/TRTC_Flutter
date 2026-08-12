// Copyright (c) Tencent. All rights reserved.
//
// trtc_plugin.cpp
//

#include "trtc_plugin.h"  // NOLINT(build/include_subdir)

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>
#include <string>
#include <utility>

#include "view/main_thread_dispatcher.h"
#include "view/texture_view_factory.h"
#include "view/tx_cloud_video_view_channel.h"
#include "view/video_frame_dispatcher.h"

namespace trtc {

// static
void TrtcPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      MK_SP<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "TencentRTCffi",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<TrtcPlugin>(registrar, channel);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

TrtcPlugin::TrtcPlugin(flutter::PluginRegistrarWindows *registrar, SP<flutter::MethodChannel<>> channel) {
  registrar_ = registrar;
  method_channel_ = channel;
  main_thread_dispatcher_ = std::make_unique<trtc_sdk_flutter::MainThreadDispatcher>();
  main_thread_dispatcher_->Initialize();
  video_view_channel_ = std::make_unique<TXCloudVideoViewChannel>(registrar_, main_thread_dispatcher_.get());
  video_view_channel_->setRenderWillDisposeCallback([this](TextureRenderer* render) {
    removeTextureRenderFromDispatchers(render);
  });
}

TrtcPlugin::~TrtcPlugin() {
  video_view_channel_.reset();
}

void TrtcPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string method_name = method_call.method_name();
  if (method_name.compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
  } else if (method_name.compare("initialize") == 0) {
    result->Success(nullptr);
  } else if (method_name.compare("trtcLog") == 0) {
    result->Success(nullptr);
  } else if (method_name.compare("setLocalTextureRender") == 0) {
    setLocalTextureRender(method_call, std::move(result));
  } else if (method_name.compare("setRemoteTextureRender") == 0) {
    setRemoteTextureRender(method_call, std::move(result));
  } else if (method_name.compare("unsetLocalTextureRender") == 0) {
    unsetLocalTextureRender(method_call, std::move(result));
  } else if (method_name.compare("unsetRemoteTextureRender") == 0) {
    unsetRemoteTextureRender(method_call, std::move(result));
  } else if (method_name.compare("startCameraDeviceTest") == 0) {
    startCameraDeviceTest(method_call, std::move(result));
  } else if (method_name.compare("stopCameraDeviceTest") == 0) {
    stopCameraDeviceTest(method_call, std::move(result));
  } else if (method_name.compare("getCustomVideoFrameListener") == 0) {
    getCustomVideoFrameListener(method_call, std::move(result));
  } else if (method_name.compare("destroySharedInstance") == 0) {
    destroySharedInstance(method_call, std::move(result));
  } else {
    result->NotImplemented();
  }
}

void TrtcPlugin::removeTextureRenderFromDispatchers(TextureRenderer* render) {
  if (!render) return;
  if (local_dispatcher_) {
    local_dispatcher_->onRenderWillDispose(render);
    if (local_dispatcher_->isEmpty()) {
      getTRTCShareInstance()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Unknown,
          nullptr);
      local_dispatcher_.reset();
    }
  }
  for (auto d_it = remote_dispatcher_map_.begin(); d_it != remote_dispatcher_map_.end();) {
    d_it->second->onRenderWillDispose(render);
    if (d_it->second->isEmpty()) {
      getTRTCShareInstance()->setRemoteVideoRenderCallback(d_it->first.c_str(), TRTCVideoPixelFormat_Unknown,
          TRTCVideoBufferType_Unknown, nullptr);
      d_it = remote_dispatcher_map_.erase(d_it);
    } else {
      ++d_it;
    }
  }
}

// MARK: - Dispatcher-pattern methods (aligned with Android/iOS)

void TrtcPlugin::setLocalTextureRender(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto viewId = std::get<int64_t>(methodParams[flutter::EncodableValue("viewId")]);
  auto streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);

  TextureRenderer* render = video_view_channel_->getTextureRenderer(viewId);
  if (render == nullptr) {
    result->Success(nullptr);
    return;
  }

  // Reuse existing dispatcher or create new one (aligned with iOS/Android)
  if (!local_dispatcher_) {
    local_dispatcher_ = MK_SP<trtc_sdk_flutter::VideoFrameDispatcher>("local");
  }
  getTRTCShareInstance()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer,
      local_dispatcher_.get());
  local_dispatcher_->setRender(streamType, render);

  result->Success(nullptr);
}

void TrtcPlugin::setRemoteTextureRender(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto viewId = std::get<int64_t>(methodParams[flutter::EncodableValue("viewId")]);
  auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]);
  auto streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);

  TextureRenderer* render = video_view_channel_->getTextureRenderer(viewId);
  if (render == nullptr) {
    result->Success(nullptr);
    return;
  }

  // Reuse existing dispatcher or create new one (aligned with iOS/Android)
  if (remote_dispatcher_map_.find(user_id) == remote_dispatcher_map_.end()) {
    remote_dispatcher_map_[user_id] = MK_SP<trtc_sdk_flutter::VideoFrameDispatcher>(user_id);
  }
  auto& dispatcher = remote_dispatcher_map_[user_id];
  getTRTCShareInstance()->setRemoteVideoRenderCallback(user_id.c_str(), TRTCVideoPixelFormat_BGRA32,
      TRTCVideoBufferType_Buffer, dispatcher.get());
  dispatcher->setRender(streamType, render);

  result->Success(nullptr);
}

void TrtcPlugin::unsetLocalTextureRender(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);

  if (local_dispatcher_) {
    local_dispatcher_->removeRender(streamType);
    if (local_dispatcher_->isEmpty()) {
      getTRTCShareInstance()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Unknown,
          nullptr);
      local_dispatcher_.reset();
    }
  }

  result->Success(nullptr);
}

void TrtcPlugin::unsetRemoteTextureRender(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]);
  auto streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);

  auto dispatcher_it = remote_dispatcher_map_.find(user_id);
  if (dispatcher_it != remote_dispatcher_map_.end()) {
    dispatcher_it->second->removeRender(streamType);
    if (dispatcher_it->second->isEmpty()) {
      getTRTCShareInstance()->setRemoteVideoRenderCallback(user_id.c_str(), TRTCVideoPixelFormat_Unknown,
          TRTCVideoBufferType_Unknown, nullptr);
      remote_dispatcher_map_.erase(dispatcher_it);
    }
  }

  result->Success(nullptr);
}  // NOLINT(whitespace/blank_line)

void TrtcPlugin::startCameraDeviceTest(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto viewId = std::get<int64_t>(methodParams[flutter::EncodableValue("viewId")]);

  TextureRenderer* render = video_view_channel_->getTextureRenderer(viewId);
  if (render == nullptr) {
    result->Success(flutter::EncodableValue(-1));
    return;
  }

  if (!local_dispatcher_) {
    local_dispatcher_ = MK_SP<trtc_sdk_flutter::VideoFrameDispatcher>("local");
  }
  local_dispatcher_->setRender(static_cast<int>(TRTCVideoStreamTypeBig), render);

  int code = getTRTCShareInstance()->getDeviceManager()->startCameraDeviceTest(local_dispatcher_.get());
  result->Success(flutter::EncodableValue(code));
}

void TrtcPlugin::stopCameraDeviceTest(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  getTRTCShareInstance()->getDeviceManager()->stopCameraDeviceTest();
  if (local_dispatcher_) {
    local_dispatcher_->removeRender(static_cast<int>(TRTCVideoStreamTypeBig));
    if (local_dispatcher_->isEmpty()) {
      local_dispatcher_.reset();
    }
  }
  result->Success(nullptr);
}

void TrtcPlugin::getCustomVideoFrameListener(
  const flutter::MethodCall<flutter::EncodableValue> &method_call,
  std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  auto arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
  auto texture_id = std::get<int64_t>(arguments[flutter::EncodableValue("textureId")]);

  TextureRenderer* texture_renderer = video_view_channel_->getTextureRenderer(texture_id);
  if (texture_renderer == nullptr) {
    result->Error("INVALID_ARGUMENT", "No observer found for textureId");
    return;
  }

  liteav::V2TXLivePlayerObserver* observer = static_cast<liteav::V2TXLivePlayerObserver*>(texture_renderer);
  intptr_t ptr_value = reinterpret_cast<intptr_t>(observer);
  result->Success(flutter::EncodableValue(ptr_value));
}

void TrtcPlugin::destroySharedInstance(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (local_dispatcher_) {
    local_dispatcher_->disposeAll();
    getTRTCShareInstance()->setLocalVideoRenderCallback(TRTCVideoPixelFormat_Unknown, TRTCVideoBufferType_Unknown,
        nullptr);
    local_dispatcher_.reset();
  }
  for (auto& pair : remote_dispatcher_map_) {
    pair.second->disposeAll();
    getTRTCShareInstance()->setRemoteVideoRenderCallback(pair.first.c_str(), TRTCVideoPixelFormat_Unknown,
        TRTCVideoBufferType_Unknown, nullptr);
  }
  remote_dispatcher_map_.clear();
  result->Success(nullptr);
}

}  // namespace trtc
