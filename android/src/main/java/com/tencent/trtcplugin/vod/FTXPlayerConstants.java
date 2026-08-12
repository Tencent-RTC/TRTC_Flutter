// Copyright (c) 2022 Tencent. All rights reserved.

package com.tencent.trtcplugin.vod;

import com.tencent.rtmp.TXLiveConstants;

/**
 * Common event codes and player constants.
 *
 * <p>Originally split into {@code FTXEvent} (event ids/keys) and {@code common/FTXPlayerConstants}
 * (render-mode / drm enums). They are merged here under one class to reduce file/dir sprawl during
 * the simplify pass; the file now sits at the {@code vod/} root.
 */
public class FTXPlayerConstants {

    public interface ViewType {
        int TEXTURE_TYPE = 0;
        int SURFACE_TYPE = 1;
        int DRM_SURFACE_TYPE = 2;
    }

    public static final String FTX_RENDER_VIEW = "FTXRenderViewType";
    public static final String RENDER_TYPE_KEY = "renderViewType";

    /** Volume change. */
    public static final int EVENT_VOLUME_CHANGED = 1;
    /** Lost audio output playback focus. */
    public static final int EVENT_AUDIO_FOCUS_PAUSE = 2;
    /** Obtained audio output focus. */
    public static final int EVENT_AUDIO_FOCUS_PLAY = 3;
    /** Brightness change. */
    public static final int EVENT_BRIGHTNESS_CHANGED = 4;

    // Video pre-download completed.
    public static final int EVENT_PREDOWNLOAD_ON_COMPLETE = 200;

    // Video pre-download error.
    public static final int EVENT_PREDOWNLOAD_ON_ERROR = 201;

    // fileId preload is start, callback url, taskId and other video info
    public static final int EVENT_PREDOWNLOAD_ON_START = 202;

    // Video download started.
    public static final int EVENT_DOWNLOAD_START = 301;
    // Video download progress.
    public static final int EVENT_DOWNLOAD_PROGRESS = 302;
    // Video download stopped.
    public static final int EVENT_DOWNLOAD_STOP = 303;
    // Video download completed.
    public static final int EVENT_DOWNLOAD_FINISH = 304;
    // Video download error.
    public static final int EVENT_DOWNLOAD_ERROR = 305;

    public static final int NO_ERROR = 0;
    /** PIP event. */
    public static final String PIP_CHANNEL_NAME = "cloud.tencent.com/playerPlugin/componentEvent";
    // PIP broadcast action.
    public static final String ACTION_PIP_PLAY_CONTROL = "vodPlayControl";
    // PIP operation.
    public static final String EXTRA_NAME_PLAY_OP = "vodPlayOp";
    // Player to be operated on PIP
    public static final String EXTRA_NAME_PLAYER_ID = "vodPlayerId";
    // pip player event id
    public static final String EXTRA_NAME_PIP_PLAYER_EVENT_ID = "pipPlayerEventId";
    // pip player event params
    public static final String EXTRA_NAME_PIP_PLAYER_EVENT_PARAMS = "pipPlayerEventParams";
    // Progress rewind.
    public static final int EXTRA_PIP_PLAY_BACK = 101;
    // Resume/pause.
    public static final int EXTRA_PIP_PLAY_RESUME_OR_PAUSE = 102;
    // Progress forward.
    public static final int EXTRA_PIP_PLAY_FORWARD = 103;
    // PIP error, Android version is too low.
    public static final int ERROR_PIP_LOWER_VERSION = -101;
    // PIP error, picture-in-picture permission is turned off.
    public static final int ERROR_PIP_DENIED_PERMISSION = -102;
    // PIP error, current interface has been destroyed.
    public static final int ERROR_PIP_ACTIVITY_DESTROYED = -103;
    // PIP error, miss player
    public static final int ERROR_PIP_MISS_PLAYER = -109;
    // PIP error, pip is busy
    public static final int ERROR_PIP_IN_BUSY = -110;
    // PIP error, device does not support picture-in-picture.
    public static final int ERROR_PIP_FEATURE_NOT_SUPPORT = -104;
    // Event from PIP container, eventBus key value.
    public static final String EVENT_PIP_ACTION = "com.tencent.flutter.pipevent";
    // Player event from PIP players, eventBus key value.
    public static final String EVENT_PIP_PLAYER_EVENT_ACTION = "com.tencent.flutter.pipplayerevent";
    // Event name key inside the PIP event bundle.
    public static final String EVENT_PIP_MODE_NAME = "pipEventName";
    // Current PIP playback time.
    public static final String EVENT_PIP_PLAY_TIME = "playTime";
    // Event from PIP container, entered PIP.
    public static final int EVENT_PIP_MODE_ALREADY_ENTER = 1;
    // Event from PIP container, exited PIP.
    public static final int EVENT_PIP_MODE_ALREADY_EXIT = 2;
    // Event from PIP container, started entering PIP.
    public static final int EVENT_PIP_MODE_REQUEST_START = 3;
    // Event from PIP container, PIP UI has changed, > Android 31.
    public static final int EVENT_PIP_MODE_UI_STATE_CHANGED = 4;
    // PIP interface is restored, i.e. click the enlarge button.
    public static final int EVENT_PIP_MODE_RESTORE_UI = 5;

