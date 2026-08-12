// Copyright (c) 2022 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod.pip;

import android.app.Activity;
import android.app.PictureInPictureParams;
import android.app.PictureInPictureUiState;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;

import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.rtmp.ITXVodPlayListener;
import com.tencent.rtmp.TXLiveConstants;
import com.tencent.rtmp.TXVodPlayer;
import com.tencent.rtmp.ui.TXCloudVideoView;
import com.tencent.trtcplugin.vod.FTXPlayerConstants;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager.PipParams;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager.TXPipResult;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager.TXPlayerHolder;
import com.tencent.trtcplugin.vod.pip.FTXPIPManager.TXSimpleEventBus;
import com.tencent.trtcplugin.vod.tools.FTXVodUtils.FTXContextWrapper;
import com.tencent.trtcplugin.vod.tools.FTXVodUtils.TXFlutterEngineHolder;

/**
 * Vod Picture-in-Picture Activity (v3).
 *
 * <p>Design notes:
 * <ul>
 *   <li>Extends {@link android.app.Activity} directly without androidx.appcompat, keeping the v3 plugin lightweight.</li>
 *   <li>The view hierarchy is built entirely in Java, no res/layout resource is required.</li>
 *   <li>Only Vod scenarios are supported; Live-related code has been removed together with the v3 migration.</li>
 * </ul>
 */
