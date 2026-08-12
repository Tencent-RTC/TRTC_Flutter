// Copyright (c) 2026 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod.tools;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.liteav.txcplayer.model.TXSubtitleRenderModel;
import com.tencent.trtcplugin.vod.FTXPlayerConstants;
import com.tencent.rtmp.TXVodConstants;
import com.tencent.rtmp.TXVodPlayConfig;
import com.tencent.rtmp.downloader.TXVodDownloadMediaInfo;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;

/**
 * VOD module utility aggregator.
 *
 * <p>This class consolidates the original {@code tools/*} helpers and the top-level
 * {@code FTXTransformation} into a single source file so that the {@code vod} package
 * is no longer scattered with 5 tiny utility files. Each former class is preserved as a
 * static nested class and keeps its original public API:</p>
 *
 * <ul>
 *   <li>{@link Transformation}        – previously {@code FTXTransformation}
 *       (Live conversion has been removed in v3 because Live is not supported).</li>
 *   <li>{@link TXCommonUtil}          – previously {@code tools/TXCommonUtil};
 *       now also exposes the unified {@link TXCommonUtil#argInt}/{@link TXCommonUtil#argDouble}
 *       /{@link TXCommonUtil#argBool} helpers shared by every {@code MethodCall} entry
 *       (E/F/G dedup).</li>
 *   <li>{@link TXFlutterEngineHolder} – previously {@code tools/TXFlutterEngineHolder}
 *       together with its inner {@code TXAppStatusListener}.</li>
 *   <li>{@link FTXContextWrapper}     – previously {@code tools/FTXContextWrapper}.</li>
 *   <li>{@link FTXVersionAdapter}     – previously {@code tools/FTXVersionAdapter}.</li>
 * </ul>
 *
 * <p>Usage examples:</p>
 * <pre>
 *   FTXVodUtils.TXCommonUtil.getParams(0, bundle);
 *   FTXVodUtils.TXFlutterEngineHolder.getInstance().attachBindLife(binding);
 *   FTXVodUtils.Transformation.transformToVodConfig(map);
 *   FTXVodUtils.TXCommonUtil.argInt(call, "playerId", null);
 * </pre>
 */
public final class FTXVodUtils {

    private FTXVodUtils() {
    }

    // =====================================================================================
    // Object conversion (formerly FTXTransformation)
    // =====================================================================================

    /**
     * Object conversion utilities.
     *
     * <p>The Live conversion ({@code transformToLiveConfig}) has been removed in v3 because
     * Live playback is no longer supported. SuperPlayer keeps the Live variant intact.</p>
     */
    public static class Transformation {

        private Transformation() {
        }

