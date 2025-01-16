package com.tencent.trtcplugin.listener;
import com.tencent.live.beauty.custom.TXCustomBeautyDef;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;

import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesser;
import com.tencent.trtcplugin.TRTCCloudPlugin;

import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyBufferType;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyPixelFormat;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyVideoFrame;

public class ProcessVideoFrame implements TRTCCloudListener.TRTCVideoFrameListener {
    private ITXCustomBeautyProcesser    mCustomBeautyProcesser;

    public ProcessVideoFrame(ITXCustomBeautyProcesser processer) {
        mCustomBeautyProcesser = processer;
    }

    /**
     * 基于 V2TXLiveVideoFrame 创建
     * @param frame
     */
    private static TXCustomBeautyVideoFrame createCustomBeautyVideoFrame(TRTCCloudDef.TRTCVideoFrame frame) {
        TXCustomBeautyVideoFrame videoFrame = new TXCustomBeautyVideoFrame();
        if (frame.pixelFormat == TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN) {
            videoFrame.pixelFormat = TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatUnknown;
        } else if (frame.pixelFormat == TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_I420) {
            videoFrame.pixelFormat = TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatI420;
        } else if (frame.pixelFormat == TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D) {
            videoFrame.pixelFormat = TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatTexture2D;
        }

        if (frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_UNKNOWN) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeUnknown;
        } else if (frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_ARRAY) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeByteArray;
        } else if (frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_BYTE_BUFFER) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeByteBuffer;
        } else if (frame.bufferType == TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE) {
            videoFrame.bufferType = TXCustomBeautyBufferType.TXCustomBeautyBufferTypeTexture;
        }

        if (null != frame.texture) {
            videoFrame.texture = new TXCustomBeautyDef.TXThirdTexture();
            videoFrame.texture.textureId = frame.texture.textureId;
            videoFrame.texture.eglContext10 = frame.texture.eglContext10;
            videoFrame.texture.eglContext14 = frame.texture.eglContext14;
        }

        videoFrame.data = frame.data;
        videoFrame.buffer = frame.buffer;
        videoFrame.width = frame.width;
        videoFrame.height = frame.height;
        videoFrame.rotation = frame.rotation;
        videoFrame.timestamp = frame.timestamp;
        return videoFrame;
    }

    /**
     * 自定义视频处理回调
     *
     * @param srcFrame 用于承载未处理的视频画面
     * @param dstFrame 用于承载处理过的视频画面
     */
    public int onProcessVideoFrame(TRTCCloudDef.TRTCVideoFrame  srcFrame,
                                   TRTCCloudDef.TRTCVideoFrame  dstFrame) {
        TXCustomBeautyVideoFrame srcThirdFrame = createCustomBeautyVideoFrame(srcFrame);
        TXCustomBeautyVideoFrame dstThirdFrame = createCustomBeautyVideoFrame(dstFrame);
        if(mCustomBeautyProcesser != null) {
            mCustomBeautyProcesser.onProcessVideoFrame(srcThirdFrame, dstThirdFrame);
        }
        if (dstThirdFrame.texture != null) {
            dstFrame.texture.textureId = dstThirdFrame.texture.textureId;
        }
        dstFrame.data = dstThirdFrame.data;
        dstFrame.buffer = dstThirdFrame.buffer;
        dstFrame.width = dstThirdFrame.width;
        dstFrame.height = dstThirdFrame.height;
        dstFrame.rotation = dstThirdFrame.rotation;
        return 0;
    }

    /**
     * SDK 内部的 OpenGL 环境的创建通知
     */
    public void onGLContextCreated() {

    }

    /**
     * SDK 内部的 OpenGL 环境的销毁通知
     */
    public void onGLContextDestory() {
        ITXCustomBeautyProcesserFactory processerFactory = TRTCCloudPlugin.getBeautyProcesserFactory();
        if (processerFactory != null) {
            processerFactory.destroyCustomBeautyProcesser();
        }
        mCustomBeautyProcesser = null;
    }
}
