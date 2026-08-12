// Copyright (c) 2022 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod.impl.render;

import android.view.Surface;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.trtcplugin.vod.impl.ui.FTXRenderView;
import com.tencent.trtcplugin.vod.impl.ui.FTXRenderView.FTXRenderCarrier;

/**
 * Abstract render host that bridges the concrete VOD player ({@link com.tencent.rtmp.TXVodPlayer})
 * and the Flutter PlatformView ({@link FTXRenderView} / {@link FTXRenderCarrier}).
 *
 * <p>The two collaborator contracts (formerly the {@code FTXPlayerRenderHost} and
 * {@code FTXPlayerRenderSurfaceHost} interfaces) are collapsed directly into this abstract base
 * class. Callers that previously typed against either interface should now type against
 * {@link FTXVodPlayerRenderHost}; the only existing implementation is {@code FTXVodPlayer},
 * so the contract semantics are preserved without the extra interface indirection.
 */
public abstract class FTXVodPlayerRenderHost {

    private static final String TAG = "FTXVodPlayerRenderHost";

    protected FTXRenderCarrier mRenderCarrier;
    protected FTXRenderView mCurRenderView;

    public void setUpPlayerView(FTXRenderView renderView) {
        if (null != renderView) {
            LiteavLog.i(TAG, "start setUpPlayerView:" + renderView.getViewId() + ", player:" + hashCode());
            mCurRenderView = renderView;
            renderView.setPlayer(this);
        } else {
            LiteavLog.w(TAG, "start setUpPlayerView met null view, reset player, player:" + hashCode());
            mCurRenderView = null;
            setRenderView(null);
        }
    }

    public void setRenderView(FTXRenderCarrier textureView) {
        if (null != textureView) {
            LiteavLog.i(TAG, "start bind Player:" + textureView + ", player:" + hashCode());
            textureView.bindPlayer(this);
            mRenderCarrier = textureView;
        } else {
            LiteavLog.i(TAG, "setRenderView met a null textureView, player:" + hashCode());
            removeRenderView();
        }
    }

    public void setSurface(Surface surface) {
        final TXVodPlayer vodPlayer = getVodPlayer();
        if (null != vodPlayer) {
            LiteavLog.w(TAG, "start setSurface: " + surface + ", player:" + hashCode());
            vodPlayer.setSurface(surface);
        } else {
            LiteavLog.w(TAG, "setSurface met a null player, player:" + hashCode());
        }
    }

    private void removeRenderView() {
        LiteavLog.i(TAG, "start removeRenderView, player:" + hashCode());
        if (null != mRenderCarrier) {
            mRenderCarrier.bindPlayer(null);
        }
        final TXVodPlayer vodPlayer = getVodPlayer();
        if (null != vodPlayer) {
            vodPlayer.setSurface(null);
        }
        mRenderCarrier = null;
    }

    protected void updateTextureRenderMode(long renderMode) {
        if (null != mRenderCarrier) {
            mRenderCarrier.updateRenderMode(renderMode);
        }
    }

    protected void notifyTextureResolution(int videoWidth, int videoHeight) {
        if (null != mRenderCarrier) {
            mRenderCarrier.notifyVideoResolutionChanged(videoWidth, videoHeight);
        }
    }

    protected void notifyTextureRotation(float rotation) {
        if (null != mRenderCarrier) {
            mRenderCarrier.notifyTextureRotation(rotation);
        }
    }

    public FTXRenderCarrier getCurCarrier() {
        return mRenderCarrier;
    }

    protected abstract TXVodPlayer getVodPlayer();

    public abstract void handleTRTCObj(FTXRenderCarrier carrier);

    // The following abstract methods replace the former FTXPlayerRenderSurfaceHost interface;
    // concrete subclasses (FTXVodPlayer) provide the implementations.
    public abstract long getPlayerRenderMode();

    public abstract float getRotation();

    public abstract int getVideoWidth();

    public abstract int getVideoHeight();
}