        /**
         * Convert map to vod config.
         */
        @SuppressWarnings("unchecked")
        public static TXVodPlayConfig transformToVodConfig(Map<Object, Object> config) {
            TXVodPlayConfig playConfig = new TXVodPlayConfig();
            if (config == null) return playConfig;

            Integer connectRetryCount = (Integer) config.get("connectRetryCount");
            if (intIsNotEmpty(connectRetryCount)) {
                playConfig.setConnectRetryCount(connectRetryCount);
            }
            Integer connectRetryInterval = (Integer) config.get("connectRetryInterval");
            if (intIsNotEmpty(connectRetryInterval)) {
                playConfig.setConnectRetryInterval(connectRetryInterval);
            }
            Integer timeout = (Integer) config.get("timeout");
            if (intIsNotEmpty(timeout)) {
                playConfig.setTimeout(timeout);
            }
            Integer playerType = (Integer) config.get("playerType");
            if (null != playerType) {
                playConfig.setPlayerType(playerType);
            }
            Map<String, String> headers = (Map<String, String>) config.get("headers");
            if (null == headers) {
                headers = new HashMap<>();
            }
            playConfig.setHeaders(headers);
            Boolean enableAccurateSeek = (Boolean) config.get("enableAccurateSeek");
            if (null != enableAccurateSeek) {
                playConfig.setEnableAccurateSeek(enableAccurateSeek);
            }
            Boolean autoRotate = (Boolean) config.get("autoRotate");
            if (null != autoRotate) {
                playConfig.setAutoRotate(autoRotate);
            }
            Boolean smoothSwitchBitrate = (Boolean) config.get("smoothSwitchBitrate");
            if (null != smoothSwitchBitrate) {
                playConfig.setSmoothSwitchBitrate(smoothSwitchBitrate);
            }
            String cacheMp4ExtName = (String) config.get("cacheMp4ExtName");
            if (!TextUtils.isEmpty(cacheMp4ExtName)) {
                playConfig.setCacheMp4ExtName(cacheMp4ExtName);
            }
            Integer progressInterval = (Integer) config.get("progressInterval");
            if (intIsNotEmpty(progressInterval)) {
                playConfig.setProgressInterval(progressInterval);
            }
            Float maxBufferSize = toFloat(config.get("maxBufferSize"));
            if (floatIsNotEmpty(maxBufferSize)) {
                playConfig.setMaxBufferSize(maxBufferSize);
            }
            Float maxPreloadSize = toFloat(config.get("maxPreloadSize"));
            if (floatIsNotEmpty(maxPreloadSize)) {
                playConfig.setMaxPreloadSize(maxPreloadSize);
            }
            Integer firstStartPlayBufferTime = (Integer) config.get("firstStartPlayBufferTime");
            if (null != firstStartPlayBufferTime) {
                playConfig.setFirstStartPlayBufferTime(firstStartPlayBufferTime);
            }
            Integer nextStartPlayBufferTime = (Integer) config.get("nextStartPlayBufferTime");
            if (null != nextStartPlayBufferTime) {
                playConfig.setNextStartPlayBufferTime(nextStartPlayBufferTime);
            }
            String overlayKey = (String) config.get("overlayKey");
            if (!TextUtils.isEmpty(overlayKey)) {
                playConfig.setOverlayKey(overlayKey);
            }
            String overlayIv = (String) config.get("overlayIv");
            if (!TextUtils.isEmpty(overlayIv)) {
                playConfig.setOverlayIv(overlayIv);
            }
            Map<String, Object> extInfoMap = (Map<String, Object>) config.get("extInfoMap");
            if (null == extInfoMap) {
                extInfoMap = new HashMap<>();
            }
            playConfig.setExtInfo(extInfoMap);
            Boolean enableRenderProcess = (Boolean) config.get("enableRenderProcess");
            if (null != enableRenderProcess) {
                playConfig.setEnableRenderProcess(enableRenderProcess);
            }
            // preferredResolution: accept both int (current Dart toMap) and String (legacy Pigeon).
            Long preferredResolution = toLong(config.get("preferredResolution"));
            if (null != preferredResolution && preferredResolution > 0) {
                playConfig.setPreferredResolution(preferredResolution);
            }
            Integer mediaType = toInt(config.get("mediaType"));
            if (null != mediaType) {
                playConfig.setMediaType(mediaType);
            }
            Integer encryptedMp4Level = toInt(config.get("encryptedMp4Level"));
            if (null != encryptedMp4Level) {
                playConfig.setEncryptedMp4Level(encryptedMp4Level);
            }
            Object preferAudioTrack = config.get("preferAudioTrack");
            if (preferAudioTrack instanceof String) {
                // Pass empty string / null through to the SDK, same as SuperPlayer.
                playConfig.setPreferredAudioTrack((String) preferAudioTrack);
            }
            return playConfig;
        }

