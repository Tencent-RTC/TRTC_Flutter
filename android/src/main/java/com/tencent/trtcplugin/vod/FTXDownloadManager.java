// Copyright (c) 2026 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod;

import com.tencent.trtcplugin.vod.tools.FTXVodUtils;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.TXPlayInfoParams;
import com.tencent.rtmp.downloader.ITXVodDownloadListener;
import com.tencent.rtmp.downloader.ITXVodFilePreloadListener;
import com.tencent.rtmp.downloader.ITXVodPreloadListener;
import com.tencent.rtmp.downloader.TXVodDownloadDataSource;
import com.tencent.rtmp.downloader.TXVodDownloadManager;
import com.tencent.rtmp.downloader.TXVodDownloadMediaInfo;
import com.tencent.rtmp.downloader.TXVodPreloadManager;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Video download management: pre-download and offline download.
 * All calls are routed through the {@code TencentVodDownload} channel of {@link VodMethodChannelHandler}.
 */
public class FTXDownloadManager implements ITXVodDownloadListener {

    private static final String TAG = "FTXDownloadManager";

    private final FlutterPlugin.FlutterPluginBinding mFlutterPluginBinding;
    private final VodMethodChannelHandler mHandler;
    private final ExecutorService mPreloadPool = Executors.newCachedThreadPool();

    private boolean isInitDownloadListener = false;

    public FTXDownloadManager(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding,
                              @NonNull VodMethodChannelHandler handler) {
        this.mFlutterPluginBinding = flutterPluginBinding;
        this.mHandler = handler;
    }

    public void destroy() {
        TXVodDownloadManager.getInstance().setListener(null);
    }

    private void initDownloadListenerIfNeed() {
        if (!isInitDownloadListener) {
            isInitDownloadListener = true;
            TXVodDownloadManager.getInstance().setListener(this);
        }
    }

    // ============================== MethodCall entry ==============================

