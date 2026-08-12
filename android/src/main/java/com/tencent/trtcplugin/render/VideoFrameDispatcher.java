package com.tencent.trtcplugin.render;

import android.util.SparseArray;

import com.tencent.trtc.TRTCCloudDef;
import com.tencent.trtc.TRTCCloudListener;
import com.tencent.trtcplugin.utils.TRTCLogger;

public class VideoFrameDispatcher implements TRTCCloudListener.TRTCVideoRenderListener {

    private static final String TAG = "VideoFrameDispatcher";
    private static final int MAX_STREAM_TYPES = 3;

    private final String mUserId;
    private final SparseArray<TextureRender> mRenders = new SparseArray<>(MAX_STREAM_TYPES);

    public VideoFrameDispatcher(String userId) {
        mUserId = userId;
    }

    public String getUserId() {
        return mUserId;
    }

    public synchronized void setRender(int streamType, TextureRender render) {
        TextureRender old = mRenders.get(streamType);
        if (old != null && old != render) {
            old.stop();
        }
        mRenders.put(streamType, render);
        TRTCLogger.i(TAG + " setRender userId=" + mUserId + " streamType=" + streamType);
    }

    public synchronized void removeRender(int streamType) {
        TextureRender render = mRenders.get(streamType);
        if (render != null) {
            render.stop();
            mRenders.remove(streamType);
            TRTCLogger.i(TAG + " removeRender userId=" + mUserId + " streamType=" + streamType);
        }
    }

    public synchronized boolean isEmpty() {
        return mRenders.size() == 0;
    }

    public synchronized void disposeAll() {
        for (int i = 0; i < mRenders.size(); i++) {
            mRenders.valueAt(i).stop();
        }
        mRenders.clear();
    }

    @Override
    public synchronized void onRenderVideoFrame(String userId, int streamType, TRTCCloudDef.TRTCVideoFrame frame) {
        TextureRender render = mRenders.get(streamType);
        if (render != null) {
            render.onVideoFrame(frame);
        }
    }
}