        /**
         * Convert map to TXSubtitleRenderModel. Keys must match Dart FTXSubtitleRenderModel.toMap.
         */
        public static TXSubtitleRenderModel transToTitleRenderModel(Map<Object, Object> msg) {
            TXSubtitleRenderModel renderModel = new TXSubtitleRenderModel();
            if (msg == null) return renderModel;

            Integer canvasWidth = toInt(msg.get("canvasWidth"));
            if (null != canvasWidth) renderModel.canvasWidth = canvasWidth;
            Integer canvasHeight = toInt(msg.get("canvasHeight"));
            if (null != canvasHeight) renderModel.canvasHeight = canvasHeight;
            Object familyName = msg.get("familyName");
            if (familyName instanceof String) renderModel.familyName = (String) familyName;
            Float fontSize = toFloat(msg.get("fontSize"));
            if (null != fontSize) renderModel.fontSize = fontSize;
            Float fontScale = toFloat(msg.get("fontScale"));
            if (null != fontScale) renderModel.fontScale = fontScale;
            Integer fontColor = toInt(msg.get("fontColor"));
            if (null != fontColor) renderModel.fontColor = fontColor;
            Object bold = msg.get("isBondFontStyle");
            if (bold instanceof Boolean) renderModel.isBondFontStyle = (Boolean) bold;
            Float outlineWidth = toFloat(msg.get("outlineWidth"));
            if (null != outlineWidth) renderModel.outlineWidth = outlineWidth;
            Integer outlineColor = toInt(msg.get("outlineColor"));
            if (null != outlineColor) renderModel.outlineColor = outlineColor;
            Float lineSpace = toFloat(msg.get("lineSpace"));
            if (null != lineSpace) renderModel.lineSpace = lineSpace;
            Float startMargin = toFloat(msg.get("startMargin"));
            if (null != startMargin) renderModel.startMargin = startMargin;
            Float endMargin = toFloat(msg.get("endMargin"));
            if (null != endMargin) renderModel.endMargin = endMargin;
            Float verticalMargin = toFloat(msg.get("verticalMargin"));
            if (null != verticalMargin) renderModel.verticalMargin = verticalMargin;
            return renderModel;
        }

        private static Float toFloat(Object v) {
            if (v instanceof Number) return ((Number) v).floatValue();
            return null;
        }

        private static Integer toInt(Object v) {
            if (v instanceof Number) return ((Number) v).intValue();
            return null;
        }

        private static Long toLong(Object v) {
            if (v instanceof Number) return ((Number) v).longValue();
            if (v instanceof String) {
                try {
                    return Long.parseLong((String) v);
                } catch (NumberFormatException ignored) {
                    return null;
                }
            }
            return null;
        }

        private static boolean intIsNotEmpty(Integer value) {
            return null != value && value > 0;
        }

        private static boolean floatIsNotEmpty(Float value) {
            return null != value && value > 0;
        }
    }

    // =====================================================================================
    // Common utility (formerly tools/TXCommonUtil) – also hosts the shared MethodCall arg helpers
    // =====================================================================================

    /**
     * Common utility class.
     */
    public static class TXCommonUtil {

        private TXCommonUtil() {
        }

        private static final String TAG = "TXCommonUtil";

        private static final String KEY_MAX_BRIGHTNESS = "max_brightness";
        private static final String KEY_IS_MIUI = "is_miui";

        private static final Map<String, Object> CACHE_MAP = new HashMap<>();

        static final Map<Integer, Integer> DOWNLOAD_STATE_MAP = new HashMap<Integer, Integer>() {{
            put(TXVodDownloadMediaInfo.STATE_INIT, FTXPlayerConstants.EVENT_DOWNLOAD_START);
            put(TXVodDownloadMediaInfo.STATE_START, FTXPlayerConstants.EVENT_DOWNLOAD_PROGRESS);
            put(TXVodDownloadMediaInfo.STATE_FINISH, FTXPlayerConstants.EVENT_DOWNLOAD_FINISH);
            put(TXVodDownloadMediaInfo.STATE_STOP, FTXPlayerConstants.EVENT_DOWNLOAD_STOP);
            put(TXVodDownloadMediaInfo.STATE_ERROR, FTXPlayerConstants.EVENT_DOWNLOAD_ERROR);
        }};

        /**
         * Return the system max brightness. Handles MIUI devices where the value is
         * not always 255 (MIUI on Android 13+ reports 128).
         *
         * @return max
         */
        public static float getBrightnessMax() {
            if (CACHE_MAP.containsKey(KEY_MAX_BRIGHTNESS)) {
                //noinspection ConstantConditions
                return (float) CACHE_MAP.get(KEY_MAX_BRIGHTNESS);
            }
            float maxBrightness = 255f;
            try {
                Resources system = Resources.getSystem();
                int resId = system.getIdentifier("config_screenBrightnessSettingMaximum",
                        "integer", "android");
                if (resId != 0) {
                    maxBrightness = system.getInteger(resId);
                }
            } catch (Exception e) {
                LiteavLog.e(TAG, "getBrightnessMax error", e);
            }
            if (TXCommonUtil.isMIUI() && Build.VERSION.SDK_INT >= 33) {
                maxBrightness = 128F;
            }
            CACHE_MAP.put(KEY_MAX_BRIGHTNESS, maxBrightness);
            return maxBrightness;
        }

