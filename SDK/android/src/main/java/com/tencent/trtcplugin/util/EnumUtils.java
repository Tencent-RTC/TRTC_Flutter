package com.tencent.trtcplugin.util;

import static com.tencent.trtc.TRTCCloudDef.TRTC_PublishBigStream_ToCdn;
import static com.tencent.trtc.TRTCCloudDef.TRTC_PublishMixStream_ToCdn;
import static com.tencent.trtc.TRTCCloudDef.TRTC_PublishMixStream_ToRoom;
import static com.tencent.trtc.TRTCCloudDef.TRTC_PublishMode_Unknown;
import static com.tencent.trtc.TRTCCloudDef.TRTC_PublishSubStream_ToCdn;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FILL;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_RENDER_MODE_FIT;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SMALL;
import static com.tencent.trtc.TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_SUB;

import com.tencent.trtc.TRTCCloudDef;

import java.util.Map;

public class EnumUtils {

    public static int getPublishMode(int index) {
        switch (index) {
            case 0:
                return TRTC_PublishMode_Unknown;
            case 1:
                return TRTC_PublishBigStream_ToCdn;
            case 2:
                return TRTC_PublishSubStream_ToCdn;
            case 3:
                return TRTC_PublishMixStream_ToCdn;
            case 4:
                return TRTC_PublishMixStream_ToRoom;
            default:
                return TRTC_PublishMode_Unknown;
        }
    }

    public static int getVideoRenderFillMode(int index) {
        switch (index) {
            case 0:
                return TRTC_VIDEO_RENDER_MODE_FILL;
            case 1:
                return TRTC_VIDEO_RENDER_MODE_FIT;
            default:
                return TRTC_VIDEO_RENDER_MODE_FILL;
        }
    }

    public static int getVideoStreamType(int index) {
        switch (index) {
            case 0:
                return TRTC_VIDEO_STREAM_TYPE_BIG;
            case 1:
                return TRTC_VIDEO_STREAM_TYPE_SMALL;
            case 2:
                return TRTC_VIDEO_STREAM_TYPE_SUB;
            default:
                return TRTC_VIDEO_STREAM_TYPE_BIG;
        }
    }
}
