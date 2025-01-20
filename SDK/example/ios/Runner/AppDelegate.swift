import UIKit
import Flutter
import TXLiteAVSDK_Professional
import tencent_trtc_cloud
import TXCustomBeautyProcesserPlugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    lazy var customBeautyInstance: TRTCVideoCustomPreprocessor = {
        let customBeautyInstance = TRTCVideoCustomPreprocessor()
        customBeautyInstance.brightness = 0.5
        return customBeautyInstance
    }()

    TencentTRTCCloud.register(customBeautyProcesserFactory: customBeautyInstance)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

extension TRTCVideoCustomPreprocessor: ITXCustomBeautyProcesserFactory {
    public func createCustomBeautyProcesser() -> ITXCustomBeautyProcesser {
        return self
    }
    
    public func destroyCustomBeautyProcesser() {
        invalidateBindedTexture()
    }
}

extension TRTCVideoCustomPreprocessor: ITXCustomBeautyProcesser {
    public func getSupportedPixelFormat() -> ITXCustomBeautyPixelFormat {
        return .Texture2D
    }
    
    public func getSupportedBufferType() -> ITXCustomBeautyBufferType {
        return .Texture
    }
    
    public func onProcessVideoFrame(srcFrame: ITXCustomBeautyVideoFrame, dstFrame: ITXCustomBeautyVideoFrame) -> ITXCustomBeautyVideoFrame {
        let outPutTextureId = processTexture(srcFrame.textureId, width: UInt32(srcFrame.width), height: UInt32(srcFrame.height))
        dstFrame.textureId = outPutTextureId
        return dstFrame
    }
}
