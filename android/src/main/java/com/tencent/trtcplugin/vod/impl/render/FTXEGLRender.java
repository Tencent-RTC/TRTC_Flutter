package com.tencent.trtcplugin.vod.impl.render;

import android.graphics.SurfaceTexture;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.os.Handler;
import android.os.HandlerThread;
import android.view.Surface;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.trtcplugin.vod.FTXPlayerConstants;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class FTXEGLRender implements SurfaceTexture.OnFrameAvailableListener {

    private static final String TAG = "FTXEGLRender";

    private static final long FRAME_WAIT_TIME = 5000;
    private static final int FPS_DEFAULT = 30;
    // min refresh count for obtain new img
    private static final int RE_DRAW_COUNT = 30;

    private SurfaceTexture mSurfaceTexture;
    private FTXTextureRender mTextureRender;
    private Surface mInputSurface;
    private Surface mOutPutSurface;

    private EGLDisplay mEGLDisplay = EGL14.EGL_NO_DISPLAY;
    private final EGLContext mEGLContext = EGL14.EGL_NO_CONTEXT;
    private EGLContext mEGLContextEncoder = EGL14.EGL_NO_CONTEXT;
    private final EGLSurface mEGLSurface = EGL14.EGL_NO_SURFACE;
    private EGLSurface mEGLSurfaceEncoder = EGL14.EGL_NO_SURFACE;

    private EGLContext mEGLSavedContext = EGL14.EGL_NO_CONTEXT;
    private EGLDisplay mEGLSavedDisplay = EGL14.EGL_NO_DISPLAY;
    private EGLSurface mEGLSaveReadSurface = EGL14.EGL_NO_SURFACE;
    private EGLSurface mEGLSaveDrawSurface = EGL14.EGL_NO_SURFACE;

    private int mWidth;
    private int mHeight;
    private float mRotation = 0;
    private boolean mStart = false;
    private final Lock mLock = new ReentrantLock();
    private long mPreTime = 0;
    private long mCurrentTime;
    private long mRenderMode = FTXPlayerConstants.FTXRenderMode.FULL_FILL_CONTAINER;
    private int mViewWidth;
    private int mViewHeight;
    private int mFps;
    private float frameInterval = 0;
    private HandlerThread mDrawHandlerThread = new HandlerThread(TAG);
    private Handler mDrawHandler = null;
    private boolean isReleased = false;
    private boolean mIsFirstFrame = false;

    private FVodTRTCHelper mTRTCHelper;
    private boolean mEnableFrameCopy = false;
    private OnFrameCopyListener mFrameCopyListener;
    private FTXPixelFrame mCachedPixelFrame;  // 复用的帧对象，避免频繁创建

    public interface OnFrameCopyListener {

        void onFrameCopied(FTXPixelFrame frame);
    }

    public FTXEGLRender(int width, int height) {
        this(width, height, FPS_DEFAULT);
    }

    public FTXEGLRender(int width, int height, int fps) {
        mWidth = width;
        mHeight = height;
        this.mFps = fps;
        frameInterval = (float) 1000 / fps - (float) ((float) 1000 / fps * 0.15);
        LiteavLog.i(TAG, "initFPs fps: " + fps + "video_interval: " + frameInterval);
    }

    @Override
    public void onFrameAvailable(SurfaceTexture surfaceTexture) {
        /*
        onFrameAvailable 默认在主线程回调，导致使用 onFrameAvailable 触发的渲染动作，会受到主线程其他操作的影响，导致渲染产生延迟。
        一般情况下会晚两到五帧左右，尤其表现在起播的时候，首帧事件已经来临，但是画面延迟了一点（播放过程中不受影响，因为渲染的虽然晚了，但是画面拉取的仍然是当前最新的画面）
        。或者暂停状态下 seek，seek 之后画面改变，纹理上的画面仍然是 seek 之前或者上一次 seek 的画面。
        所以这里使用独立线程主动拉取画面进行渲染，但是一直拉取画面，会导致发热情况严重，所以默认有 60帧率的限制。所以这块播放器默认帧率为 60帧。
         */
        if (mStart) {
            mDrawHandler.post(new Runnable() {
                @Override
                public void run() {
                    if (!mIsFirstFrame) {
                        mLock.lock();
                        startDrawSurface(true);
                        mLock.unlock();
                    } else {
                        mIsFirstFrame = false;
                        refreshRender(true);
                    }
                }
            });
        }
    }

    private synchronized void startDrawSurface(boolean isNewFrame) {
        try {
            if (!mStart) {
                LiteavLog.e(TAG, "draw thread is dead");
                return;
            }
            saveCurrentEglEnvironment();
            if (!makeCurrent(1)) {
                return;
            }
            if (!mOutPutSurface.isValid()) {
                return;
            }

            mCurrentTime = System.currentTimeMillis();

            if (isNewFrame) {
                try {
                    mSurfaceTexture.updateTexImage();
                } catch (Exception e) {
                    LiteavLog.e(TAG, "updateTexImage failed: " + e.getMessage());
                    return;
                }
            }

            mTextureRender.drawFrame();
            swapBuffers();
            mPreTime = mCurrentTime;

            // 如果启用了帧复制，在绘制前复制一份纹理
            if (mEnableFrameCopy) {
                copyFrameForTRTC();
            }

        } catch (Exception e) {
            LiteavLog.e(TAG, "startDrawSurface error: " + e);
        } finally {
            restoreEglEnvironment();
        }
    }

    public boolean initOpengl(Surface surface, boolean needClearOld) {
        LiteavLog.i(TAG, "initOpengl " + (null == surface ? "null" : ""));
        isReleased = false;
        mIsFirstFrame = true;
        boolean bRet = true;
        do {
            saveCurrentEglEnvironment();
            if (!eglSetup(surface)) {
                LiteavLog.e(TAG, "eglSetup error");
                bRet = false;
                break;
            }

            if (!makeCurrent(1)) {
                bRet = false;
                break;
            }
        } while (false);

        if (!bRet) {
            releaseEgl();
            restoreEglEnvironment();
            return bRet;
        }

        setup(needClearOld);

        restoreEglEnvironment();
        return true;
    }

    public boolean initOpengl(Surface surface) {
        return initOpengl(surface, true);
    }

    /**
     * Creates interconnected instances of TextureRender, SurfaceTexture, and Surface.
     */
    private void setup(boolean needClearOld) {
        mTextureRender = new FTXTextureRender(mViewWidth, mViewHeight);
        mTextureRender.surfaceCreated();
        mTextureRender.updateSizeAndRenderMode(mWidth, mHeight, mRenderMode);
        mTextureRender.setRotationAngle(mRotation);
        LiteavLog.d(TAG, "textureID=" + mTextureRender.getTextureID());
        if (null == mInputSurface || needClearOld) {
            mSurfaceTexture = new SurfaceTexture(mTextureRender.getTextureID());
            // vide size for soft encode surface
            mSurfaceTexture.setDefaultBufferSize(mViewWidth, mViewHeight);
            mSurfaceTexture.setOnFrameAvailableListener(this);
            mInputSurface = new Surface(mSurfaceTexture);
        }
    }

    public void updateSizeAndRenderMode(int width, int height, long renderMode) {
        mWidth = width;
        mHeight = height;
        mRenderMode = renderMode;
        if (null != mTextureRender) {
            mTextureRender.updateSizeAndRenderMode(width, height, renderMode);
        } else {
            LiteavLog.w(TAG, "mTextureRender is null");
        }
    }

    public void updateRotation(float rotation) {
        mRotation = rotation;
        if (null != mTextureRender) {
            mTextureRender.setRotationAngle(rotation);
        } else {
            LiteavLog.w(TAG, "mTextureRender is null");
        }
    }

    public void setViewPortSize(int width, int height) {
        mViewWidth = width;
        mViewHeight = height;
        if (null != mSurfaceTexture) {
            mSurfaceTexture.setDefaultBufferSize(width, height);
        }
        if (null != mTextureRender) {
            mTextureRender.setViewPortSize(width, height);
        }
    }

    private boolean eglSetup(Surface surface) {
        mEGLDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
        if (mEGLDisplay == EGL14.EGL_NO_DISPLAY) {
            checkEglError("unable to get EGL10 display");
            return false;
        }

        int[] version = new int[2];
        if (!EGL14.eglInitialize(mEGLDisplay, version, 0, version, 1)) {
            checkEglError("unable to initialize EGL10");
            return false;
        }
        // Configure EGL for pbuffer and OpenGL ES 2.0, 24-bit RGB.
        int[] attribList = new int[]{
                EGL14.EGL_RED_SIZE, 8,
                EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8,
                EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                EGL14.EGL_SURFACE_TYPE, EGL14.EGL_WINDOW_BIT,
                EGL14.EGL_NONE
        };

        int[] numEglConfigs = new int[1];
        EGLConfig[] eglConfigs = new EGLConfig[1];
        if (!EGL14.eglChooseConfig(mEGLDisplay, attribList, 0, eglConfigs, 0,
                eglConfigs.length, numEglConfigs, 0)) {
            checkEglError("eglChooseConfig error");
            return false;
        }
        // Configure context for OpenGL ES 2.0.
        //6、创建 EglContext
        int[] attrib_list = new int[]{
                EGL14.EGL_CONTEXT_CLIENT_VERSION, 2,
                EGL14.EGL_NONE
        };

        mEGLContextEncoder = EGL14.eglCreateContext(mEGLDisplay, eglConfigs[0], EGL14.EGL_NO_CONTEXT,
                attrib_list, 0);
        checkEglError("eglCreateContext", false);
        if (mEGLContextEncoder == EGL14.EGL_NO_CONTEXT) {
            LiteavLog.e(TAG, "null context2");
            return false;
        }

        int[] surfaceAttribs2 = {
                EGL14.EGL_NONE
        };
        mEGLSurfaceEncoder = EGL14.eglCreateWindowSurface(mEGLDisplay, eglConfigs[0], surface,
                surfaceAttribs2, 0);   //creates an EGL window surface and returns its handle
        checkEglError("eglCreateWindowSurface", false);

        if (mEGLSurfaceEncoder == EGL14.EGL_NO_SURFACE) {
            LiteavLog.e(TAG, "surface was null");
            return false;
        }
        mOutPutSurface = surface;
        return true;
    }

    private boolean checkEglError(String msg) {
        return checkEglError(msg, true);
    }

    private boolean checkEglError(String msg, boolean needPrintMsg) {
        int error = 0;
        if ((error = EGL14.eglGetError()) != EGL14.EGL_SUCCESS) {
            LiteavLog.e(TAG, "checkEglError: " + msg + "error: " + error);
            return false;
        } else if (needPrintMsg) {
            LiteavLog.e(TAG, msg);
        }

        return true;
    }

    public boolean makeCurrent(int index) {
        if (index == 0) {
            if (!EGL14.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
                checkEglError("makeCurrent");
                return false;
            }
        } else {
            if (!EGL14.eglMakeCurrent(mEGLDisplay, mEGLSurfaceEncoder, mEGLSurfaceEncoder, mEGLContextEncoder)) {
                checkEglError("makeCurrent");
                return false;
            }
        }
        return true;
    }

    public boolean swapBuffers() {
        boolean result = EGL14.eglSwapBuffers(mEGLDisplay, mEGLSurfaceEncoder);
        checkEglError("eglSwapBuffers", false);
        return result;
    }

    private void saveCurrentEglEnvironment() {
        try {
            // 获取当前环境
            mEGLSavedDisplay = EGL14.eglGetCurrentDisplay();
            mEGLSavedContext = EGL14.eglGetCurrentContext();
            mEGLSaveDrawSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_DRAW);
            mEGLSaveReadSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_READ);
        } catch (Exception e) {
            LiteavLog.e(TAG, "Save EGL error: " + e);
            resetSavedEnvironment();
        }
    }

    private void resetSavedEnvironment() {
        mEGLSavedDisplay = EGL14.EGL_NO_DISPLAY;
        mEGLSaveDrawSurface = EGL14.EGL_NO_SURFACE;
        mEGLSaveReadSurface = EGL14.EGL_NO_SURFACE;
        mEGLSavedContext = EGL14.EGL_NO_CONTEXT;
    }

    private void restoreEglEnvironment() {
        try {
            // 检查是否有效保存了EGL环境
            if (mEGLSavedDisplay != EGL14.EGL_NO_DISPLAY
                    && mEGLSavedContext != EGL14.EGL_NO_CONTEXT
                    && mEGLSaveDrawSurface != EGL14.EGL_NO_SURFACE) {

                // 检查当前环境是否已被更改
                EGLDisplay currentDisplay = EGL14.eglGetCurrentDisplay();
                EGLContext currentContext = EGL14.eglGetCurrentContext();
                EGLSurface currentDrawSurface = EGL14.eglGetCurrentSurface(EGL14.EGL_DRAW);

                // 仅在必要时才恢复环境
                if (!mEGLSavedDisplay.equals(currentDisplay)
                        || !mEGLSavedContext.equals(currentContext)
                        || !mEGLSaveDrawSurface.equals(currentDrawSurface)) {

                    // 安全恢复操作
                    if (!EGL14.eglMakeCurrent(
                            mEGLSavedDisplay,
                            mEGLSaveDrawSurface,
                            mEGLSaveReadSurface,
                            mEGLSavedContext)) {

                        int error = EGL14.eglGetError();
                        LiteavLog.e(TAG, "Restore failed: EGL error 0x" + Integer.toHexString(error));

                        // 恢复失败时的安全回退
                        EGL14.eglMakeCurrent(
                                mEGLSavedDisplay,
                                EGL14.EGL_NO_SURFACE,
                                EGL14.EGL_NO_SURFACE,
                                EGL14.EGL_NO_CONTEXT
                        );
                    }
                }
            } else {
                if (mEGLDisplay != EGL14.EGL_NO_DISPLAY) {
                    EGL14.eglMakeCurrent(
                            mEGLDisplay,
                            EGL14.EGL_NO_SURFACE,
                            EGL14.EGL_NO_SURFACE,
                            EGL14.EGL_NO_CONTEXT
                    );
                }
            }
        } catch (Exception e) {
            LiteavLog.e(TAG, "Critical restore error: " + e);
        } finally {
            // 重置保存的环境状态
            mEGLSavedDisplay = EGL14.EGL_NO_DISPLAY;
            mEGLSaveDrawSurface = EGL14.EGL_NO_SURFACE;
            mEGLSaveReadSurface = EGL14.EGL_NO_SURFACE;
            mEGLSavedContext = EGL14.EGL_NO_CONTEXT;
        }
    }

    private void releaseEgl() {
        if (mEGLDisplay != EGL14.EGL_NO_DISPLAY) {
            EGL14.eglMakeCurrent(mEGLDisplay, EGL14.EGL_NO_SURFACE,
                    EGL14.EGL_NO_SURFACE,
                    EGL14.EGL_NO_CONTEXT);
        }
        if (mEGLSurfaceEncoder != EGL14.EGL_NO_SURFACE) {
            EGL14.eglDestroySurface(mEGLDisplay, mEGLSurfaceEncoder);
        }
        if (mEGLContextEncoder != EGL14.EGL_NO_CONTEXT) {
            EGL14.eglDestroyContext(mEGLDisplay, mEGLContextEncoder);
        }

        EGL14.eglTerminate(mEGLDisplay);

        mEGLDisplay = EGL14.EGL_NO_DISPLAY;
        mEGLSurfaceEncoder = EGL14.EGL_NO_SURFACE;
        mEGLContextEncoder = EGL14.EGL_NO_CONTEXT;
    }

    private void eglUninstall(boolean needReleaseDecodeSurface) {
        if (!makeCurrent(1)) {
            LiteavLog.e(TAG, "makeCurrent error");
            return;
        }
        if (mTextureRender != null) {
            mTextureRender.deleteTexture();
        }
        
        if (mTRTCHelper != null) {
            mTRTCHelper.release();
            mTRTCHelper = null;
        }

        releaseEgl();

        if (needReleaseDecodeSurface && mInputSurface != null) {
            mInputSurface.release();
            mInputSurface = null;
        }
        
        if (mSurfaceTexture != null) {
            mSurfaceTexture.release();
            mSurfaceTexture = null;
        }
    }

    public void startRender() {
        LiteavLog.i(TAG, "called start render");
        if (mDrawHandlerThread.isAlive()) {
            LiteavLog.e(TAG, "old draw thread is alive, stop first");
            mDrawHandlerThread.quitSafely();
        }
        mDrawHandlerThread = new HandlerThread(TAG);
        mDrawHandlerThread.start();
        mDrawHandler = new Handler(mDrawHandlerThread.getLooper());
        mStart = true;
    }

    public void refreshRender() {
        refreshRender(false);
    }

    public void refreshRender(boolean isForcePullFrame) {
        if (null != mDrawHandler) {
            mDrawHandler.post(new Runnable() {
                @Override
                public void run() {
                    mLock.lock();
                    for (int i = 0; i < RE_DRAW_COUNT; i++) {
                        startDrawSurface(isForcePullFrame);
                    }
                    mLock.unlock();
                }
            });
        }
    }

    public synchronized void resumeRender() {
        mLock.lock();
        mStart = true;
        mLock.unlock();
    }

    public synchronized void pauseRender() {
        mLock.lock();
        mStart = false;
        mLock.unlock();
    }

    public synchronized void stopRender() {
        stopRender(true);
    }

    public synchronized void stopRender(boolean isCompleteRelease) {
        if (isReleased) {
            LiteavLog.i(TAG, "stopRender return, already released");
            return;
        }
        LiteavLog.i(TAG, "stopRender");
        // unLock render thread
        mStart = false;
        mRotation = 0;
        if (null != mTextureRender) {
            mTextureRender.setRotationAngle(0);
        }
        saveCurrentEglEnvironment();
        final boolean contextCompare = mEGLContextEncoder.equals(mEGLSavedContext);
        eglUninstall(isCompleteRelease);
        if (null != mDrawHandlerThread) {
            mDrawHandlerThread.quitSafely();
            mDrawHandler = null;
        }

        mEnableFrameCopy = false;
        mFrameCopyListener = null;
        mCachedPixelFrame = null;

        if (!contextCompare) {
            LiteavLog.d(TAG, "restoreEglEnvironment");
            restoreEglEnvironment();
        }
        isReleased = true;
    }

    public Surface getInputSurface() {
        return mInputSurface;
    }

    public void clearSurfaceIfCan() {
        if (null != mTextureRender) {
            mTextureRender.cleanDrawCache();
        }
    }

    public void setEnableFrameCopy(boolean enable, OnFrameCopyListener listener) {
        mEnableFrameCopy = enable;
        mFrameCopyListener = listener;
    }

    /**
     * 复制当前帧用于 TRTC 推流
     */
    private void copyFrameForTRTC() {
        if (!mEnableFrameCopy || mTextureRender == null) {
            return;
        }

        int textureId = mTextureRender.getTextureID();
        if (textureId <= 0) {
            return;
        }

        if (mTRTCHelper == null) {
            mTRTCHelper = new FVodTRTCHelper();
        }

        int copyWidth = mWidth;
        int copyHeight = mHeight;
        if (copyWidth <= 0 || copyHeight <= 0) {
            return;
        }

        if (!mTRTCHelper.isInitialized()
                || mTRTCHelper.getTextureWidth() != copyWidth
                || mTRTCHelper.getTextureHeight() != copyHeight) {
            if (!mTRTCHelper.init(copyWidth, copyHeight)) {
                LiteavLog.e(TAG, "Failed to init TRTCHelper");
                return;
            }
        }

        int copyTextureId = mTRTCHelper.copyFrame(textureId);
        if (copyTextureId > 0 && mFrameCopyListener != null) {
            // 单线程模型使用成员变量
            if (mCachedPixelFrame == null) {
                mCachedPixelFrame = new FTXPixelFrame();
            }
            mCachedPixelFrame.setTextureId(copyTextureId);
            mCachedPixelFrame.setWidth(copyWidth);
            mCachedPixelFrame.setHeight(copyHeight);
            mCachedPixelFrame.setGLContext(mEGLContextEncoder);
            mFrameCopyListener.onFrameCopied(mCachedPixelFrame);
        }
    }

    // ---- Nested types (formerly standalone files in player/render/ and player/render/gl/) ----

    /**
     * Lightweight bag of texture/context info handed off to TRTC custom-video-capture path. Was a
     * standalone {@code FTXPixelFrame.java} before the simplify pass.
     */
    public static class FTXPixelFrame {

        private int textureId;

        private Object glContext;

        private int width;

        private int height;

        public int getTextureId() {
            return textureId;
        }

        public void setTextureId(int textureId) {
            this.textureId = textureId;
        }

        public Object getGLContext() {
            return glContext;
        }

        public void setGLContext(Object glContext) {
            this.glContext = glContext;
        }

        public int getWidth() {
            return width;
        }

        public void setWidth(int width) {
            this.width = width;
        }

        public int getHeight() {
            return height;
        }

        public void setHeight(int height) {
            this.height = height;
        }
    }

    /**
     * One-shot helper that paints a black frame onto a {@link Surface}, used to clear the last
     * decoded image. Was a standalone {@code GLSurfaceTools.java} before the simplify pass.
     */
    public static class GLSurfaceTools {

        public void clearSurface(Surface surface) {
            EGLDisplay display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
            int[] version = new int[2];
            EGL14.eglInitialize(display, version, 0, version, 1);
            int[] attribList = {
                    EGL14.EGL_RED_SIZE, 8,
                    EGL14.EGL_GREEN_SIZE, 8,
                    EGL14.EGL_BLUE_SIZE, 8,
                    EGL14.EGL_ALPHA_SIZE, 8,
                    EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT,
                    EGL14.EGL_NONE, 0,
                    EGL14.EGL_NONE
            };
            EGLConfig[] configs = new EGLConfig[1];
            int[] numConfigs = new int[1];
            EGL14.eglChooseConfig(display, attribList, 0, configs, 0, configs.length, numConfigs, 0);

            EGLConfig config = configs[0];
            EGLContext context = EGL14.eglCreateContext(display, config, EGL14.EGL_NO_CONTEXT, new int[]{
                    EGL14.EGL_CONTEXT_CLIENT_VERSION, 2,
                    EGL14.EGL_NONE
            }, 0);
            EGLSurface eglSurface = EGL14.eglCreateWindowSurface(display, config, surface,
                    new int[]{
                            EGL14.EGL_NONE
                    }, 0);
            EGL14.eglMakeCurrent(display, eglSurface, eglSurface, context);
            android.opengl.GLES20.glClearColor(0, 0, 0, 1);
            android.opengl.GLES20.glClear(android.opengl.GLES20.GL_COLOR_BUFFER_BIT);
            EGL14.eglSwapBuffers(display, eglSurface);
            EGL14.eglDestroySurface(display, eglSurface);
            EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
            EGL14.eglDestroyContext(display, context);
            EGL14.eglTerminate(display);
        }
    }

    /**
     * GL texture painter that draws the decoded SurfaceTexture onto the current EGL surface. Was a
     * standalone {@code FTXTextureRender.java} before the simplify pass; inlined here as a
     * package-private static nested class because it is consumed solely by {@link FTXEGLRender}.
     */
    static class FTXTextureRender {
        private static final int FLOAT_SIZE_BYTES = 4;
        private static final String TAG_TR = "FTXTextureRender";

        private static final float[] FULL_RECTANGLE_COORDS = {
                -1.0f, -1.0f, 1.0f,   // 0 bottom left
                1.0f, -1.0f, 1.0f,   // 1 bottom right
                -1.0f, 1.0f, 1.0f,   // 2 top left
                1.0f, 1.0f, 1.0f   // 3 top right
        };

        private static final float[] FULL_RECTANGLE_TEX_COORDS = {
                0.0f, 1.0f, 1f, 1.0f,    // 0 bottom left
                1.0f, 1.0f, 1f, 1.0f,     // 1 bottom right
                0.0f, 0.0f, 1f, 1.0f,    // 2 top left
                1.0f, 0.0f, 1f, 1.0f     // 3 top right
        };

        private static final java.nio.FloatBuffer FULL_RECTANGLE_BUF =
                TXGlUtilVideo.createFloatBuffer(FULL_RECTANGLE_COORDS);
        private static final java.nio.FloatBuffer FULL_RECTANGLE_TEX_BUF =
                TXGlUtilVideo.createFloatBuffer(FULL_RECTANGLE_TEX_COORDS);

        private static final String VERTEX_SHADER =
                "uniform mat4 uMVPMatrix;\n" +
                        "attribute vec4 aPosition;\n" +
                        "attribute vec2 aTextureCoord;\n" +
                        "varying vec2 vTextureCoord;\n" +
                        "void main() {\n" +
                        "    gl_Position = uMVPMatrix * aPosition;\n" +
                        "    vTextureCoord = aTextureCoord;\n" + // Core fix: apply the texture matrix.
                        "}\n";

        private static final String VIDEO_FRAGMENT_SHADER =
                "#extension GL_OES_EGL_image_external : require\n"
                        + "precision mediump float;\n"
                        + "varying vec2 vTextureCoord;\n"
                        + "uniform samplerExternalOES sTexture;\n"
                        + "void main() {\n"
                        + "    vec2 safeCoord = vTextureCoord;\n"
                        + "    safeCoord.x = clamp(safeCoord.x, 0.001, 0.999);\n"
                        + "    safeCoord.y = clamp(safeCoord.y, 0.001, 0.999);\n"
                        + "    gl_FragColor = texture2D(sTexture, safeCoord);\n"
                        + "}\n";

        private final float[] projectionMatrix = new float[16];
        private final float[] rotationMatrix = new float[16];
        private final float[] mResultMatrix = new float[16];

        private int mVideoFragmentProgram;
        private int muMVPMatrixHandle;
        private int maPositionHandle;
        private int maTexCoordHandle;
        private int maTextureHandle;
        private int mVideoWidth;
        private int mVideoHeight;
        private final int[] textureID = new int[1];
        private long mRenderMode = FTXPlayerConstants.FTXRenderMode.FULL_FILL_CONTAINER;
        private int mPortWidth;
        private int mPortHeight;

        private float rotationAngle = 0;

        FTXTextureRender(int width, int height) {
            mPortWidth = width;
            mPortHeight = height;
        }

        /**
         * Initializes GL state. Call this after the EGL surface has been created and made current.
         */
        void surfaceCreated() {
            mVideoFragmentProgram = TXGlUtilVideo.createProgram(VERTEX_SHADER, VIDEO_FRAGMENT_SHADER);
            maPositionHandle = android.opengl.GLES20.glGetAttribLocation(mVideoFragmentProgram, "aPosition");
            maTexCoordHandle = android.opengl.GLES20.glGetAttribLocation(mVideoFragmentProgram, "aTextureCoord");
            muMVPMatrixHandle = android.opengl.GLES20.glGetUniformLocation(mVideoFragmentProgram, "uMVPMatrix");
            maTextureHandle = android.opengl.GLES20.glGetUniformLocation(mVideoFragmentProgram, "sTexture");

            textureID[0] = initTex();
        }

        int getTextureID() {
            return textureID[0];
        }

        void deleteTexture() {
            android.opengl.GLES20.glDeleteProgram(mVideoFragmentProgram);
            android.opengl.GLES20.glDeleteTextures(1, textureID, 0);
        }

        /**
         * Create external texture.
         *
         * @return texture ID
         */
        int initTex() {
            int[] tex = new int[1];
            android.opengl.GLES20.glGenTextures(1, tex, 0);
            android.opengl.GLES20.glActiveTexture(android.opengl.GLES20.GL_TEXTURE0);
            android.opengl.GLES20.glBindTexture(android.opengl.GLES11Ext.GL_TEXTURE_EXTERNAL_OES, tex[0]);
            android.opengl.GLES20.glTexParameteri(android.opengl.GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                    android.opengl.GLES20.GL_TEXTURE_WRAP_S, android.opengl.GLES20.GL_CLAMP_TO_EDGE);
            android.opengl.GLES20.glTexParameteri(android.opengl.GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                    android.opengl.GLES20.GL_TEXTURE_WRAP_T, android.opengl.GLES20.GL_CLAMP_TO_EDGE);
            android.opengl.GLES20.glTexParameterf(android.opengl.GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                    android.opengl.GLES20.GL_TEXTURE_MIN_FILTER, android.opengl.GLES20.GL_LINEAR);
            android.opengl.GLES20.glTexParameterf(android.opengl.GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                    android.opengl.GLES20.GL_TEXTURE_MAG_FILTER, android.opengl.GLES20.GL_LINEAR);
            return tex[0];
        }

        void updateSizeAndRenderMode(int width, int height, long renderMode) {
            mVideoWidth = width;
            mVideoHeight = height;
            mRenderMode = renderMode;
            if (mPortWidth > 0 && mPortHeight > 0 && mVideoWidth > 0 && mVideoHeight > 0) {
                float left = -1;
                float right = 1;
                float top = 1;
                float bottom = 1;

                final float videoRadio = (float) mVideoWidth / mVideoHeight;
                final float viewRadio = (float) mPortWidth / mPortHeight;
                boolean isFixWidth = false;
                if (renderMode == FTXPlayerConstants.FTXRenderMode.ADJUST_RESOLUTION) {
                    isFixWidth = videoRadio > viewRadio;
                } else if (renderMode == FTXPlayerConstants.FTXRenderMode.FULL_FILL_CONTAINER) {
                    isFixWidth = videoRadio <= viewRadio;
                }

                if (isFixWidth) {
                    final float viewShouldHeight = mPortWidth / videoRadio;
                    final float heightRadio = viewShouldHeight / mPortHeight;
                    left = -1f;
                    right = 1f;
                    bottom = -1f / heightRadio;
                    top = 1f / heightRadio;
                    LiteavLog.i(TAG_TR, "heightRadio:" + heightRadio + ",mWidth:" + mVideoWidth
                            + ",mHeight:" + mVideoHeight + ",viewWidth:" + mPortWidth + "，viewHeight:"
                            + mPortHeight + ",hashCode:" + hashCode());
                } else {
                    final float viewShouldWidth = mPortHeight * videoRadio;
                    final float widthRadio = viewShouldWidth / mPortWidth;
                    left = -1f / widthRadio;
                    right = 1f / widthRadio;
                    bottom = -1f;
                    top = 1f;
                    LiteavLog.i(TAG_TR, "widthRadio:" + widthRadio + ",mWidth:" + mVideoWidth
                            + ",mHeight:" + mVideoHeight + ",viewWidth:" + mPortWidth + "，viewHeight:"
                            + mPortHeight + ",hashCode:" + hashCode());
                }
                updateProjection(left, right, bottom, top);
            } else {
                LiteavLog.w(TAG_TR, "updateSizeAndRenderMode failed, size maybe zero, mWidth:" + mVideoWidth
                        + ",mHeight:" + mVideoHeight + ",viewWidth:" + mPortWidth + "，viewHeight:"
                        + mPortHeight + ",hashCode:" + hashCode());
            }
        }

        void setViewPortSize(int width, int height) {
            mPortWidth = width;
            mPortHeight = height;
            LiteavLog.i(TAG_TR, "setViewPortSize：,viewWidth:" + mPortWidth
                    + "，viewHeight：" + mPortHeight + ",hashCode:" + hashCode());
            updateSizeAndRenderMode(mVideoWidth, mVideoHeight, mRenderMode);
        }

        private void updateProjection(float left, float right, float bottom, float top) {
            // reset
            android.opengl.Matrix.setIdentityM(projectionMatrix, 0);
            android.opengl.Matrix.orthoM(projectionMatrix, 0, left, right, bottom, top, -1f, 1f);
            // merge
            mergerMatrix();
        }

        void setRotationAngle(float angle) {
            rotationAngle = angle;
            // reset
            android.opengl.Matrix.setIdentityM(rotationMatrix, 0);
            android.opengl.Matrix.setRotateM(rotationMatrix, 0, rotationAngle, 0, 0, -1);
            // merge
            mergerMatrix();
        }

        private synchronized void mergerMatrix() {
            // reset
            android.opengl.Matrix.setIdentityM(mResultMatrix, 0);
            android.opengl.Matrix.multiplyMM(mResultMatrix, 0, projectionMatrix, 0, rotationMatrix, 0);
        }

        void cleanDrawCache() {
            android.opengl.GLES20.glViewport(0, 0, mPortWidth, mPortHeight);
            android.opengl.GLES20.glClear(android.opengl.GLES20.GL_COLOR_BUFFER_BIT);
        }

        /**
         * Draws the external texture in SurfaceTexture onto the current EGL surface.
         */
        synchronized void drawFrame() {
            cleanDrawCache();
            // video frame
            android.opengl.GLES20.glUseProgram(mVideoFragmentProgram);

            // OpenGL rotates counterclockwise, here it needs to be modified to rotate clockwise.
            android.opengl.GLES20.glUniformMatrix4fv(muMVPMatrixHandle, 1, false, mResultMatrix, 0);

            android.opengl.GLES20.glActiveTexture(android.opengl.GLES20.GL_TEXTURE0);
            android.opengl.GLES20.glBindTexture(android.opengl.GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureID[0]);
            android.opengl.GLES20.glUniform1i(maTextureHandle, 0);

            // Enable the "aPosition" vertex attribute.
            android.opengl.GLES20.glEnableVertexAttribArray(maPositionHandle);
            // Connect vertexBuffer to "aPosition".
            android.opengl.GLES20.glVertexAttribPointer(maPositionHandle, 3,
                    android.opengl.GLES20.GL_FLOAT, false, 3 * FLOAT_SIZE_BYTES, FULL_RECTANGLE_BUF);
            // Enable the "aTextureCoord" vertex attribute.
            android.opengl.GLES20.glEnableVertexAttribArray(maTexCoordHandle);
            // Connect texBuffer to "aTextureCoord".
            android.opengl.GLES20.glVertexAttribPointer(maTexCoordHandle, 4,
                    android.opengl.GLES20.GL_FLOAT, false, 4 * FLOAT_SIZE_BYTES, FULL_RECTANGLE_TEX_BUF);
            // Draw the rect.
            android.opengl.GLES20.glDrawArrays(android.opengl.GLES20.GL_TRIANGLE_STRIP, 0, 4);
            // Done -- disable vertex array, texture, and program.
            android.opengl.GLES20.glDisableVertexAttribArray(maPositionHandle);
            android.opengl.GLES20.glDisableVertexAttribArray(maTexCoordHandle);
            android.opengl.GLES20.glUseProgram(0);
        }
    }
}
