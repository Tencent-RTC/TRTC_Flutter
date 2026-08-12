// Copyright (c) 2026 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod;

import com.tencent.trtcplugin.vod.tools.FTXVodUtils;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.SparseArray;
import android.view.OrientationEventListener;

import androidx.annotation.NonNull;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.TXLiveBase;
import com.tencent.rtmp.TXLiveBaseListener;
import com.tencent.rtmp.TXPlayerGlobalSetting;
import com.tencent.trtcplugin.vod.pip.TXAndroid12BridgeService;
import com.tencent.trtcplugin.vod.impl.ui.FTXRenderViewFactory;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Vod 模块 MethodChannel 统一分发入口。
 *
 * 替代原 SuperPlayerPlugin.java（Pigeon 版本），对接 Dart 侧的
 *   - TencentVodPlugin   （全局方法：License / 缓存 / Log / createVodPlayer）
 *   - TencentVodPlayer   （实例方法：按 playerId 分发到 FTXVodPlayer）
 *   - TencentVodDownload （下载：分发到 FTXDownloadManager）
 *
 * C2 阶段：建立分发骨架；FTXVodPlayer / FTXDownloadManager 的 onMethodCall 分发在 C3/C4 完成。
 */
public class VodMethodChannelHandler {

    private static final String TAG = "VodMethodChannelHandler";

    public static final String CHANNEL_PLAYER   = "TencentVodPlayer";
    public static final String CHANNEL_DOWNLOAD = "TencentVodDownload";
    public static final String CHANNEL_PLUGIN   = "TencentVodPlugin";

    public static final String EVENT_ON_PLAYER_EVENT      = "onPlayerEvent";
    public static final String EVENT_ON_PLAYER_NET_EVENT  = "onPlayerNetEvent";
    public static final String EVENT_ON_DOWNLOAD_EVENT    = "onDownloadEvent";
    public static final String EVENT_ON_PREDOWNLOAD_EVENT = "onPreDownloadEvent";
    public static final String EVENT_ON_PIP_EVENT         = "onPipEvent";
    public static final String EVENT_ON_SDK_LISTENER      = "onSDKListener";
    public static final String EVENT_ON_NATIVE_EVENT      = "onNativeEvent";

    private final FlutterPlugin.FlutterPluginBinding mFlutterPluginBinding;
    private final Handler mMainHandler = new Handler(Looper.getMainLooper());

    private final MethodChannel mPluginChannel;
    private final MethodChannel mPlayerChannel;
    private final MethodChannel mDownloadChannel;

    private final SparseArray<FTXVodPlayer> mPlayers = new SparseArray<>();
    private FTXDownloadManager mDownloadManager;
    private FTXPIPManager mPipManager;
    private FTXRenderViewFactory mRenderViewFactory;

    private OrientationEventListener mOrientationManager;
    private int mCurrentOrientation = FTXPlayerConstants.ORIENTATION_PORTRAIT_UP;

