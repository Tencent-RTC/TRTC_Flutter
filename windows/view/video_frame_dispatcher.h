// Copyright (c) Tencent. All rights reserved.
//
// video_frame_dispatcher.h
//

#ifndef SDK_TRTC_V3_WINDOWS_VIEW_VIDEO_FRAME_DISPATCHER_H_
#define SDK_TRTC_V3_WINDOWS_VIEW_VIDEO_FRAME_DISPATCHER_H_

#include <map>
#include <memory>
#include <mutex>
#include <string>

#include "include/TRTC/TRTCCloudCallback.h"

class TextureRenderer;

namespace trtc_sdk_flutter {

/**
 * VideoFrameDispatcher - Dispatches video frames to the correct TextureRenderer based on stream type.
 *
 * This class is aligned with iOS TRTCVideoFrameDispatcher and Android VideoFrameDispatcher.
 * Each user (local or remote) has one dispatcher that manages multiple stream types (Big/Small/Sub).
 */
class VideoFrameDispatcher : public ITRTCVideoRenderCallback {
 public:
    explicit VideoFrameDispatcher(const std::string& userId);
    ~VideoFrameDispatcher();

    const std::string& getUserId() const { return user_id_; }

    void setRender(int streamType, TextureRenderer* render);
    void removeRender(int streamType);
    void onRenderWillDispose(TextureRenderer* render);
    bool isEmpty() const;
    void disposeAll();

    // ITRTCVideoRenderCallback
    void onRenderVideoFrame(const char* user_id, TRTCVideoStreamType stream_type, TRTCVideoFrame* frame) override;

 private:
    std::string user_id_;
    std::map<int, TextureRenderer*> renders_;
    mutable std::mutex mutex_;
};

}  // namespace trtc_sdk_flutter

#endif  // SDK_TRTC_V3_WINDOWS_VIEW_VIDEO_FRAME_DISPATCHER_H_
