// Copyright (c) 2022 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod;

import com.tencent.trtcplugin.vod.tools.FTXVodUtils;
import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.ITXVodPlayListener;
import com.tencent.rtmp.TXBitrateItem;
import com.tencent.rtmp.TXImageSprite;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXPlayInfoParams;
import com.tencent.rtmp.TXPlayerDrmBuilder;
import com.tencent.rtmp.TXTrackInfo;
import com.tencent.rtmp.TXVodConstants;
import com.tencent.rtmp.TXVodDef;
import com.tencent.rtmp.TXVodPlayConfig;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager.TXPipResult;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager.TXPlayerHolder;
import com.tencent.trtcplugin.vod.impl.render.FTXEGLRender.FTXPixelFrame;
import com.tencent.trtcplugin.vod.impl.render.FTXVodPlayerRenderHost;
import com.tencent.trtcplugin.vod.impl.render.FVodTRTCHelper.FTRTCCloudClassInvoker;
import com.tencent.trtcplugin.vod.impl.render.FTXEGLRender;
import com.tencent.trtcplugin.vod.impl.ui.FTXRenderView.FTXRenderCarrier;
import com.tencent.trtcplugin.vod.impl.ui.FTXRenderView;
import com.tencent.trtcplugin.vod.impl.ui.FTXRenderViewFactory;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * VOD player plugin processor.
 * <p>
 * Pigeon -> MethodChannel 迁移后：所有 Dart 调用通过 VodMethodChannelHandler 的 TencentVodPlayer
 * 通道（按 playerId）路由到本实例的 {@link #onMethodCall(MethodCall, MethodChannel.Result)}。
 * 播放器事件 / 网络事件反向推送复用 {@link VodMethodChannelHandler#invokePlayerEvent}。
 */
public class FTXVodPlayer extends FTXVodPlayerRenderHost implements ITXVodPlayListener {

    private static final String TAG = "FTXVodPlayer";
    private static final int Uninitialized = -101;

    /**
     * Player id allocator. Formerly defined on {@code FTXBasePlayer}; moved down to the concrete
     * implementation as part of the simplify pass (FTXBasePlayer has been removed).
     */
    private static final AtomicInteger mAtomicId = new AtomicInteger(0);
    private final int mPlayerId = mAtomicId.incrementAndGet();

    private final FlutterPlugin.FlutterPluginBinding mFlutterPluginBinding;
    private final VodMethodChannelHandler mHandler;
    private final FTXPIPManager mPipManager;
    private final FTXRenderViewFactory mRenderViewFactory;
    private final Handler mUIHandler = new Handler(Looper.getMainLooper());

    private TXVodPlayer mVodPlayer;
    private TXImageSprite mTxImageSprite;
    private FTRTCCloudClassInvoker mTRTCInvoker;
    private boolean mIsStartPublishTRTC = false;
    private FTXEGLRender.OnFrameCopyListener mFrameCopyListener;
    private boolean mEnableHardwareDecode = true;
    private boolean mHardwareDecodeFail = false;
    private boolean mNeedPipResume = false;
    private long mCurrentRenderMode = FTXPlayerConstants.FTXRenderMode.FULL_FILL_CONTAINER;
    private float mCurrentRotation = 0;
    private TXVodPlayConfig mCurConfig = new TXVodPlayConfig();

    public int getPlayerId() {
        return mPlayerId;
    }

    private final FTXPIPManager.PipCallback mPipCallback = new FTXPIPManager.PipCallback() {
        @Override
        public void onPipResult(TXPipResult result) {
            if (mVodPlayer != null) {
                if (null != mCurRenderView) {
                    mCurRenderView.setPlayer(FTXVodPlayer.this);
                }
                mVodPlayer.setVodListener(FTXVodPlayer.this);
            }
            // Resume the player when leaving PIP if it was playing.
            if (result.isPlaying()) {
                if (FTXVodUtils.TXFlutterEngineHolder.getInstance().isInForeground()) {
                    playerResume();
                } else {
                    mNeedPipResume = true;
                }
            }
        }

        @Override
        public void onPipPlayerEvent(int event, Bundle bundle) {
            onPlayEvent(mVodPlayer, event, bundle);
        }
    };

    private final FTXVodUtils.TXFlutterEngineHolder.TXAppStatusListener mAppLifeListener
            = new FTXVodUtils.TXFlutterEngineHolder.TXAppStatusListener() {
        @Override
        public void onResume() {
            if (mNeedPipResume) {
                mNeedPipResume = false;
                playerResume();
            }
        }

        @Override
        public void onEnterBack() {
        }
    };

    public FTXVodPlayer(FlutterPlugin.FlutterPluginBinding flutterPluginBinding,
                        FTXPIPManager pipManager,
                        FTXRenderViewFactory renderViewFactory,
                        boolean onlyAudio,
                        @NonNull VodMethodChannelHandler handler) {
        super();
        mFlutterPluginBinding = flutterPluginBinding;
        mPipManager = pipManager;
        mRenderViewFactory = renderViewFactory;
        mHandler = handler;
        FTXVodUtils.TXFlutterEngineHolder.getInstance().addAppLifeListener(mAppLifeListener);
        init(onlyAudio);
    }

    public void destroy() {
        if (mVodPlayer != null) {
            stopPlay(true);
            mVodPlayer.setPlayerView((TXCloudVideoView) null);
            mVodPlayer = null;
        }
        mCurrentRotation = 0;
        mCurRenderView = null;
        FTXVodUtils.TXFlutterEngineHolder.getInstance().removeAppLifeListener(mAppLifeListener);
        releaseTXImageSprite();
        if (null != mPipManager) {
            mPipManager.releaseCallback(getPlayerId());
        }
    }

    // =========================================================
    // ITXVodPlayListener
    // =========================================================

    @Override
    public void onPlayEvent(TXVodPlayer txVodPlayer, int event, Bundle bundle) {
        switch (event) {
            case TXLiveConstants.PLAY_EVT_CHANGE_RESOLUTION:
                String evtParam3 = bundle.getString("EVT_PARAM3");
                if (!TextUtils.isEmpty(evtParam3)) {
                    String[] array = evtParam3.split(",");
                    if (array.length == 6) {
                        int videoWidth = Integer.parseInt(array[4]) - Integer.parseInt(array[2]) + 1;
                        int videoHeight = Integer.parseInt(array[5]) - Integer.parseInt(array[3]) + 1;
                        int videoLeft = -Integer.parseInt(array[2]);
                        int videoTop = -Integer.parseInt(array[3]);
                        int videoRight = Integer.parseInt(array[4]) + 1 - Integer.parseInt(array[0]);
                        int videoBottom = Integer.parseInt(array[5]) + 1 - Integer.parseInt(array[1]);
                        bundle.putInt("videoWidth", videoWidth);
                        bundle.putInt("videoHeight", videoHeight);
                        bundle.putInt("videoLeft", videoLeft);
                        bundle.putInt("videoTop", videoTop);
                        bundle.putInt("videoRight", videoRight);
                        bundle.putInt("videoBottom", videoBottom);
                        sendPlayerEvent(event, bundle, false);
                        return;
                    }
                }
                long rotation = bundle.getLong(TXVodConstants.EVT_KEY_VIDEO_ROTATION);
                if (mCurConfig.isAutoRotate()) {
                    notifyTextureRotation(rotation);
                }
                mCurrentRotation = rotation;
                break;
            case TXLiveConstants.PLAY_WARNING_HW_ACCELERATION_FAIL:
                mHardwareDecodeFail = true;
                break;
            case TXLiveConstants.PLAY_EVT_VOD_PLAY_PREPARED:
                notifyTextureResolution(txVodPlayer.getWidth(), txVodPlayer.getHeight());
                break;
            case TXVodConstants.VOD_PLAY_EVT_SEEK_COMPLETE:
                reDraw();
                break;
            default:
                break;
        }
        if (event != TXVodConstants.VOD_PLAY_EVT_PLAY_PROGRESS) {
            LiteavLog.i(TAG, "onPlayEvent:" + event + "," + bundle.getString(TXLiveConstants.EVT_DESCRIPTION));
        }
        if (event == TXLiveConstants.PLAY_EVT_RCV_FIRST_I_FRAME) {
            mUIHandler.postDelayed(() -> sendPlayerEvent(event, bundle, false), 200);
        } else {
            sendPlayerEvent(event, bundle, false);
        }
    }

    @Override
    public void onNetStatus(TXVodPlayer txVodPlayer, Bundle bundle) {
        sendPlayerEvent(0, bundle, true);
    }

    private void sendPlayerEvent(int event, Bundle bundle, boolean isNetEvent) {
        final Map<String, Object> params = FTXVodUtils.TXCommonUtil.getParams(event, bundle);
        mUIHandler.post(() -> mHandler.invokePlayerEvent(getPlayerId(), params, isNetEvent));
    }

    // =========================================================
    // MethodChannel 分发入口（由 VodMethodChannelHandler 路由，带 playerId）
    // =========================================================

    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String method = call.method;
        try {
            switch (method) {
                // 播放控制
                case "startVodPlay": {
                    String url = call.argument("value");
                    result.success(startPlayerVodPlay(url) == 0);
                    break;
                }
                case "startVodPlayWithParams": {
                    Integer appId = FTXVodUtils.TXCommonUtil.argInt(call, "appId", 0);
                    String fileId = call.argument("fileId");
                    String psign = call.argument("psign");
                    startPlayerVodPlayWithParams(appId == null ? 0 : appId, fileId, psign);
                    result.success(null);
                    break;
                }
                case "startPlayDrm": {
                    result.success((long) startPlayDrmInternal(call));
                    break;
                }
                case "stop": {
                    Boolean isNeedClear = call.argument("value");
                    result.success(stopPlay(isNeedClear != null && isNeedClear) == 1);
                    break;
                }
                case "isPlaying":
                    result.success(isPlayerPlaying());
                    break;
                case "pause":
                    playerPause();
                    result.success(null);
                    break;
                case "resume":
                    playerResume();
                    result.success(null);
                    break;
                case "setAutoPlay": {
                    Boolean v = call.argument("value");
                    setIsAutoPlay(v != null && v);
                    result.success(null);
                    break;
                }

                // 属性 / 配置
                case "setMute": {
                    Boolean v = call.argument("value");
                    if (v != null) setPlayerMute(v);
                    result.success(null);
                    break;
                }
                case "setLoop": {
                    Boolean v = call.argument("value");
                    if (v != null) setPlayerLoop(v);
                    result.success(null);
                    break;
                }
                case "isLoop":
                    result.success(isVodPlayerLoop());
                    break;
                case "seek": {
                    Double v = FTXVodUtils.TXCommonUtil.argDouble(call, "value", (Double) null);
                    if (v != null) seekPlayer(v.floatValue());
                    result.success(null);
                    break;
                }
                case "seekToPdtTime": {
                    Integer v = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (v != null) seekToPdtTime(v.longValue());
                    result.success(null);
                    break;
                }
                case "setRate": {
                    Double v = FTXVodUtils.TXCommonUtil.argDouble(call, "value", (Double) null);
                    if (v != null) setPlayerRate(v.floatValue());
                    result.success(null);
                    break;
                }
                case "setStartTime": {
                    Double v = FTXVodUtils.TXCommonUtil.argDouble(call, "value", (Double) null);
                    if (v != null) setPlayerStartTime(v);
                    result.success(null);
                    break;
                }
                case "setAudioPlayOutVolume": {
                    Integer v = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (v != null) setPlayerAudioPlayoutVolume(v);
                    result.success(null);
                    break;
                }
                case "setRequestAudioFocus": {
                    Boolean v = call.argument("value");
                    result.success(requestPlayerAudioFocus(v != null && v));
                    break;
                }
                case "setToken": {
                    String v = call.argument("value");
                    setPlayerToken(v);
                    result.success(null);
                    break;
                }
                case "setConfig": {
                    @SuppressWarnings("unchecked")
                    Map<Object, Object> cfg = (Map<Object, Object>) (Map<?, ?>) call.arguments();
                    setPlayConfig(cfg);
                    result.success(null);
                    break;
                }
                case "enableHardwareDecode": {
                    Boolean v = call.argument("value");
                    result.success(enablePlayerHardwareDecode(v != null && v));
                    break;
                }

                // 码率 / 轨道
                case "getSupportedBitrate":
                    result.success(getPlayerSupportedBitrates());
                    break;
                case "getBitrateIndex":
                    result.success((long) getPlayerBitrateIndex());
                    break;
                case "setBitrateIndex": {
                    Integer idx = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (idx != null) setPlayerBitrateIndex(idx);
                    result.success(null);
                    break;
                }

                // 尺寸 / 时间
                case "getCurrentPlaybackTime":
                    result.success(BigDecimal.valueOf(getPlayerCurrentPlaybackTime()).doubleValue());
                    break;
                case "getBufferDuration":
                    result.success(BigDecimal.valueOf(getPlayerBufferDuration()).doubleValue());
                    break;
                case "getPlayableDuration":
                    result.success(BigDecimal.valueOf(getPlayerPlayableDuration()).doubleValue());
                    break;
                case "getWidth":
                    result.success((long) getPlayerWidth());
                    break;
                case "getHeight":
                    result.success((long) getPlayerHeight());
                    break;
                case "getDuration":
                    if (null != mVodPlayer) {
                        result.success(BigDecimal.valueOf(mVodPlayer.getDuration()).doubleValue());
                    } else {
                        result.success(0.0);
                    }
                    break;

                // 画中画
                case "enterPictureInPictureMode":
                    result.success((long) enterPictureInPictureModeInternal(call));
                    break;
                case "exitPictureInPictureMode":
                    mPipManager.exitPipByPlayerId(getPlayerId());
                    result.success(null);
                    break;

                // 缩略图
                case "initImageSprite":
                    initImageSpriteInternal(call);
                    result.success(null);
                    break;
                case "getImageSprite": {
                    Double time = FTXVodUtils.TXCommonUtil.argDouble(call, "value", (Double) null);
                    result.success(time != null ? getPlayerImageSprite(time) : new byte[0]);
                    break;
                }

                // 字幕 / 轨道
                case "addSubtitleSource": {
                    if (null != mVodPlayer) {
                        String url = call.argument("url");
                        String name = call.argument("name");
                        String mimeType = call.argument("mimeType");
                        mVodPlayer.addSubtitleSource(url, name, mimeType);
                    }
                    result.success(null);
                    break;
                }
                case "getSubtitleTrackInfo":
                    result.success(getTrackInfoList(true));
                    break;
                case "getAudioTrackInfo":
                    result.success(getTrackInfoList(false));
                    break;
                case "selectTrack": {
                    Integer idx = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (idx != null && null != mVodPlayer) mVodPlayer.selectTrack(idx);
                    result.success(null);
                    break;
                }
                case "deselectTrack": {
                    Integer idx = FTXVodUtils.TXCommonUtil.argInt(call, "value", null);
                    if (idx != null && null != mVodPlayer) mVodPlayer.deselectTrack(idx);
                    result.success(null);
                    break;
                }
                case "setSubtitleStyle": {
                    if (null != mVodPlayer) {
                        // Dart 侧传 {'style': model.toMap()}，需读嵌套 key "style"，与 iOS 对齐。
                        @SuppressWarnings("unchecked")
                        Map<Object, Object> style = call.argument("style");
                        if (style != null) {
                            mVodPlayer.setSubtitleStyle(FTXVodUtils.Transformation.transToTitleRenderModel(style));
                        }
                    }
                    result.success(null);
                    break;
                }
                case "setStringOption":
                    setStringOptionInternal(call);
                    result.success(null);
                    break;

                // 渲染
                case "setPlayerView": {
                    Integer viewId = FTXVodUtils.TXCommonUtil.argInt(call, "renderViewId", null);
                    if (viewId != null) setPlayerView(viewId);
                    result.success(null);
                    break;
                }
                case "setRenderMode": {
                    Integer mode = FTXVodUtils.TXCommonUtil.argInt(call, "renderMode", null);
                    if (mode != null) setRenderMode((long) mode);
                    result.success(null);
                    break;
                }
                case "reDraw":
                    reDraw();
                    result.success(null);
                    break;

                // TRTC
                case "enableTRTC": {
                    Boolean v = call.argument("isEnable");
                    enableTRTC(v != null && v);
                    result.success(null);
                    break;
                }
                case "publishVideo":
                    publishVideo();
                    result.success(null);
                    break;
                case "unpublishVideo":
                    unpublishVideo();
                    result.success(null);
                    break;
                case "publishAudio":
                    publishAudio();
                    result.success(null);
                    break;
                case "unpublishAudio":
                    unpublishAudio();
                    result.success(null);
                    break;

                default:
                    LiteavLog.w(TAG, "[player] notImplemented: " + method);
                    result.notImplemented();
                    break;
            }
        } catch (Throwable t) {
            LiteavLog.e(TAG, "[player] " + method + " error", t);
            result.error("VOD_PLAYER_ERROR", t.getMessage(), null);
        }
    }

    // =========================================================
    // 内部实现（保留原 SuperPlayer 语义）
    // =========================================================

    protected long init(boolean onlyAudio) {
        if (mVodPlayer == null) {
            mVodPlayer = new TXVodPlayer(mFlutterPluginBinding.getApplicationContext());
            mVodPlayer.setVodListener(this);
            mVodPlayer.setRenderMode(TXLiveConstants.RENDER_MODE_ADJUST_RESOLUTION);
            TXVodPlayConfig playConfig = new TXVodPlayConfig();
            FTXVodUtils.FTXVersionAdapter.enableCustomSubtitle(playConfig, 0);
            FTXVodUtils.FTXVersionAdapter.enableDrmLevel3(playConfig, true);
            mCurConfig = playConfig;
            mVodPlayer.setConfig(playConfig);
            mVodPlayer.setVodSubtitleDataListener(new ITXVodPlayListener.ITXVodSubtitleDataListener() {
                @Override
                public void onSubtitleData(TXVodDef.TXVodSubtitleData sub) {
                    LiteavLog.i(TAG, "callback subtitle"
                            + " ,index:" + sub.trackIndex
                            + " ,startMs:" + sub.startPositionMs
                            + " ,durationMs:" + sub.durationMs
                            + " ,content:" + sub.subtitleData);
                    Bundle bundle = new Bundle();
                    bundle.putString(FTXPlayerConstants.EXTRA_SUBTITLE_DATA, sub.subtitleData);
                    bundle.putLong(FTXPlayerConstants.EXTRA_SUBTITLE_START_POSITION_MS, sub.startPositionMs);
                    bundle.putLong(FTXPlayerConstants.EXTRA_SUBTITLE_DURATION_MS, sub.durationMs);
                    bundle.putLong(FTXPlayerConstants.EXTRA_SUBTITLE_TRACK_INDEX, sub.trackIndex);
                    sendPlayerEvent(FTXPlayerConstants.EVENT_SUBTITLE_DATA, bundle, false);
                }
            });
            setPlayer(onlyAudio);
        }
        return FTXPlayerConstants.NO_ERROR;
    }

    void setPlayer(boolean onlyAudio) {
        if (!onlyAudio) {
            if (mVodPlayer != null && null != mCurRenderView) {
                mCurRenderView.setPlayer(this);
            }
        }
    }

    int startPlayerVodPlay(String url) {
        if (mVodPlayer != null) {
            if (null != mCurRenderView) {
                mCurRenderView.setPlayer(this);
            }
            mCurrentRotation = 0;
            return mVodPlayer.startVodPlay(url);
        }
        return Uninitialized;
    }

    void startPlayerVodPlayWithParams(int appId, String fileId, String psign) {
        if (mVodPlayer != null) {
            if (null != mCurRenderView) {
                mCurRenderView.setPlayer(this);
            }
            mVodPlayer.startVodPlay(new TXPlayInfoParams(appId, fileId, psign));
        }
    }

    private int startPlayDrmInternal(MethodCall call) {
        if (mVodPlayer == null) return Uninitialized;
        String licenseUrl = call.argument("licenseUrl");
        String playUrl = call.argument("playUrl");
        TXPlayerDrmBuilder builder = new TXPlayerDrmBuilder(licenseUrl, playUrl);
        // deviceCertificateUrl：与 iOS 对齐，非空时调用 setProvisionUrl。
        String deviceCertificateUrl = call.argument("deviceCertificateUrl");
        if (deviceCertificateUrl != null && !deviceCertificateUrl.isEmpty()) {
            builder.setProvisionUrl(deviceCertificateUrl);
        }
        return mVodPlayer.startPlayDrm(builder);
    }

    int stopPlay(boolean isNeedClearLastImg) {
        int result = Uninitialized;
        if (mVodPlayer != null) {
            result = mVodPlayer.stopPlay(isNeedClearLastImg);
        }
        mUIHandler.removeCallbacksAndMessages(null);
        mPipManager.exitPipByPlayerId(getPlayerId());
        releaseTXImageSprite();
        mHardwareDecodeFail = false;
        if (isNeedClearLastImg && null != mCurRenderView) {
            LiteavLog.i(TAG, "stopPlay target clear last img, player:" + hashCode());
            mCurRenderView.clearTexture();
        }
        return result;
    }

    boolean isPlayerPlaying() {
        return mVodPlayer != null && mVodPlayer.isPlaying();
    }

    void playerPause() {
        if (mVodPlayer != null) {
            mVodPlayer.pause();
            if (mPipManager.isInPipMode()) {
                mPipManager.notifyCurrentPipPlayerPlayState(getPlayerId(), isPlayerPlaying());
            }
        }
    }

    void playerResume() {
        if (mVodPlayer != null) mVodPlayer.resume();
    }

    void setPlayerMute(boolean mute) { if (mVodPlayer != null) mVodPlayer.setMute(mute); }
    void setPlayerAudioPlayoutVolume(int volume) { if (mVodPlayer != null) mVodPlayer.setAudioPlayoutVolume(volume); }
    void setPlayerLoop(boolean loop) { if (mVodPlayer != null) mVodPlayer.setLoop(loop); }
    void setPlayerStartTime(double startTime) { if (mVodPlayer != null) mVodPlayer.setStartTime((float) startTime); }
    void setIsAutoPlay(boolean isAutoPlay) { if (mVodPlayer != null) mVodPlayer.setAutoPlay(isAutoPlay); }

    List<?> getPlayerSupportedBitrates() {
        if (mVodPlayer != null) {
            ArrayList<TXBitrateItem> bitrates = mVodPlayer.getSupportedBitrates();
            ArrayList<Map<Object, Object>> jsons = new ArrayList<>();
            for (TXBitrateItem item : bitrates) {
                Map<Object, Object> map = new HashMap<>();
                map.put("bitrate", item.bitrate);
                map.put("width", item.width);
                map.put("height", item.height);
                map.put("index", item.index);
                jsons.add(map);
            }
            return jsons;
        }
        return Collections.emptyList();
    }

    void setPlayerBitrateIndex(int i) { if (mVodPlayer != null) mVodPlayer.setBitrateIndex(i); }
    void seekPlayer(float progress) { if (mVodPlayer != null) mVodPlayer.seek(progress); }
    void setPlayerRate(float rate) { if (mVodPlayer != null) mVodPlayer.setRate(rate); }

    public void seekToPdtTime(long pdtTimeMs) {
        if (mVodPlayer != null) mVodPlayer.seekToPdtTime(pdtTimeMs);
    }

    void setPlayConfig(Map<Object, Object> config) {
        if (mVodPlayer != null) {
            TXVodPlayConfig playConfig = FTXVodUtils.Transformation.transformToVodConfig(config);
            FTXVodUtils.FTXVersionAdapter.enableCustomSubtitle(playConfig, 0);
            FTXVodUtils.FTXVersionAdapter.enableDrmLevel3(playConfig, true);
            mCurConfig = playConfig;
            mVodPlayer.setConfig(playConfig);
        }
    }

    float getPlayerCurrentPlaybackTime() { return mVodPlayer != null ? mVodPlayer.getCurrentPlaybackTime() : 0; }
    float getPlayerPlayableDuration()   { return mVodPlayer != null ? mVodPlayer.getPlayableDuration()   : 0; }
    float getPlayerBufferDuration()     { return mVodPlayer != null ? mVodPlayer.getBufferDuration()     : 0; }
    int   getPlayerWidth()              { return mVodPlayer != null ? mVodPlayer.getWidth()              : 0; }
    int   getPlayerHeight()             { return mVodPlayer != null ? mVodPlayer.getHeight()             : 0; }

    void setPlayerToken(String token) {
        if (mVodPlayer != null) {
            mVodPlayer.setToken(TextUtils.isEmpty(token) ? null : token);
        }
    }

    boolean isVodPlayerLoop() { return mVodPlayer != null && mVodPlayer.isLoop(); }

    boolean enablePlayerHardwareDecode(boolean enable) {
        if (mVodPlayer != null) {
            mEnableHardwareDecode = enable;
            return mVodPlayer.enableHardwareDecode(enable);
        }
        return false;
    }

    boolean requestPlayerAudioFocus(boolean focus) {
        return mVodPlayer != null && mVodPlayer.setRequestAudioFocus(focus);
    }

    int getPlayerBitrateIndex() { return mVodPlayer != null ? mVodPlayer.getBitrateIndex() : -1; }

    private int enterPictureInPictureModeInternal(MethodCall call) {
        mPipManager.addCallback(getPlayerId(), mPipCallback);
        FTXPIPManager.PipParams pipParams = new FTXPIPManager.PipParams(
                mPipManager.toAndroidPath((String) call.argument("backIconForAndroid")),
                mPipManager.toAndroidPath((String) call.argument("playIconForAndroid")),
                mPipManager.toAndroidPath((String) call.argument("pauseIconForAndroid")),
                mPipManager.toAndroidPath((String) call.argument("forwardIconForAndroid")),
                getPlayerId());
        pipParams.setIsPlaying(isPlayerPlaying());
        pipParams.setCurrentPlayTime(getPlayerCurrentPlaybackTime());
        int pipResult = FTXPlayerConstants.ERROR_PIP_MISS_PLAYER;
        if (null != mVodPlayer) {
            pipParams.setRadio(mVodPlayer.getWidth(), mVodPlayer.getHeight());
            pipResult = mPipManager.enterPip(pipParams, new TXPlayerHolder(mVodPlayer));
            if (pipResult == FTXPlayerConstants.NO_ERROR) {
                playerPause();
            }
        }
        return pipResult;
    }

    private void initImageSpriteInternal(MethodCall call) {
        releaseTXImageSprite();
        String vvtUrl = call.argument("vvtUrl");
        @SuppressWarnings("unchecked")
        List<String> imageUrls = (List<String>) call.argument("imageUrls");
        mTxImageSprite = new TXImageSprite(mFlutterPluginBinding.getApplicationContext());
        mTxImageSprite.setVTTUrlAndImageUrls(vvtUrl, imageUrls);
    }

    private byte[] getPlayerImageSprite(final Double time) {
        if (mTxImageSprite != null && null != time) {
            Bitmap bitmap = mTxImageSprite.getThumbnail(time.floatValue());
            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            if (null != bitmap) {
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, stream);
                return stream.toByteArray();
            }
        } else {
            LiteavLog.e(TAG, "getImageSprite failed, time is null or initImageSprite not invoke");
        }
        return null;
    }

    private void releaseTXImageSprite() {
        if (mTxImageSprite != null) {
            mTxImageSprite.release();
            mTxImageSprite = null;
        }
    }

    @SuppressWarnings("unchecked")
    private void setStringOptionInternal(MethodCall call) {
        if (mVodPlayer == null) return;
        String key = call.argument("key");
        Object raw = call.argument("value");
        if (!(raw instanceof List) || ((List<Object>) raw).isEmpty() || TextUtils.isEmpty(key)) return;
        Object value = ((List<Object>) raw).get(0);
        // HEVC 降级播放参数进行特殊判断，保证 flutter 层接口一致
        if (TextUtils.equals("VOD_KEY_BACKUP_URL", key)) {
            mVodPlayer.setStringOption(TXVodConstants.VOD_KEY_BACKUP_URL, value);
        } else if (TextUtils.equals("VOD_KEY_VIDEO_CODEC_TYPE", key)) {
            mVodPlayer.setStringOption(TXVodConstants.VOD_KEY_MIMETYPE, value);
        } else {
            mVodPlayer.setStringOption(key, value);
        }
    }

    private List<Object> getTrackInfoList(boolean subtitle) {
        List<Object> json = new ArrayList<>();
        if (null == mVodPlayer) return json;
        List<TXTrackInfo> list = subtitle ? mVodPlayer.getSubtitleTrackInfo() : mVodPlayer.getAudioTrackInfo();
        for (TXTrackInfo trackInfo : list) {
            Map<Object, Object> map = new HashMap<>();
            map.put("trackType", trackInfo.trackType);
            map.put("trackIndex", trackInfo.trackIndex);
            map.put("name", trackInfo.name);
            map.put("isSelected", trackInfo.isSelected);
            map.put("isExclusive", trackInfo.isExclusive);
            map.put("isInternal", trackInfo.isInternal);
            json.add(map);
        }
        return json;
    }

    // =========================================================
    // 渲染 & TRTC
    // =========================================================

    public void reDraw() {
        if (mCurRenderView != null) {
            mCurRenderView.getRenderView().reDrawVod(true);
        }
    }

    public void enableTRTC(boolean isEnabled) {
        if (mVodPlayer == null) return;
        if (isEnabled) {
            Object trtcCloud = getTRTCCloudInstance();
            if (trtcCloud == null) {
                LiteavLog.e(TAG, "enableTRTC failed: TRTCCloud class not found or sharedInstance failed,"
                        + "please use professional sdk");
                return;
            }
            mTRTCInvoker = new FTRTCCloudClassInvoker(trtcCloud);
            mVodPlayer.attachTRTC(trtcCloud);
            if (null != mRenderCarrier) handleTRTCObj(mRenderCarrier);
        } else {
            mVodPlayer.detachTRTC();
            mTRTCInvoker = null;
            mIsStartPublishTRTC = false;
            mFrameCopyListener = null;
            if (null != mRenderCarrier) mRenderCarrier.enableTRTCCloud(false, null);
        }
    }

    private Object getTRTCCloudInstance() {
        try {
            Class<?> trtcCloudClass = Class.forName("com.tencent.trtc.TRTCCloud");
            java.lang.reflect.Method sharedInstanceMethod = trtcCloudClass.getMethod("sharedInstance",
                    android.content.Context.class);
            return sharedInstanceMethod.invoke(null, mFlutterPluginBinding.getApplicationContext());
        } catch (ClassNotFoundException e) {
            LiteavLog.e(TAG, "TRTCCloud class not found: " + e.getMessage());
        } catch (NoSuchMethodException e) {
            LiteavLog.e(TAG, "TRTCCloud.sharedInstance method not found: " + e.getMessage());
        } catch (Exception e) {
            LiteavLog.e(TAG, "Failed to get TRTCCloud instance: " + e.getMessage());
        }
        return null;
    }

    @Override
    public void handleTRTCObj(FTXRenderCarrier carrier) {
        if (null != carrier) {
            carrier.enableTRTCCloud(true, mFrameCopyListener = new FTXEGLRender.OnFrameCopyListener() {
                @Override
                public void onFrameCopied(FTXPixelFrame frame) {
                    if (null != mTRTCInvoker && mIsStartPublishTRTC) {
                        mTRTCInvoker.sendCustomVideoData(frame);
                    }
                }
            });
        }
    }

    public void publishVideo() {
        if (mVodPlayer != null) mVodPlayer.publishVideo();
        if (null != mTRTCInvoker) mTRTCInvoker.setTRTCCustomVideoCapture(true);
        mIsStartPublishTRTC = true;
    }

    public void unpublishVideo() {
        if (mVodPlayer != null) mVodPlayer.unpublishVideo();
        if (null != mTRTCInvoker) mTRTCInvoker.setTRTCCustomVideoCapture(false);
        mIsStartPublishTRTC = false;
    }

    public void publishAudio()   { if (mVodPlayer != null) mVodPlayer.publishAudio();   }
    public void unpublishAudio() { if (mVodPlayer != null) mVodPlayer.unpublishAudio(); }

    public void setPlayerView(int viewId) {
        FTXRenderView renderView = mRenderViewFactory.findViewById(viewId);
        if (null == renderView) {
            LiteavLog.e(TAG, "setPlayerView can not find renderView by id:" + viewId
                    + ", release player's renderView");
        }
        setUpPlayerView(renderView);
    }

    public void setRenderMode(long renderMode) {
        if (mCurrentRenderMode != renderMode) {
            mCurrentRenderMode = renderMode;
            updateTextureRenderMode(renderMode);
        }
    }

    @Override
    public long getPlayerRenderMode() { return mCurrentRenderMode; }

    @Override
    public float getRotation() { return mCurrentRotation; }

    @Override
    public int getVideoWidth() { return null != mVodPlayer ? mVodPlayer.getWidth() : 0; }

    @Override
    public int getVideoHeight() { return null != mVodPlayer ? mVodPlayer.getHeight() : 0; }

    @Override
    protected TXVodPlayer getVodPlayer() { return mVodPlayer; }
}
