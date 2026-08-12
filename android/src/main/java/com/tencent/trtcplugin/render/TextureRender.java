package com.tencent.trtcplugin.render;

import android.annotation.TargetApi;
import android.opengl.GLES20;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.view.Surface;

import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtcplugin.utils.TRTCLogger;

import java.nio.FloatBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

@TargetApi(17)
public class TextureRender implements Handler.Callback {

    private static final String TAG = "TextureRender";
    private static final int MSG_DESTROY = 1;

    private final HandlerThread  mRenderThread;
    private final RenderHandler  mRenderHandler;
    private final MethodChannel  mChannel;
    private final Handler        mMainHandler = new Handler(Looper.getMainLooper());

    private volatile boolean mDestroyed = false;

    private final FloatBuffer mVertexBuffer;
    private final FloatBuffer mTexCoordBuffer;

    private EGLHelper      mEgl;
    private GLDrawer       mRenderer;
    private volatile Surface mSurface;
    private android.opengl.EGLContext mSharedEglCtx = null;

    private final TextureEntryCompat mTextureEntry;

    private volatile int mSurfaceW;
    private volatile int mSurfaceH;

    private int mLastInputW;
    private int mLastInputH;

    private int mLastOutputW;
    private int mLastOutputH;

    private int mLastNotifiedW;
    private int mLastNotifiedH;

    public TextureRender(long textureId, BinaryMessenger messenger,
                         TextureEntryCompat textureEntry) {
        mVertexBuffer   = GLDrawer.createVertexBuffer();
        mTexCoordBuffer = GLDrawer.createTexCoordBuffer();
        mChannel = new MethodChannel(messenger, "tencent_rtc_texture_" + textureId);
        mTextureEntry = textureEntry;

        mRenderThread = new HandlerThread(TAG);
        mRenderThread.start();
        mRenderHandler = new RenderHandler(mRenderThread.getLooper(), this);
    }

    public void start(Surface surface, int width, int height) {
        mSurface = surface;
        mSurfaceW = width;
        mSurfaceH = height;
    }

    public void stop() {
        mDestroyed = true;  
        mRenderHandler.obtainMessage(MSG_DESTROY).sendToTarget();
    }

    public void onVideoFrame(TRTCCloudDef.TRTCVideoFrame frame) {
        if (mDestroyed) {
            return;
        }
        mRenderHandler.runAndWaitDone(() -> renderInternal(frame));
    }

    private void notifyAspectRatioIfNeeded(int width, int height) {
        if (width == mLastNotifiedW && height == mLastNotifiedH) {
            return;
        }
        mLastNotifiedW = width;
        mLastNotifiedH = height;
        Map<String, Object> args = new HashMap<>();
        args.put("width", width);
        args.put("height", height);
        mMainHandler.post(() -> mChannel.invokeMethod("updateVideoAspectRatio", args));
    }

    private void initEgl(android.opengl.EGLContext sharedContext) {
        if (mSurface == null || !mSurface.isValid()) {
            return;
        }
        EGLHelper egl = new EGLHelper();
        try {
            egl.initialize(sharedContext, mSurface, mSurfaceW, mSurfaceH);
            egl.makeCurrent();
        } catch (Exception e) {
            TRTCLogger.e("initEgl failed with shared ctx: " + e.getMessage());
            egl.release();
            // Fallback: 不使用 shared context 重试
            if (sharedContext != null) {
                egl = new EGLHelper();
                try {
                    egl.initialize(null, mSurface, mSurfaceW, mSurfaceH);
                    egl.makeCurrent();
                    sharedContext = null;
                } catch (Exception e2) {
                    TRTCLogger.e("initEgl fallback without shared ctx also failed: " + e2.getMessage());
                    egl.release();
                    return;
                }
            } else {
                return;
            }
        }
        mEgl = egl;
        mSharedEglCtx = sharedContext;
        mRenderer = new GLDrawer();
        mRenderer.init();
    }

    private void releaseEgl() {
        if (mRenderer != null) {
            mRenderer.destroy();
            mRenderer = null;
        }
        if (mEgl != null) {
            mEgl.release();
            mEgl = null;
        }
        mSharedEglCtx = null;
    }

    private void renderInternal(TRTCCloudDef.TRTCVideoFrame frame) {
        if (frame.bufferType != TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE) {
            return;
        }

        if (mSurface != null && !mSurface.isValid()) {
            releaseEgl();
            return;
        }

        if (mSurface != null && frame.width > 0 && frame.height > 0
                && (mLastInputW != frame.width || mLastInputH != frame.height)) {
            mSurfaceW = frame.width;
            mSurfaceH = frame.height;
            boolean surfaceChanged = mTextureEntry.setSize(frame.width, frame.height);
            if (surfaceChanged) {
                mSurface = mTextureEntry.getSurface();
                releaseEgl();
            }
            notifyAspectRatioIfNeeded(frame.width, frame.height);
        }

        android.opengl.EGLContext frameEglCtx = (frame.texture != null && frame.texture.eglContext14 != null)
                ? (android.opengl.EGLContext) frame.texture.eglContext14
                : null;

        if (mEgl != null && !mEgl.isContextValid()) {
            releaseEgl();
        }

        if (mEgl != null && frameEglCtx != null && mSharedEglCtx != null
                && mSharedEglCtx != frameEglCtx) {
            releaseEgl();
        }

        if (mEgl == null && mSurface != null && frame.texture != null
                && mSurfaceW > 0 && mSurfaceH > 0) {
            initEgl(frameEglCtx);
        }
        if (mEgl == null) {
            return;
        }

        if (mLastInputW != frame.width || mLastInputH != frame.height
                || mLastOutputW != mSurfaceW || mLastOutputH != mSurfaceH) {
            GLDrawer.updateVertexAndTexCoord(mVertexBuffer, mTexCoordBuffer,
                    false, frame.width, frame.height, mSurfaceW, mSurfaceH);
            mLastInputW = frame.width;
            mLastInputH = frame.height;
            mLastOutputW = mSurfaceW;
            mLastOutputH = mSurfaceH;
        }

        try {
            mEgl.makeCurrent();
        } catch (EGLHelper.EGLException e) {
            TRTCLogger.e("makeCurrent failed: " + e.getMessage());
            releaseEgl();
            return;
        }

        GLES20.glViewport(0, 0, mSurfaceW, mSurfaceH);
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
        GLES20.glClearColor(0, 0, 0, 1f);
        GLES20.glClear(GLES20.GL_DEPTH_BUFFER_BIT | GLES20.GL_COLOR_BUFFER_BIT);

        mRenderer.draw(frame.texture.textureId, mVertexBuffer, mTexCoordBuffer);

        try {
            mEgl.swapBuffers();
        } catch (EGLHelper.EGLException e) {
            TRTCLogger.e("swapBuffers failed: " + e.getMessage());
            releaseEgl();
        }
    }

    private void destroyInternal() {
        mDestroyed = true;
        releaseEgl();
        mRenderHandler.getLooper().quitSafely();
    }

    @Override
    public boolean handleMessage(Message msg) {
        switch (msg.what) {
            case MSG_DESTROY:
                destroyInternal();
                break;
            default:
                break;
        }
        return true;
    }

    static class RenderHandler extends Handler {
        RenderHandler(Looper looper, Callback callback) {
            super(looper, callback);
        }

        void runAndWaitDone(Runnable runnable) {
            final CountDownLatch latch = new CountDownLatch(1);
            boolean posted = post(() -> {
                runnable.run();
                latch.countDown();
            });
            if (!posted) {
                return;
            }
            try {
                latch.await();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }
}
