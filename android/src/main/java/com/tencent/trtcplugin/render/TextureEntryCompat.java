package com.tencent.trtcplugin.render;

import android.view.Surface;
import com.tencent.trtcplugin.utils.TRTCLogger;
import io.flutter.view.TextureRegistry;

/**
 * 兼容层：统一封装 SurfaceProducer（Flutter 3.22+）和 SurfaceTextureEntry（旧版本）。
 */
public abstract class TextureEntryCompat {

    public abstract long id();

    public abstract Surface getSurface();

    /**
     * 更新 buffer 大小。
     * SurfaceProducer：调用 setSize() 后 Surface 对象会变化（需要重新 getSurface）。
     * SurfaceTextureEntry：调用 setDefaultBufferSize() 后 Surface 对象保持不变。
     *
     * @return true 表示 Surface 对象已变化（SurfaceProducer），false 表示未变化（SurfaceTextureEntry）。
     */
    public abstract boolean setSize(int width, int height);

    public abstract void release();

    /**
     * 运行时检测 SurfaceProducer 是否可用，并创建对应的实现。
     */
    public static TextureEntryCompat create(TextureRegistry registry) {
        if (isSurfaceProducerAvailable(registry)) {
            return createSurfaceProducerEntry(registry);
        } else {
            return createSurfaceTextureEntry(registry);
        }
    }

    private static volatile Boolean sSurfaceProducerAvailable = null;

    private static boolean isSurfaceProducerAvailable(TextureRegistry registry) {
        if (sSurfaceProducerAvailable != null) {
            return sSurfaceProducerAvailable;
        }
        try {
            registry.getClass().getMethod("createSurfaceProducer");
            sSurfaceProducerAvailable = true;
        } catch (NoSuchMethodException e) {
            sSurfaceProducerAvailable = false;
        }
        return sSurfaceProducerAvailable;
    }

    private static TextureEntryCompat createSurfaceProducerEntry(TextureRegistry registry) {
        TextureRegistry.SurfaceProducer producer = registry.createSurfaceProducer();
        TRTCLogger.i("TextureEntryCompat | using SurfaceProducer, textureId=" + producer.id());
        return new TextureEntryCompat() {
            @Override
            public long id() {
                return producer.id();
            }

            @Override
            public Surface getSurface() {
                return producer.getSurface();
            }

            @Override
            public boolean setSize(int width, int height) {
                producer.setSize(width, height);
                return true;
            }

            @Override
            public void release() {
                producer.release();
            }
        };
    }

    @SuppressWarnings("deprecation")
    private static TextureEntryCompat createSurfaceTextureEntry(TextureRegistry registry) {
        TextureRegistry.SurfaceTextureEntry entry = registry.createSurfaceTexture();
        Surface surface = new Surface(entry.surfaceTexture());
        TRTCLogger.i("TextureEntryCompat | using SurfaceTextureEntry (legacy), textureId=" + entry.id());
        return new TextureEntryCompat() {
            @Override
            public long id() {
                return entry.id();
            }

            @Override
            public Surface getSurface() {
                return surface;
            }

            @Override
            public boolean setSize(int width, int height) {
                entry.surfaceTexture().setDefaultBufferSize(width, height);
                return false;
            }

            @Override
            public void release() {
                surface.release();
                entry.release();
            }
        };
    }
}
