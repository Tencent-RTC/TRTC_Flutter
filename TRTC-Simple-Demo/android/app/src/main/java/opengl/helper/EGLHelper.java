package com.tencent.trtc_demo.opengl.helper;

/**
 * Android has two sets of EGL classes. In order to facilitate use, they abstract them and only provide the following interfaces.
 *
 * @param <T>
 */
public interface EGLHelper<T> {
    /**
     * Return to EglContext to create shared EglContext, etc.
     */
    T getContext();

    /**
     * Bind EglContext to the current thread, and Draw Surface and Read Surface saved in Helper.
     */
    void makeCurrent();

    /**
     * Lift the current thread -bound EGLCONTEXT, Draw Surface, and Read Surface.
     */
    void unmakeCurrent();

    /**
     * Brush the rendered content on the binding drawing target.
     */
    boolean swapBuffers();

    /**
     * Destroy the created EglContext and related resources.
     */
    void destroy();
}