    public static final String PIP_ACTION_DO_EXIT = "com.tencent.flutter.doExitPip";
    // Start PIP.
    public static final String PIP_ACTION_START = "com.tencent.flutter.startPip";
    // Exit PIP.
    public static final String PIP_ACTION_EXIT = "com.tencent.flutter.exitPip";
    // Update PIP.
    public static final String PIP_ACTION_UPDATE = "com.tencent.flutter.updatePip";
    // PIP parameters.
    public static final String EXTRA_NAME_PARAMS = "pipParams";
    // End parameters of PIP.
    public static final String EXTRA_NAME_RESULT = "pipResult";
    // Whether the player is currently playing when PIP ends.
    public static final String EXTRA_NAME_IS_PLAYING = "isPlaying";

    // VOD player.
    public static final int PLAYER_VOD = 1;
    // NOTE: PLAYER_LIVE removed in v3 (no live scenarios). Do NOT sync this deletion back to
    // SuperPlayer because SuperPlayer still owns live players.

    // Screen rotation event.
    public static final int EVENT_ORIENTATION_CHANGED = 401;
    // Screen rotation direction.
    public static final String EXTRA_NAME_ORIENTATION = "orientation";
    // Portrait.
    public static final int ORIENTATION_PORTRAIT_UP = 411;
    // Landscape, bottom on the right.
    public static final int ORIENTATION_LANDSCAPE_RIGHT = 412;
    // Portrait, top at the bottom.
    public static final int ORIENTATION_PORTRAIT_DOWN = 413;
    // Landscape, bottom on the left.
    public static final int ORIENTATION_LANDSCAPE_LEFT = 414;


    // SDK event - onLog
    public static final int EVENT_ON_LOG = 501;
    // SDK event - onUpdateNetworkTime
    public static final int EVENT_ON_UPDATE_NETWORK_TIME = 502;
    // SDK event - onLicenceLoaded
    public static final int EVENT_ON_LICENCE_LOADED = 503;
    // SDK event - onCustomHttpDNS
    public static final int EVENT_ON_CUSTOM_HTTP_DNS = 504;

    // These events may be common, so the specific field identifier is removed.
    public static final String EVENT_LOG_LEVEL = "logLevel";
    public static final String EVENT_LOG_MODULE = "logModule";
    public static final String EVENT_LOG_MSG = "logMsg";
    public static final String EVENT_ERR_CODE = "errCode";
    public static final String EVENT_ERR_MSG = "errMsg";
    public static final String EVENT_RESULT = "result";
    public static final String EVENT_REASON = "reason";
    public static final String EVENT_HOST_NAME = "hostName";
    public static final String EVENT_IPS = "ips";

