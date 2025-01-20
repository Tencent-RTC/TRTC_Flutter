package com.tencent.trtcplugin.util;

import com.tencent.trtc.TRTCCloudDef;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ObjectUtils {

    public static TRTCCloudDef.TRTCPublishTarget getTRTCPublishTargetFromMap(Map<String, Object> targetMap) {
        if (targetMap == null) {
            return null;
        }

        TRTCCloudDef.TRTCPublishTarget target = new TRTCCloudDef.TRTCPublishTarget();

        if (targetMap.containsKey("mode")) {
            int modeIndex = (int) targetMap.get("mode");
            target.mode = EnumUtils.getPublishMode(modeIndex);
        }

        if (targetMap.containsKey("cdnUrlList")) {
            List<Map<String, Object>> cdnUrlDicList = (List<Map<String, Object>>) targetMap.get("cdnUrlList");
            for (Map<String, Object> cdnUrlDic : cdnUrlDicList) {
                TRTCCloudDef.TRTCPublishCdnUrl cdnUrl = new TRTCCloudDef.TRTCPublishCdnUrl();

                if (cdnUrlDic.containsKey("rtmpUrl")) {
                    String rtmpUrl = (String) cdnUrlDic.get("rtmpUrl");
                    cdnUrl.rtmpUrl = rtmpUrl;
                }

                if (cdnUrlDic.containsKey("isInternalLine")) {
                    cdnUrl.isInternalLine = (boolean) cdnUrlDic.get("isInternalLine");
                }

                if (target.cdnUrlList == null) {
                    target.cdnUrlList = new ArrayList<>();
                }
                target.cdnUrlList.add(cdnUrl);
            }
        }

        if (targetMap.containsKey("mixStreamIdentity")) {
            Map<String, Object> mixStreamIdentityDic = (Map<String, Object>) targetMap.get("mixStreamIdentity");
            target.mixStreamIdentity = getTRTCUserFromMap(mixStreamIdentityDic);
        }

        return target;
    }

    public static TRTCCloudDef.TRTCStreamEncoderParam getTRTCStreamEncoderParamFromMap(Map<String, Object> encoderParamMap) {
        if (encoderParamMap == null) {
            return null;
        }

        TRTCCloudDef.TRTCStreamEncoderParam encoderParam = new TRTCCloudDef.TRTCStreamEncoderParam();

        if (encoderParamMap.containsKey("videoEncodedWidth")) {
            encoderParam.videoEncodedWidth = (int) encoderParamMap.get("videoEncodedWidth");
        }

        if (encoderParamMap.containsKey("videoEncodedHeight")) {
            encoderParam.videoEncodedHeight = (int) encoderParamMap.get("videoEncodedHeight");
        }

        if (encoderParamMap.containsKey("videoEncodedFPS")) {
            encoderParam.videoEncodedFPS = (int) encoderParamMap.get("videoEncodedFPS");
        }

        if (encoderParamMap.containsKey("videoEncodedGOP")) {
            encoderParam.videoEncodedGOP = (int) encoderParamMap.get("videoEncodedGOP");
        }

        if (encoderParamMap.containsKey("videoEncodedKbps")) {
            encoderParam.videoEncodedKbps = (int) encoderParamMap.get("videoEncodedKbps");
        }

        if (encoderParamMap.containsKey("audioEncodedSampleRate")) {
            encoderParam.audioEncodedSampleRate = (int) encoderParamMap.get("audioEncodedSampleRate");
        }

        if (encoderParamMap.containsKey("audioEncodedChannelNum")) {
            encoderParam.audioEncodedChannelNum = (int) encoderParamMap.get("audioEncodedChannelNum");
        }

        if (encoderParamMap.containsKey("audioEncodedKbps")) {
            encoderParam.audioEncodedKbps = (int) encoderParamMap.get("audioEncodedKbps");
        }

        if (encoderParamMap.containsKey("audioEncodedCodecType")) {
            encoderParam.audioEncodedCodecType = (int) encoderParamMap.get("audioEncodedCodecType");
        }

        return encoderParam;
    }

    public static TRTCCloudDef.TRTCStreamMixingConfig getTRTCStreamMixingConfigFromMap(Map<String, Object> mixingConfigMap) {
        if (mixingConfigMap == null) {
            return null;
        }

        TRTCCloudDef.TRTCStreamMixingConfig mixingConfig = new TRTCCloudDef.TRTCStreamMixingConfig();

        if (mixingConfigMap.containsKey("backgroundColor")) {
            int backgroundColor = (int) mixingConfigMap.get("backgroundColor");
            mixingConfig.backgroundColor = backgroundColor;
        }

        if (mixingConfigMap.containsKey("backgroundImage")) {
            String backgroundImage = (String) mixingConfigMap.get("backgroundImage");
            mixingConfig.backgroundImage = backgroundImage;
        }

        if (mixingConfigMap.containsKey("videoLayoutList")) {
            List<Map<String, Object>> videoLayoutDicList = (List<Map<String, Object>>) mixingConfigMap.get("videoLayoutList");
            for (Map<String, Object> videoLayoutDic : videoLayoutDicList) {
                mixingConfig.videoLayoutList.add(getTRTCVideoLayoutFromMap(videoLayoutDic));
            }
        }

        if (mixingConfigMap.containsKey("audioMixUserList")) {
            List<Map<String, Object>> audioMixUserDicList = (List<Map<String, Object>>) mixingConfigMap.get("audioMixUserList");
            for (Map<String, Object> audioMixUserDic : audioMixUserDicList) {
                mixingConfig.audioMixUserList.add(getTRTCUserFromMap(audioMixUserDic));
            }
        }

        if (mixingConfigMap.containsKey("watermarkList")) {
            List<Map<String, Object>> watermarkDicList = (List<Map<String, Object>>) mixingConfigMap.get("watermarkList");
            for (Map<String, Object> watermarkDic : watermarkDicList) {
                mixingConfig.watermarkList.add(getTRTCWatermarkFromMap(watermarkDic));
            }
        }

        return mixingConfig;
    }

    public static TRTCCloudDef.TRTCUser getTRTCUserFromMap(Map<String, Object> userMap) {
        if (userMap == null) {
            return null;
        }

        TRTCCloudDef.TRTCUser user = new TRTCCloudDef.TRTCUser();
        if (userMap.containsKey("userId")) {
            user.userId = (String) userMap.get("userId");
        }
        if (userMap.containsKey("intRoomId")) {
            user.intRoomId = (int) userMap.get("intRoomId");
        }

        if (userMap.containsKey("strRoomId")) {
            user.strRoomId = (String) userMap.get("strRoomId");
        }
        return user;
    }

    public static TRTCCloudDef.TRTCVideoLayout getTRTCVideoLayoutFromMap(Map<String, Object> videoLayoutMap) {
        if (videoLayoutMap == null) {
            return null;
        }

        TRTCCloudDef.TRTCVideoLayout videoLayout = new TRTCCloudDef.TRTCVideoLayout();
        if (videoLayoutMap.containsKey("rect")) {
            Map<String, Object> rectDic = (Map<String, Object>) videoLayoutMap.get("rect");

            if (rectDic.containsKey("originX")) {
                double originX = (double) rectDic.get("originX");
                videoLayout.x = (int) originX;
            }

            if (rectDic.containsKey("originY")) {
                double originY = (double) rectDic.get("originY");
                videoLayout.y = (int) originY;
            }

            if (rectDic.containsKey("sizeWidth")) {
                double sizeWidth = (double) rectDic.get("sizeWidth");
                videoLayout.width = (int) sizeWidth;
            }

            if (rectDic.containsKey("sizeHeight")) {
                double sizeHeight = (double) rectDic.get("sizeHeight");
                videoLayout.height = (int) sizeHeight;
            }
        }

        if (videoLayoutMap.containsKey("zOrder")) {
            int zOrder = (int) videoLayoutMap.get("zOrder");
            videoLayout.zOrder = zOrder;
        }

        if (videoLayoutMap.containsKey("fillMode")) {
            int fillModeIndex = (int) videoLayoutMap.get("fillMode");
            videoLayout.fillMode = EnumUtils.getVideoRenderFillMode(fillModeIndex);
        }

        if (videoLayoutMap.containsKey("backgroundColor")) {
            int backgroundColor = (int) videoLayoutMap.get("backgroundColor");
            videoLayout.backgroundColor = backgroundColor;
        }

        if (videoLayoutMap.containsKey("placeHolderImage")) {
            String placeHolderImage = (String) videoLayoutMap.get("placeHolderImage");
            videoLayout.placeHolderImage = placeHolderImage;
        }

        if (videoLayoutMap.containsKey("fixedVideoUser")) {
            Map<String, Object> fixedVideoUserDic = (Map<String, Object>) videoLayoutMap.get("fixedVideoUser");
            videoLayout.fixedVideoUser = getTRTCUserFromMap(fixedVideoUserDic);
        }

        if (videoLayoutMap.containsKey("fixedVideoStreamType")) {
            int fixedVideoStreamType = (int) videoLayoutMap.get("fixedVideoStreamType");
            videoLayout.fixedVideoStreamType = EnumUtils.getVideoStreamType(fixedVideoStreamType);
        }
        return videoLayout;
    }

    public static TRTCCloudDef.TRTCWatermark getTRTCWatermarkFromMap(Map<String, Object> watermarkMap) {
        if (watermarkMap == null) {
            return null;
        }

        TRTCCloudDef.TRTCWatermark watermark = new TRTCCloudDef.TRTCWatermark();
        if (watermarkMap.containsKey("watermarkUrl")) {
            String watermarkUrl = (String) watermarkMap.get("watermarkUrl");
            watermark.watermarkUrl = watermarkUrl;
        }

        if (watermarkMap.containsKey("zOrder")) {
            int zOrder = (int) watermarkMap.get("zOrder");
            watermark.zOrder = zOrder;
        }

        if (watermarkMap.containsKey("rect")) {
            Map<String, Object> rectDic = (Map<String, Object>) watermarkMap.get("rect");

            if (rectDic.containsKey("originX")) {
                double originX = (double) rectDic.get("originX");
                watermark.x = (int) originX;
            }

            if (rectDic.containsKey("originY")) {
                double originY = (double) rectDic.get("originY");
                watermark.y = (int) originY;
            }

            if (rectDic.containsKey("sizeWidth")) {
                double sizeWidth = (double) rectDic.get("sizeWidth");
                watermark.width = (int) sizeWidth;
            }

            if (rectDic.containsKey("sizeHeight")) {
                double sizeHeight = (double) rectDic.get("sizeHeight");
                watermark.height = (int) sizeHeight;
            }
        }
        return watermark;
    }
}
