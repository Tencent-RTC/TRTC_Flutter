package com.tencent.trtcplugin.vod.impl.ui;

import android.content.Context;
import android.view.Surface;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.trtcplugin.vod.FTXPlayerConstants;
import com.tencent.trtcplugin.vod.impl.render.FTXEGLRender;
import com.tencent.trtcplugin.vod.impl.render.FTXVodPlayerRenderHost;

import java.util.Map;

import io.flutter.plugin.platform.PlatformView;

/**
 * Flutter PlatformView host that owns a {@link FTXRenderCarrier} (Surface or Texture) and binds it
 * to the player. The original {@code FTXRenderCarrier} / {@code FTXCarrierSurfaceListener} /
 * {@code FTXTextureContainer} small files were collapsed into this class as nested types during
 * the simplify pass to reduce file/dir count.
 */
public class FTXRenderView implements PlatformView {
    private static final String TAG = "FTXRenderView";

    private FTXRenderCarrier mTextureView;
    private FTXVodPlayerRenderHost mBasePlayer;
    private final int mViewId;
    private final Context mContext;
    private final FTXTextureContainer mContainer;
    private final int mRenderType;
    private FTXRenderViewFactory mFactory;

    public FTXRenderView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams,
                         FTXRenderViewFactory factory) {
        if (null != creationParams) {
            Object renderTypeObj = creationParams.get(FTXPlayerConstants.RENDER_TYPE_KEY);
            if (renderTypeObj instanceof Integer) {
                mRenderType = (int) renderTypeObj;
            } else {
                mRenderType = FTXPlayerConstants.ViewType.TEXTURE_TYPE;
            }
        } else {
            mRenderType = FTXPlayerConstants.ViewType.TEXTURE_TYPE;
        }
        mFactory = factory;
        mContext = context;
        mContainer = new FTXTextureContainer(context);
        mContainer.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));
        resetRenderView();
        LiteavLog.i(TAG, "view " + id + " is created， renderType:" + mRenderType);
        mViewId = id;
    }

    public FTXRenderCarrier getRenderView() {
        return mTextureView;
    }

    private void resetRenderView() {
        if (mRenderType == FTXPlayerConstants.ViewType.TEXTURE_TYPE) {
            mTextureView = new FTXTextureView(mContext);
        } else if (mRenderType == FTXPlayerConstants.ViewType.SURFACE_TYPE
                || mRenderType == FTXPlayerConstants.ViewType.DRM_SURFACE_TYPE) {
            mTextureView = new FTXSurfaceView(mContext);
        } else {
            LiteavLog.e(TAG, "unknown view type :" + mRenderType + ", use default type TEXTURE_TYPE");
            mTextureView = new FTXTextureView(mContext);
        }
        mContainer.setCarrier(mTextureView);
    }

    public void setPlayer(FTXVodPlayerRenderHost player) {
        LiteavLog.i(TAG, "start setPlayer, viewId:" + mViewId);
        if (mBasePlayer != player) {
            LiteavLog.i(TAG, "setPlayer, player is not equal, old:" + mBasePlayer
                    + ",new:" + player + ", view:" + hashCode());
            if (null != mBasePlayer) {
                mBasePlayer.setRenderView(null);
                mTextureView.removeAllSurfaceListener();
                clearTexture();
            }
            mBasePlayer = player;
        } else {
            LiteavLog.i(TAG, "setPlayer, player is same, player:" + player
                    + " refresh it, view:" + hashCode());
        }
        player.setRenderView(mTextureView);
    }

    public void clearTexture() {
        resetRenderView();
    }

    @Nullable
    @Override
    public View getView() {
        return mContainer;
    }

    public int getViewId() {
        return mViewId;
    }

    @Override
    public void dispose() {
        mFactory.removeByViewId(mViewId);
        mContainer.setCarrier(null);
        mBasePlayer = null;
        LiteavLog.i(TAG, "render view is dispose, id:" + mViewId + ", view:" + hashCode());
    }

    // ---- Nested types (formerly standalone files in ui/render/) ----------------------------

    /** Listener fired when the underlying Surface/SurfaceTexture becomes available or destroyed. */
    public interface FTXCarrierSurfaceListener {

        void onSurfaceTextureAvailable(Surface surface);

        boolean onSurfaceTextureDestroyed(Surface surface);
    }

    /**
     * Common contract implemented by both {@link FTXTextureView} and {@link FTXSurfaceView}.
     * Provides bind/unbind, render-mode/rotation/resolution updates and TRTC frame copy hooks.
     */
    public interface FTXRenderCarrier {

        void bindPlayer(FTXVodPlayerRenderHost surfaceHost);

        void clearLastImg();

        void notifyVideoResolutionChanged(int videoWidth, int videoHeight);

        void notifyTextureRotation(float rotation);

        void updateRenderMode(long renderMode);

        void requestLayoutSizeByContainerSize(int viewWidth, int viewHeight);

        void destroyRender();

        void reDrawVod(boolean isForcePullFrame);

        void addSurfaceTextureListener(FTXCarrierSurfaceListener listener);

        void removeSurfaceTextureListener(FTXCarrierSurfaceListener listener);

        void removeAllSurfaceListener();

        void enableTRTCCloud(boolean enable, FTXEGLRender.OnFrameCopyListener listener);
    }

    /** FrameLayout container holding the active {@link FTXRenderCarrier}. */
    public static class FTXTextureContainer extends FrameLayout {

        private static final String TAG = "FTXTextureContainer";

        private FTXRenderCarrier mTextureHolder;

        public FTXTextureContainer(@NonNull Context context) {
            super(context);
        }

        public synchronized void setCarrier(FTXRenderCarrier carrier) {
            LiteavLog.i(TAG, "called setUp new carrier:" + carrier + ",view:" + hashCode());
            if (mTextureHolder != carrier) {
                if (null == carrier) {
                    LiteavLog.i(TAG, "start remove old carrier:" + mTextureHolder + ",view:" + hashCode());
                    removeView((View) mTextureHolder);
                    mTextureHolder.destroyRender();
                    mTextureHolder.removeAllSurfaceListener();
                } else {
                    LiteavLog.i(TAG, "start add new carrier:" + carrier + ",view:" + hashCode());
                    // remove old
                    removeView((View) mTextureHolder);
                    addView((View) carrier);
                }
                mTextureHolder = carrier;
            }
        }

        @Override
        public void removeAllViews() {
            super.removeAllViews();
            LiteavLog.i(TAG, "target removeAllViews,view:" + hashCode());
        }

        @Override
        public void removeView(View view) {
            super.removeView(view);
            LiteavLog.i(TAG, "target removeView, child:" + view + ",view:" + hashCode());
        }

        @Override
        protected void onSizeChanged(int w, int h, int oldw, int oldh) {
            super.onSizeChanged(w, h, oldw, oldh);
            if (null != mTextureHolder) {
                mTextureHolder.requestLayoutSizeByContainerSize(w, h);
            }
        }
    }
}
