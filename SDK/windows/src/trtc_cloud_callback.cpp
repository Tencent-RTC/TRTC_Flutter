#include "trtc_cloud.h"
#include "include/TRTC/ITRTCCloud.h"
#include "include/TRTC/TRTCCloudDef.h"
#include "include/TRTC/TRTCCloudCallback.h"
#include "include/TRTC/ITXAudioEffectManager.h"
#include "include/macros.h"
#include <windows.h>
#include <flutter/encodable_value.h>
#include "include/rapidjson/document.h"
#include "include/rapidjson/stringbuffer.h"
#include "include/rapidjson/writer.h"

using flutter::MethodChannel;
using flutter::EncodableMap;
using flutter::EncodableList;
using std::string;
using flutter::EncodableValue;

namespace trtc_sdk_flutter {

class TRTCCloudCallbackImpl : public ITRTCCloudCallback
{
    private:
       SP<flutter::MethodChannel<>>  method_channel_;
       string LISTENER_FUNC_NAME = "onListener";

    public:
        TRTCCloudCallbackImpl(SP<flutter::MethodChannel<>> channel) {
            method_channel_ = channel;
        }
        void onError(TXLiteAVError err_code, const char* err_msg, void* extra_info) {
            EncodableMap values;
            values[string("errCode")] = err_code;
            values[string("errMsg")] = err_msg;
            // values[string("extraInfo")] = extra_info;
            EncodableMap params;
            params[string("type")] = "onError";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onWarning(TXLiteAVWarning warning_code, const char* warning_msg, void* extra_info) {
            EncodableMap values;
            values[string("warningCode")] = warning_code;
            values[string("warningMsg")] = warning_msg;
            // values[string("extraInfo")] = extra_info;
            EncodableMap params;
            params[string("type")] = "onWarning";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onEnterRoom(int result) {
            EncodableMap params;
            params[string("type")] = "onEnterRoom";
            params[string("params")] = result;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onExitRoom(int result) {
            EncodableMap params;
            params[string("type")] = "onExitRoom";
            params[string("params")] = result;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        // 切换角色的事件回调
        void onSwitchRole(TXLiteAVError err_code, const char* err_msg) {
            EncodableMap values;
            values[string("errCode")] = err_code;
            values[string("errMsg")] = err_msg;
            EncodableMap params;
            params[string("type")] = "onSwitchRole";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onConnectOtherRoom(const char* userId, TXLiteAVError errCode, const char* errMsg) {
            EncodableMap values;
            values[string("userId")] = userId;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onConnectOtherRoom";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onDisconnectOtherRoom(TXLiteAVError errCode, const char* errMsg) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onDisConnectOtherRoom";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onSwitchRoom(TXLiteAVError errCode, const char* errMsg) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onSwitchRoom";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onStartPublishing(int errCode, const char* errMsg) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onStartPublishing";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onStopPublishing(int errCode, const char* errMsg) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onStopPublishing";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onStartPublishCDNStream(int errCode, const char* errMsg) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onStartPublishCDNStream";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onStopPublishCDNStream(int errCode, const char* errMsg) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("errMsg")] = errMsg;
            EncodableMap params;
            params[string("type")] = "onStopPublishCDNStream";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onRemoteUserEnterRoom(const char* user_id) {
            EncodableMap params;
            params[string("type")] = "onRemoteUserEnterRoom";
            params[string("params")] = user_id;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onRemoteUserLeaveRoom(const char* user_id, int reason) {
            EncodableMap values;
            values[string("userId")] = user_id;
            values[string("reason")] = reason;
            EncodableMap params;
            params[string("type")] = "onRemoteUserLeaveRoom";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onUserVideoAvailable(const char* user_id, bool available) {
            EncodableMap values;
            values[string("userId")] = user_id;
            values[string("available")] = available;
            EncodableMap params;
            params[string("type")] = "onUserVideoAvailable";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onUserSubStreamAvailable(const char* user_id, bool available) {
            EncodableMap values;
            values[string("userId")] = user_id;
            values[string("available")] = available;
            EncodableMap params;
            params[string("type")] = "onUserSubStreamAvailable";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onUserAudioAvailable(const char* user_id, bool available) {
            EncodableMap values;
            values[string("userId")] = user_id;
            values[string("available")] = available;
            EncodableMap params;
            params[string("type")] = "onUserAudioAvailable";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onFirstAudioFrame(const char* user_id) {
            EncodableMap params;
            params[string("type")] = "onFirstAudioFrame";
            params[string("params")] = user_id;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onSendFirstLocalVideoFrame(int streamType) {
            EncodableMap params;
            params[string("type")] = "onSendFirstLocalVideoFrame";
            params[string("params")] = streamType;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onFirstVideoFrame(const char* user_id, const TRTCVideoStreamType streamType, const int	width, const int height) {
            EncodableMap values;
            values[string("width")] = width;
            values[string("height")] = height;
            values[string("user_id")] = user_id;
            EncodableMap params;
            params[string("type")] = "onFirstVideoFrame";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onSendFirstLocalAudioFrame() {
            EncodableMap params;
            params[string("type")] = "onSendFirstLocalAudioFrame";
            params[string("params")] = "";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onSystemAudioLoopbackError(TXLiteAVError errCode) {
            EncodableMap values;
            values[string("errCode")] = errCode;
            EncodableMap params;
            params[string("type")] = "onSystemAudioLoopbackError";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onNetworkQuality(TRTCQualityInfo local_quality, TRTCQualityInfo* remote_quality, uint32_t remote_quality_count) {
            EncodableMap values;
            EncodableMap localQuality;
            localQuality[string("userId")] = local_quality.userId;
            localQuality[string("quality")] = local_quality.quality;

            EncodableList mList;
            for (uint32_t i = 0; i < remote_quality_count; ++i) {
                EncodableMap volumeItem;
                volumeItem[string("userId")] = remote_quality[i].userId;
                volumeItem[string("quality")] = remote_quality[i].quality;
                mList.push_back(volumeItem);
            }
            
            values[string("localQuality")] = localQuality;
            values[string("remoteQuality")] = mList;
            values[string("remoteQualityCount")] = (int)remote_quality_count;
            EncodableMap params;
            params[string("type")] = "onNetworkQuality";
            params[string("params")] = values;
            // method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onStatistics(const TRTCStatistics& statis) {
            EncodableMap values;
            values[string("appCpu")] = (int)statis.appCpu;
            values[string("upLoss")] = (int)statis.upLoss;
            values[string("downLoss")] = (int)statis.downLoss;
            values[string("systemCpu")] = (int)statis.systemCpu;
            values[string("rtt")] = (int)statis.rtt;
            values[string("receivedBytes")] = (int)statis.receivedBytes;
            values[string("sentBytes")] = (int)statis.sentBytes;
            values[string("localStatisticsArraySize")] = (int)statis.localStatisticsArraySize;
            values[string("remoteStatisticsArraySize")] = (int)statis.remoteStatisticsArraySize;

            EncodableList localStatisticsArray;
            for (uint32_t i = 0; i < (int)statis.localStatisticsArraySize; ++i) {
                EncodableMap volumeItem;
                volumeItem[string("width")] = (int)statis.localStatisticsArray[i].width;
                volumeItem[string("height")] = (int)statis.localStatisticsArray[i].height;
                volumeItem[string("frameRate")] = (int)statis.localStatisticsArray[i].frameRate;
                volumeItem[string("videoBitrate")] = (int)statis.localStatisticsArray[i].videoBitrate;
                volumeItem[string("audioSampleRate")] = (int)statis.localStatisticsArray[i].audioSampleRate;
                volumeItem[string("audioBitrate")] = (int)statis.localStatisticsArray[i].audioBitrate;
                volumeItem[string("streamType")] = (int)statis.localStatisticsArray[i].streamType;
                localStatisticsArray.push_back(volumeItem);
            }
            values[string("localStatisticsArray")] = localStatisticsArray;

            EncodableList remoteStatisticsArray;
            for (uint32_t i = 0; i < (int)statis.remoteStatisticsArraySize; ++i) {
                EncodableMap volumeItem;
                volumeItem[string("userId")] = statis.remoteStatisticsArray[i].userId;
                volumeItem[string("finalLoss")] = (int)statis.remoteStatisticsArray[i].finalLoss;
                volumeItem[string("width")] = (int)statis.remoteStatisticsArray[i].width;
                volumeItem[string("height")] = (int)statis.remoteStatisticsArray[i].height;
                volumeItem[string("frameRate")] = (int)statis.remoteStatisticsArray[i].frameRate;
                volumeItem[string("videoBitrate")] = (int)statis.remoteStatisticsArray[i].videoBitrate;
                volumeItem[string("audioSampleRate")] = (int)statis.remoteStatisticsArray[i].audioSampleRate;
                volumeItem[string("audioBitrate")] = (int)statis.remoteStatisticsArray[i].audioBitrate;
                volumeItem[string("jitterBufferDelay")] = (int)statis.remoteStatisticsArray[i].jitterBufferDelay;
                volumeItem[string("point2PointDelay")] = (int)statis.remoteStatisticsArray[i].point2PointDelay;
                volumeItem[string("audioTotalBlockTime")] = (int)statis.remoteStatisticsArray[i].audioTotalBlockTime;
                volumeItem[string("audioBlockRate")] = (int)statis.remoteStatisticsArray[i].audioBlockRate;
                volumeItem[string("videoTotalBlockTime")] = (int)statis.remoteStatisticsArray[i].videoTotalBlockTime;
                volumeItem[string("videoBlockRate")] = (int)statis.remoteStatisticsArray[i].videoBlockRate;
                volumeItem[string("streamType")] = (int)statis.remoteStatisticsArray[i].streamType;
                remoteStatisticsArray.push_back(volumeItem);
            }
            values[string("remoteStatisticsArray")] = remoteStatisticsArray;

            EncodableMap params;
            params[string("type")] = "onStatistics";
            params[string("params")] = values;
            // method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onConnectionLost() {
            EncodableMap params;
            params[string("type")] = "onConnectionLost";
            params[string("params")] = "";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onTryToReconnect() {
            EncodableMap params;
            params[string("type")] = "onTryToReconnect";
            params[string("params")] = "";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onConnectionRecovery() {
            EncodableMap params;
            params[string("type")] = "onConnectionRecovery";
            params[string("params")] = "";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onSpeedTest(const TRTCSpeedTestResult& currentResult, uint32_t finishedCount, uint32_t totalCount) {
            EncodableMap values;
            EncodableMap result;
            result[string("ip")] = currentResult.ip;
            result[string("downLostRate")] = currentResult.downLostRate;
            result[string("upLostRate")] = currentResult.upLostRate;
            result[string("rtt")] = currentResult.rtt;
            result[string("quality")] = currentResult.quality;

            values[string("currentResult")] = result;
            values[string("finishedCount")] = (int)finishedCount;
            values[string("totalCount")] = (int)totalCount;
           
            EncodableMap params;
            params[string("type")] = "onSpeedTest";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onSpeedTestResult(const TRTCSpeedTestResult& result) {
            EncodableMap values;
            EncodableMap resultMap;

            resultMap[string("availableDownBandwidth")] = result.availableDownBandwidth;
            resultMap[string("availableUpBandwidth")] = result.availableUpBandwidth;
            resultMap[string("downJitter")] = result.downJitter;
            resultMap[string("downLostRate")] = result.downLostRate;
            resultMap[string("errMsg")] = result.errMsg;
            resultMap[string("ip")] = result.ip;
            resultMap[string("quality")] = result.quality;
            resultMap[string("rtt")] = result.rtt;
            resultMap[string("success")] = result.success;
            resultMap[string("upJitter")] = result.upJitter;
            resultMap[string("upLostRate")] = result.upLostRate;

            values[string("result")] = resultMap;

            EncodableMap params;
            params[string("type")] = "onSpeedTestResult";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onMicDidReady() {
            EncodableMap params;
            params[string("type")] = "onMicDidReady";
            params[string("params")] = "";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
        void onCameraDidReady() {
            EncodableMap params;
            params[string("type")] = "onCameraDidReady";
            params[string("params")] = "";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onUserVoiceVolume(TRTCVolumeInfo* user_volumes, uint32_t user_volumes_vount, uint32_t total_volume) {
            EncodableMap values;
            EncodableList mList;
            for (uint32_t i = 0; i < user_volumes_vount; ++i) {
                EncodableMap volumeItem;
                volumeItem[string("userId")] = user_volumes[i].userId;
                volumeItem[string("volume")] = (int)user_volumes[i].volume;
                mList.push_back(volumeItem);
            }
            values[string("userVolumes")] = mList;
            values[string("userVolumesCount")] = (int)user_volumes_vount;
            values[string("totalVolume")] = (int)total_volume;
           
            EncodableMap params;
            params[string("type")] = "onUserVoiceVolume";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onSetMixTranscodingConfig(int err, const char *err_msg){
            EncodableMap values;
            values[string("errCode")] = err;
            values[string("errMsg")] = err_msg;
            EncodableMap params;
            params[string("type")] = "onSetMixTranscodingConfig";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onDeviceChange(const char* deviceId, TRTCDeviceType type, TRTCDeviceState state){
            EncodableMap values;
            values[string("deviceId")] = deviceId;
            values[string("type")] = type;
            values[string("state")] = state;
            EncodableMap params;
            params[string("type")] = "onDeviceChange";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onTestMicVolume(uint32_t volume) {
            EncodableMap params;
            params[string("type")] = "onTestMicVolume";
            params[string("params")] = (int)volume;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onTestSpeakerVolume(uint32_t volume) {
            EncodableMap params;
            params[string("type")] = "onTestSpeakerVolume";
            params[string("params")] = (int)volume;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onRecvCustomCmdMsg(const char* userId, int32_t cmdID, uint32_t seq, const uint8_t* message, uint32_t messageSize) {
            EncodableMap values;
            values[string("userId")] = userId;
            values[string("cmdID")] = cmdID;
            values[string("seq")] = (int)seq;
            values[string("message")] = std::string(reinterpret_cast<const char*>(message), messageSize);
            values[string("messageSize")] = (int)messageSize;
            EncodableMap params;
            params[string("type")] = "onRecvCustomCmdMsg";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

         void onMissCustomCmdMsg(const char* userId, int32_t cmdID, int errCode, int missed) {
            EncodableMap values;
            values[string("userId")] = userId;
            values[string("cmdID")] = cmdID;
            values[string("errCode")] = errCode;
            values[string("missed")] = missed;
            EncodableMap params;
            params[string("type")] = "onMissCustomCmdMsg";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }
};

class TXMusicPreloadObserverImpl : public ITXMusicPreloadObserver {
    private:
        SP<flutter::MethodChannel<>>  method_channel_;
        string LISTENER_FUNC_NAME = "onMusicPreloadObserver";

    public:
        TXMusicPreloadObserverImpl(SP<flutter::MethodChannel<>> channel) {
            method_channel_ = channel;
        }

        void onLoadProgress(int id, int progress){
            EncodableMap values;
            values[string("id")] = id;
            values[string("progress")] = progress;
            values[string("type")] = "onLoadProgress";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(values));
        }

        void onLoadError(int id, int errorCode){
            EncodableMap values;
            values[string("id")] = id;
            values[string("errCode")] = errorCode;
            values[string("type")] = "onLoadError";
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(values));
        }
};

class TXMusicPlayObserverImpl : public ITXMusicPlayObserver {
    private:
        SP<flutter::MethodChannel<>>  method_channel_;
        string LISTENER_FUNC_NAME = "onListener";

    public:
        TXMusicPlayObserverImpl(SP<flutter::MethodChannel<>> channel) {
            method_channel_ = channel;
        }

        void onStart(int id, int errCode){
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("id")] = id;
            EncodableMap params;
            params[string("type")] = "onMusicObserverStart";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onPlayProgress (int id, long curPtsMS, long durationMS){
            EncodableMap values;
            values[string("curPtsMS")] = curPtsMS;
            values[string("durationMS")] = durationMS;
            values[string("id")] = id;
            EncodableMap params;
            params[string("type")] = "onMusicObserverPlayProgress";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

        void onComplete (int id, int errCode){
            EncodableMap values;
            values[string("errCode")] = errCode;
            values[string("id")] = id;
            EncodableMap params;
            params[string("type")] = "onMusicObserverComplete";
            params[string("params")] = values;
            method_channel_->InvokeMethod(LISTENER_FUNC_NAME, std::make_unique<EncodableValue>(params));
        }

};
}


