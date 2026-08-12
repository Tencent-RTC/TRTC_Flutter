//
//  TencentVideoTextureRender.swift
//  tencent_trtc_cloud
//
import TXLiteAVSDK_Professional
import Foundation
import TXCustomBeautyProcesserPlugin

class ProcessVideoFrame:NSObject,TRTCVideoFrameDelegate {
    private var beautyInstance: ITXCustomBeautyProcesser? = nil
    init(_ beautyInstance: ITXCustomBeautyProcesser){
    self.beautyInstance = beautyInstance
  }
    func onGLContextDestory() {
    }
    /// 自定义视频处理回调
    func onProcessVideoFrame(_ srcFrame: TRTCVideoFrame, dstFrame: TRTCVideoFrame) -> UInt32 {
        guard let beautyInstance = beautyInstance else {
            dstFrame.textureId = srcFrame.textureId
            return 0
        }
        let srcBeautyFrame = ObjectUtils.convertTRTCVideoFrame(trtcVideoFrame: srcFrame)
        let dstBeautyFrame = ObjectUtils.convertTRTCVideoFrame(trtcVideoFrame: dstFrame)
        let dstThirdFrame = beautyInstance.onProcessVideoFrame(srcFrame: srcBeautyFrame,
                                                               dstFrame: dstBeautyFrame)
        dstFrame.textureId = dstThirdFrame.textureId
        dstFrame.pixelBuffer = dstThirdFrame.pixelBuffer
        if let pixelFormat = dstThirdFrame.pixelFormat {
            dstFrame.pixelFormat = ObjectUtils.convertToTRTCPixelFormat(beautyPixelFormat: pixelFormat)
        }
        dstFrame.width = UInt32(dstThirdFrame.width)
        dstFrame.height = UInt32(dstThirdFrame.height)
        dstFrame.data = dstThirdFrame.data
        dstFrame.rotation = TRTCVideoRotation(rawValue: dstThirdFrame.rotation.rawValue) ?? dstFrame.rotation

        return 0
    }
}
