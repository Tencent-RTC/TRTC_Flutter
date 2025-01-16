#include "trtc_cloud.h"
#include "include/macros.h"
#include <windows.h>
#include <flutter/encodable_value.h>
#include "include/rapidjson/document.h"
#include "include/rapidjson/stringbuffer.h"
#include "include/rapidjson/writer.h"

using namespace rapidjson;

using flutter::MethodChannel;
using flutter::EncodableMap;
using std::string;
using flutter::EncodableValue;

namespace trtc_sdk_flutter {

SDKManager::SDKManager(SP<flutter::MethodChannel<>> method_channel, flutter::TextureRegistrar *registrar) {
  registrar_ = registrar;
  method_channel_ = method_channel;
}
void SDKManager::sharedInstance(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    trtc_cloud = getTRTCShareInstance();
    trtc_cloud->addCallback(new TRTCCloudCallbackImpl(method_channel_));
    result->Success(nullptr);
};
void SDKManager::destroySharedInstance(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    destroyTRTCShareInstance();
    trtc_cloud = nullptr;
    renderMap.clear();
    result->Success(nullptr);
};
void SDKManager::getSDKVersion(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    std::string version = trtc_cloud->getSDKVersion();
    result->Success(flutter::EncodableValue(version));
};

void SDKManager::enterRoom(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    trtc_cloud->callExperimentalAPI("{\"api\": \"setFramework\", \"params\": {\"framework\": 7}}");
    auto userId = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
    auto userSig = std::get<std::string>(methodParams[flutter::EncodableValue("userSig")]).c_str();
    auto sdkAppId = std::get<int>(methodParams[flutter::EncodableValue("sdkAppId")]);
    auto roomId = std::get<std::string>(methodParams[flutter::EncodableValue("roomId")]);
    auto strRoomId = std::get<std::string>(methodParams[flutter::EncodableValue("strRoomId")]).c_str();
    auto role = std::get<int>(methodParams[flutter::EncodableValue("role")]);
    auto streamId = std::get<std::string>(methodParams[flutter::EncodableValue("streamId")]).c_str();
    auto userDefineRecordId = std::get<std::string>(methodParams[flutter::EncodableValue("userDefineRecordId")]).c_str();
    auto privateMapKey = std::get<std::string>(methodParams[flutter::EncodableValue("privateMapKey")]).c_str();
    auto businessInfo = std::get<std::string>(methodParams[flutter::EncodableValue("businessInfo")]).c_str();
    auto scene = std::get<int>(methodParams[flutter::EncodableValue("scene")]);

    TRTCParams params;
    params.sdkAppId = sdkAppId;
    params.userId = userId;
    params.userSig = userSig;
    params.roomId = std::stoi(roomId);
    params.strRoomId = strRoomId;
    params.role = static_cast<TRTCRoleType>(role);
    params.streamId = streamId;
    params.userDefineRecordId = userDefineRecordId;
    params.privateMapKey = privateMapKey;
    params.businessInfo = businessInfo;

    trtc_cloud->enterRoom(params, static_cast<TRTCAppScene>(scene));
    result->Success(nullptr);
};
void SDKManager::exitRoom(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    trtc_cloud->exitRoom();
    result->Success(nullptr);
};
void SDKManager::switchRoom(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto config = std::get<std::string>(methodParams[flutter::EncodableValue("config")]);
    Document configDo;
    configDo.Parse(config.c_str());
    
    TRTCSwitchRoomConfig params;
    params.roomId = configDo["roomId"].GetInt();
    params.strRoomId = configDo["strRoomId"].GetString();
    params.userSig = configDo["userSig"].GetString();
    params.privateMapKey = configDo["privateMapKey"].GetString();
    trtc_cloud->switchRoom(params);
    result->Success(nullptr);
};
void SDKManager::connectOtherRoom(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto jsonParams = std::get<std::string>(methodParams[flutter::EncodableValue("param")]).c_str();
    trtc_cloud->connectOtherRoom(jsonParams);
    result->Success(nullptr);
};
void SDKManager::disconnectOtherRoom(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    trtc_cloud->disconnectOtherRoom();
    result->Success(nullptr);
};
void SDKManager::switchRole(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto role = std::get<int>(methodParams[flutter::EncodableValue("role")]);
    trtc_cloud->switchRole(static_cast<TRTCRoleType>(role));
    result->Success(nullptr);
};
void SDKManager::setDefaultStreamRecvMode(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto autoRecvAudio = std::get<bool>(methodParams[flutter::EncodableValue("autoRecvAudio")]);
        auto autoRecvVideo = std::get<bool>(methodParams[flutter::EncodableValue("autoRecvVideo")]);
        trtc_cloud->setDefaultStreamRecvMode(autoRecvAudio, autoRecvVideo);
        result->Success(nullptr);
};
void SDKManager::startPublishing(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto streamId = std::get<std::string>(methodParams[flutter::EncodableValue("streamId")]).c_str();
        auto type = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);
        trtc_cloud->startPublishing(streamId, static_cast<TRTCVideoStreamType>(type));
        result->Success(nullptr);
};
void SDKManager::stopPublishing(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopPublishing();
        result->Success(nullptr);
};
void SDKManager::startPublishCDNStream(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCPublishCDNParam param;
        param.appId = configDo["appId"].GetInt();
        param.bizId = configDo["bizId"].GetInt();
        param.url = configDo["url"].GetString();
        trtc_cloud->startPublishCDNStream(param);
        result->Success(nullptr);
};
void SDKManager::stopPublishCDNStream(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopPublishCDNStream();
        result->Success(nullptr);
};
void SDKManager::setMixTranscodingConfig(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto configParam = std::get<std::string>(methodParams[flutter::EncodableValue("config")]);
        Document configDo;
        configDo.Parse(configParam.c_str());
        if(configDo.IsNull()) {
            trtc_cloud->setMixTranscodingConfig(nullptr);
            result->Success(nullptr);
            return;
        }

        TRTCTranscodingConfig config;
        if(!(configDo["appId"].IsNull())) {
            config.appId = configDo["appId"].GetInt();
        }
        if(!(configDo["bizId"].IsNull())) {
            config.bizId = configDo["bizId"].GetInt();
        }
        if(!(configDo["backgroundImage"].IsNull())) {
            config.backgroundImage = configDo["backgroundImage"].GetString();
        }
        if(!(configDo["streamId"].IsNull())) {
            config.streamId = configDo["streamId"].GetString();
        }
        config.videoWidth = configDo["videoWidth"].GetInt();
        config.mode = static_cast<TRTCTranscodingConfigMode>(configDo["mode"].GetInt());
        config.videoHeight = configDo["videoHeight"].GetInt();
        config.videoFramerate = configDo["videoFramerate"].GetInt();
        config.videoGOP = configDo["videoGOP"].GetInt();
        config.videoBitrate = configDo["videoBitrate"].GetInt();
        config.audioBitrate = configDo["audioBitrate"].GetInt();
        config.audioSampleRate = configDo["audioSampleRate"].GetInt();
        config.audioChannels = configDo["audioChannels"].GetInt();
        // config.mixUsersArraySize = configDo["mixUsersArraySize"].GetInt();

        trtc_cloud->setMixTranscodingConfig(&config);
        //todo
        // TRTCMixUser * mixArray;

        result->Success(nullptr);
};
void SDKManager::startLocalPreview(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        trtc_cloud->startLocalPreview(nullptr);
        result->Success(nullptr);
};
void SDKManager::stopLocalPreview(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopLocalPreview();
        result->Success(nullptr);
};
void SDKManager::startRemoteView(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto stream_type = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);
        trtc_cloud->startRemoteView(user_id, static_cast<TRTCVideoStreamType >(stream_type), nullptr);
        result->Success(nullptr);
};
void SDKManager::stopRemoteView(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto stream_type = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);
        trtc_cloud->stopRemoteView(user_id, static_cast<TRTCVideoStreamType >(stream_type));
        result->Success(nullptr);
};
void SDKManager::stopAllRemoteView(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopAllRemoteView();
        result->Success(nullptr);
};
void SDKManager::muteRemoteAudio(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        trtc_cloud->muteRemoteAudio(user_id, mute);
        result->Success(nullptr);
};
void SDKManager::muteAllRemoteAudio(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        trtc_cloud->muteAllRemoteAudio(mute);
        result->Success(nullptr);
};
void SDKManager::setRemoteAudioVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        trtc_cloud->setRemoteAudioVolume(user_id,  volume);
        result->Success(nullptr);
};
void SDKManager::setAudioCaptureVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        trtc_cloud->setAudioCaptureVolume(volume);
        result->Success(nullptr);
};
void SDKManager::getAudioCaptureVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        // int result = trtc_cloud->getAudioCaptureVolume();
        result->Success(flutter::EncodableValue(trtc_cloud->getAudioCaptureVolume()));
};
void SDKManager::setAudioPlayoutVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        trtc_cloud->setAudioPlayoutVolume(volume);
        result->Success(nullptr);
};
void SDKManager::getAudioPlayoutVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        // int result = trtc_cloud->getAudioPlayoutVolume();
        // result->Success(flutter::EncodableValue(result));
        result->Success(flutter::EncodableValue(trtc_cloud->getAudioPlayoutVolume()));
};
void SDKManager::startLocalAudio(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto quality = std::get<int>(methodParams[flutter::EncodableValue("quality")]);
        trtc_cloud->startLocalAudio(static_cast<TRTCAudioQuality>(quality));
        result->Success(nullptr);
};
void SDKManager::stopLocalAudio(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopLocalAudio();
        result->Success(nullptr);
};
void SDKManager::muteRemoteVideoStream(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto user_id = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        trtc_cloud->muteRemoteVideoStream(user_id, static_cast<TRTCVideoStreamType>(0), mute);
        result->Success(nullptr);
};
void SDKManager::muteAllRemoteVideoStreams(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        trtc_cloud->muteAllRemoteVideoStreams(mute);
        result->Success(nullptr);
};
void SDKManager::setVideoEncoderParam(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCVideoEncParam param;
        param.videoResolution = static_cast<TRTCVideoResolution>(configDo["videoResolution"].GetInt());
        param.resMode = static_cast<TRTCVideoResolutionMode>(configDo["videoResolutionMode"].GetInt());
        param.videoFps = configDo["videoFps"].GetInt();
        param.videoBitrate = configDo["videoBitrate"].GetInt();
        param.minVideoBitrate = configDo["minVideoBitrate"].GetInt();
        param.enableAdjustRes = configDo["enableAdjustRes"].GetBool();
        trtc_cloud->setVideoEncoderParam(param);
        result->Success(nullptr);
};
void SDKManager::setNetworkQosParam(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCNetworkQosParam param;
        param.preference = static_cast<TRTCVideoQosPreference>(configDo["preference"].GetInt());
        param.controlMode = static_cast<TRTCQosControlMode>(configDo["controlMode"].GetInt());
        trtc_cloud->setNetworkQosParam(param);
        result->Success(nullptr);
};
void SDKManager::setLocalRenderParams(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCRenderParams params;
        params.fillMode = static_cast<TRTCVideoFillMode>(configDo["fillMode"].GetInt());
        params.mirrorType = static_cast<TRTCVideoMirrorType>(configDo["mirrorType"].GetInt());
        params.rotation = static_cast<TRTCVideoRotation>(configDo["rotation"].GetInt());
        trtc_cloud->setLocalRenderParams(params);
        result->Success(nullptr);
};
void SDKManager::setRemoteRenderParams(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        auto streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);
        auto userId = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCRenderParams params;
        params.fillMode = static_cast<TRTCVideoFillMode>(configDo["fillMode"].GetInt());
        params.mirrorType = static_cast<TRTCVideoMirrorType>(configDo["mirrorType"].GetInt());
        params.rotation = static_cast<TRTCVideoRotation>(configDo["rotation"].GetInt());
        trtc_cloud->setRemoteRenderParams(userId, static_cast<TRTCVideoStreamType>(streamType), params);
        result->Success(nullptr);
};
void SDKManager::setVideoEncoderRotation(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto rotation = std::get<int>(methodParams[flutter::EncodableValue("rotation")]);
        TRTCVideoRotation trtcRotation = static_cast<TRTCVideoRotation>(rotation);
        trtc_cloud->setVideoEncoderRotation(trtcRotation);
        result->Success(nullptr);
};
void SDKManager::setVideoEncoderMirror(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto mirror = std::get<bool>(methodParams[flutter::EncodableValue("mirror")]);
        trtc_cloud->setVideoEncoderMirror(mirror);
        result->Success(nullptr);
};
void SDKManager::enableEncSmallVideoStream(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        //todo
        result->Success(nullptr);
};
void SDKManager::setRemoteVideoStreamType(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto userId = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        trtc_cloud->setRemoteVideoStreamType(userId, static_cast<TRTCVideoStreamType>(type));
        result->Success(nullptr);
};
void SDKManager::snapshotVideo(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        //todo
        result->Success(nullptr);
};
void SDKManager::setLocalVideoRenderListener(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto userId = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        trtc_cloud->startLocalPreview(nullptr);
        TextureRenderer* trtc_render = new TextureRenderer(registrar_, method_channel_, static_cast<TRTCVideoStreamType>(0), userId);
        trtc_cloud->setLocalVideoRenderCallback(TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, trtc_render);
        int64_t texture_id = trtc_render->texture_id();
        renderMap[texture_id] = trtc_render;
        result->Success(flutter::EncodableValue(texture_id));
};
void SDKManager::unregisterTexture(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto textureID = std::get<int64_t>(methodParams[flutter::EncodableValue("textureID")]);
        TextureRenderer* trtc_render = renderMap[textureID];
        trtc_render->unRegisterTexture();
        renderMap[textureID] = nullptr;
        result->Success(nullptr);
};
void SDKManager::setRemoteVideoRenderListener(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);
        auto userId = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        TRTCVideoStreamType stype = static_cast<TRTCVideoStreamType>(streamType);
        trtc_cloud->startRemoteView(userId, stype, nullptr);
        TextureRenderer* trtc_render = new TextureRenderer(registrar_, method_channel_, stype, userId);
        trtc_cloud->setRemoteVideoRenderCallback(userId, TRTCVideoPixelFormat_BGRA32, TRTCVideoBufferType_Buffer, trtc_render);
        int64_t texture_id = trtc_render->texture_id();
        renderMap[texture_id] = trtc_render;
        result->Success(flutter::EncodableValue(texture_id));
};
void SDKManager::muteLocalAudio(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        trtc_cloud->muteLocalAudio(mute);
        result->Success(nullptr);
};
void SDKManager::muteLocalVideo(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        trtc_cloud->muteLocalVideo(static_cast<TRTCVideoStreamType>(0), mute);
        result->Success(nullptr);
};
void SDKManager::enableAudioVolumeEvaluation(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto interval = std::get<int>(methodParams[flutter::EncodableValue("intervalMs")]);
        trtc_cloud->enableAudioVolumeEvaluation(interval, true);
        result->Success(nullptr);
};
void SDKManager::startAudioRecording(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCAudioRecordingParams audioRecordingParams;
        audioRecordingParams.filePath = configDo["filePath"].GetString();
        int value = trtc_cloud->startAudioRecording(audioRecordingParams);
        result->Success(flutter::EncodableValue(value));
};
void SDKManager::stopAudioRecording(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopAudioRecording();
        result->Success(nullptr);
};
void SDKManager::startLocalRecording(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("param")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCLocalRecordingParams audioRecordingParams;
        audioRecordingParams.filePath = configDo["filePath"].GetString();
        audioRecordingParams.recordType = static_cast<TRTCLocalRecordType>(configDo["recordType"].GetInt());
        audioRecordingParams.interval = configDo["interval"].GetInt();
        trtc_cloud->startLocalRecording(audioRecordingParams);
        result->Success(flutter::EncodableValue(nullptr));
};
void SDKManager::stopLocalRecording(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopLocalRecording();
        result->Success(nullptr);
};
void SDKManager::setSystemVolumeType(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        //C++没有这个接口
        result->Success(nullptr);
};
void SDKManager::getDeviceManager(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        deviceManager = trtc_cloud->getDeviceManager();
        result->Success(nullptr);
};
void SDKManager::getBeautyManager(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        //C++没有这个接口
        result->Success(nullptr);
};
void SDKManager::getAudioEffectManager(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        audioEffectManager = trtc_cloud->getAudioEffectManager();
        result->Success(nullptr);
};
void SDKManager::getScreenCaptureSources(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        int thumbnailWidth = std::get<int>(methodParams[flutter::EncodableValue("thumbnailWidth")]);
        int thumbnailHeight = std::get<int>(methodParams[flutter::EncodableValue("thumbnailHeight")]);
        int iconWidth = std::get<int>(methodParams[flutter::EncodableValue("iconWidth")]);
        int iconHeight = std::get<int>(methodParams[flutter::EncodableValue("iconHeight")]);
        SIZE thumbnailSize = {thumbnailWidth, thumbnailHeight};
        SIZE iconSize = {iconWidth, iconHeight};
        ITRTCScreenCaptureSourceList *sourceList = trtc_cloud->getScreenCaptureSources(thumbnailSize, iconSize);
        result->Success(SDKManager::ToEncodableValue(sourceList));
}
void SDKManager::selectScreenCaptureTarget(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        TRTCScreenCaptureSourceInfo sourceInfo = SDKManager::FromEncodableValue(methodParams[flutter::EncodableValue("sourceInfo")]);
        TRTCScreenCaptureProperty property = SDKManager::FromEncodableValueProperty(methodParams[flutter::EncodableValue("property")]);
        int captureTop = std::get<int>(methodParams[flutter::EncodableValue("captureTop")]);
        int captureLeft = std::get<int>(methodParams[flutter::EncodableValue("captureLeft")]);
        int captureRight = std::get<int>(methodParams[flutter::EncodableValue("captureRight")]);
        int captureBottom = std::get<int>(methodParams[flutter::EncodableValue("captureBottom")]);
        RECT captureRect = {captureLeft, captureTop, captureRight, captureBottom};
        trtc_cloud->selectScreenCaptureTarget(sourceInfo, captureRect, property);
        result->Success(nullptr);
}
void SDKManager::startScreenCapture(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("encParams")]);
        int streamType = std::get<int>(methodParams[flutter::EncodableValue("streamType")]);
        Document configDo;
        configDo.Parse(config.c_str());
        TRTCVideoEncParam param;
        param.videoResolution = static_cast<TRTCVideoResolution>(configDo["videoResolution"].GetInt());
        param.resMode = static_cast<TRTCVideoResolutionMode>(configDo["videoResolutionMode"].GetInt());
        param.videoFps = configDo["videoFps"].GetInt();
        param.videoBitrate = configDo["videoBitrate"].GetInt();
        param.minVideoBitrate = configDo["minVideoBitrate"].GetInt();
        param.enableAdjustRes = configDo["enableAdjustRes"].GetBool();
        trtc_cloud->startScreenCapture(nullptr, static_cast<TRTCVideoStreamType>(streamType), &param);
        result->Success(nullptr);
};
void SDKManager::stopScreenCapture(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopScreenCapture();
        result->Success(nullptr);
};
void SDKManager::pauseScreenCapture(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->pauseScreenCapture();
        result->Success(nullptr);
};
void SDKManager::setWatermark(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        //todo
        // trtc_cloud->setWaterMark(static_cast<TRTCVideoStreamType>(streamType), srcData, static_cast<TRTCWaterMarkSrcType>(srcType), nWidth, nHeight, xOffset, yOffset, fWidthRatio);
        result->Success(nullptr);
};
void SDKManager::sendCustomCmdMsg(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto data = std::get<std::string>(methodParams[flutter::EncodableValue("data")]).c_str();
        auto cmdID = std::get<int>(methodParams[flutter::EncodableValue("cmdID")]);
        auto reliable = std::get<bool>(methodParams[flutter::EncodableValue("reliable")]);
        auto ordered = std::get<bool>(methodParams[flutter::EncodableValue("ordered")]);
        const uint8_t* message = reinterpret_cast<const uint8_t*>(data);
        bool res = trtc_cloud->sendCustomCmdMsg(cmdID, message, sizeof(message), reliable, ordered);
        result->Success(flutter::EncodableValue(res));
};
void SDKManager::sendSEIMsg(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        //todo
        // result = trtc_cloud->sendSEIMsg(data, data_size, repeat_count);
        result->Success(nullptr);
};
void SDKManager::startSpeedTest(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto userId = std::get<std::string>(methodParams[flutter::EncodableValue("userId")]).c_str();
        auto userSig = std::get<std::string>(methodParams[flutter::EncodableValue("userSig")]).c_str();
        auto sdkAppId = std::get<int>(methodParams[flutter::EncodableValue("sdkAppId")]);
        trtc_cloud->startSpeedTest(sdkAppId, userId, userSig);
        result->Success(nullptr);
};
void SDKManager::startSpeedTestWithParams(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto paramsMap = std::get<flutter::EncodableMap>(methodParams.at(flutter::EncodableValue("params")));

    TRTCSpeedTestParams params = TRTCSpeedTestParams();
    params.userId = std::get<std::string>(paramsMap[flutter::EncodableValue("userId")]).c_str();
    params.userSig = std::get<std::string>(paramsMap[flutter::EncodableValue("userSig")]).c_str();
    params.sdkAppId = std::get<int>(paramsMap[flutter::EncodableValue("sdkAppId")]);
    params.expectedDownBandwidth = std::get<int>(paramsMap[flutter::EncodableValue("expectedDownBandwidth")]);
    params.expectedUpBandwidth = std::get<int>(paramsMap[flutter::EncodableValue("expectedUpBandwidth")]);

    int scene = std::get<int>(paramsMap[flutter::EncodableValue("scene")]);
    params.scene = static_cast<TRTCSpeedTestScene>(scene);

    int return_value = trtc_cloud->startSpeedTest(params);
    result->Success(flutter::EncodableValue(return_value));
};
void SDKManager::stopSpeedTest(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopSpeedTest();
        result->Success(nullptr);
};
void SDKManager::setLogLevel(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto level = std::get<int>(methodParams[flutter::EncodableValue("level")]);
        trtc_cloud->setLogLevel(static_cast<TRTCLogLevel>(level));
        result->Success(nullptr);
};
void SDKManager::setConsoleEnabled(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto enabled = std::get<bool>(methodParams[flutter::EncodableValue("enabled")]);
        trtc_cloud->setConsoleEnabled(enabled);
        result->Success(nullptr);
};
void SDKManager::setLogDirPath(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto path = std::get<std::string>(methodParams[flutter::EncodableValue("path")]).c_str();
        trtc_cloud->setLogDirPath(path);
        result->Success(nullptr);
};
void SDKManager::setLogCompressEnabled(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto enabled = std::get<bool>(methodParams[flutter::EncodableValue("enabled")]);
        trtc_cloud->setLogCompressEnabled(enabled);
        result->Success(nullptr);
};
void SDKManager::callExperimentalAPI(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto json = std::get<std::string>(methodParams[flutter::EncodableValue("jsonStr")]).c_str();
        trtc_cloud->callExperimentalAPI(json);
        result->Success(nullptr);
};
void SDKManager::resumeScreenCapture(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->resumeScreenCapture();
        result->Success(nullptr);
};
void SDKManager::setBeautyStyle(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto style = std::get<int>(methodParams[flutter::EncodableValue("beautyStyle")]);
        _beautyStyle = style;
        trtc_cloud->setBeautyStyle(static_cast<TRTCBeautyStyle>(style), _beautyLevel, _whitenessLevel, _ruddinessLevel);
        result->Success(nullptr);
};
void SDKManager::setBeautyLevel(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto level = std::get<int>(methodParams[flutter::EncodableValue("beautyLevel")]);
        _beautyLevel = level;
        trtc_cloud->setBeautyStyle(static_cast<TRTCBeautyStyle>(_beautyStyle), level, _whitenessLevel, _ruddinessLevel);
        result->Success(nullptr);
};
void SDKManager::setWhitenessLevel(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto level = std::get<int>(methodParams[flutter::EncodableValue("whitenessLevel")]);
        _whitenessLevel = level;
        trtc_cloud->setBeautyStyle(static_cast<TRTCBeautyStyle>(_beautyStyle), _beautyLevel, level, _ruddinessLevel);
        result->Success(nullptr);
};
void SDKManager::setRuddyLevel(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto level = std::get<int>(methodParams[flutter::EncodableValue("ruddyLevel")]);
        _ruddinessLevel = level;
        trtc_cloud->setBeautyStyle(static_cast<TRTCBeautyStyle>(_beautyStyle), _beautyLevel, _whitenessLevel, level);
        result->Success(nullptr);
};
void SDKManager::startPlayMusic(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto config = std::get<std::string>(methodParams[flutter::EncodableValue("musicParam")]);
        Document configDo;
        configDo.Parse(config.c_str());
        
        int id = configDo["id"].GetInt();
        AudioMusicParam params = AudioMusicParam(id, "");
        params.path = const_cast<char*>((configDo["path"].GetString()));
        params.loopCount = configDo["loopCount"].GetInt();
        params.publish = configDo["publish"].GetBool();
        params.isShortFile = configDo["isShortFile"].GetBool();
        params.startTimeMS = configDo["startTimeMS"].GetInt();
        params.endTimeMS = configDo["endTimeMS"].GetInt();
        audioEffectManager->startPlayMusic(params);
        result->Success(flutter::EncodableValue(true));

        if (musicPlayObserver == nullptr) {
            musicPlayObserver.reset(new TXMusicPlayObserverImpl(method_channel_));
            audioEffectManager->setMusicObserver(id, musicPlayObserver.get());
        }
};
void SDKManager::startSystemAudioLoopback(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto path = std::get<std::string>(methodParams[flutter::EncodableValue("path")]).c_str();
        trtc_cloud->startSystemAudioLoopback(path);
        result->Success(nullptr);
};
void SDKManager::stopSystemAudioLoopback(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        trtc_cloud->stopSystemAudioLoopback();
        result->Success(nullptr);
};
void SDKManager::setSystemAudioLoopbackVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        trtc_cloud->setSystemAudioLoopbackVolume(volume);
        result->Success(nullptr);
};
void SDKManager::stopPlayMusic(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        audioEffectManager->stopPlayMusic(id);
        result->Success(nullptr);
}
void SDKManager::pausePlayMusic(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        audioEffectManager->pausePlayMusic(id);
        result->Success(nullptr);
}
void SDKManager::resumePlayMusic(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        audioEffectManager->resumePlayMusic(id);
        result->Success(nullptr);
}
void SDKManager::setMusicPublishVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        audioEffectManager->setMusicPublishVolume(id, volume);
        result->Success(nullptr);
}
void SDKManager::setMusicPlayoutVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        audioEffectManager->setMusicPlayoutVolume(id, volume);
        result->Success(nullptr);
}
void SDKManager::setAllMusicVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        audioEffectManager->setAllMusicVolume(volume);
        result->Success(nullptr);
}
void SDKManager::setMusicPitch(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        auto pitch = std::get<std::string>(methodParams[flutter::EncodableValue("pitch")]);
        audioEffectManager->setMusicPitch(id, std::stof(pitch));
        result->Success(nullptr);
}
void SDKManager::setMusicSpeedRate(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        auto speedRate = std::get<std::string>(methodParams[flutter::EncodableValue("speedRate")]);
        audioEffectManager->setMusicSpeedRate(id, std::stof(speedRate));
        result->Success(nullptr);
}
void SDKManager::getMusicCurrentPosInMS(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        result->Success(flutter::EncodableValue(audioEffectManager->getMusicCurrentPosInMS(id)));
}
void SDKManager::seekMusicToPosInMS(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto id = std::get<int>(methodParams[flutter::EncodableValue("id")]);
        auto pts = std::get<int>(methodParams[flutter::EncodableValue("pts")]);
        audioEffectManager->seekMusicToPosInTime(id, pts);
        result->Success(nullptr);
}
void SDKManager::getMusicDurationInMS(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto path = std::get<std::string>(methodParams[flutter::EncodableValue("path")]).c_str();
        result->Success(flutter::EncodableValue(audioEffectManager->getMusicDurationInMS(const_cast<char*>(path))));
}
void SDKManager::setVoiceReverbType(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        audioEffectManager->setVoiceReverbType(static_cast<TXVoiceReverbType>(type));
        result->Success(nullptr);
}
void SDKManager::setVoiceChangerType(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
    audioEffectManager->setVoiceChangerType(static_cast<TXVoiceChangerType>(type));
    result->Success(nullptr);
}
void SDKManager::setVoiceCaptureVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        audioEffectManager->setVoiceCaptureVolume(volume);
        result->Success(nullptr);
}
void SDKManager::preloadMusic(const flutter::MethodCall<flutter::EncodableValue> &method_call,
                                std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
    auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto config = std::get<std::string>(methodParams[flutter::EncodableValue("preloadParam")]);
    Document configDo;
    configDo.Parse(config.c_str());

    int id = configDo["id"].GetInt();
    AudioMusicParam params = AudioMusicParam(id, "");
    params.path = const_cast<char*>((configDo["path"].GetString()));
    params.loopCount = configDo["loopCount"].GetInt();
    params.publish = configDo["publish"].GetBool();
    params.isShortFile = configDo["isShortFile"].GetBool();
    params.startTimeMS = configDo["startTimeMS"].GetInt();
    params.endTimeMS = configDo["endTimeMS"].GetInt();
    audioEffectManager->preloadMusic(params);
    result->Success(flutter::EncodableValue(true));

    if (musicPreloadObserver == nullptr) {
        musicPreloadObserver.reset(new TXMusicPreloadObserverImpl(method_channel_));
        audioEffectManager->setPreloadObserver(musicPreloadObserver.get());
    }
};
void SDKManager::getDevicesList(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        ITXDeviceCollection* deviceInfo = deviceManager->getDevicesList(static_cast<TXMediaDeviceType>(type));

        EncodableMap res;
        EncodableList mList;
        res[string("count")] = (int)deviceInfo->getCount();
        for (uint32_t i = 0; i < (int)deviceInfo->getCount(); ++i) {
            EncodableMap volumeItem;
            volumeItem[string("deviceName")] = deviceInfo->getDeviceName(i);
            volumeItem[string("deviceId")] = deviceInfo->getDevicePID(i);
            mList.push_back(volumeItem);
        }
        res[string("deviceList")] = mList;
        deviceInfo->release();
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::setCurrentDevice(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        auto deviceId = std::get<std::string>(methodParams[flutter::EncodableValue("deviceId")]).c_str();
        int res = deviceManager->setCurrentDevice(static_cast<TXMediaDeviceType >(type), deviceId);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::enableFollowingDefaultAudioDevice(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        auto enable = std::get<bool>(methodParams[flutter::EncodableValue("enable")]);
        int res = deviceManager->enableFollowingDefaultAudioDevice(static_cast<TXMediaDeviceType>(type), enable);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::getCurrentDevice(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        ITXDeviceInfo* deviceInfo = deviceManager->getCurrentDevice(static_cast<TXMediaDeviceType >(type));
        EncodableMap deviceItem;
        deviceItem[string("deviceName")] = deviceInfo->getDeviceName();
        deviceItem[string("deviceId")] = deviceInfo->getDevicePID();
        deviceInfo->release();
        result->Success(deviceItem);
}
void SDKManager::setCurrentDeviceVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        int res = deviceManager->setCurrentDeviceVolume(static_cast<TXMediaDeviceType>(type), volume);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::getCurrentDeviceVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        int volume = deviceManager->getCurrentDeviceVolume(static_cast<TXMediaDeviceType>(type));
        result->Success(flutter::EncodableValue(volume));
}
void SDKManager::setCurrentDeviceMute(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        auto mute = std::get<bool>(methodParams[flutter::EncodableValue("mute")]);
        int res = deviceManager->setCurrentDeviceMute(static_cast<TXMediaDeviceType>(type), mute);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::getCurrentDeviceMute(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto type = std::get<int>(methodParams[flutter::EncodableValue("type")]);
        bool res = deviceManager->getCurrentDeviceMute(static_cast<TXMediaDeviceType>(type));
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::startMicDeviceTest(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto interval = std::get<int>(methodParams[flutter::EncodableValue("interval")]);
        int res = deviceManager->startMicDeviceTest(interval);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::stopMicDeviceTest(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        int res = deviceManager->stopMicDeviceTest();
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::startSpeakerDeviceTest(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto filePath = std::get<std::string>(methodParams[flutter::EncodableValue("filePath")]).c_str();
        int res = deviceManager->startSpeakerDeviceTest(filePath);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::stopSpeakerDeviceTest(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        int res = deviceManager->stopSpeakerDeviceTest();
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::setApplicationPlayVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto volume = std::get<int>(methodParams[flutter::EncodableValue("volume")]);
        int res = deviceManager->setApplicationPlayVolume(volume);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::getApplicationPlayVolume(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        int res = deviceManager->getApplicationPlayVolume();
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::setApplicationMuteState(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        auto methodParams = std::get<flutter::EncodableMap>(*method_call.arguments());
        auto bMute = std::get<bool>(methodParams[flutter::EncodableValue("bMute")]);
        int res = deviceManager->setApplicationMuteState(bMute);
        result->Success(flutter::EncodableValue(res));
}
void SDKManager::getApplicationMuteState(const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        bool res = deviceManager->getApplicationMuteState();
        result->Success(flutter::EncodableValue(res));
}

flutter::EncodableValue SDKManager::ToEncodableValue(ITRTCScreenCaptureSourceList* list) {
  flutter::EncodableMap result_map;

  int32_t count = static_cast<int32_t>(list->getCount());
  result_map[flutter::EncodableValue("count")] = flutter::EncodableValue(count);

  flutter::EncodableList encodable_list;

  for (int32_t i = 0; i < count; i++) {
    TRTCScreenCaptureSourceInfo info = list->getSourceInfo(i);
    flutter::EncodableValue encodable_value = SDKManager::ToEncodableValue(info);

    encodable_list.push_back(encodable_value);
  }

  result_map[flutter::EncodableValue("sourceInfo")] = flutter::EncodableValue(encodable_list);
  list->release();

  return flutter::EncodableValue(result_map);
}

flutter::EncodableValue SDKManager::ToEncodableValue(const TRTCScreenCaptureSourceInfo& info) {
  std::map<flutter::EncodableValue, flutter::EncodableValue> map;

  map[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(info.type));
  map[flutter::EncodableValue("sourceId")] = flutter::EncodableValue(static_cast<int64_t>(reinterpret_cast<intptr_t>(info.sourceId)));

  std::string source_name_string(info.sourceName);
  map[flutter::EncodableValue("sourceName")] = flutter::EncodableValue(source_name_string);

  map[flutter::EncodableValue("thumbBGRA")] = ToEncodableValue(info.thumbBGRA);
  map[flutter::EncodableValue("iconBGRA")] = ToEncodableValue(info.iconBGRA);
  map[flutter::EncodableValue("isMinimizeWindow")] = flutter::EncodableValue(info.isMinimizeWindow);
  map[flutter::EncodableValue("isMainScreen")] = flutter::EncodableValue(info.isMainScreen);
  map[flutter::EncodableValue("x")] = flutter::EncodableValue(info.x);
  map[flutter::EncodableValue("y")] = flutter::EncodableValue(info.y);

  int32_t signed_width = static_cast<int32_t>(info.width);
  int32_t signed_height = static_cast<int32_t>(info.height);

  map[flutter::EncodableValue("width")] = flutter::EncodableValue(signed_width);
  map[flutter::EncodableValue("height")] = flutter::EncodableValue(signed_height);

  return flutter::EncodableValue(map);
}

flutter::EncodableValue SDKManager::ToEncodableValue(const TRTCImageBuffer& imageBuffer) {
  std::map<flutter::EncodableValue, flutter::EncodableValue> map;

  std::vector<uint8_t> buffer_vector(imageBuffer.buffer, imageBuffer.buffer + imageBuffer.length);
  map[flutter::EncodableValue("buffer")] = flutter::EncodableValue(buffer_vector);

  int32_t signed_length = static_cast<int32_t>(imageBuffer.length);
  int32_t signed_width = static_cast<int32_t>(imageBuffer.width);
  int32_t signed_height = static_cast<int32_t>(imageBuffer.height);

  map[flutter::EncodableValue("length")] = flutter::EncodableValue(signed_length);
  map[flutter::EncodableValue("width")] = flutter::EncodableValue(signed_width);
  map[flutter::EncodableValue("height")] = flutter::EncodableValue(signed_height);

  return flutter::EncodableValue(map);
}

TRTCScreenCaptureSourceInfo SDKManager::FromEncodableValue(const flutter::EncodableValue& value) {
  TRTCScreenCaptureSourceInfo info;

  const flutter::EncodableMap& map = std::get<flutter::EncodableMap>(value);

  info.type = static_cast<TRTCScreenCaptureSourceType>(std::get<int>(map.at(flutter::EncodableValue("type"))));

  info.sourceId = reinterpret_cast<TXView>(static_cast<intptr_t>(std::get<int>(map.at(flutter::EncodableValue("sourceId")))));

  std::string source_name_string = std::get<std::string>(map.at(flutter::EncodableValue("sourceName")));
  info.sourceName = source_name_string.c_str();

  info.thumbBGRA = FromEncodableValueToBuffer(map.at(flutter::EncodableValue("thumbBGRA")));
  info.iconBGRA = FromEncodableValueToBuffer(map.at(flutter::EncodableValue("iconBGRA")));

  info.isMinimizeWindow = std::get<bool>(map.at(flutter::EncodableValue("isMinimizeWindow")));
  info.isMainScreen = std::get<bool>(map.at(flutter::EncodableValue("isMainScreen")));

  info.x = std::get<int>(map.at(flutter::EncodableValue("x")));
  info.y = std::get<int>(map.at(flutter::EncodableValue("y")));

  info.width = std::get<int>(map.at(flutter::EncodableValue("width")));
  info.height = std::get<int>(map.at(flutter::EncodableValue("height")));


  return info;
}

TRTCImageBuffer SDKManager::FromEncodableValueToBuffer(const flutter::EncodableValue& value) {  
  TRTCImageBuffer buffer;

  const flutter::EncodableMap& map = std::get<flutter::EncodableMap>(value);

  std::vector<uint8_t> buffer_vector = std::get<std::vector<uint8_t>>(map.at(flutter::EncodableValue("buffer")));
  buffer.buffer = reinterpret_cast<const char*>(buffer_vector.data());

  buffer.length = std::get<int>(map.at(flutter::EncodableValue("length")));
  buffer.width = std::get<int>(map.at(flutter::EncodableValue("width")));
  buffer.height = std::get<int>(map.at(flutter::EncodableValue("height")));
  
  return buffer;
}

TRTCScreenCaptureProperty SDKManager::FromEncodableValueProperty(const flutter::EncodableValue& value) {
  TRTCScreenCaptureProperty property;

  const flutter::EncodableMap& map = std::get<flutter::EncodableMap>(value);

  property.enableCaptureMouse = std::get<bool>(map.at(flutter::EncodableValue("enableCaptureMouse")));
  property.enableHighLight = std::get<bool>(map.at(flutter::EncodableValue("enableHighLight")));
  property.enableHighPerformance = std::get<bool>(map.at(flutter::EncodableValue("enableHighPerformance")));
  property.highLightColor = std::get<int>(map.at(flutter::EncodableValue("highLightColor")));
  property.highLightWidth = std::get<int>(map.at(flutter::EncodableValue("highLightWidth")));
  property.enableCaptureChildWindow = std::get<bool>(map.at(flutter::EncodableValue("enableCaptureChildWindow")));

  return property;
}

} // namespace tim_sdk_flutter