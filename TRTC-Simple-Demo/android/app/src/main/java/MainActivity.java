package com.tencent.trtc_demo;
import android.os.Bundle;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.content.Intent;

import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesser;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyBufferType;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyPixelFormat;
import static com.tencent.live.beauty.custom.TXCustomBeautyDef.TXCustomBeautyVideoFrame;

import com.tencent.trtc_demo.opengl.FrameBuffer;
import com.tencent.trtc_demo.opengl.GpuImageGrayscaleFilter;
import com.tencent.trtc_demo.opengl.OpenGlUtils;
import com.tencent.trtc_demo.opengl.Rotation;
import com.tencent.trtcplugin.TRTCCloudPlugin;

import java.nio.FloatBuffer;
import android.opengl.GLES20;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    startService(new Intent(this, MediaService.class));
  }
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    TRTCCloudPlugin.register(new TXThirdBeauty());
  }

  class TXThirdBeauty implements ITXCustomBeautyProcesserFactory {

    private BeautyProcessor customBeautyProcesser;

    @Override
    public ITXCustomBeautyProcesser createCustomBeautyProcesser() {
      customBeautyProcesser = new BeautyProcessor();
      return customBeautyProcesser;
    }

    @Override
    public void destroyCustomBeautyProcesser() {
      if (null != customBeautyProcesser) {
        customBeautyProcesser.destroy();
        customBeautyProcesser = null;
      }
    }
  }

  class BeautyProcessor implements ITXCustomBeautyProcesser {

    private FrameBuffer mFrameBuffer;
    private GpuImageGrayscaleFilter mGrayscaleFilter;
    private FloatBuffer mGLCubeBuffer;
    private FloatBuffer mGLTextureBuffer;

    public void destroy() {
      if (mFrameBuffer != null) {
        mFrameBuffer.uninitialize();
        mFrameBuffer = null;
      }
      if (mGrayscaleFilter != null) {
        mGrayscaleFilter.destroy();
        mGrayscaleFilter = null;
      }
    }

    @Override
    public TXCustomBeautyPixelFormat getSupportedPixelFormat() {
      return TXCustomBeautyPixelFormat.TXCustomBeautyPixelFormatTexture2D;
    }

    @Override
    public TXCustomBeautyBufferType getSupportedBufferType() {
      return TXCustomBeautyBufferType.TXCustomBeautyBufferTypeTexture;
    }

    @Override
    public void onProcessVideoFrame(TXCustomBeautyVideoFrame srcFrame, TXCustomBeautyVideoFrame dstFrame) {
      final int width = srcFrame.width;
      final int height = srcFrame.height;
      if (mFrameBuffer == null || mFrameBuffer.getWidth() != width || mFrameBuffer.getHeight() != height) {
        if (mFrameBuffer != null) {
          mFrameBuffer.uninitialize();
        }
        mFrameBuffer = new FrameBuffer(width, height);
        mFrameBuffer.initialize();
      }
      if (mGrayscaleFilter == null) {
        mGrayscaleFilter = new GpuImageGrayscaleFilter();
        mGrayscaleFilter.init();
        mGrayscaleFilter.onOutputSizeChanged(width, height);

        mGLCubeBuffer = OpenGlUtils.createNormalCubeVerticesBuffer();
        mGLTextureBuffer = OpenGlUtils.createTextureCoordsBuffer(Rotation.NORMAL, false, false);
      }
      GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFrameBuffer.getFrameBufferId());
      GLES20.glViewport(0, 0, width, height);
      mGrayscaleFilter.onDraw(srcFrame.texture.textureId, mGLCubeBuffer, mGLTextureBuffer);
      dstFrame.texture.textureId = mFrameBuffer.getTextureId();
      GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
    }
  }
}
