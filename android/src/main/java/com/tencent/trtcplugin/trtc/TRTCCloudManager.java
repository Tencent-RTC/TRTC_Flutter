package com.tencent.trtcplugin.trtc;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.view.Surface;

import androidx.annotation.NonNull;

import com.tencent.liteav.live.V2TXLivePremierJni;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesser;
import com.tencent.live.beauty.custom.ITXCustomBeautyProcesserFactory;
import com.tencent.live.beauty.custom.TXCustomBeautyDef;
import com.tencent.trtc.TRTCCloud;
import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtcplugin.TRTCPlugin;
import com.tencent.trtcplugin.render.TextureEntryCompat;
import com.tencent.trtcplugin.render.TextureRender;
import com.tencent.trtcplugin.render.VideoFrameDispatcher;
import com.tencent.trtcplugin.utils.MethodCallParams;
import com.tencent.trtcplugin.utils.ImageIO;
import com.tencent.trtcplugin.utils.ObjectUtils;
import com.tencent.trtcplugin.utils.ProcessVideoFrame;
import com.tencent.trtcplugin.utils.TRTCLogger;
import com.tencent.trtcplugin.view.TXCloudVideoViewChannel;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TRTCCloudManager {
    private static final int DEFAULT_VIDEO_WIDTH  = 720;
    private static final int DEFAULT_VIDEO_HEIGHT = 1280;

    private Context mContext;
    private MethodChannel mChannel;

    private ITXCustomBeautyProcesser mCustomBeautyProcesser;
    private ExecutorService mExecutor = Executors.newSingleThreadExecutor();
    private Handler mMainHandler = new Handler(Looper.getMainLooper());

    private Bitmap mMuteImage;

    private AITranscriberManagerHandler mTranscriberHandler;
    private TXCloudVideoViewChannel mVideoViewChannel;

    private final HashMap<String, VideoFrameDispatcher> mRemoteDispatcherMap = new HashMap<>();
    private VideoFrameDispatcher mLocalDispatcher;
    private BinaryMessenger mBinaryMessenger;

    public TRTCCloudManager(Context context, MethodChannel channel, TXCloudVideoViewChannel videoViewChannel,
                            BinaryMessenger messenger) {
        mContext = context;
        mChannel = channel;
        mVideoViewChannel = videoViewChannel;
        mBinaryMessenger = messenger;
        mTranscriberHandler = new AITranscriberManagerHandler(context, channel);
        channel.setMethodCallHandler(this::onMethodCall);
    }

    public void release() {
        mChannel.setMethodCallHandler(null);
        mMainHandler.removeCallbacksAndMessages(null);
        mExecutor.shutdown();
        if (mMuteImage != null) {
            mMuteImage.recycle();
        }
        if (mTranscriberHandler != null) {
            mTranscriberHandler.release();
        }
        for (VideoFrameDispatcher dispatcher : mRemoteDispatcherMap.values()) {
            dispatcher.disposeAll();
        }
        mRemoteDispatcherMap.clear();
        if (mLocalDispatcher != null) {
            mLocalDispatcher.disposeAll();
            mLocalDispatcher = null;
        }
    }

    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (mTranscriberHandler != null && mTranscriberHandler.handleMethodCall(call, result)) {
            return;
        }

        try {
            Method method = TRTCCloudManager.class.getDeclaredMethod(call.method, MethodCall.class, MethodChannel.Result.class);  // CHECKSTYLE:SUPPRESS LineLength
            method.invoke(this, call, result);
        } catch (NoSuchMethodException e) {
            TRTCLogger.e("method=" + call.method + " | arguments=" + call.arguments + " | error=" + e);
        } catch (IllegalAccessException e) {
            TRTCLogger.e("method=" + call.method + " | arguments=" + call.arguments + " | error=" + e);
        } catch (Exception e) {
            TRTCLogger.e("method=" + call.method + " | arguments=" + call.arguments + " | error=" + e);
        }
    }

    private void initialize(MethodCall call, MethodChannel.Result result) {
        result.success(null);
    }

    private void snapshotVideo(MethodCall call, MethodChannel.Result result) {
        String userId = MethodCallParams.getParam(call, result, "userId");
        int streamType = MethodCallParams.getParam(call, result, "streamType");
        int sourceType = MethodCallParams.getParam(call, result, "sourceType");
        String path = MethodCallParams.getParam(call, result, "path");
        TRTCCloud.sharedInstance(mContext).snapshotVideo(userId, streamType, sourceType, new TRTCCloudListener.TRTCSnapshotListener() {  // CHECKSTYLE:SUPPRESS LineLength
            @Override
            public void onSnapshotComplete(Bitmap bitmap) {
                submitExecute(() -> {
                    ImageIO.SaveResult saveResult = ImageIO.save(mContext, bitmap, path);
                    mMainHandler.post(() -> notifySnapshotComplete(userId, saveResult));
                }, "snapshot save");
            }
        });
        result.success(null);
    }

    private void setVideoMuteImage(MethodCall call, MethodChannel.Result result) {
        String filePath = MethodCallParams.getParam(call, result, "imagePath");
        int fps = MethodCallParams.getParam(call, result, "fps");

        submitExecute(() -> {
            if (mMuteImage != null) {
                mMuteImage.recycle();
            }
            mMuteImage = ImageIO.loadBitmapFromFile(mContext, filePath);
            mMainHandler.post(() -> {
                if (mMuteImage == null) {
                    TRTCLogger.e(" setVideoMuteImage | failed to load bitmap");
                } else {
                    TRTCCloud.sharedInstance(mContext).setVideoMuteImage(mMuteImage, fps);
                }
            });
        }, "setVideoMuteImage");

        result.success(null);
    }

    private void setWatermark(MethodCall call, MethodChannel.Result result) {
        String filePath = MethodCallParams.getParam(call, result, "imagePath");
        int streamType = MethodCallParams.getParam(call, result, "streamType");
        double x = MethodCallParams.getParam(call, result, "x");
        double y = MethodCallParams.getParam(call, result, "y");
        double width = MethodCallParams.getParam(call, result, "width");

        submitExecute(() -> {
            Bitmap watermark = ImageIO.loadBitmapFromFile(mContext, filePath);
            mMainHandler.post(() -> {
                if (watermark == null) {
                    TRTCLogger.e(" setWatermark | failed to load bitmap");
                } else {
                    TRTCCloud.sharedInstance(mContext).setWatermark(watermark, streamType, (float) x, (float) y, (float) width);  // CHECKSTYLE:SUPPRESS LineLength
                }
            });
        }, "setWatermark");

        result.success(null);
    }

    private void enableVideoProcessByNative(MethodCall call, MethodChannel.Result result) {
        boolean enable = MethodCallParams.getParam(call, result, "enable");
        ITXCustomBeautyProcesserFactory processFactory = TRTCPlugin.getBeautyProcesserFactory();
        if (enable) {
            if (mCustomBeautyProcesser == null) {
                mCustomBeautyProcesser = processFactory.createCustomBeautyProcesser();
            }
            TXCustomBeautyDef.TXCustomBeautyBufferType bufferType = mCustomBeautyProcesser.getSupportedBufferType();
            TXCustomBeautyDef.TXCustomBeautyPixelFormat pixelFormat = mCustomBeautyProcesser.getSupportedPixelFormat();
            ProcessVideoFrame processVideo = new ProcessVideoFrame(mCustomBeautyProcesser);
            int ret = TRTCCloud.sharedInstance(mContext).setLocalVideoProcessListener(ObjectUtils.convertTRTCPixelFormat(pixelFormat),  // CHECKSTYLE:SUPPRESS LineLength
                    ObjectUtils.convertTRTCBufferType(bufferType), processVideo);
            result.success(ret);
        } else {
            if (mCustomBeautyProcesser != null) {
                processFactory.destroyCustomBeautyProcesser();
                mCustomBeautyProcesser = null;
            }
            int ret = TRTCCloud.sharedInstance(mContext).setLocalVideoProcessListener(TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_UNKNOWN,  // CHECKSTYLE:SUPPRESS LineLength
                    TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_UNKNOWN, null);
            result.success(ret);
        }
    }

    private void getCustomVideoProcessListener(MethodCall call, MethodChannel.Result result) {
        result.success(V2TXLivePremierJni.getObjectAddress(TRTCPlugin.getCustomVideoProcessObserver()));
    }

    private void notifySnapshotComplete(String userId, ImageIO.SaveResult result) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("path", result.path);
        params.put("errCode", result.code);
        params.put("errMsg", result.message);

        mChannel.invokeMethod("onSnapshotComplete", params);
    }

    private void destroySharedInstance(MethodCall call, MethodChannel.Result result) {
        TRTCCloud.destroySharedInstance();
        result.success(null);
    }

    private void submitExecute(Runnable task, String operationName) {
        if (mExecutor.isShutdown() || mExecutor.isTerminated()) {
            TRTCLogger.w("Thread pool is shutdown, skip " + operationName + " operation");
            return;
        }

        try {
            mExecutor.execute(task);
            return;
        } catch (Exception e) {
            TRTCLogger.e("Failed to submit " + operationName + " task to executor: " + e.getMessage());
            return;
        }
    }

    private void setLocalTextureRender(MethodCall call, MethodChannel.Result result) {
        long viewId    = MethodCallParams.<Number>getParam(call, result, "viewId").longValue();
        int streamType = MethodCallParams.getParam(call, result, "streamType");  // CHECKSTYLE:SUPPRESS VariableDeclarationUsageDistance

        TextureEntryCompat entry = mVideoViewChannel.getTextureViewEntry(viewId);
        if (entry == null) {
            TRTCLogger.e("setLocalTextureRender | textureId=" + viewId + " not found");
            result.success(null);
            return;
        }

        if (mLocalDispatcher == null) {
            mLocalDispatcher = new VideoFrameDispatcher("local");
        }
        int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        int bufferType  = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
        TRTCCloud.sharedInstance(mContext).setLocalVideoRenderListener(pixelFormat, bufferType, mLocalDispatcher);

        entry.setSize(DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
        Surface surface = entry.getSurface();

        TextureRender render = new TextureRender(viewId, mBinaryMessenger, entry);
        render.start(surface, DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
        mLocalDispatcher.setRender(streamType, render);

        TRTCLogger.i("setLocalTextureRender | streamType=" + streamType + " textureId=" + viewId);
        result.success(null);
    }

    private void setRemoteTextureRender(MethodCall call, MethodChannel.Result result) {
        long viewId    = MethodCallParams.<Number>getParam(call, result, "viewId").longValue();
        String userId  = MethodCallParams.getParam(call, result, "userId");
        int streamType = MethodCallParams.getParam(call, result, "streamType");  // CHECKSTYLE:SUPPRESS VariableDeclarationUsageDistance

        TextureEntryCompat entry = mVideoViewChannel.getTextureViewEntry(viewId);
        if (entry == null) {
            TRTCLogger.e("setRemoteTextureRender | textureId=" + viewId + " not found");
            result.success(null);
            return;
        }

        VideoFrameDispatcher dispatcher = mRemoteDispatcherMap.get(userId);
        if (dispatcher == null) {
            dispatcher = new VideoFrameDispatcher(userId);
            mRemoteDispatcherMap.put(userId, dispatcher);
        }
        int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
        int bufferType  = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
        TRTCCloud.sharedInstance(mContext).setRemoteVideoRenderListener(userId, pixelFormat, bufferType, dispatcher);

        entry.setSize(DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
        Surface surface = entry.getSurface();

        TextureRender render = new TextureRender(viewId, mBinaryMessenger, entry);
        render.start(surface, DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
        dispatcher.setRender(streamType, render);

        TRTCLogger.i("setRemoteTextureRender | userId=" + userId + " streamType=" + streamType + " textureId=" + viewId);  // CHECKSTYLE:SUPPRESS LineLength
        result.success(null);
    }

    private void unsetLocalTextureRender(MethodCall call, MethodChannel.Result result) {
        int streamType = MethodCallParams.getParam(call, result, "streamType");
        if (mLocalDispatcher != null) {
            mLocalDispatcher.removeRender(streamType);
            if (mLocalDispatcher.isEmpty()) {
                int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
                int bufferType  = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
                TRTCCloud.sharedInstance(mContext).setLocalVideoRenderListener(pixelFormat, bufferType, null);
                mLocalDispatcher = null;
            }
        }
        TRTCLogger.i("unsetLocalTextureRender | streamType=" + streamType);
        result.success(null);
    }

    private void unsetRemoteTextureRender(MethodCall call, MethodChannel.Result result) {
        String userId  = MethodCallParams.getParam(call, result, "userId");
        int streamType = MethodCallParams.getParam(call, result, "streamType");

        VideoFrameDispatcher dispatcher = mRemoteDispatcherMap.get(userId);
        if (dispatcher != null) {
            dispatcher.removeRender(streamType);
            if (dispatcher.isEmpty()) {
                int pixelFormat = TRTCCloudDef.TRTC_VIDEO_PIXEL_FORMAT_Texture_2D;
                int bufferType  = TRTCCloudDef.TRTC_VIDEO_BUFFER_TYPE_TEXTURE;
                TRTCCloud.sharedInstance(mContext).setRemoteVideoRenderListener(userId, pixelFormat, bufferType, null);
                mRemoteDispatcherMap.remove(userId);
            }
        }

        TRTCLogger.i("unsetRemoteTextureRender | userId=" + userId + " streamType=" + streamType);
        result.success(null);
    }
}