    // Subtitle data event id.
    public static final int EVENT_SUBTITLE_DATA = 601;
    // Subtitle data extra keys.
    public static final String EXTRA_SUBTITLE_DATA = "subtitleData";
    public static final String EXTRA_SUBTITLE_START_POSITION_MS = "startPositionMs";
    public static final String EXTRA_SUBTITLE_DURATION_MS = "durationMs";
    public static final String EXTRA_SUBTITLE_TRACK_INDEX = "trackIndex";

    // Player event keys.
    public static final String EVT_KEY_PLAYER_EVENT = "event";
    public static final String EVT_KEY_PLAYER_WIDTH = "EVT_WIDTH";
    public static final String EVT_KEY_PLAYER_HEIGHT = "EVT_HEIGHT";

    public interface TUINetConst {
        String NET_STATUS_CPU_USAGE = TXLiveConstants.NET_STATUS_CPU_USAGE;
        String NET_STATUS_VIDEO_WIDTH = TXLiveConstants.NET_STATUS_VIDEO_WIDTH;
        String NET_STATUS_VIDEO_HEIGHT = TXLiveConstants.NET_STATUS_VIDEO_HEIGHT;
        String NET_STATUS_VIDEO_FPS = TXLiveConstants.NET_STATUS_VIDEO_FPS;
        String NET_STATUS_VIDEO_GOP = TXLiveConstants.NET_STATUS_VIDEO_GOP;
        String NET_STATUS_VIDEO_BITRATE = TXLiveConstants.NET_STATUS_VIDEO_BITRATE;
        String NET_STATUS_AUDIO_BITRATE = TXLiveConstants.NET_STATUS_AUDIO_BITRATE;
        String NET_STATUS_NET_SPEED = TXLiveConstants.NET_STATUS_NET_SPEED;
        String NET_STATUS_AUDIO_CACHE = TXLiveConstants.NET_STATUS_AUDIO_CACHE;
        String NET_STATUS_VIDEO_CACHE = TXLiveConstants.NET_STATUS_VIDEO_CACHE;
        String NET_STATUS_AUDIO_INFO = TXLiveConstants.NET_STATUS_AUDIO_INFO;
        String NET_STATUS_NET_JITTER = TXLiveConstants.NET_STATUS_NET_JITTER;
        String NET_STATUS_SERVER_IP = TXLiveConstants.NET_STATUS_SERVER_IP;
        String NET_STATUS_VIDEO_DPS = TXLiveConstants.NET_STATUS_VIDEO_DPS;
        String NET_STATUS_QUALITY_LEVEL = TXLiveConstants.NET_STATUS_QUALITY_LEVEL;
        String NET_STATUS_SYSTEM_CPU = "SYSTEM_CPU";
        String NET_STATUS_VIDEO_LOSS = "VIDEO_PACKET_LOSS";
        String NET_STATUS_AUDIO_LOSS = "AUDIO_PACKET_LOSS";
        String NET_STATUS_AUDIO_TOTAL_BLOCK_TIME = "AUDIO_TOTAL_BLOCK_TIME";
        String NET_STATUS_VIDEO_TOTAL_BLOCK_TIME = "VIDEO_TOTAL_BLOCK_TIME";
        String NET_STATUS_VIDEO_BLOCK_RATE = "VIDEO_BLOCK_RATE";
        String NET_STATUS_AUDIO_BLOCK_RATE = "AUDIO_BLOCK_RATE";
        String NET_STATUS_RTT = "RTT";
    }

    public interface FTXRenderMode {

        /**
         * Display the video content fully according to the video aspect ratio.
         */
        long ADJUST_RESOLUTION = 0;

        /**
         * Fill the container completely according to the video aspect ratio, and crop the overflowing parts.
         */
        long FULL_FILL_CONTAINER = 1;

        /**
         * Fill the container completely according to the video aspect ratio, and deform to fill the container.
         */
        long SCALE_FULL_FILL_CONTAINER = 2;
    }

    public interface FTXDrmProvisionEnvInt {

        long DRM_PROVISION_ENV_COM = 0;

        long DRM_PROVISION_ENV_CN = 1;
    }
}
