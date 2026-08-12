//
//  ObjectUtils.swift
//  tencent_rtc_sdk
//
//  Created by iveshe on 2025/3/26.
//

import Foundation
import TXLiteAVSDK_Professional
import TXCustomBeautyProcesserPlugin

class ObjectUtils {
    
    static func convertToTRTCBufferType(beautyBufferType: ITXCustomBeautyBufferType) -> TRTCVideoBufferType {
        switch beautyBufferType {
        case .Unknown:
            return .unknown
        case .PixelBuffer:
            return .pixelBuffer
        case .Data:
            return .nsData
        case .Texture:
            return .texture
        }
    }
    
    static func convertToTRTCPixelFormat(beautyPixelFormat: ITXCustomBeautyPixelFormat) -> TRTCVideoPixelFormat {
        switch beautyPixelFormat {
        case .Unknown:
            return ._Unknown
        case .I420:
            return ._I420
        case .Texture2D:
            return ._Texture_2D
        case .BGRA:
            return ._32BGRA
        case .NV12:
            return ._NV12
        }
    }
    
    
    static func convertTRTCVideoFrame(trtcVideoFrame: TRTCVideoFrame) -> ITXCustomBeautyVideoFrame {
        let beautyVideoFrame = ITXCustomBeautyVideoFrame()
        beautyVideoFrame.data = trtcVideoFrame.data
        beautyVideoFrame.pixelBuffer = trtcVideoFrame.pixelBuffer
        beautyVideoFrame.width = UInt(trtcVideoFrame.width)
        beautyVideoFrame.height = UInt(trtcVideoFrame.height)
        beautyVideoFrame.textureId = trtcVideoFrame.textureId
        
        switch trtcVideoFrame.rotation {
        case ._0:
            beautyVideoFrame.rotation = .rotation_0
        case ._90:
            beautyVideoFrame.rotation = .rotation_90
        case ._180:
            beautyVideoFrame.rotation = .rotation_180
        case ._270:
            beautyVideoFrame.rotation = .rotation_270
        default:
            beautyVideoFrame.rotation = .rotation_0
        }
        
        switch trtcVideoFrame.pixelFormat {
        case ._Unknown:
            beautyVideoFrame.pixelFormat = .Unknown
        case ._I420:
            beautyVideoFrame.pixelFormat = .I420
        case ._Texture_2D:
            beautyVideoFrame.pixelFormat = .Texture2D
        case ._32BGRA:
            beautyVideoFrame.pixelFormat = .BGRA
        case ._NV12:
            beautyVideoFrame.pixelFormat = .NV12
        default:
            beautyVideoFrame.pixelFormat = .Unknown
        }
        
        beautyVideoFrame.bufferType = ITXCustomBeautyBufferType(rawValue:
            trtcVideoFrame.bufferType.rawValue) ?? .Unknown
        beautyVideoFrame.timestamp = trtcVideoFrame.timestamp
        return beautyVideoFrame
    }
}
