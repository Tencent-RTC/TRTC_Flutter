#import "CameraDeviceTestBridge.h"

#import "trtc_c_api/trtc_cloud.h"
#import "trtc_c_api/tx_device_manager.h"

namespace liteav {
enum TRTCVideoStreamType {
  TRTCVideoStreamTypeBig = 0,
  TRTCVideoStreamTypeSmall = 1,
  TRTCVideoStreamTypeSub = 2,
};

enum TRTCVideoPixelFormat {
  TRTCVideoPixelFormat_Unknown = 0,
  TRTCVideoPixelFormat_I420 = 1,
  TRTCVideoPixelFormat_Texture_2D = 2,
  TRTCVideoPixelFormat_BGRA32 = 3,
  TRTCVideoPixelFormat_NV21 = 4,
  TRTCVideoPixelFormat_RGBA32 = 5,
};


enum TRTCVideoBufferType {
  TRTCVideoBufferType_Unknown = 0,
  TRTCVideoBufferType_Buffer = 1,
  TRTCVideoBufferType_Texture = 3,
  TRTCVideoBufferType_TextureD3D11 = 4,
  TRTCVideoBufferType_PixelBuffer = 5,
};

enum TRTCVideoRotation { TRTCVideoRotation0 = 0 };

struct TRTCTexture;


struct TRTCVideoFrame {
  TRTCVideoPixelFormat videoFormat;
  TRTCVideoBufferType bufferType;
  TRTCTexture *texture;
  char *data;
  uint32_t length;
  uint32_t width;
  uint32_t height;
  uint64_t timestamp;
  TRTCVideoRotation rotation;
};

class ITRTCVideoRenderCallback {
 public:
  virtual ~ITRTCVideoRenderCallback() {}
  virtual void onRenderVideoFrame(const char *userId,
                                  TRTCVideoStreamType streamType,
                                  TRTCVideoFrame *frame) {}
};

}  // namespace liteav

namespace {

class CameraTestRenderCallback : public liteav::ITRTCVideoRenderCallback {
 public:
  explicit CameraTestRenderCallback(TRTCCameraTestVideoFrameCallback cb)
      : callback_(cb) {}

  void onRenderVideoFrame(const char *userId,
                          liteav::TRTCVideoStreamType streamType,
                          liteav::TRTCVideoFrame *frame) override {
    if (callback_ == nullptr || frame == nullptr || frame->data == nullptr) {
      return;
    }
    callback_(reinterpret_cast<const uint8_t *>(frame->data), frame->length,
              (int)frame->videoFormat, frame->width, frame->height);
  }

 private:
  TRTCCameraTestVideoFrameCallback callback_;
};
CameraTestRenderCallback *g_callback = nullptr;

}  // namespace

int trtc_camera_device_test_start(TRTCCameraTestVideoFrameCallback callback) {
  trtc_cloud cloud = trtc_cloud_get_instance(nullptr);
  if (cloud == nullptr) {
    return -1;
  }
  tx_device_manager manager = trtc_cloud_get_device_manager(cloud);
  if (manager == nullptr) {
    return -1;
  }

  // 已有测试在运行，拒绝重复启动（上层应保证先 stop 再 start）
  if (g_callback != nullptr) {
    return -1;
  }

  g_callback = new CameraTestRenderCallback(callback);

  int code = tx_device_manager_start_camera_device_test_and_callback(
      manager, static_cast<tx_video_render_callback>(g_callback));

  if (code != 0) {
    delete g_callback;
    g_callback = nullptr;
  }
  return code;
}

int trtc_camera_device_test_stop(void) {
  int code = 0;
  trtc_cloud cloud = trtc_cloud_get_instance(nullptr);
  if (cloud != nullptr) {
    tx_device_manager manager = trtc_cloud_get_device_manager(cloud);
    if (manager != nullptr) {
      code = tx_device_manager_stop_camera_device_test(manager);
    }
  }
  if (g_callback != nullptr) {
    delete g_callback;
    g_callback = nullptr;
  }
  return code;
}
