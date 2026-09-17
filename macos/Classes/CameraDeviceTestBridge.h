#ifndef CameraDeviceTestBridge_h
#define CameraDeviceTestBridge_h

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/// 摄像头测试视频帧回调（原始数据 buffer）
/// macOS 摄像头测试的自定义渲染回调实测为 I420 + ByteBuffer，这里透传裸数据，
/// 由上层（渲染端）自行决定如何转换/渲染。
/// @param data   帧数据首地址（仅回调期间有效，需在回调内同步使用/拷贝）。
/// @param length 帧数据字节数（I420 = width*height*3/2）。
/// @param format 像素格式，参考 TRTCVideoPixelFormat（I420=1、BGRA32=3 等）。
/// @param width  帧宽（像素）。
/// @param height 帧高（像素）。
typedef void (*TRTCCameraTestVideoFrameCallback)(const uint8_t *data,
                                                 uint32_t length,
                                                 int format,
                                                 uint32_t width,
                                                 uint32_t height);

/// 启动摄像头设备测试（纯 C 路径）。
/// 内部：trtc_cloud_get_instance -> trtc_cloud_get_device_manager
///       -> tx_device_manager_start_camera_device_test_and_callback。
/// 摄像头测试全局同时只有一个，桥接层内部持有回调对象，无需外部管理句柄。
/// @param callback 帧回调（可为 NULL，此时仅启动测试不回帧）。
/// @return C 接口返回的错误码。
int trtc_camera_device_test_start(TRTCCameraTestVideoFrameCallback callback);

/// 停止摄像头设备测试，并释放 start 时创建的回调对象。
/// @return C 接口返回的错误码。
int trtc_camera_device_test_stop(void);

#ifdef __cplusplus
}
#endif

#endif /* CameraDeviceTestBridge_h */
