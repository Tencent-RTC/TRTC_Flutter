// Copyright (c) 2026 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod.tools;

import com.tencent.trtcplugin.vod.tools.FTXVodUtils;
import com.tencent.trtcplugin.vod.FTXPlayerConstants;
import com.tencent.trtcplugin.vod.VodMethodChannelHandler;
import android.content.Context;
import android.view.OrientationEventListener;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.TXLiveBase;
import com.tencent.rtmp.TXLiveBaseListener;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Process-wide shared resources for the Vod module.
 *
 * The handler itself stays per-engine (aligned with the official Flutter plugin model such as
 * video_player_android), but process-level hooks must only be attached once for the whole app:
 *   - TXLiveBase.setListener (License callback only accepts one listener)
 *   - OrientationEventListener (one listener per app is enough)
 *   - TXFlutterEngineHolder (ActivityLifecycle callbacks, one per Application)
 *
 * This class keeps an ordered set of attached handlers and reference-counts the global hooks
 * based on the number of attached handlers. When the first handler attaches, the hooks are wired
 * up; when the last handler detaches, they are torn down.
 *
 * SDK events that are conceptually global (License loaded / orientation changed) are fanned out to
 * every attached handler so that every Flutter engine gets the same notification.
 */
public final class VodGlobalResource {

    private static final String TAG = "VodGlobalResource";

    private static final class Holder {
        private static final VodGlobalResource INSTANCE = new VodGlobalResource();
    }

    public static VodGlobalResource getInstance() {
        return Holder.INSTANCE;
    }

    private final Object mLock = new Object();
    private final Set<VodMethodChannelHandler> mAttachedHandlers = new LinkedHashSet<>();

    private OrientationEventListener mOrientationManager;
    private int mCurrentOrientation = FTXPlayerConstants.ORIENTATION_PORTRAIT_UP;

    private final TXLiveBaseListener mSDKEvent = new TXLiveBaseListener() {
        @Override
        public void onLicenceLoaded(int result, String reason) {
            super.onLicenceLoaded(result, reason);
            LiteavLog.v(TAG, "onLicenceLoaded,result:" + result + ",reason:" + reason);
            broadcastLicenceLoaded(result, reason);
        }
    };

    private VodGlobalResource() {
    }

    /**
     * Called from {@link VodMethodChannelHandler#attach()}.
     * The first attach wires up the global hooks; subsequent attaches only register the handler
     * for broadcasting.
     */
    public void acquire(@NonNull VodMethodChannelHandler handler,
                        @NonNull FlutterPlugin.FlutterPluginBinding binding) {
        synchronized (mLock) {
            boolean wasEmpty = mAttachedHandlers.isEmpty();
            mAttachedHandlers.add(handler);
            LiteavLog.i(TAG, "acquire handler=" + handler
                    + ", size=" + mAttachedHandlers.size() + ", firstAttach=" + wasEmpty);
            if (wasEmpty) {
                TXLiveBase.setListener(mSDKEvent);
                FTXVodUtils.TXFlutterEngineHolder.getInstance().attachBindLife(binding);
            }
        }
    }

    /**
     * Called from {@link VodMethodChannelHandler#detach()}.
     * The last detach tears down the global hooks; earlier detaches only unregister the handler.
     */
    public void release(@NonNull VodMethodChannelHandler handler,
                        @NonNull FlutterPlugin.FlutterPluginBinding binding) {
        synchronized (mLock) {
            mAttachedHandlers.remove(handler);
            boolean nowEmpty = mAttachedHandlers.isEmpty();
            LiteavLog.i(TAG, "release handler=" + handler
                    + ", size=" + mAttachedHandlers.size() + ", lastDetach=" + nowEmpty);
            if (nowEmpty) {
                TXLiveBase.setListener(null);
                if (mOrientationManager != null) {
                    mOrientationManager.disable();
                    mOrientationManager = null;
                }
                FTXVodUtils.TXFlutterEngineHolder.getInstance().destroy(binding);
            }
        }
    }

    /**
     * Start the shared orientation service if it is not running yet. Safe to call repeatedly
     * across engines; only the first call enables the underlying {@link OrientationEventListener}.
     */
    public boolean startOrientationService(@NonNull Context appCtx) {
        synchronized (mLock) {
            if (mOrientationManager != null) return true;
            try {
                mOrientationManager = new OrientationEventListener(appCtx) {
                    @Override
                    public void onOrientationChanged(int orientation) {
                        if (!isDeviceAutoRotateOn(appCtx)) return;
                        int ev = mapOrientation(orientation, mCurrentOrientation);
                        if (ev != mCurrentOrientation) {
                            mCurrentOrientation = ev;
                            broadcastOrientationChanged(ev);
                        }
                    }
                };
                mOrientationManager.enable();
                return true;
            } catch (Exception e) {
                LiteavLog.e(TAG, "startOrientationService error", e);
                return false;
            }
        }
    }

    private void broadcastLicenceLoaded(int result, String reason) {
        List<VodMethodChannelHandler> snapshot;
        synchronized (mLock) {
            snapshot = new ArrayList<>(mAttachedHandlers);
        }
        for (VodMethodChannelHandler h : snapshot) {
            h.dispatchLicenceLoaded(result, reason);
        }
    }

    private void broadcastOrientationChanged(int orientation) {
        List<VodMethodChannelHandler> snapshot;
        synchronized (mLock) {
            snapshot = new ArrayList<>(mAttachedHandlers);
        }
        for (VodMethodChannelHandler h : snapshot) {
            h.dispatchOrientationChanged(orientation);
        }
    }

    private static int mapOrientation(int orientation, int current) {
        int ev = current;
        if (((orientation >= 0) && (orientation < 30)) || (orientation > 330)) {
            ev = FTXPlayerConstants.ORIENTATION_PORTRAIT_UP;
        } else if (orientation > 240 && orientation < 300) {
            ev = FTXPlayerConstants.ORIENTATION_LANDSCAPE_RIGHT;
        } else if (orientation > 150 && orientation < 210) {
            ev = FTXPlayerConstants.ORIENTATION_PORTRAIT_DOWN;
        } else if (orientation > 60 && orientation < 110) {
            ev = FTXPlayerConstants.ORIENTATION_LANDSCAPE_LEFT;
        }
        return ev;
    }

    private static boolean isDeviceAutoRotateOn(@Nullable Context ctx) {
        if (ctx == null) return false;
        try {
            return android.provider.Settings.System.getInt(
                    ctx.getContentResolver(),
                    android.provider.Settings.System.ACCELEROMETER_ROTATION, 0) == 1;
        } catch (Exception e) {
            LiteavLog.e(TAG, "isDeviceAutoRotateOn error", e);
            return false;
        }
    }
}
