package com.tencent.trtcplugin.view;

import android.view.Surface;

import com.tencent.liteav.live.V2TXLivePremierJni;
import com.tencent.trtcplugin.render.TextureEntryCompat;
import com.tencent.trtcplugin.utils.MethodCallParams;
import com.tencent.trtcplugin.utils.TRTCLogger;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.concurrent.ConcurrentHashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class TXCloudVideoViewChannel {
    private static final String TAG = "TXCloudVideoViewChannel";
    private static final String CHANNEL_NAME = "TXCloudVideoViewChannel";

    private final MethodChannel mChannel;
    private final TextureRegistry mTextureRegister;
    private final ConcurrentHashMap<Long, TextureEntryCompat> mEntryHashMap = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Long, Surface> mSurfaceHashMap = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Long, Long> mSurfaceAddressHashMap = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Long, TextureEntryCompat> mSurfaceEntryMap = new ConcurrentHashMap<>();

    public TXCloudVideoViewChannel(BinaryMessenger messenger, TextureRegistry textureRegistry) {
        mTextureRegister = textureRegistry;
        mChannel = new MethodChannel(messenger, CHANNEL_NAME);
        mChannel.setMethodCallHandler(this::handleMethodCall);
    }

    public TextureEntryCompat getTextureViewEntry(long viewId) {
        return mSurfaceEntryMap.get(viewId);
    }

    public void release() {
        mChannel.setMethodCallHandler(null);
        for (TextureEntryCompat entry : mEntryHashMap.values()) {
            entry.release();
        }
        mEntryHashMap.clear();
        mSurfaceHashMap.clear();

        for (Long surfaceAddress : mSurfaceAddressHashMap.values()) {
            V2TXLivePremierJni.releaseObjectAddress(surfaceAddress);
        }
        mSurfaceAddressHashMap.clear();

        for (TextureEntryCompat entry : mSurfaceEntryMap.values()) {
            entry.release();
        }
        mSurfaceEntryMap.clear();
    }

    private void handleMethodCall(MethodCall call, MethodChannel.Result result) {
        try {
            Method method = TXCloudVideoViewChannel.class.getDeclaredMethod(call.method, MethodCall.class,
                    MethodChannel.Result.class);
            method.invoke(this, call, result);
        } catch (NoSuchMethodException e) {
            result.notImplemented();
        } catch (Exception e) {
            TRTCLogger.e(TAG + " | method=" + call.method + " | arguments=" + call.arguments + " | error=" + e);
        }
    }

    private void getTextureId(MethodCall call, MethodChannel.Result result) {
        TextureEntryCompat entry = TextureEntryCompat.create(mTextureRegister);
        long textureId = entry.id();
        mEntryHashMap.put(textureId, entry);
        result.success(textureId);
    }

    private void getSurfaceId(MethodCall call, MethodChannel.Result result) {
        Integer textureId = MethodCallParams.getParam(call, result, "textureId");
        if (textureId == null) {
            result.success(0);
            return;
        }
        Long surfaceAddress = mSurfaceAddressHashMap.get(textureId.longValue());
        if (surfaceAddress != null) {
            result.success(surfaceAddress);
            return;
        }
        TextureEntryCompat entry = mEntryHashMap.get(textureId.longValue());
        if (entry == null) {
            result.success(0);
            return;
        }
        Surface surface = entry.getSurface();
        surfaceAddress = V2TXLivePremierJni.getObjectAddress(surface);
        mSurfaceHashMap.put(textureId.longValue(), surface);
        mSurfaceAddressHashMap.put(textureId.longValue(), surfaceAddress);
        result.success(surfaceAddress);
    }

    private void setRenderSize(MethodCall call, MethodChannel.Result result) {
        Integer textureId = MethodCallParams.getParam(call, result, "textureId");
        Integer width = MethodCallParams.getParam(call, result, "width");
        Integer height = MethodCallParams.getParam(call, result, "height");
        if (textureId == null || width == null || height == null || width <= 0 || height <= 0) {
            result.success(null);
            return;
        }
        TextureEntryCompat entry = mSurfaceEntryMap.get(textureId.longValue());
        if (entry == null) {
            result.success(null);
            return;
        }
        boolean surfaceChanged = entry.setSize(width, height);
        if (surfaceChanged) {
            Long oldAddress = mSurfaceAddressHashMap.get(textureId.longValue());
            if (oldAddress != null) {
                V2TXLivePremierJni.releaseObjectAddress(oldAddress);
            }
            Surface newSurface = entry.getSurface();
            long newAddress = V2TXLivePremierJni.getObjectAddress(newSurface);
            mSurfaceHashMap.put(textureId.longValue(), newSurface);
            mSurfaceAddressHashMap.put(textureId.longValue(), newAddress);
            result.success(newAddress);
        } else {
            result.success(null);
        }
    }

    private void unregisterTexture(MethodCall call, MethodChannel.Result result) {
        Integer textureId = MethodCallParams.getParam(call, result, "textureId");
        if (textureId == null) {
            result.success(null);
            return;
        }
        TextureEntryCompat entry = mEntryHashMap.remove(textureId.longValue());
        if (entry != null) {
            entry.release();
        }
        Long surfaceAddress = mSurfaceAddressHashMap.remove(textureId.longValue());
        if (surfaceAddress != null) {
            V2TXLivePremierJni.releaseObjectAddress(surfaceAddress);
        }
        mSurfaceHashMap.remove(textureId.longValue());
        result.success(null);
    }

    private void createTextureView(MethodCall call, MethodChannel.Result result) {
        TextureEntryCompat entry = TextureEntryCompat.create(mTextureRegister);
        long textureId = entry.id();
        mSurfaceEntryMap.put(textureId, entry);
        TRTCLogger.i(TAG + " | createTextureView | textureId=" + textureId);
        result.success(textureId);
    }

    private void disposeTextureView(MethodCall call, MethodChannel.Result result) {
        long textureId = MethodCallParams.<Number>getParam(call, result, "textureId").longValue();
        TRTCLogger.i(TAG + " | disposeTextureView | textureId=" + textureId);
        TextureEntryCompat entry = mSurfaceEntryMap.remove(textureId);
        if (entry != null) {
            entry.release();
        }
        result.success(null);
    }
}