    private final TXLiveBaseListener mSDKEvent = new TXLiveBaseListener() {
        @Override
        public void onLicenceLoaded(int result, String reason) {
            super.onLicenceLoaded(result, reason);
            LiteavLog.v(TAG, "onLicenceLoaded,result:" + result + ",reason:" + reason);
            mMainHandler.post(() -> {
                Bundle params = new Bundle();
                params.putInt(FTXPlayerConstants.EVENT_RESULT, result);
                params.putString(FTXPlayerConstants.EVENT_REASON, reason);
                invokePluginEvent(EVENT_ON_SDK_LISTENER,
                        FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_ON_LICENCE_LOADED, params));
            });
        }
    };

    public VodMethodChannelHandler(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        mFlutterPluginBinding = binding;
        mPluginChannel   = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_PLUGIN);
        mPlayerChannel   = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_PLAYER);
        mDownloadChannel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_DOWNLOAD);
    }

    /** 在 TRTCPlugin.onAttachedToEngine 中调用。 */
    public void attach() {
        LiteavLog.i(TAG, "attach");
        mRenderViewFactory = new FTXRenderViewFactory(mFlutterPluginBinding.getBinaryMessenger());
        mFlutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory(FTXPlayerConstants.FTX_RENDER_VIEW, mRenderViewFactory);

        FTXVodUtils.TXFlutterEngineHolder.getInstance().attachBindLife(mFlutterPluginBinding);
        mDownloadManager = new FTXDownloadManager(mFlutterPluginBinding, this);

        mPluginChannel.setMethodCallHandler(this::onPluginMethodCall);
        mPlayerChannel.setMethodCallHandler(this::onPlayerMethodCall);
        mDownloadChannel.setMethodCallHandler(this::onDownloadMethodCall);

        TXLiveBase.setListener(mSDKEvent);
    }

    /** 在 TRTCPlugin.onDetachedFromEngine 中调用。 */
    public void detach() {
        LiteavLog.i(TAG, "detach");
        if (mDownloadManager != null) {
            mDownloadManager.destroy();
        }
        if (mOrientationManager != null) {
            mOrientationManager.disable();
            mOrientationManager = null;
        }
        if (mPipManager != null) {
            // 先触发退出（此时 ActivityListener 仍在位，Dart 侧能收到 EVENT_PIP_MODE_ALREADY_EXIT），
            // 再释放监听，避免 exit 事件丢失导致 Dart 状态机卡住。
            mPipManager.exitCurrentPip();
            mPipManager.releaseActivityListener();
        }
        Context ctx = mFlutterPluginBinding.getApplicationContext();
        Intent serviceIntent = new Intent(ctx, TXAndroid12BridgeService.class);
        ctx.stopService(serviceIntent);
        FTXVodUtils.TXFlutterEngineHolder.getInstance().destroy(mFlutterPluginBinding);
        TXLiveBase.setListener(null);
        releaseAllPlayer();

        mPluginChannel.setMethodCallHandler(null);
        mPlayerChannel.setMethodCallHandler(null);
        mDownloadChannel.setMethodCallHandler(null);
    }

    // ------------- Plugin 通道 -------------

    private void onPluginMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String method = call.method;
        try {
            switch (method) {
                case "getLiteAVSDKVersion":
                case "getPlatformVersion":
                    result.success(TXLiveBase.getSDKVersionStr());
                    break;
                case "createVodPlayer": {
                    boolean onlyAudio = FTXVodUtils.TXCommonUtil.argBool(call, "onlyAudio", false);
                    FTXVodPlayer player = new FTXVodPlayer(mFlutterPluginBinding,
                            getPipManager(), mRenderViewFactory, onlyAudio, this);
                    int playerId = player.getPlayerId();
                    mPlayers.append(playerId, player);
                    LiteavLog.i(TAG, "createVodPlayer :" + playerId);
                    result.success(playerId);
                    break;
                }
                case "setConsoleEnabled": {
                    Boolean v = call.argument("value");
                    if (v != null) TXLiveBase.setConsoleEnabled(v);
                    result.success(null);
                    break;
                }
                case "releasePlayer": {
                    Integer pid = FTXVodUtils.TXCommonUtil.argInt(call, "playerId", null);
                    if (pid != null) {
                        LiteavLog.i(TAG, "releasePlayer :" + pid);
                        FTXVodPlayer player = mPlayers.get(pid);
                        if (player != null) {
                            player.destroy();
                            mPlayers.remove(pid);
                        }
                    }
                    result.success(null);
                    break;
                }
                case "setGlobalMaxCacheSize": {
                    Integer size = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (size != null && size > 0) {
                        TXPlayerGlobalSetting.setMaxCacheSize(size);
                    }
                    result.success(null);
                    break;
                }
                case "setGlobalCacheFolderPath": {
                    String postfix = call.argument("value");
                    boolean ok = false;
                    if (!TextUtils.isEmpty(postfix)) {
                        File sdcardDir = mFlutterPluginBinding
                                .getApplicationContext().getExternalFilesDir(null);
                        if (sdcardDir != null) {
                            TXPlayerGlobalSetting.setCacheFolderPath(
                                    sdcardDir.getPath() + File.separator + postfix);
                            ok = true;
                        }
                    }
                    result.success(ok);
                    break;
                }
                case "setGlobalCacheFolderCustomPath": {
                    String p = call.argument("androidAbsolutePath");
                    boolean ok = false;
                    if (!TextUtils.isEmpty(p)) {
                        TXPlayerGlobalSetting.setCacheFolderPath(p);
                        ok = true;
                    }
                    result.success(ok);
                    break;
                }
                case "setGlobalLicense": {
                    String licenseUrl = call.argument("licenseUrl");
                    String licenseKey = call.argument("licenseKey");
                    TXLiveBase.getInstance().setLicence(
                            mFlutterPluginBinding.getApplicationContext(), licenseUrl, licenseKey);
                    result.success(null);
                    break;
                }
                case "setLogLevel": {
                    Integer level = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (level != null) TXLiveBase.setLogLevel(level);
                    result.success(null);
                    break;
                }
                case "setGlobalEnv": {
                    String env = call.argument("value");
                    result.success(TXLiveBase.setGlobalEnv(env));
                    break;
                }
                case "startVideoOrientationService":
                    result.success(innerStartVideoOrientationService());
                    break;
                case "setUserId":
                    TXLiveBase.setUserId((String) call.argument("value"));
                    result.success(null);
                    break;
                case "setLicenseFlexibleValid": {
                    Boolean v = call.argument("value");
                    if (v != null) TXPlayerGlobalSetting.setLicenseFlexibleValid(v);
                    result.success(null);
                    break;
                }
                case "setDrmProvisionEnv": {
                    Integer env = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (env != null) {
                        if (env == FTXPlayerConstants.FTXDrmProvisionEnvInt.DRM_PROVISION_ENV_CN) {
                            TXPlayerGlobalSetting.setDrmProvisionEnv(
                                    TXPlayerGlobalSetting.DrmProvisionEnv.DRM_PROVISION_ENV_CN);
                        } else {
                            TXPlayerGlobalSetting.setDrmProvisionEnv(
                                    TXPlayerGlobalSetting.DrmProvisionEnv.DRM_PROVISION_ENV_COM);
                        }
                    }
                    result.success(null);
                    break;
                }
                case "isDeviceSupportPip":
                    result.success(getPipManager().isSupportDevice());
                    break;
                default:
                    LiteavLog.w(TAG, "[plugin] notImplemented: " + method);
                    result.notImplemented();
                    break;
            }
        } catch (Throwable t) {
            LiteavLog.e(TAG, "[plugin] " + method + " error", t);
            result.error("VOD_PLUGIN_ERROR", t.getMessage(), null);
        }
    }

    // ------------- Player 通道 -------------

    private void onPlayerMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Integer pid = FTXVodUtils.TXCommonUtil.argInt(call, "playerId", null);
        if (pid == null) {
            LiteavLog.w(TAG, "[player] missing playerId: " + call.method);
            result.error("VOD_PLAYER_MISSING_ID", "playerId is required", null);
            return;
        }
        FTXVodPlayer player = mPlayers.get(pid);
        if (player == null) {
            LiteavLog.w(TAG, "[player] no player for id=" + pid + ", method=" + call.method);
            result.error("VOD_PLAYER_NOT_FOUND", "player not found: " + pid, null);
            return;
        }
        player.onMethodCall(call, result);
    }

    // ------------- Download 通道 -------------

    private void onDownloadMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (mDownloadManager == null) {
            result.error("download_not_ready", "FTXDownloadManager not initialized", null);
            return;
        }
        mDownloadManager.onMethodCall(call, result);
    }

    // ------------- 事件反向推送 -------------

    public void invokePlayerEvent(int playerId, @NonNull Map<String, Object> event, boolean isNetEvent) {
        Map<String, Object> payload = new HashMap<>();
        payload.put("playerId", playerId);
        payload.put("event", event);
        mMainHandler.post(() -> mPlayerChannel.invokeMethod(
                isNetEvent ? EVENT_ON_PLAYER_NET_EVENT : EVENT_ON_PLAYER_EVENT, payload));
    }

    public void invokePipEvent(@NonNull Map<String, Object> event) {
        mMainHandler.post(() -> mPlayerChannel.invokeMethod(EVENT_ON_PIP_EVENT, event));
    }

    public void invokeDownloadEvent(@NonNull Map<String, Object> event) {
        mMainHandler.post(() -> mDownloadChannel.invokeMethod(EVENT_ON_DOWNLOAD_EVENT, event));
    }

    public void invokePreDownloadEvent(@NonNull Map<String, Object> event) {
        mMainHandler.post(() -> mDownloadChannel.invokeMethod(EVENT_ON_PREDOWNLOAD_EVENT, event));
    }

    public void invokePluginEvent(@NonNull String method, @NonNull Map<String, Object> event) {
        mMainHandler.post(() -> mPluginChannel.invokeMethod(method, event));
    }

    /**
     * 由 {@link VodGlobalResource} 在收到 {@code TXLiveBaseListener.onLicenceLoaded} 后
     * fan-out 给每个 attached handler 调用，将 License 加载结果转成
     * {@code EVENT_ON_SDK_LISTENER} 事件发到 Plugin 通道。
     */
    public void dispatchLicenceLoaded(int result, String reason) {
        mMainHandler.post(() -> {
            Bundle params = new Bundle();
            params.putInt(FTXPlayerConstants.EVENT_RESULT, result);
            params.putString(FTXPlayerConstants.EVENT_REASON, reason);
            invokePluginEvent(EVENT_ON_SDK_LISTENER,
                    FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_ON_LICENCE_LOADED, params));
        });
    }

    /**
     * 由 {@link VodGlobalResource} 在 OrientationEventListener 触发方向变化后
     * fan-out 给每个 attached handler 调用，将方向事件转成
     * {@code EVENT_ON_NATIVE_EVENT} 发到 Plugin 通道。
     */
    public void dispatchOrientationChanged(int orientation) {
        mMainHandler.post(() -> {
            Bundle bundle = new Bundle();
            bundle.putInt(FTXPlayerConstants.EXTRA_NAME_ORIENTATION, orientation);
            invokePluginEvent(EVENT_ON_NATIVE_EVENT,
                    FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_ORIENTATION_CHANGED, bundle));
        });
    }

    // ------------- 内部工具 -------------

    private FTXPIPManager getPipManager() {
        if (mPipManager == null) {
            mPipManager = new FTXPIPManager(mFlutterPluginBinding, this);
        }
        return mPipManager;
    }

    private synchronized void releaseAllPlayer() {
        LiteavLog.i(TAG, "releaseAllPlayer size=" + mPlayers.size());
        for (int i = 0; i < mPlayers.size(); i++) {
            FTXVodPlayer player = mPlayers.valueAt(i);
            if (player != null) player.destroy();
        }
        mPlayers.clear();
    }

    private boolean innerStartVideoOrientationService() {
        if (mOrientationManager != null) return true;
        try {
            mOrientationManager = new OrientationEventListener(
                    mFlutterPluginBinding.getApplicationContext()) {
                @Override
                public void onOrientationChanged(int orientation) {
                    if (!isDeviceAutoRotateOn()) return;
                    int ev = getOrientationEvent(orientation);
                    if (ev != mCurrentOrientation) {
                        mCurrentOrientation = ev;
                        Bundle bundle = new Bundle();
                        bundle.putInt(FTXPlayerConstants.EXTRA_NAME_ORIENTATION, ev);
                        invokePluginEvent(EVENT_ON_NATIVE_EVENT,
                                FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_ORIENTATION_CHANGED, bundle));
                    }
                }
            };
            mOrientationManager.enable();
        } catch (Exception e) {
            LiteavLog.e(TAG, "innerStartVideoOrientationService error", e);
            return false;
        }
        return true;
    }

    private int getOrientationEvent(int orientation) {
        int ev = mCurrentOrientation;
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

    private boolean isDeviceAutoRotateOn() {
        try {
            return android.provider.Settings.System.getInt(
                    mFlutterPluginBinding.getApplicationContext().getContentResolver(),
                    android.provider.Settings.System.ACCELEROMETER_ROTATION, 0) == 1;
        } catch (Exception e) {
            LiteavLog.e(TAG, "isDeviceAutoRotateOn error", e);
            return false;
        }
    }
}