        public static boolean isMIUI() {
            if (CACHE_MAP.containsKey(KEY_IS_MIUI)) {
                //noinspection ConstantConditions
                return (boolean) CACHE_MAP.get(KEY_IS_MIUI);
            } else {
                String pro = Build.MANUFACTURER;
                boolean isMiui = TextUtils.equals(pro, "Xiaomi");
                CACHE_MAP.put(KEY_IS_MIUI, isMiui);
                return isMiui;
            }
        }

        /**
         * Convert an event Bundle into a MethodChannel-serializable map. The "event"
         * key carries the event code; pass {@code event = 0} to skip writing the event key
         * (this also subsumes the former {@code transToMap}).
         */
        public static Map<String, Object> getParams(int event, Bundle bundle) {
            Map<String, Object> param = new HashMap<>();
            if (event != 0) {
                param.put(FTXPlayerConstants.EVT_KEY_PLAYER_EVENT, event);
            }

            if (bundle != null && !bundle.isEmpty()) {
                Set<String> keySet = bundle.keySet();
                for (String key : keySet) {
                    Object val = bundle.get(key);
                    if (null != val) {
                        param.put(key, val);
                    }
                }
            }

            return param;
        }

        public static int getDownloadEventByState(int mediaInfoDownloadState) {
            Integer event = DOWNLOAD_STATE_MAP.get(mediaInfoDownloadState);
            return null != event ? event : FTXPlayerConstants.EVENT_DOWNLOAD_ERROR;
        }

        public static boolean isBlankStr(String value) {
            if (null == value) {
                return false;
            }
            return value.trim().isEmpty();
        }

        // ---------------- Shared MethodCall argument helpers (E/F/G dedup) ----------------

        /**
         * Read an integer-like {@code MethodCall} argument. Accepts {@link Integer},
         * {@link Long} or any other {@link Number} subclass; returns {@code def} when
         * missing or of an incompatible type.
         */
        public static Integer argInt(@NonNull MethodCall call, @NonNull String key, @Nullable Integer def) {
            Object v = call.argument(key);
            if (v instanceof Integer) return (Integer) v;
            if (v instanceof Long)    return ((Long) v).intValue();
            if (v instanceof Number)  return ((Number) v).intValue();
            return def;
        }

        /**
         * Read a long-like {@code MethodCall} argument.
         */
        public static long argLong(@NonNull MethodCall call, @NonNull String key, long def) {
            Object v = call.argument(key);
            if (v instanceof Number) return ((Number) v).longValue();
            return def;
        }

        /**
         * Read a double-like {@code MethodCall} argument (boxed return for nullable callers).
         */
        public static Double argDouble(@NonNull MethodCall call, @NonNull String key, @Nullable Double def) {
            Object v = call.argument(key);
            if (v instanceof Double)  return (Double) v;
            if (v instanceof Float)   return ((Float) v).doubleValue();
            if (v instanceof Number)  return ((Number) v).doubleValue();
            return def;
        }

        /**
         * Same as {@link #argDouble(MethodCall, String, Double)} but with a primitive default.
         */
        public static double argDouble(@NonNull MethodCall call, @NonNull String key, double def) {
            Object v = call.argument(key);
            if (v instanceof Number) return ((Number) v).doubleValue();
            return def;
        }

        /**
         * Read a boolean-like {@code MethodCall} argument.
         */
        public static boolean argBool(@NonNull MethodCall call, @NonNull String key, boolean def) {
            Object v = call.argument(key);
            return (v instanceof Boolean) ? (Boolean) v : def;
        }
    }

    // =====================================================================================
    // Flutter engine holder (formerly tools/TXFlutterEngineHolder)
    // =====================================================================================

    public static class TXFlutterEngineHolder {