public class FlutterPipImplActivity extends Activity implements ITXVodPlayListener,
        ServiceConnection, TXSimpleEventBus.EventSubscriber {

    private static final String TAG = "FlutterPipImplActivity";
    private static TXPlayerHolder pipPlayerHolder;
    private static boolean isInPip = false;

    /**
     * Compatibility flag for MIUI 12.5.1: set to true when the state reported by
     * onPictureInPictureModeChanged disagrees with isInPictureInPictureMode(); the exit event is
     * then dispatched later in onConfigurationChanged once a size change is detected.
     */
    private boolean needToExitPip = false;
    private int configWidth = 0;
    private int configHeight = 0;

    private TXCloudVideoView mVideoRenderView;
    private ProgressBar mVideoProgress;
    private RelativeLayout mPipContainer;

    // In PiP mode, tapping the top-right close button triggers onStop first; the zoom button does not.
    private boolean mIsNeedToStop = false;
    private boolean mIsRegisterReceiver = false;
    private PipParams mCurrentParams;
    private Handler mMainHandler;
    private boolean mIsPipFinishing = false;
    private TXPlayerHolder mPlayerHolder;
    private boolean mIsPlayEnd = false;

    private final BroadcastReceiver pipActionReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Bundle data = intent.getExtras();
            if (null != data && null != mCurrentParams) {
                int playerId = data.getInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, -1);
                if (playerId == mCurrentParams.getCurrentPlayerId()) {
                    int controlCode = data.getInt(FTXPlayerConstants.EXTRA_NAME_PLAY_OP, -1);
                    switch (controlCode) {
                        case FTXPlayerConstants.EXTRA_PIP_PLAY_BACK:
                            handlePlayBack();
                            break;
                        case FTXPlayerConstants.EXTRA_PIP_PLAY_RESUME_OR_PAUSE:
                            int isPlaying = data.getInt(FTXPlayerConstants.EXTRA_NAME_IS_PLAYING, 0);
                            if (isPlaying != 0) {
                                handleResumeOrPause(isPlaying == 1);
                            } else {
                                handleResumeOrPause();
                            }
                            break;
                        case FTXPlayerConstants.EXTRA_PIP_PLAY_FORWARD:
                            handlePlayForward();
                            break;
                        default:
                            LiteavLog.e(TAG, "unknown control code");
                            break;
                    }
                }
            }
        }
    };

    public static int startPip(Activity activity, PipParams params, TXPlayerHolder playerHolder) {
        if (null == playerHolder) {
            LiteavLog.e(TAG, "startPip failed, playerHolder is null");
            return FTXPlayerConstants.ERROR_PIP_MISS_PLAYER;
        }
        if (null == playerHolder.getVodPlayer()) {
            LiteavLog.e(TAG, "startPip failed, vodPlayer is null");
            return FTXPlayerConstants.ERROR_PIP_MISS_PLAYER;
        }
        if (isInPip) {
            LiteavLog.e(TAG, "startPip failed, pip is busy");
            return FTXPlayerConstants.ERROR_PIP_IN_BUSY;
        }
        isInPip = true;
        // pause first, resume video after entered pip
        playerHolder.pause();
        pipPlayerHolder = playerHolder;
        Intent intent = new Intent(activity, FlutterPipImplActivity.class);
        Bundle bundle = new Bundle();
        bundle.putParcelable(FTXPlayerConstants.EXTRA_NAME_PARAMS, params);
        intent.setAction(FTXPlayerConstants.PIP_ACTION_START);
        intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
        intent.putExtra("data", bundle);
        activity.startActivity(intent);
        return FTXPlayerConstants.NO_ERROR;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mMainHandler = new Handler(getMainLooper());
        bindAndroid12BugServiceIfNeed();
        registerPipBroadcast();
        // Programmatic layout: a RelativeLayout containing TXCloudVideoView and ProgressBar.
        setContentView(buildPipContentView());
        if (null == pipPlayerHolder) {
            LiteavLog.e(TAG, "lack pipPlayerHolder, please check the pip argument");
            destroyPipAct();
            return;
        }
        mPlayerHolder = pipPlayerHolder;
        if (null != mPlayerHolder.getVodPlayer()) {
            setVodPlayerListener();
        } else {
            LiteavLog.e(TAG, "lack pipPlayerHolder player, please check the pip argument");
            destroyPipAct();
            return;
        }
        TXSimpleEventBus.getInstance().register(FTXPlayerConstants.PIP_ACTION_EXIT, this);
        TXSimpleEventBus.getInstance().register(FTXPlayerConstants.PIP_ACTION_UPDATE, this);
        Intent intent = getIntent();
        Bundle data = intent.getBundleExtra("data");
        if (null != data) {
            PipParams params = data.getParcelable(FTXPlayerConstants.EXTRA_NAME_PARAMS);
            if (null == params) {
                LiteavLog.e(TAG, "lack pip params,please check the argument");
                destroyPipAct();
            } else {
                mCurrentParams = params;
                if (VERSION.SDK_INT >= VERSION_CODES.O) {
                    configPipMode(params.buildParams(this));
                } else {
                    configPipMode(null);
                }
            }
        }
    }

    /**
     * Build the PiP Activity content view in pure Java, replacing the original
     * R.layout.activity_flutter_pip_impl resource.
     * Hierarchy:
     *   RelativeLayout (root mPipContainer, match parent)
     *     - TXCloudVideoView (mVideoRenderView, fills the container)
     *     - ProgressBar      (mVideoProgress, horizontal, aligned to bottom)
     */
    private View buildPipContentView() {
        mPipContainer = new RelativeLayout(this);
        mPipContainer.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT));

        mVideoRenderView = new TXCloudVideoView(this);
        RelativeLayout.LayoutParams videoLp = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        mVideoRenderView.setLayoutParams(videoLp);
        mPipContainer.addView(mVideoRenderView);

        // Use the thin Holo style so the default Material height does not cover the video.
        mVideoProgress = new ProgressBar(this, null, 0,
                android.R.style.Widget_Holo_ProgressBar_Horizontal);
        // Fixed 3dp height, matching the XML layout of the original super_player project.
        int progressHeightPx = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, 3f, getResources().getDisplayMetrics());
        RelativeLayout.LayoutParams progressLp = new RelativeLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                progressHeightPx);
        progressLp.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
        mVideoProgress.setLayoutParams(progressLp);
        mVideoProgress.setMax(100);
        mPipContainer.addView(mVideoProgress);

        // Hidden initially; shown after entering PiP to avoid a black flash.
        mVideoRenderView.setVisibility(View.GONE);
        mVideoProgress.setVisibility(View.GONE);
        return mPipContainer;
    }

    private void setVodPlayerListener() {
        mPlayerHolder.getVodPlayer().setVodListener(this);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            boolean isInPictureInPictureMode = isInPictureInPictureMode();
            if (isInPictureInPictureMode) {
                configWidth = newConfig.screenWidthDp;
                configHeight = newConfig.screenHeightDp;
            } else if (needToExitPip && configWidth != newConfig.screenWidthDp
                    && configHeight != newConfig.screenHeightDp) {
                handlePipExitEvent();
                needToExitPip = false;
            }
        }
    }

    /**
     * Compatibility workaround for MIUI 12.5: in PiP mode, after opening another app, swiping up to
     * exit and then tapping the PiP window, onPictureInPictureModeChanged may be mistakenly invoked
     * with a closed state.
     */
    @Override
    public void onPictureInPictureModeChanged(boolean ignore) {
        boolean isInPictureInPictureMode = ignore;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            isInPictureInPictureMode = isInPictureInPictureMode();
        }
        if (isInPictureInPictureMode != ignore) {
            needToExitPip = true;
        } else {
            if (isInPictureInPictureMode) {
                sendPipEvent(FTXPlayerConstants.EVENT_PIP_MODE_ALREADY_ENTER, null);
                setUpPipVideo();
            } else {
                handlePipExitEvent();
            }
        }
        super.onPictureInPictureModeChanged(isInPictureInPictureMode);
    }

    @Override
    public void onPictureInPictureModeChanged(boolean isInPictureInPictureMode, Configuration newConfig) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig);
    }

    @Override
    public void onPictureInPictureUiStateChanged(PictureInPictureUiState pipState) {
        super.onPictureInPictureUiStateChanged(pipState);
        sendPipEvent(FTXPlayerConstants.EVENT_PIP_MODE_UI_STATE_CHANGED, null);
    }

    /**
     * Callback after enterPictureInPictureMode takes effect (Android 31+ only).
     */
    @Override
    public boolean onPictureInPictureRequested() {
        return super.onPictureInPictureRequested();
    }

    @Override
    public boolean enterPictureInPictureMode(PictureInPictureParams params) {
        return super.enterPictureInPictureMode(params);
    }

    private void configPipMode(final PictureInPictureParams params) {
        mVideoRenderView.post(new Runnable() {
            @Override
            public void run() {
                if (VERSION.SDK_INT >= VERSION_CODES.N) {
                    if (VERSION.SDK_INT >= VERSION_CODES.O) {
                        enterPictureInPictureMode(params);
                    } else {
                        enterPictureInPictureMode();
                    }
                }
            }
        });
    }

    private void registerPipBroadcast() {
        if (!mIsRegisterReceiver) {
            IntentFilter pipIntentFilter = new IntentFilter(FTXPlayerConstants.ACTION_PIP_PLAY_CONTROL);
            FTXContextWrapper.registerReceiverForNotExport(this, pipActionReceiver, pipIntentFilter);
            mIsRegisterReceiver = true;
        }
    }

    private void unRegisterPipBroadcast() {
        if (mIsRegisterReceiver) {
            unregisterReceiver(pipActionReceiver);
        }
    }

    private void handlePipExitEvent() {
        Bundle data = new Bundle();
        TXPipResult pipResult = new TXPipResult();
        pipResult.setPlaying(mPlayerHolder.isPlaying());
        if (mPlayerHolder.getPlayerType() == FTXPlayerConstants.PLAYER_VOD) {
            if (mIsPlayEnd) {
                pipResult.setPlayTime(0F);
            } else {
                Float currentPlayTime = mPlayerHolder.getVodPlayer().getCurrentPlaybackTime();
                pipResult.setPlayTime(currentPlayTime);
            }
            pipResult.setPlayerId(mCurrentParams.getCurrentPlayerId());
            data.putParcelable(FTXPlayerConstants.EXTRA_NAME_RESULT, pipResult);
        }
        if (null != mPlayerHolder.getVodPlayer()) {
            mPlayerHolder.getVodPlayer().setSurface(null);
            mPlayerHolder.getVodPlayer().setPlayerView((TXCloudVideoView) null);
            mPlayerHolder.getVodPlayer().setVodListener(null);
        }
        mPlayerHolder.pause();
        int codeEvent = mIsNeedToStop ? FTXPlayerConstants.EVENT_PIP_MODE_ALREADY_EXIT : FTXPlayerConstants.EVENT_PIP_MODE_RESTORE_UI;
        exitPip(codeEvent == FTXPlayerConstants.EVENT_PIP_MODE_ALREADY_EXIT, codeEvent, data);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIntent(intent);
    }

    private void handleIntent(Intent intent) {
        if (intent != null) {
            String action = intent.getAction();
            handleAction(action, intent.getExtras());
        }
    }

    private void handleAction(String action, Bundle params) {
        if (TextUtils.equals(action, FTXPlayerConstants.PIP_ACTION_START)) {
            startPipVideo();
        } else if (TextUtils.equals(action, FTXPlayerConstants.PIP_ACTION_EXIT)) {
            int playerId = -1;
            if (null != params) {
                playerId = params.getInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, -1);
            }
            if (playerId == -1 || playerId == mCurrentParams.getCurrentPlayerId()) {
                mIsNeedToStop = true;
                handlePipExitEvent();
            } else {
                LiteavLog.w(TAG, "close pip failed, playerId not found:" + playerId);
            }
        } else if (TextUtils.equals(action, FTXPlayerConstants.PIP_ACTION_UPDATE)) {
            if (null != params) {
                PipParams pipParams = params.getParcelable(FTXPlayerConstants.EXTRA_NAME_PARAMS);
                updatePip(pipParams);
            }
        } else if (TextUtils.equals(action, FTXPlayerConstants.PIP_ACTION_DO_EXIT)) {
            destroyPipAct();
        } else {
            LiteavLog.e(TAG, "unknown pip action:" + action);
        }
    }

    private void destroyPipAct() {
        overridePendingTransition(0, 0);
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            FlutterPipImplActivity.this.finishAndRemoveTask();
        } else {
            FlutterPipImplActivity.this.finish();
        }
        mIsPipFinishing = false;
        pipPlayerHolder = null;
        isInPip = false;
    }

    private void updatePip(PipParams pipParams) {
        if (null != pipParams && !isDestroyed() && !isFinishing()) {
            mCurrentParams = pipParams;
            if (VERSION.SDK_INT >= VERSION_CODES.O) {
                setPictureInPictureParams(pipParams.buildParams(this));
            }
        }
    }

    /**
     * Reorder the previous Activity to the front of the task stack, preventing the PiP window from
     * failing to bring the host app forward on some devices.
     */
    public void movePreActToFront() {
        Activity activity = TXFlutterEngineHolder.getInstance().getPreActivity();
        if (null != activity) {
            Intent intent = new Intent(FlutterPipImplActivity.this, activity.getClass());
            intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(intent);
        }
    }

    /**
     * Reorder the current PiP Activity to the front, as a compatibility workaround for devices
     * where tapping the PiP window fails to bring the app forward.
     */
    public void moveCurActToFront() {
        mPipContainer.post(new Runnable() {
            @Override
            public void run() {
                Activity activity = FlutterPipImplActivity.this;
                Intent intent = new Intent(FlutterPipImplActivity.this, activity.getClass());
                intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT);
                intent.setAction(FTXPlayerConstants.PIP_ACTION_DO_EXIT);
                startActivity(intent);
            }
        });
    }

    /**
     * Close PiP by finishing the current Activity.
     *
     * @param closeImmediately true to close immediately (user dismisses PiP);
     *                         false to close with a delay (restore PiP to the original UI).
     */
    private void exitPip(boolean closeImmediately, final int codeEvent, final Bundle data) {
        if (mIsPipFinishing) {
            return;
        }
        mIsPipFinishing = true;
        if (!isDestroyed() || !isFinishing()) {
            // Android 12 foreground-service restriction: finishing too early after exiting PiP may
            // prevent the host app from launching, so a delayed finish is used.
            if (!closeImmediately) {
                mVideoRenderView.setVisibility(View.GONE);
                mVideoProgress.setVisibility(View.GONE);
                mMainHandler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        // Re-launch this Activity to bring the original AppTask back to the front.
                        moveCurActToFront();
                        sendPipEvent(codeEvent, data);
                    }
                }, 500);
            } else {
                destroyPipAct();
                sendPipEvent(codeEvent, data);
            }
        }
    }

    private void startPipVideo() {
        startPlay();
    }

    private void startPlay() {
        if (null != mPlayerHolder) {
            boolean isInitPlaying = mPlayerHolder.isPlayingWhenCreate();
            if (isInitPlaying) {
                mPlayerHolder.resume();
            }
        } else {
            LiteavLog.e(TAG, "miss player when startPlay");
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        mIsNeedToStop = true;
    }

    @Override
    protected void onResume() {
        super.onResume();
        mIsNeedToStop = false;
    }

    @Override
    protected void onDestroy() {
        unRegisterPipBroadcast();
        if (Build.VERSION.SDK_INT >= VERSION_CODES.Q) {
            unbindService(this);
            Intent serviceIntent = new Intent(getApplicationContext(), TXAndroid12BridgeService.class);
            stopService(serviceIntent);
        }
        TXSimpleEventBus.getInstance().unregisterAllType(this);
        mPlayerHolder = null;
        pipPlayerHolder = null;
        isInPip = false;
        attachRenderView(null);
        super.onDestroy();
    }

    private void bindAndroid12BugServiceIfNeed() {
        if (Build.VERSION.SDK_INT >= VERSION_CODES.Q) {
            Intent serviceIntent = new Intent(getApplicationContext(), TXAndroid12BridgeService.class);
            startService(serviceIntent);
            bindService(serviceIntent, this, Context.BIND_AUTO_CREATE);
        }
    }

    private void attachRenderView(TXCloudVideoView videoView) {
        if (null != mPlayerHolder) {
            if (mPlayerHolder.getPlayerType() == FTXPlayerConstants.PLAYER_VOD) {
                mPlayerHolder.getVodPlayer().setPlayerView(videoView);
            } else {
                LiteavLog.e(TAG, "unknown player type:" + mPlayerHolder.getPlayerType());
            }
        } else {
            LiteavLog.e(TAG, "pip video model is null");
        }
    }

    private void handlePlayBack() {
        if (mPlayerHolder.getPlayerType() == FTXPlayerConstants.PLAYER_VOD) {
            TXVodPlayer vodPlayer = mPlayerHolder.getVodPlayer();
            if (vodPlayer.isPlaying()) {
                float backPlayTime = vodPlayer.getCurrentPlaybackTime() - 10;
                if (backPlayTime < 0) {
                    backPlayTime = 0;
                }
                vodPlayer.seek(backPlayTime);
            }
        }
    }

    private void handleResumeOrPause() {
        boolean dstPlaying = !mPlayerHolder.isPlaying();
        if (dstPlaying) {
            mPlayerHolder.resume();
        } else {
            mPlayerHolder.pause();
        }
        handleResumeOrPause(dstPlaying);
    }

    private void handleResumeOrPause(boolean playingStatus) {
        mCurrentParams.setIsPlaying(playingStatus);
        updatePip(mCurrentParams);
    }

    private void handlePlayForward() {
        if (mPlayerHolder.getPlayerType() == FTXPlayerConstants.PLAYER_VOD) {
            TXVodPlayer vodPlayer = mPlayerHolder.getVodPlayer();
            if (vodPlayer.isPlaying()) {
                float forwardPlayTime = vodPlayer.getCurrentPlaybackTime() + 10;
                float duration = vodPlayer.getDuration();
                if (forwardPlayTime > duration) {
                    forwardPlayTime = duration;
                }
                vodPlayer.seek(forwardPlayTime);
            }
        }
    }

    private void sendPipEvent(int eventCode, Bundle data) {
        if (null == data) {
            data = new Bundle();
        }
        data.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, mCurrentParams.getCurrentPlayerId());
        data.putInt(FTXPlayerConstants.EVENT_PIP_MODE_NAME, eventCode);
        TXSimpleEventBus.getInstance().post(FTXPlayerConstants.EVENT_PIP_ACTION, data);
    }

    /**
     * Show the video and progress bar. Views are hidden initially to avoid a black flash at PiP
     * start-up and are only revealed after entering PiP mode.
     */
    private void setUpPipVideo() {
        mVideoRenderView.setVisibility(View.VISIBLE);
        mVideoProgress.setVisibility(View.VISIBLE);
        mPipContainer.setBackgroundColor(Color.parseColor("#33000000"));
        attachRenderView(mVideoRenderView);
        startPipVideo();
    }

    private void controlPipPlayStatus(boolean isPlaying) {
        if (null != mCurrentParams) {
            mCurrentParams.setIsPlaying(isPlaying);
            updatePip(mCurrentParams);
        }
    }

    @Override
    public void onPlayEvent(TXVodPlayer txVodPlayer, int event, Bundle bundle) {
        if (VERSION.SDK_INT >= VERSION_CODES.N && isInPictureInPictureMode()) {
            if (null != mCurrentParams) {
                if (event == TXLiveConstants.PLAY_EVT_PLAY_END) {
                    mCurrentParams.setIsPlaying(false);
                    updatePip(mCurrentParams);
                } else if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
                    mCurrentParams.setIsPlaying(true);
                    updatePip(mCurrentParams);
                }
            }
            if (event == TXLiveConstants.PLAY_EVT_PLAY_END) {
                mIsPlayEnd = true;
                controlPipPlayStatus(false);
            } else if (event == TXLiveConstants.PLAY_EVT_PLAY_BEGIN) {
                mIsPlayEnd = false;
                controlPipPlayStatus(true);
            } else if (event == TXLiveConstants.PLAY_EVT_PLAY_PROGRESS) {
                int progress = bundle.getInt(TXLiveConstants.EVT_PLAY_PROGRESS_MS);
                int duration = bundle.getInt(TXLiveConstants.EVT_PLAY_DURATION_MS);
                float percentage = (progress / 1000F) / (duration / 1000F);
                final int progressToShow = Math.round(percentage * mVideoProgress.getMax());
                if (null != mVideoProgress) {
                    mVideoProgress.post(new Runnable() {
                        @Override
                        public void run() {
                            mVideoProgress.setProgress(progressToShow);
                        }
                    });
                }
            }
        }
        sendPlayerEvent(event, bundle);
    }

    private void sendPlayerEvent(int eventCode, Bundle data) {
        if (null != mCurrentParams) {
            Bundle params = new Bundle();
            params.putInt(FTXPlayerConstants.EXTRA_NAME_PLAYER_ID, mCurrentParams.getCurrentPlayerId());
            params.putInt(FTXPlayerConstants.EXTRA_NAME_PIP_PLAYER_EVENT_ID, eventCode);
            params.putBundle(FTXPlayerConstants.EXTRA_NAME_PIP_PLAYER_EVENT_PARAMS, data);
            TXSimpleEventBus.getInstance().post(FTXPlayerConstants.EVENT_PIP_PLAYER_EVENT_ACTION, params);
        }
    }

    @Override
    public void onNetStatus(TXVodPlayer txVodPlayer, Bundle bundle) {
    }

    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
    }

    @Override
    public void onServiceDisconnected(ComponentName name) {
    }

    @Override
    public void onEvent(String eventType, Object data) {
        if (TextUtils.equals(FTXPlayerConstants.PIP_ACTION_EXIT, eventType)
                || TextUtils.equals(FTXPlayerConstants.PIP_ACTION_UPDATE, eventType)) {
            handleAction(eventType, (Bundle) data);
        }
    }
}