    /**
     * Unified entry for the TencentVodDownload channel.
     * Method names and argument keys are aligned with the Dart side
     * ({@code TXVodDownloadController} / {@code vod_method_channel.dart}).
     */
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        final String method = call.method;
        try {
            switch (method) {
                case "startPreLoad": {
                    String playUrl = call.argument("playUrl");
                    double preloadSizeMB = FTXVodUtils.TXCommonUtil.argDouble(call, "preloadSizeMB", 0);
                    long preferredResolution = FTXVodUtils.TXCommonUtil.argLong(call, "preferredResolution", 0);
                    int taskId = handleStartPreLoad(playUrl, (float) preloadSizeMB, preferredResolution);
                    result.success(taskId);
                    break;
                }
                case "startPreLoadByParams": {
                    handleStartPreLoadByParams(call);
                    result.success(null);
                    break;
                }
                case "stopPreLoad": {
                    Integer taskId = call.argument("value");
                    if (taskId != null) {
                        TXVodPreloadManager.getInstance(mFlutterPluginBinding.getApplicationContext())
                                .stopPreload(taskId);
                    }
                    result.success(null);
                    break;
                }
                case "startDownload": {
                    handleStartDownload(call);
                    result.success(null);
                    break;
                }
                case "resumeDownload": {
                    handleResumeDownload(call);
                    result.success(null);
                    break;
                }
                case "stopDownload": {
                    handleStopDownload(call);
                    result.success(null);
                    break;
                }
                case "setDownloadHeaders": {
                    Map<String, String> map = call.argument("map");
                    if (map != null) {
                        TXVodDownloadManager.getInstance().setHeaders(map);
                    }
                    result.success(null);
                    break;
                }
                case "getDownloadList": {
                    result.success(handleGetDownloadList());
                    break;
                }
                case "getDownloadInfo": {
                    result.success(handleGetDownloadInfo(call));
                    break;
                }
                case "deleteDownloadMediaInfo": {
                    result.success(handleDeleteDownloadMediaInfo(call));
                    break;
                }
                default:
                    LiteavLog.w(TAG, "[download] notImplemented: " + method);
                    result.notImplemented();
            }
        } catch (Exception e) {
            LiteavLog.e(TAG, "[download] " + method + " error: " + e.getMessage());
            result.error("download_error", e.getMessage(), null);
        }
    }

    // ============================== Pre-download ==============================

    private int handleStartPreLoad(String playUrl, float preloadSizeMB, long preferredResolution) {
        final TXVodPreloadManager downloadManager =
                TXVodPreloadManager.getInstance(mFlutterPluginBinding.getApplicationContext());
        return downloadManager.startPreload(playUrl, preloadSizeMB, preferredResolution,
                new ITXVodPreloadListener() {
                    @Override
                    public void onComplete(int taskID, String url) {
                        onPreLoadCompleteEvent(taskID, url);
                    }

                    @Override
                    public void onError(int taskID, String url, int code, String msg) {
                        onPreLoadErrorEvent(-1, taskID, url, code, msg);
                    }
                });
    }

    private void handleStartPreLoadByParams(final MethodCall call) {
        final String playUrl = call.argument("playUrl");
        final String fileId = call.argument("fileId");
        final Integer appIdBoxed = call.argument("appId");
        final String pSign = call.argument("pSign");
        final double preloadSizeMB = FTXVodUtils.TXCommonUtil.argDouble(call, "preloadSizeMB", 0);
        final long preferredResolution = FTXVodUtils.TXCommonUtil.argLong(call, "preferredResolution", 0);
        final long tmpTaskId = FTXVodUtils.TXCommonUtil.argLong(call, "tmpPreloadTaskId", -1);
        final Map<String, String> httpHeader = call.argument("httpHeader");

        mPreloadPool.execute(new Runnable() {
            @Override
            public void run() {
                final boolean isUrlPreload = !TextUtils.isEmpty(playUrl);
                TXPlayInfoParams txPlayInfoParams;
                if (isUrlPreload) {
                    txPlayInfoParams = new TXPlayInfoParams(playUrl);
                } else {
                    int appId = appIdBoxed != null ? appIdBoxed : 0;
                    txPlayInfoParams = new TXPlayInfoParams(appId, fileId, pSign);
                }
                if (httpHeader != null) {
                    txPlayInfoParams.setHeaders(httpHeader);
                }
                final TXVodPreloadManager downloadManager =
                        TXVodPreloadManager.getInstance(mFlutterPluginBinding.getApplicationContext());
                int retTaskID = downloadManager.startPreload(txPlayInfoParams,
                        (float) preloadSizeMB, preferredResolution,
                        new ITXVodFilePreloadListener() {
                            @Override
                            public void onStart(int taskID, String fileId, String url, Bundle bundle) {
                                if (tmpTaskId >= 0) {
                                    onPreLoadStartEvent(tmpTaskId, taskID, fileId, url, bundle);
                                }
                            }

                            @Override
                            public void onComplete(int taskID, String url) {
                                onPreLoadCompleteEvent(taskID, url);
                            }

                            @Override
                            public void onError(int taskID, String url, int code, String msg) {
                                onPreLoadErrorEvent(tmpTaskId, taskID, url, code, msg);
                            }
                        });
                if (isUrlPreload && tmpTaskId >= 0) {
                    onPreLoadStartEvent(tmpTaskId, retTaskID, fileId, playUrl, new Bundle());
                }
            }
        });
    }

    private void onPreLoadStartEvent(long tmpTaskId, int taskId, String fileId, String url, Bundle params) {
        Bundle bundle = new Bundle();
        bundle.putLong("tmpTaskId", tmpTaskId);
        bundle.putInt("taskId", taskId);
        bundle.putString("fileId", fileId);
        bundle.putString("url", url);
        Map<String, Object> event = FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_PREDOWNLOAD_ON_START, bundle);
        event.put("params", FTXVodUtils.TXCommonUtil.getParams(0, params));
        mHandler.invokePreDownloadEvent(event);
    }

    private void onPreLoadCompleteEvent(int taskId, String url) {
        Bundle bundle = new Bundle();
        bundle.putInt("taskId", taskId);
        bundle.putString("url", url);
        mHandler.invokePreDownloadEvent(
                FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_PREDOWNLOAD_ON_COMPLETE, bundle));
    }

    private void onPreLoadErrorEvent(long tmpTaskId, int taskId, String url, int code, String msg) {
        Bundle bundle = new Bundle();
        if (tmpTaskId >= 0) {
            bundle.putLong("tmpTaskId", tmpTaskId);
        }
        bundle.putInt("taskId", taskId);
        bundle.putInt("code", code);
        bundle.putString("url", url);
        bundle.putString("msg", msg);
        mHandler.invokePreDownloadEvent(
                FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_PREDOWNLOAD_ON_ERROR, bundle));
    }

    // ============================== Download ==============================

    private void handleStartDownload(MethodCall call) {
        initDownloadListenerIfNeed();
        Integer quality = call.argument("quality");
        String videoUrl = call.argument("url");
        Integer appId = call.argument("appId");
        String fileId = call.argument("fileId");
        String pSign = call.argument("pSign");
        String userName = call.argument("userName");
        if (!TextUtils.isEmpty(videoUrl)) {
            TXVodDownloadManager.getInstance().startDownloadUrl(videoUrl, userName);
        } else if (null != appId && null != fileId) {
            TXVodDownloadDataSource dataSource =
                    new TXVodDownloadDataSource(appId, fileId, optQuality(quality), pSign, userName);
            TXVodDownloadManager.getInstance().startDownload(dataSource);
        }
    }

    private void handleResumeDownload(MethodCall call) {
        initDownloadListenerIfNeed();
        TXVodDownloadMediaInfo mediaInfo = resolveMediaInfo(call);
        if (null != mediaInfo) {
            TXVodDownloadDataSource dataSource = mediaInfo.getDataSource();
            if (dataSource != null) {
                TXVodDownloadManager.getInstance().startDownload(dataSource);
            } else {
                TXVodDownloadManager.getInstance().startDownloadUrl(mediaInfo.getUrl(), mediaInfo.getUserName());
            }
        }
    }

    private void handleStopDownload(MethodCall call) {
        initDownloadListenerIfNeed();
        TXVodDownloadMediaInfo mediaInfo = resolveMediaInfo(call);
        if (mediaInfo != null) {
            TXVodDownloadManager.getInstance().stopDownload(mediaInfo);
        }
    }

    private List<Map<String, Object>> handleGetDownloadList() {
        List<TXVodDownloadMediaInfo> medias = TXVodDownloadManager.getInstance().getDownloadMediaInfoList();
        List<Map<String, Object>> mediaResults = new ArrayList<>();
        if (null != medias) {
            for (TXVodDownloadMediaInfo mediaInfo : medias) {
                if (null != mediaInfo) {
                    mediaResults.add(buildMapFromDownloadInfo(mediaInfo));
                }
            }
        }
        return mediaResults;
    }

    private Map<String, Object> handleGetDownloadInfo(MethodCall call) {
        TXVodDownloadMediaInfo mediaInfo = resolveMediaInfo(call);
        return buildMapFromDownloadInfo(mediaInfo);
    }

    private boolean handleDeleteDownloadMediaInfo(MethodCall call) {
        TXVodDownloadMediaInfo mediaInfo = resolveMediaInfo(call);
        boolean deleteResult = false;
        if (mediaInfo != null) {
            TXVodDownloadManager.getInstance().stopDownload(mediaInfo);
            deleteResult = TXVodDownloadManager.getInstance().deleteDownloadMediaInfo(mediaInfo);
        }
        return deleteResult;
    }

    private TXVodDownloadMediaInfo resolveMediaInfo(MethodCall call) {
        Integer quality = call.argument("quality");
        String videoUrl = call.argument("url");
        Integer appId = call.argument("appId");
        String fileId = call.argument("fileId");
        String userName = call.argument("userName");
        return parseMediaInfoFromInfo(quality, videoUrl, appId, fileId, userName);
    }

    private TXVodDownloadMediaInfo parseMediaInfoFromInfo(Integer quality, String url, Integer appId,
                                                          String fileId, String userName) {
        TXVodDownloadMediaInfo mediaInfo = null;
        if (null == userName) {
            userName = "default";
        }
        if (null != appId && null != fileId) {
            mediaInfo = TXVodDownloadManager.getInstance()
                    .getDownloadMediaInfo(appId, fileId, optQuality(quality), userName);
        } else if (!TextUtils.isEmpty(url)) {
            mediaInfo = TXVodDownloadManager.getInstance().getDownloadMediaInfo(url, -1L, userName);
            if (null == mediaInfo) {
                mediaInfo = parseMediaInfoFromInfoByAll(quality, url, appId, fileId, userName);
            }
        }
        return mediaInfo;
    }

    private TXVodDownloadMediaInfo parseMediaInfoFromInfoByAll(Integer quality, String url, Integer appId,
                                                               String fileId, String userName) {
        boolean isFileIdInfo = null != appId && null != fileId;
        boolean isUrlInfo = !TextUtils.isEmpty(url);
        List<TXVodDownloadMediaInfo> mediaInfoList = TXVodDownloadManager.getInstance().getDownloadMediaInfoList();
        if (null != mediaInfoList && (isFileIdInfo || isUrlInfo)) {
            for (TXVodDownloadMediaInfo mediaInfo : mediaInfoList) {
                if (TextUtils.equals(userName, mediaInfo.getUserName())) {
                    if (isFileIdInfo) {
                        TXVodDownloadDataSource dataSource = mediaInfo.getDataSource();
                        if (null != dataSource) {
                            if (dataSource.getAppId() == appId
                                    && TextUtils.equals(dataSource.getFileId(), fileId)
                                    && optQuality(quality) == dataSource.getQuality()) {
                                return mediaInfo;
                            }
                        }
                    } else if (TextUtils.equals(url, mediaInfo.getUrl())) {
                        return mediaInfo;
                    }
                }
            }
        }
        return null;
    }

    private int optQuality(Integer quality) {
        return quality == null ? TXVodDownloadDataSource.QUALITY_UNK : quality;
    }

    // ============================== ITXVodDownloadListener ==============================

    @Override
    public void onDownloadStart(TXVodDownloadMediaInfo txVodDownloadMediaInfo) {
        Bundle bundle = buildCommonDownloadBundle(txVodDownloadMediaInfo);
        mHandler.invokeDownloadEvent(FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_DOWNLOAD_START, bundle));
    }

    @Override
    public void onDownloadProgress(TXVodDownloadMediaInfo txVodDownloadMediaInfo) {
        Bundle bundle = buildCommonDownloadBundle(txVodDownloadMediaInfo);
        mHandler.invokeDownloadEvent(FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_DOWNLOAD_PROGRESS, bundle));
    }

    @Override
    public void onDownloadStop(TXVodDownloadMediaInfo txVodDownloadMediaInfo) {
        Bundle bundle = buildCommonDownloadBundle(txVodDownloadMediaInfo);
        mHandler.invokeDownloadEvent(FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_DOWNLOAD_STOP, bundle));
    }

    @Override
    public void onDownloadFinish(TXVodDownloadMediaInfo txVodDownloadMediaInfo) {
        Bundle bundle = buildCommonDownloadBundle(txVodDownloadMediaInfo);
        mHandler.invokeDownloadEvent(FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_DOWNLOAD_FINISH, bundle));
    }

    @Override
    public void onDownloadError(TXVodDownloadMediaInfo txVodDownloadMediaInfo, int i, String s) {
        Bundle bundle = buildCommonDownloadBundle(txVodDownloadMediaInfo);
        bundle.putInt("errorCode", i);
        bundle.putString("errorMsg", s);
        mHandler.invokeDownloadEvent(FTXVodUtils.TXCommonUtil.getParams(FTXPlayerConstants.EVENT_DOWNLOAD_ERROR, bundle));
    }

    /** ijk legacy, temporarily abandoned. */
    @Override
    public int hlsKeyVerify(TXVodDownloadMediaInfo txVodDownloadMediaInfo, String s, byte[] bytes) {
        return 0;
    }

    // ============================== Map builders ==============================

    private Bundle buildCommonDownloadBundle(TXVodDownloadMediaInfo mediaInfo) {
        Bundle bundle = new Bundle();
        if (null == mediaInfo) return bundle;
        bundle.putString("playPath", mediaInfo.getPlayPath());
        bundle.putFloat("progress", mediaInfo.getProgress());
        bundle.putInt("downloadState", FTXVodUtils.TXCommonUtil.getDownloadEventByState(mediaInfo.getDownloadState()));
        bundle.putString("userName", mediaInfo.getUserName());
        bundle.putInt("duration", mediaInfo.getDuration());
        bundle.putInt("playableDuration", mediaInfo.getPlayableDuration());
        bundle.putLong("size", mediaInfo.getSize());
        bundle.putLong("downloadSize", mediaInfo.getDownloadSize());
        if (!TextUtils.isEmpty(mediaInfo.getUrl())) {
            bundle.putString("url", mediaInfo.getUrl());
        }
        if (null != mediaInfo.getDataSource()) {
            TXVodDownloadDataSource dataSource = mediaInfo.getDataSource();
            bundle.putInt("appId", dataSource.getAppId());
            bundle.putString("fileId", dataSource.getFileId());
            bundle.putString("pSign", dataSource.getPSign());
            bundle.putInt("quality", dataSource.getQuality());
            bundle.putString("token", dataSource.getToken());
        }
        bundle.putInt("speed", mediaInfo.getSpeed());
        bundle.putBoolean("isResourceBroken", mediaInfo.isResourceBroken());
        return bundle;
    }

    /**
     * Build the map returned by {@code getDownloadList} / {@code getDownloadInfo}.
     * Field names are aligned with the Dart side {@code TXVodDownloadMediaInfo.fromMap}.
     */
    private Map<String, Object> buildMapFromDownloadInfo(@Nullable TXVodDownloadMediaInfo mediaInfo) {
        Map<String, Object> map = new HashMap<>();
        if (null == mediaInfo) return map;

        map.put("playPath", mediaInfo.getPlayPath());
        BigDecimal progressDec = BigDecimal.valueOf(mediaInfo.getProgress());
        map.put("progress", progressDec.doubleValue());
        map.put("downloadState", (long) FTXVodUtils.TXCommonUtil.getDownloadEventByState(mediaInfo.getDownloadState()));
        map.put("userName", mediaInfo.getUserName());
        map.put("duration", (long) mediaInfo.getDuration());
        map.put("playableDuration", (long) mediaInfo.getPlayableDuration());
        map.put("size", mediaInfo.getSize());
        map.put("downloadSize", mediaInfo.getDownloadSize());
        if (!TextUtils.isEmpty(mediaInfo.getUrl())) {
            map.put("url", mediaInfo.getUrl());
        }
        map.put("speed", (long) mediaInfo.getSpeed());
        map.put("isResourceBroken", mediaInfo.isResourceBroken());
        if (null != mediaInfo.getDataSource()) {
            TXVodDownloadDataSource dataSource = mediaInfo.getDataSource();
            map.put("appId", (long) dataSource.getAppId());
            map.put("fileId", dataSource.getFileId());
            map.put("pSign", dataSource.getPSign());
            map.put("quality", (long) dataSource.getQuality());
            map.put("token", dataSource.getToken());
        }
        return map;
    }

}