        private static final String TAG = "TXFlutterEngineHolder";

        private static final class SingletonInstance {
            private static final TXFlutterEngineHolder instance = new TXFlutterEngineHolder();
        }

        private int mFrontContextCount = 0;
        private Application.ActivityLifecycleCallbacks mLifeCallback;
        private final List<TXAppStatusListener> mListeners = new ArrayList<>();
        private boolean mIsEnterBack = false;

        /**
         * Reference count of callers that have invoked {@link #attachBindLife}. The underlying
         * {@link Application.ActivityLifecycleCallbacks} is registered on 0->1 transition and
         * unregistered on 1->0 transition. This makes the holder safe to share across multiple
         * Flutter engines / plugin modules.
         */
        private int mBindRefCount = 0;

        private final List<WeakReference<Activity>> mActivityList = new ArrayList<>();

        public static TXFlutterEngineHolder getInstance() {
            return SingletonInstance.instance;
        }

        public void attachBindLife(FlutterPlugin.FlutterPluginBinding binding) {
            if (null == binding) {
                return;
            }
            mBindRefCount++;
            if (mLifeCallback != null) {
                LiteavLog.i(TAG, "attachBindLife already attached, refCount=" + mBindRefCount);
                return;
            }
            mLifeCallback = new Application.ActivityLifecycleCallbacks() {

                @Override
                public void onActivityCreated(@NonNull Activity activity, @Nullable Bundle savedInstanceState) {

                }

                @Override
                public void onActivityStarted(@NonNull Activity activity) {
                    mFrontContextCount++;
                    LiteavLog.i(TAG, "activity is started:" + activity);
                    if (mIsEnterBack && mFrontContextCount > 0) {
                        mIsEnterBack = false;
                        notifyResume();
                    }
                }

                @Override
                public void onActivityResumed(@NonNull Activity activity) {
                    synchronized (mActivityList) {
                        LiteavLog.i(TAG, "activity is resumed:" + activity);
                        int index = findIndexByAct(activity);
                        if (index >= 0) {
                            // refresh index
                            mActivityList.remove(index);
                        }
                        mActivityList.add(new WeakReference<>(activity));
                    }
                }

                @Override
                public void onActivityPaused(@NonNull Activity activity) {

                }

                @Override
                public void onActivityStopped(@NonNull Activity activity) {
                    mFrontContextCount--;
                    LiteavLog.i(TAG, "activity is stopped:" + activity);
                    if (!mIsEnterBack && mFrontContextCount <= 0) {
                        mIsEnterBack = true;
                        notifyEnterBack();
                    }
                }

                @Override
                public void onActivitySaveInstanceState(@NonNull Activity activity, @NonNull Bundle outState) {

                }

                @Override
                public void onActivityDestroyed(@NonNull Activity activity) {
                    synchronized (mActivityList) {
                        LiteavLog.i(TAG, "activity is destroyed:" + activity);
                        int index = findIndexByAct(activity);
                        if (index >= 0) {
                            mActivityList.remove(index);
                        }
                    }
                }
            };
            ((Application) binding.getApplicationContext()).registerActivityLifecycleCallbacks(mLifeCallback);
        }

        private int findIndexByAct(Activity activity) {
            synchronized (mActivityList) {
                int index = -1;
                for (int i = 0; i < mActivityList.size(); i++) {
                    WeakReference<Activity> weakReference = mActivityList.get(i);
                    if (weakReference.get() == activity) {
                        index = i;
                        break;
                    }
                }
                return index;
            }
        }

        public boolean isInForeground() {
            return !mIsEnterBack;
        }

        public Activity getActivityByIndex(int index) {
            synchronized (mActivityList) {
                if (index >= mActivityList.size() || index < 0) {
                    return null;
                }
                return mActivityList.get(index).get();
            }
        }

        public Activity getPreActivity() {
            synchronized (mActivityList) {
                final int size = mActivityList.size();
                final int preIndex = size - 2;
                return getActivityByIndex(preIndex);
            }
        }

        public Activity getCurActivity() {
            synchronized (mActivityList) {
                final int size = mActivityList.size();
                final int preIndex = size - 1;
                return getActivityByIndex(preIndex);
            }
        }

