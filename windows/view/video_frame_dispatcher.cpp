// Copyright (c) Tencent. All rights reserved.
//
// video_frame_dispatcher.cpp
//

#include "view/video_frame_dispatcher.h"

#include <string>

#include "view/texture_view_factory.h"

namespace trtc_sdk_flutter {

VideoFrameDispatcher::VideoFrameDispatcher(const std::string& userId)
    : user_id_(userId) {
}

VideoFrameDispatcher::~VideoFrameDispatcher() {
    disposeAll();
}

void VideoFrameDispatcher::setRender(int streamType, TextureRenderer* render) {
    std::lock_guard<std::mutex> lock(mutex_);
    renders_[streamType] = render;
}

void VideoFrameDispatcher::removeRender(int streamType) {
    std::lock_guard<std::mutex> lock(mutex_);
    renders_.erase(streamType);
}

void VideoFrameDispatcher::onRenderWillDispose(TextureRenderer* render) {
    if (render == nullptr) return;
    std::lock_guard<std::mutex> lock(mutex_);
    for (auto it = renders_.begin(); it != renders_.end();) {
        if (it->second == render) {
            it = renders_.erase(it);
        } else {
            ++it;
        }
    }
}

bool VideoFrameDispatcher::isEmpty() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return renders_.empty();
}

void VideoFrameDispatcher::disposeAll() {
    std::lock_guard<std::mutex> lock(mutex_);
    renders_.clear();
}

void VideoFrameDispatcher::onRenderVideoFrame(const char* user_id, TRTCVideoStreamType stream_type,
    TRTCVideoFrame* frame) {
    std::lock_guard<std::mutex> lock(mutex_);
    auto it = renders_.find(static_cast<int>(stream_type));
    if (it != renders_.end() && it->second != nullptr) {
        it->second->onVideoFrame(frame);
    }
}

}  // namespace trtc_sdk_flutter
