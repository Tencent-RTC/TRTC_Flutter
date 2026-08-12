package com.tencent.trtcplugin.render;

import android.annotation.TargetApi;
import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;
import android.opengl.GLES20;
import android.view.Surface;
import java.io.IOException;

@TargetApi(17)
public class EGLHelper {

    private static final String TAG = "EGLHelper";
    private static  int EGL_RECORDABLE_ANDROID = 0x3142;
    private static final int EGL_OPENGL_ES3_BIT = 0x0040;

    private EGLDisplay mEGLDisplay = EGL14.EGL_NO_DISPLAY;
    private EGLContext mEGLContext = EGL14.EGL_NO_CONTEXT;
    private EGLSurface mEGLSurface = EGL14.EGL_NO_SURFACE;
    private EGLConfig  mEGLConfig  = null;

    public void initialize(EGLContext sharedContext, Surface surface, int width, int height) throws EGLException {
        if (surface == null || !surface.isValid()) {
            throw new EGLException(EGL14.EGL_FALSE, "surface is null or invalid");
        }

        mEGLDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
        if (mEGLDisplay == EGL14.EGL_NO_DISPLAY) {
            throw new EGLException(EGL14.EGL_FALSE, "unable to get EGL14 display");
        }

        int[] version = new int[2];
        if (!EGL14.eglInitialize(mEGLDisplay, version, 0, version, 1)) {
            mEGLDisplay = EGL14.EGL_NO_DISPLAY;
            throw new EGLException(EGL14.EGL_FALSE, "unable to initialize EGL14");
        }

        mEGLConfig = chooseConfig(mEGLDisplay, EGL14.EGL_OPENGL_ES2_BIT);

        EGLContext shared = (sharedContext != null) ? sharedContext : EGL14.EGL_NO_CONTEXT;
        try {
            mEGLContext = createContext(2, shared);
        } catch (EGLException e) {
            mEGLConfig = chooseConfig(mEGLDisplay, EGL_OPENGL_ES3_BIT);
            mEGLContext = createContext(3, shared);
        }

        // 创建 WindowSurface
        int[] surfaceAttribs = {EGL14.EGL_NONE};
        try {
            mEGLSurface = EGL14.eglCreateWindowSurface(mEGLDisplay, mEGLConfig, surface, surfaceAttribs, 0);
        } catch (Exception e) {
            throw new EGLException(EGL14.eglGetError(), "eglCreateWindowSurface failed", e);
        }
        checkEglError("eglCreateWindowSurface");

        if (!EGL14.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
            checkEglError("eglMakeCurrent");
        }
    }

    public void makeCurrent() throws EGLException {
        if (!EGL14.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
            checkEglError("eglMakeCurrent");
        }
    }

    public void swapBuffers() throws EGLException {
        GLES20.glFinish();
        if (!EGL14.eglSwapBuffers(mEGLDisplay, mEGLSurface)) {
            checkEglError("eglSwapBuffers");
        }
    }

    public EGLContext getEglContext() {
        return mEGLContext;
    }

    public boolean isContextValid() {
        return mEGLContext != EGL14.EGL_NO_CONTEXT
                && mEGLDisplay != EGL14.EGL_NO_DISPLAY
                && mEGLSurface != EGL14.EGL_NO_SURFACE;
    }

    public void release() {
        if (mEGLDisplay != EGL14.EGL_NO_DISPLAY) {
            EGL14.eglMakeCurrent(mEGLDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
            if (mEGLSurface != EGL14.EGL_NO_SURFACE) {
                EGL14.eglDestroySurface(mEGLDisplay, mEGLSurface);
                mEGLSurface = EGL14.EGL_NO_SURFACE;
            }
            if (mEGLContext != EGL14.EGL_NO_CONTEXT) {
                EGL14.eglDestroyContext(mEGLDisplay, mEGLContext);
                mEGLContext = EGL14.EGL_NO_CONTEXT;
            }
            EGL14.eglReleaseThread();
        }
        mEGLDisplay = EGL14.EGL_NO_DISPLAY;
    }

    private EGLConfig chooseConfig(EGLDisplay display, int renderableType) throws EGLException {
        int[] attribList = {
                EGL14.EGL_RED_SIZE, 8,
                EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8,
                EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_DEPTH_SIZE, 0,
                EGL14.EGL_STENCIL_SIZE, 0,
                EGL14.EGL_SURFACE_TYPE, EGL14.EGL_WINDOW_BIT,
                EGL14.EGL_RENDERABLE_TYPE, renderableType,
                EGL_RECORDABLE_ANDROID, 1,
                EGL14.EGL_NONE
        };
        EGLConfig[] configs = new EGLConfig[1];
        int[] numConfigs = new int[1];
        if (!EGL14.eglChooseConfig(display, attribList, 0, configs, 0, 1, numConfigs, 0)) {
            throw new EGLException(EGL14.eglGetError(), "eglChooseConfig failed");
        }
        return configs[0];
    }

    private EGLContext createContext(int clientVersion, EGLContext sharedContext) throws EGLException {
        int[] attribList = {
                EGL14.EGL_CONTEXT_CLIENT_VERSION, clientVersion,
                EGL14.EGL_NONE
        };
        EGLContext context = EGL14.eglCreateContext(mEGLDisplay, mEGLConfig, sharedContext, attribList, 0);
        checkEglError("eglCreateContext(ES " + clientVersion + ")");
        return context;
    }

    private void checkEglError(String op) throws EGLException {
        int error = EGL14.eglGetError();
        if (error != EGL14.EGL_SUCCESS) {
            throw new EGLException(error, op);
        }
    }

    public static class EGLException extends IOException {
        private final int errorCode;

        public EGLException(int errorCode, String message) {
            super(message);
            this.errorCode = errorCode;
        }

        public EGLException(int errorCode, String message, Throwable cause) {
            super(message, cause);
            this.errorCode = errorCode;
        }

        @Override
        public String getMessage() {
            return "EGL error 0x" + Integer.toHexString(errorCode) + ": " + super.getMessage();
        }
    }
}
