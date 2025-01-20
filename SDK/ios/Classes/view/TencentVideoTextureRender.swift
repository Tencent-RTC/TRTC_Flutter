//
//  TencentVideoTextureRender.swift
//  tencent_trtc_cloud
//
//  Created by gavinwjwang on 2022/1/11.
//
import TXLiteAVSDK_Professional
import Foundation
import UIKit
import CoreVideo
import CoreMedia


class TencentVideoTextureRender: NSObject, FlutterTexture ,TRTCVideoRenderDelegate,TRTCVideoFrameDelegate {
    private var _textures: FlutterTextureRegistry?
    private var buffer: CVPixelBuffer?
    private var _userId: String?
    private var _streamType:TRTCVideoStreamType?
    public var textureID: Int64?
    private let lock = NSLock()
    private var channel: FlutterMethodChannel = FlutterMethodChannel()
    
    private var videoWidth: UInt32 = 0
    private var videoHeight: UInt32 = 0
    
    init(_ textureRegistry: FlutterTextureRegistry, userId:String, streamType:TRTCVideoStreamType, messager: FlutterBinaryMessenger){
        _textures = textureRegistry
        _userId = userId
        _streamType = streamType
        super.init()
        textureID = textureRegistry.register(self)
        
        guard let textureID = textureID else { return }
        channel = FlutterMethodChannel(name: "trtcCloudChannel_texture_\(textureID)", binaryMessenger: messager)
    }

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if let buffer = buffer {
            lock.lock()
            let output = Unmanaged.passRetained(buffer)
            lock.unlock()
            return output
        }
        return nil
    }
    
    public func onRenderVideoFrame( _ frame:TRTCVideoFrame, userId:String?, streamType:TRTCVideoStreamType) {
        if streamType != _streamType { return }
        
        if frame.width != videoWidth || frame.height != videoHeight {
            videoWidth = frame.width
            videoHeight = frame.height
            channel.invokeMethod("updateTextureVideoResolution", arguments: ["width": videoWidth, "height": videoHeight])
        }
        
        guard let pixelBuffer = frame.pixelBuffer  else { return }
        lock.lock()
        buffer = pixelBuffer
        lock.unlock()
        
        if textureID != nil {
            _textures?.textureFrameAvailable(textureID!)
        }
    }
    
    func onProcessVideoFrame(_ srcFrame :TRTCVideoFrame, dstFrame:TRTCVideoFrame) -> UInt32{
      dstFrame.pixelBuffer = srcFrame.pixelBuffer
      if dstFrame.pixelBuffer != nil {
          buffer = dstFrame.pixelBuffer
          if textureID != nil {
              _textures?.textureFrameAvailable(textureID!)
          }
      }
      return 0
    }
}
