package com.tencent.trtc_demo.opengl.helper;

import android.util.Log;
import android.view.Surface;

import javax.microedition.khronos.egl.EGL10;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.egl.EGLContext;
import javax.microedition.khronos.egl.EGLDisplay;
import javax.microedition.khronos.egl.EGLSurface;

public class EGL10Helper implements EGLHelper<EGLContext> {

    private static final String TAG = "EGL10Helper";

    public static EGL10Helper createEGLSurface(EGLConfig config, EGLContext context, Surface surface, int width,
            int height) {
        EGL10Helper egl = new EGL10Helper(width, height);
        if (egl.initialize(config, context, surface)) {
            return egl;
        } else {
            return null;
        }
    }

    private final int mWidth;
    private final int mHeight;
    private EGLDisplay mEGLDisplay = EGL10.EGL_NO_DISPLAY;
    private EGLContext mEGLContext = EGL10.EGL_NO_CONTEXT;
    private EGLSurface mEGLSurface = EGL10.EGL_NO_SURFACE;
    private EGL10 mEGL;
    private EGLConfig mEGLConfig;

    private EGL10Helper(int width, int height) {
        mWidth = width;
        mHeight = height;
    }

    @Override
    public boolean swapBuffers() {
        boolean ret = mEGL.eglSwapBuffers(mEGLDisplay, mEGLSurface);
        checkEglError();
        return ret;
    }

    @Override
    public void makeCurrent() {
        mEGL.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext);
        checkEglError();
    }

    public void destroy() {
        if (mEGLDisplay != EGL10.EGL_NO_DISPLAY) {
            mEGL.eglMakeCurrent(mEGLDisplay, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_CONTEXT);

            if (mEGLSurface != EGL10.EGL_NO_SURFACE) {
                mEGL.eglDestroySurface(mEGLDisplay, mEGLSurface);
                mEGLSurface = EGL10.EGL_NO_SURFACE;
            }
            if (mEGLContext != EGL10.EGL_NO_CONTEXT) {
                mEGL.eglDestroyContext(mEGLDisplay, mEGLContext);
                mEGLContext = EGL10.EGL_NO_CONTEXT;
            }
            mEGL.eglTerminate(mEGLDisplay);
            checkEglError();
        }
        mEGLDisplay = EGL10.EGL_NO_DISPLAY;
    }

    public void unmakeCurrent() {
        if (mEGLDisplay != EGL10.EGL_NO_DISPLAY) {
            mEGL.eglMakeCurrent(mEGLDisplay, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_SURFACE, EGL10.EGL_NO_CONTEXT);
        }
    }

    private boolean initialize(EGLConfig config, EGLContext context, Surface surface) {
        mEGL = (EGL10) EGLContext.getEGL();
        mEGLDisplay = mEGL.eglGetDisplay(EGL10.EGL_DEFAULT_DISPLAY);
        mEGL.eglInitialize(mEGLDisplay, new int[2]);
        if (config == null) {
            int[] numConfig = new int[1];
            EGLConfig[] configs = new EGLConfig[1];
            int[] configAttributes = surface == null ? ATTRIBUTES_FOR_OFFSCREEN_SURFACE : ATTRIBUTES_FOR_SURFACE;
            mEGL.eglChooseConfig(mEGLDisplay, configAttributes, configs, 1, numConfig);
            mEGLConfig = configs[0];
        } else {
            mEGLConfig = config;
        }

        int version = 2;
        int[] attribList = {
                EGL_CONTEXT_CLIENT_VERSION, version,
                EGL10.EGL_NONE
        };

        if (context == null) {
            context = EGL10.EGL_NO_CONTEXT;
        }
        mEGLContext = mEGL.eglCreateContext(mEGLDisplay, mEGLConfig, context, attribList);
        if (mEGLContext == EGL10.EGL_NO_CONTEXT) {
            checkEglError();
            return false;
        }

        int[] attribListPbuffer = {
                EGL10.EGL_WIDTH, mWidth,
                EGL10.EGL_HEIGHT, mHeight,
                EGL10.EGL_NONE
        };
        if (surface == null) {
            mEGLSurface = mEGL.eglCreatePbufferSurface(mEGLDisplay, mEGLConfig, attribListPbuffer);
        } else {
            mEGLSurface = mEGL.eglCreateWindowSurface(mEGLDisplay, mEGLConfig, surface, null);
        }
        if (mEGLSurface == EGL10.EGL_NO_SURFACE) {
            checkEglError();
            return false;
        }

        if (!mEGL.eglMakeCurrent(mEGLDisplay, mEGLSurface, mEGLSurface, mEGLContext)) {
            checkEglError();
            return false;
        }
        return true;
    }

    @Override
    public EGLContext getContext() {
        return mEGLContext;
    }

    public void checkEglError() {
        int ec = mEGL.eglGetError();
        if (ec != EGL10.EGL_SUCCESS) {
            Log.e(TAG, "EGL error: 0x" + Integer.toHexString(ec));
        }
    }

    private static final int EGL_RECORDABLE_ANDROID = 0x3142;
    private static final int EGL_CONTEXT_CLIENT_VERSION = 0x3098;
    private static final int EGL_OPENGL_ES2_BIT = 4;


    private static final int[] ATTRIBUTES_FOR_OFFSCREEN_SURFACE = {
            EGL10.EGL_SURFACE_TYPE, EGL10.EGL_PBUFFER_BIT, // The front desk shows Surface here EGL10.EGL_WINDOW_BIT
            EGL10.EGL_RED_SIZE, 8,
            EGL10.EGL_GREEN_SIZE, 8,
            EGL10.EGL_BLUE_SIZE, 8,
            EGL10.EGL_ALPHA_SIZE, 8,
            EGL10.EGL_DEPTH_SIZE, 0,
            EGL10.EGL_STENCIL_SIZE, 0,
            EGL10.EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL10.EGL_NONE
    };
    private static final int[] ATTRIBUTES_FOR_SURFACE = {
            EGL10.EGL_SURFACE_TYPE, EGL10.EGL_WINDOW_BIT, // The front desk shows Surface here EGL10.EGL_WINDOW_BIT
            EGL10.EGL_RED_SIZE, 8,
            EGL10.EGL_GREEN_SIZE, 8,
            EGL10.EGL_BLUE_SIZE, 8,
            EGL10.EGL_ALPHA_SIZE, 8,
            EGL10.EGL_DEPTH_SIZE, 0,
            EGL10.EGL_STENCIL_SIZE, 0,
            EGL10.EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_RECORDABLE_ANDROID, 1,
            EGL10.EGL_NONE
    };
}
