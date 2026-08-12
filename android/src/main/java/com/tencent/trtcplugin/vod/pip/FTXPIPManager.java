// Copyright (c) 2022 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod.pip;

import android.app.Activity;
import android.app.AppOpsManager;
import android.app.PendingIntent;
import android.app.PictureInPictureParams;
import android.app.PictureInPictureParams.Builder;
import android.app.RemoteAction;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Icon;
import android.os.Build;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.Rational;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.trtcplugin.vod.FTXPlayerConstants;
import com.tencent.trtcplugin.vod.tools.FTXVodUtils.TXCommonUtil;
import com.tencent.trtcplugin.vod.tools.FTXVodUtils.TXFlutterEngineHolder;
import com.tencent.trtcplugin.vod.VodMethodChannelHandler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Picture-in-picture management.
 *
 * <p>PIP events are dispatched to Dart via
 * {@link VodMethodChannelHandler#invokePipEvent(Map)} over the TencentVodPlayer channel.</p>
 *
 * <p>Note: Three small helper types ({@link TXPipResult}, {@link TXPlayerHolder},
 * {@link TXSimpleEventBus}) used to live in standalone files under {@code vod/pip/}. They were
 * inlined here as {@code public static} nested classes to reduce file count, since they only
 * serve the PIP sub-domain.</p>
 */
public class FTXPIPManager {

    private static final String TAG = "FTXPIPManager";

    private boolean misInit = false;
    private final Map<Integer, PipCallback> pipCallbacks = new HashMap<>();
    private final FlutterPlugin.FlutterPluginBinding mFlutterPluginBinding;
    private final FlutterPlugin.FlutterAssets mFlutterAssets;
    private final VodMethodChannelHandler mHandler;
    private boolean mIsInPipMode = false;

    /**
     * EventBus subscriber adapter. Implemented as an anonymous inner class to break the
     * "FTXPIPManager implements its own nested interface" cyclic-inheritance trap that the
     * compiler reports when both {@link TXSimpleEventBus} and FTXPIPManager would otherwise be
     * declared in the same enclosing class.
     */
    private final TXSimpleEventBus.EventSubscriber mBusSubscriber = new TXSimpleEventBus.EventSubscriber() {
        @Override
        public void onEvent(String eventType, Object data) {
            handleBusEvent(eventType, data);
        }
    };

    /**
     * Picture-in-picture management.
     *
     * @param flutterPluginBinding FlutterPluginBinding.
     * @param handler              VodMethodChannelHandler used to dispatch PIP events to Dart.
     */
    public FTXPIPManager(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding,
                         @NonNull VodMethodChannelHandler handler) {
        this.mFlutterAssets = flutterPluginBinding.getFlutterAssets();
        this.mFlutterPluginBinding = flutterPluginBinding;
        this.mHandler = handler;
        registerActivityListener();
    }

    /**
     * Register the `activityResult` callback. Must be called.
     */
    public void registerActivityListener() {
        if (!misInit) {
            TXSimpleEventBus.getInstance().register(FTXPlayerConstants.EVENT_PIP_ACTION, mBusSubscriber);
            TXSimpleEventBus.getInstance().register(FTXPlayerConstants.EVENT_PIP_PLAYER_EVENT_ACTION, mBusSubscriber);
            misInit = true;
        }
    }

    private void handlePlayerEvent(int playerId, int eventId, Bundle params) {
        PipCallback pipCallback = pipCallbacks.get(playerId);
        if (null != pipCallback) {
            pipCallback.onPipPlayerEvent(eventId, params);
        }
    }

    private void handlePipResult(TXPipResult result) {
        PipCallback pipCallback = pipCallbacks.get(result.getPlayerId());
        if (null != pipCallback) {
            pipCallback.onPipResult(result);
        }
    }

    /**
     * Enter picture-in-picture mode.
     *
     * @return {@link FTXPlayerConstants} ERROR_PIP
     */
    public int enterPip(PipParams params, TXPlayerHolder playerHolder) {
        int pipResult = isSupportDevice();
        if (pipResult == FTXPlayerConstants.NO_ERROR) {
            pipResult = FlutterPipImplActivity.startPip(TXFlutterEngineHolder.getInstance().getCurActivity(),
                    params, playerHolder);
            if (pipResult == FTXPlayerConstants.NO_ERROR) {
                mHandler.invokePipEvent(
                        TXCommonUtil.getParams(FTXPlayerConstants.EVENT_PIP_MODE_REQUEST_START, null));
            }
            mIsInPipMode = true;
        }
        return pipResult;
    }

    /**
     * Notify to exit the current picture-in-picture mode.
     */
    public void exitCurrentPip() {
        exitPipByPlayerId(-1);
    }

    /**
     * @param playerId -1 is close anyway
     */
    public void exitPipByPlayerId(int playerId) {
        if (isInPipMode()) {
            Bundle params = new Bundle();
            params.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, playerId);
            TXSimpleEventBus.getInstance().post(FTXPlayerConstants.PIP_ACTION_EXIT, params);
        }
    }

    /**
     * Whether the device supports picture-in-picture mode.
     */
    public int isSupportDevice() {
        int pipResult = FTXPlayerConstants.NO_ERROR;
        Activity activity = TXFlutterEngineHolder.getInstance().getCurActivity();
        if (null != activity) {
            if (!activity.isDestroyed()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    // check permission
                    boolean isSuccess =
                            activity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE);
                    if (!isSuccess) {
                        pipResult = FTXPlayerConstants.ERROR_PIP_FEATURE_NOT_SUPPORT;
                        LiteavLog.e(TAG, "enterPip failed,because PIP feature is disabled");
                    } else if (!hasPipPermission(activity)) {
                        pipResult = FTXPlayerConstants.ERROR_PIP_DENIED_PERMISSION;
                        LiteavLog.e(TAG, "enterPip failed,because PIP has no permission");
                    }
                } else {
                    pipResult = FTXPlayerConstants.ERROR_PIP_LOWER_VERSION;
                    LiteavLog.e(TAG, "enterPip failed,because android version is too low,"
                            + "Minimum supported version is android 24,but current is "
                            + Build.VERSION.SDK_INT);
                }
            } else {
                pipResult = FTXPlayerConstants.ERROR_PIP_ACTIVITY_DESTROYED;
                LiteavLog.e(TAG, "enterPip failed,because activity is destroyed");
            }
        } else {
            pipResult = FTXPlayerConstants.ERROR_PIP_ACTIVITY_DESTROYED;
            LiteavLog.e(TAG, "current activity is null, please check cur act status!");
        }
        return pipResult;
    }

    private boolean hasPipPermission(Activity activity) {
        AppOpsManager appOpsManager = (AppOpsManager) activity.getSystemService(Context.APP_OPS_SERVICE);
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            int permissionResult = appOpsManager.checkOpNoThrow(AppOpsManager.OPSTR_PICTURE_IN_PICTURE,
                    android.os.Process.myUid(), activity.getPackageName());
            return permissionResult == AppOpsManager.MODE_ALLOWED;
        } else {
            return true;
        }
    }

    public boolean isInPipMode() {
        return mIsInPipMode;
    }

    public void notifyCurrentPipPlayerPlayState(int playerId, boolean isPlaying) {
        Bundle playOrPauseData = new Bundle();
        playOrPauseData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, playerId);
        playOrPauseData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAY_OP, FTXPlayerConstants.EXTRA_PIP_PLAY_RESUME_OR_PAUSE);
        playOrPauseData.putInt(FTXPlayerConstants.EXTRA_NAME_IS_PLAYING, isPlaying ? 1 : 2);
        Intent playOrPauseIntent =
                new Intent(FTXPlayerConstants.ACTION_PIP_PLAY_CONTROL).putExtras(playOrPauseData);
        mFlutterPluginBinding.getApplicationContext().sendBroadcast(playOrPauseIntent);
    }

    /**
     * Set the PIP control callback. Repeated registration for the same player overwrites the previous one.
     */
    public void addCallback(Integer playerId, PipCallback callback) {
        if (!pipCallbacks.containsValue(callback)) {
            pipCallbacks.put(playerId, callback);
        }
    }

    /**
     * Unregister the broadcast receiver. Must be called when leaving the page to avoid memory leaks.
     */
    public void releaseCallback(int playerId) {
        pipCallbacks.remove(playerId);
    }

    public void releaseActivityListener() {
        try {
            if (misInit) {
                TXSimpleEventBus.getInstance().unregister(FTXPlayerConstants.EVENT_PIP_ACTION, mBusSubscriber);
                TXSimpleEventBus.getInstance().unregister(FTXPlayerConstants.EVENT_PIP_PLAYER_EVENT_ACTION, mBusSubscriber);
                misInit = false;
            }
        } catch (Exception e) {
            LiteavLog.e(TAG, "releaseActivityListener error", e);
        }
    }

    /**
     * Update the PIP floating window action buttons.
     */
    public void updatePipActions(PipParams params) {
        if (isInPipMode()) {
            Bundle bundle = new Bundle();
            bundle.putParcelable(FTXPlayerConstants.EXTRA_NAME_PARAMS, params);
            TXSimpleEventBus.getInstance().post(FTXPlayerConstants.PIP_ACTION_UPDATE, bundle);
        }
    }

    public String toAndroidPath(String path) {
        if (TextUtils.isEmpty(path)) {
            return path;
        }
        return mFlutterAssets.getAssetFilePathByName(path);
    }

    /**
     * Internal dispatch routine. Was {@code public void onEvent(...)} (an EventSubscriber method)
     * before the simplify pass; renamed to break the cyclic-inheritance trap mentioned above.
     */
    private void handleBusEvent(String eventType, Object data) {
        if (TextUtils.equals(eventType, FTXPlayerConstants.EVENT_PIP_ACTION)) {
            Bundle params = (Bundle) data;
            int pipEventId = params.getInt(FTXPlayerConstants.EVENT_PIP_MODE_NAME, -1);
            Bundle callbackData = new Bundle();
            if ((pipEventId == FTXPlayerConstants.EVENT_PIP_MODE_ALREADY_EXIT
                    || pipEventId == FTXPlayerConstants.EVENT_PIP_MODE_RESTORE_UI)) {
                TXPipResult pipResult = params.getParcelable(FTXPlayerConstants.EXTRA_NAME_RESULT);
                if (null != pipResult) {
                    callbackData.putFloat(FTXPlayerConstants.EVENT_PIP_PLAY_TIME, pipResult.getPlayTime());
                    handlePipResult(pipResult);
                }
                mIsInPipMode = false;
            }
            mHandler.invokePipEvent(TXCommonUtil.getParams(pipEventId, callbackData));
        } else if (TextUtils.equals(eventType, FTXPlayerConstants.EVENT_PIP_PLAYER_EVENT_ACTION)) {
            Bundle params = (Bundle) data;
            int playerId = params.getInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, -1);
            int eventId = params.getInt(FTXPlayerConstants.EXTRA_NAME_PIP_PLAYER_EVENT_ID, -1);
            Bundle playerEventParams = params.getBundle(FTXPlayerConstants.EXTRA_NAME_PIP_PLAYER_EVENT_PARAMS);
            handlePlayerEvent(playerId, eventId, playerEventParams);
        }
    }

    public static class PipParams implements Parcelable {

        private final String mPlayBackAssetPath;
        private final String mPlayResumeAssetPath;
        private final String mPlayPauseAssetPath;
        private final String mPlayForwardAssetPath;
        private final int mCurrentPlayerId;
        private final boolean mIsNeedPlayBack;
        private final boolean mIsNeedPlayForward;
        private final boolean mIsNeedPlayControl;
        private boolean mIsPlaying = false;
        private float mCurrentPlayTime = 0;
        private int mViewWith = 16;
        private int mViewHeight = 9;

        /**
         * PIP parameters.
         */
        public PipParams(String mPlayBackAssetPath, String mPlayResumeAssetPath, String mPlayPauseAssetPath,
                         String mPlayForwardAssetPath, int mCurrentPlayerId) {
            this(mPlayBackAssetPath, mPlayResumeAssetPath, mPlayPauseAssetPath, mPlayForwardAssetPath,
                    mCurrentPlayerId, !TXCommonUtil.isBlankStr(mPlayBackAssetPath),
                    !TXCommonUtil.isBlankStr(mPlayForwardAssetPath)
                    , !TXCommonUtil.isBlankStr(mPlayResumeAssetPath)
                            && !TXCommonUtil.isBlankStr(mPlayPauseAssetPath));
        }

        public PipParams(String mPlayBackAssetPath, String mPlayResumeAssetPath, String mPlayPauseAssetPath,
                String mPlayForwardAssetPath, int mCurrentPlayerId, boolean isNeedPlayBack,
                boolean isNeedPlayForward, boolean isNeedPlayControl) {
            this.mPlayBackAssetPath = mPlayBackAssetPath;
            this.mPlayResumeAssetPath = mPlayResumeAssetPath;
            this.mPlayPauseAssetPath = mPlayPauseAssetPath;
            this.mPlayForwardAssetPath = mPlayForwardAssetPath;
            this.mCurrentPlayerId = mCurrentPlayerId;
            this.mIsNeedPlayBack = isNeedPlayBack;
            this.mIsNeedPlayForward = isNeedPlayForward;
            this.mIsNeedPlayControl = isNeedPlayControl;
        }

        protected PipParams(Parcel in) {
            mPlayBackAssetPath = in.readString();
            mPlayResumeAssetPath = in.readString();
            mPlayPauseAssetPath = in.readString();
            mPlayForwardAssetPath = in.readString();
            mCurrentPlayerId = in.readInt();
            mIsNeedPlayBack = in.readByte() != 0;
            mIsNeedPlayForward = in.readByte() != 0;
            mIsNeedPlayControl = in.readByte() != 0;
            mIsPlaying = in.readByte() != 0;
            mCurrentPlayTime = in.readFloat();
            mViewWith = in.readInt();
            mViewHeight = in.readInt();
        }

        public static final Creator<PipParams> CREATOR = new Creator<PipParams>() {
            @Override
            public PipParams createFromParcel(Parcel in) {
                return new PipParams(in);
            }

            @Override
            public PipParams[] newArray(int size) {
                return new PipParams[size];
            }
        };

        public void setIsPlaying(boolean isPlay) {
            this.mIsPlaying = isPlay;
        }

        public boolean isPlaying() {
            return mIsPlaying;
        }

        public int getCurrentPlayerId() {
            return mCurrentPlayerId;
        }

        public float getCurrentPlayTime() {
            return mCurrentPlayTime;
        }

        public void setCurrentPlayTime(float mCurrentPlayTime) {
            this.mCurrentPlayTime = mCurrentPlayTime;
        }

        public void setRadio(int width, int height) {
            mViewWith = width;
            mViewHeight = height;
        }

        public int geiRadioWith() {
            return mViewWith;
        }

        public int getRadioHeight() {
            return mViewHeight;
        }

        private final AtomicInteger mActionIdGenerator = new AtomicInteger();

        /**
         * Build PIP parameters.
         */
        @RequiresApi(api = VERSION_CODES.O)
        public PictureInPictureParams buildParams(Activity activity) {
            List<RemoteAction> actions = new ArrayList<>();
            // play back
            if (mIsNeedPlayBack) {
                Bundle backData = new Bundle();
                backData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAY_OP, FTXPlayerConstants.EXTRA_PIP_PLAY_BACK);
                backData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, mCurrentPlayerId);
                Intent backIntent = new Intent(FTXPlayerConstants.ACTION_PIP_PLAY_CONTROL)
                        .putExtras(backData)
                        .setPackage(activity.getPackageName());
                PendingIntent preIntent = PendingIntent.getBroadcast(activity, FTXPlayerConstants.EXTRA_PIP_PLAY_BACK, backIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
                RemoteAction preAction = new RemoteAction(getBackIcon(activity), "skipPre", "skip pre", preIntent);
                actions.add(preAction);
            }

            // resume or pause
            if (mIsNeedPlayControl) {
                Bundle playOrPauseData = new Bundle();
                playOrPauseData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, mCurrentPlayerId);
                playOrPauseData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAY_OP, FTXPlayerConstants.EXTRA_PIP_PLAY_RESUME_OR_PAUSE);
                Intent playOrPauseIntent = new Intent(FTXPlayerConstants.ACTION_PIP_PLAY_CONTROL)
                        .putExtras(playOrPauseData)
                        .setPackage(activity.getPackageName());
                Icon playIcon = mIsPlaying ? getPauseIcon(activity) : getPlayIcon(activity);
                PendingIntent playIntent = PendingIntent.getBroadcast(activity, mActionIdGenerator.incrementAndGet(),
                        playOrPauseIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
                RemoteAction playOrPauseAction = new RemoteAction(playIcon, "playOrPause", "play Or Pause", playIntent);
                actions.add(playOrPauseAction);
            }

            // forward
            if (mIsNeedPlayForward) {
                Bundle forwardData = new Bundle();
                forwardData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAY_OP, FTXPlayerConstants.EXTRA_PIP_PLAY_FORWARD);
                forwardData.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, mCurrentPlayerId);
                Intent forwardIntent = new Intent(FTXPlayerConstants.ACTION_PIP_PLAY_CONTROL)
                        .putExtras(forwardData)
                        .setPackage(activity.getPackageName());
                PendingIntent nextIntent = PendingIntent.getBroadcast(activity, FTXPlayerConstants.EXTRA_PIP_PLAY_FORWARD,
                        forwardIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_MUTABLE);
                RemoteAction nextAction = new RemoteAction(getForwardIcon(activity), "skipNext", "skip next",
                        nextIntent);
                actions.add(nextAction);
            }

            Builder mPipParams = new Builder();
            mPipParams.setActions(actions);
            mPipParams.setAspectRatio(new Rational(mViewWith, mViewHeight));
            if (Build.VERSION.SDK_INT >= VERSION_CODES.S) {
                mPipParams.setAutoEnterEnabled(false);
                mPipParams.setSeamlessResizeEnabled(false);
            }
            return mPipParams.build();
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        private Icon getBackIcon(Activity activity) {
            return getIcon(activity, mPlayBackAssetPath, android.R.drawable.ic_media_previous);
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        private Icon getPlayIcon(Activity activity) {
            return getIcon(activity, mPlayResumeAssetPath, android.R.drawable.ic_media_play);
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        private Icon getPauseIcon(Activity activity) {
            return getIcon(activity, mPlayPauseAssetPath, android.R.drawable.ic_media_pause);
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        private Icon getForwardIcon(Activity activity) {
            return getIcon(activity, mPlayForwardAssetPath, android.R.drawable.ic_media_next);
        }

        @RequiresApi(api = Build.VERSION_CODES.M)
        private Icon getIcon(Activity activity, String path, int defaultResId) {
            try {
                if (!TextUtils.isEmpty(path)) {
                    Bitmap iconBitmap = BitmapFactory.decodeStream(activity.getAssets().open(path));
                    return Icon.createWithBitmap(iconBitmap);
                }
            } catch (IOException e) {
                LiteavLog.e(TAG, "getIcon error", e);
            }
            return Icon.createWithResource(activity, defaultResId);
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(@NonNull Parcel dest, int flags) {
            dest.writeString(mPlayBackAssetPath);
            dest.writeString(mPlayResumeAssetPath);
            dest.writeString(mPlayPauseAssetPath);
            dest.writeString(mPlayForwardAssetPath);
            dest.writeInt(mCurrentPlayerId);
            dest.writeByte((byte) (mIsNeedPlayBack ? 1 : 0));
            dest.writeByte((byte) (mIsNeedPlayForward ? 1 : 0));
            dest.writeByte((byte) (mIsNeedPlayControl ? 1 : 0));
            dest.writeByte((byte) (mIsPlaying ? 1 : 0));
            dest.writeFloat(mCurrentPlayTime);
            dest.writeInt(mViewWith);
            dest.writeInt(mViewHeight);
        }

    }

    /**
     * PIP control callback.
     */
    public interface PipCallback {

        /** Close PIP. */
        void onPipResult(TXPipResult result);

        void onPipPlayerEvent(int event, Bundle bundle);
    }

    // =========================================================================================
    // Nested types — formerly standalone files in vod/pip/ before the simplify pass.
    // =========================================================================================

    /**
     * Picture-in-picture exit result. Was a standalone {@code TXPipResult.java} before being
     * inlined here as a {@code public static} nested class.
     */
    public static class TXPipResult implements Parcelable {
        private Float mPlayTime;
        private boolean mIsPlaying;
        private int mPlayerId;

        public TXPipResult() {
        }

        protected TXPipResult(Parcel in) {
            if (in.readByte() == 0) {
                mPlayTime = null;
            } else {
                mPlayTime = in.readFloat();
            }
            mIsPlaying = in.readByte() != 0;
            mPlayerId = in.readInt();
        }

        public static final Creator<TXPipResult> CREATOR = new Creator<TXPipResult>() {
            @Override
            public TXPipResult createFromParcel(Parcel in) {
                return new TXPipResult(in);
            }

            @Override
            public TXPipResult[] newArray(int size) {
                return new TXPipResult[size];
            }
        };

        public Float getPlayTime() {
            if (null == mPlayTime) {
                return 0F;
            }
            return mPlayTime;
        }

        public void setPlayTime(Float mPlayTime) {
            this.mPlayTime = mPlayTime;
        }

        public boolean isPlaying() {
            return mIsPlaying;
        }

        public void setPlaying(boolean playing) {
            mIsPlaying = playing;
        }

        public int getPlayerId() {
            return mPlayerId;
        }

        public void setPlayerId(int mPlayerId) {
            this.mPlayerId = mPlayerId;
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            if (mPlayTime == null) {
                dest.writeByte((byte) 0);
            } else {
                dest.writeByte((byte) 1);
                dest.writeFloat(mPlayTime);
            }
            dest.writeByte((byte) (mIsPlaying ? 1 : 0));
            dest.writeInt(mPlayerId);
        }
    }

    /**
     * Holder of the {@link TXVodPlayer} that is being used inside the PIP window. Was a standalone
     * {@code TXPlayerHolder.java} before being inlined here as a {@code public static} nested
     * class.
     */
    public static class TXPlayerHolder {

        private TXVodPlayer mVodPlayer;
        private final int mPlayerType;
        private boolean mPlayingStatus;
        private boolean mIsPlayingWhenCreated = false;

        public TXPlayerHolder(TXVodPlayer vodPlayer) {
            mVodPlayer = vodPlayer;
            mPlayingStatus = vodPlayer.isPlaying();
            mIsPlayingWhenCreated = mPlayingStatus;
            mPlayerType = FTXPlayerConstants.PLAYER_VOD;
        }

        public TXVodPlayer getVodPlayer() {
            return mVodPlayer;
        }

        public boolean isPlayingWhenCreate() {
            return mIsPlayingWhenCreated;
        }

        public boolean isPlaying() {
            return mPlayingStatus;
        }

        public void pause() {
            if (null != mVodPlayer) {
                mVodPlayer.pause();
                mPlayingStatus = false;
            }
        }

        public void resume() {
            if (null != mVodPlayer) {
                mVodPlayer.resume();
                mPlayingStatus = true;
            }
        }

        public int getPlayerType() {
            return mPlayerType;
        }
    }

    /**
     * Lightweight intra-process event bus used by PIP only. Was a standalone
     * {@code TXSimpleEventBus.java} before being inlined here as a {@code public static} nested
     * class.
     */
    public static class TXSimpleEventBus {

        private static TXSimpleEventBus instance;
        private final Map<String, List<EventSubscriber>> subscribers = new HashMap<>();

        private TXSimpleEventBus() {
        }

        public static TXSimpleEventBus getInstance() {
            if (instance == null) {
                instance = new TXSimpleEventBus();
            }
            return instance;
        }

        public void register(String eventType, EventSubscriber subscriber) {
            List<EventSubscriber> subscriberList = subscribers.get(eventType);
            if (subscriberList == null) {
                subscriberList = new ArrayList<>();
                subscribers.put(eventType, subscriberList);
            }
            subscriberList.add(subscriber);
        }

        public void unregister(String eventType, EventSubscriber subscriber) {
            List<EventSubscriber> subscriberList = subscribers.get(eventType);
            if (subscriberList != null) {
                subscriberList.remove(subscriber);
            }
        }

        public void unregisterAllType(EventSubscriber subscriber) {
            java.util.Set<String> keySets = subscribers.keySet();
            for (String key : keySets) {
                List<EventSubscriber> subscriberList = subscribers.get(key);
                if (subscriberList != null) {
                    subscriberList.remove(subscriber);
                }
            }
        }

        public void post(String eventType, Object data) {
            List<EventSubscriber> subscriberList = subscribers.get(eventType);
            if (subscriberList != null) {
                for (EventSubscriber subscriber : subscriberList) {
                    subscriber.onEvent(eventType, data);
                }
            }
        }

        public interface EventSubscriber {
            void onEvent(String eventType, Object data);
        }
    }
}