        public void destroy(FlutterPlugin.FlutterPluginBinding binding) {
            LiteavLog.i(TAG, "called engine holder destroy, refCount=" + mBindRefCount);
            if (null == binding) {
                return;
            }
            if (mBindRefCount > 0) {
                mBindRefCount--;
            }
            if (mBindRefCount > 0) {
                return;
            }
            if (null == mLifeCallback) {
                return;
            }
            ((Application) binding.getApplicationContext()).unregisterActivityLifecycleCallbacks(mLifeCallback);
            mLifeCallback = null;
        }

        public void addAppLifeListener(TXAppStatusListener listener) {
            synchronized (mListeners) {
                if (!mListeners.contains(listener)) {
                    mListeners.add(listener);
                }
            }
        }

        public void removeAppLifeListener(TXAppStatusListener listener) {
            synchronized (mListeners) {
                mListeners.remove(listener);
            }
        }

        public void clearListener() {
            synchronized (mListeners) {
                mListeners.clear();
            }
        }

        private void notifyResume() {
            synchronized (mListeners) {
                for (TXAppStatusListener listener : mListeners) {
                    listener.onResume();
                }
            }
        }

        private void notifyEnterBack() {
            synchronized (mListeners) {
                for (TXAppStatusListener listener : mListeners) {
                    listener.onEnterBack();
                }
            }
        }

        public abstract static class TXAppStatusListener {
            public abstract void onResume();

            public abstract void onEnterBack();
        }
    }

    // =====================================================================================
    // Context wrapper (formerly tools/FTXContextWrapper)
    // =====================================================================================

    public static class FTXContextWrapper {

        private FTXContextWrapper() {
        }

        @SuppressLint({"UnspecifiedRegisterReceiverFlag", "WrongConstant"})
        public static void registerReceiverForNotExport(Context applicationContext, BroadcastReceiver receiver,
                                                        IntentFilter filter) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                applicationContext.registerReceiver(receiver, filter, 0x4);
            } else {
                applicationContext.registerReceiver(receiver, filter);
            }
        }
    }

    // =====================================================================================
    // SDK version adapter (formerly tools/FTXVersionAdapter)
    // =====================================================================================

    public static class FTXVersionAdapter {

        private FTXVersionAdapter() {
        }

        private static final String TAG = "FTXVersionAdapter";

        public static void enableCustomSubtitle(TXVodPlayConfig config, int isOpen) {
            if (null == config) {
                config = new TXVodPlayConfig();
            }
            Map<String, Object> extInfo = safeGetExtInfo(config);
            String customKeyName = getVodKeyValue("PLAYER_OPTION_KEY_SUBTITLE_OUTPUT_TYPE");
            if (null != customKeyName) {
                extInfo.put(customKeyName, isOpen);
                config.setExtInfo(extInfo);
            }
        }

        public static void enableDrmLevel3(TXVodPlayConfig config, boolean isOpen) {
            if (null == config) {
                config = new TXVodPlayConfig();
            }
            Map<String, Object> extInfo = safeGetExtInfo(config);
            String customKeyName = getVodKeyValue("VOD_USE_DRM_L3");
            if (null != customKeyName) {
                extInfo.put(customKeyName, isOpen);
                config.setExtInfo(extInfo);
            }
        }

        private static Map<String, Object> safeGetExtInfo(TXVodPlayConfig config) {
            Map<String, Object> extInfo = config.getExtInfoMap();
            if (extInfo == null) {
                extInfo = new HashMap<>();
            }
            //noinspection UnnecessaryLocalVariable
            Map<String, Object> canModifyMap = new HashMap<>(extInfo);
            return canModifyMap;
        }

        public static String getVodKeyValue(String paramDeclareName) {
            try {
                Class<?> clazz = TXVodConstants.class;
                Field field = clazz.getDeclaredField(paramDeclareName);
                field.setAccessible(true);
                Object value = field.get(null);
                return (String) value;
            } catch (NoSuchFieldException | IllegalAccessException e) {
                LiteavLog.e(TAG, "vod key obtain failed, maybe version is too low", e);
            }
            return null;
        }
    }
}