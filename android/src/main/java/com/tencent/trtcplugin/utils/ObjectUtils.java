package com.tencent.trtcplugin.utils;

import com.tencent.live.beauty.custom.TXCustomBeautyDef;
import com.tencent.trtc.TRTCCloudDef;

public class ObjectUtils {
    public static int convertTRTCPixelFormat(TXCustomBeautyDef.TXCustomBeautyPixelFormat format) {
        switch (format) {
            case TXCustomBeautyPixelFormatUnknown:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN;
            case TXCustomBeautyPixelFormatI420:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420;
            case TXCustomBeautyPixelFormatTexture2D:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
            default:
                return TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN;
        }
    }

    public static int convertTRTCBufferType(TXCustomBeautyDef.TXCustomBeautyBufferType type) {
        switch (type) {
            case TXCustomBeautyBufferTypeUnknown:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_UNKNOWN;
            case TXCustomBeautyBufferTypeByteBuffer:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_BUFFER;
            case TXCustomBeautyBufferTypeByteArray:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY;
            case TXCustomBeautyBufferTypeTexture:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
            default:
                return TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_UNKNOWN;
        }
    }
}
