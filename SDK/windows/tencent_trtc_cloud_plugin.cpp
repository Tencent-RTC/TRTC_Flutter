#include "include/tencent_trtc_cloud/tencent_trtc_cloud_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <string>
#include <map>
#include <memory>
#include <sstream>

#include "include/TRTC/ITRTCCloud.h"
#include "include/TRTC/TRTCCloudDef.h"

#include "src/trtc_cloud.h"

using trtc_sdk_flutter::SDKManager;

namespace {

class TencentTrtcCloudPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TencentTrtcCloudPlugin();

  virtual ~TencentTrtcCloudPlugin();

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  
  private:
    bool isInit_ = false;
    UP<SDKManager> sdk_manager_;
};

// static
void TencentTrtcCloudPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      MK_SP<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "trtcCloudChannel",
          &flutter::StandardMethodCodec::GetInstance());
  auto plugin = std::make_unique<TencentTrtcCloudPlugin>();
  plugin->sdk_manager_ = std::make_unique<SDKManager>(channel, registrar->texture_registrar());

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

TencentTrtcCloudPlugin::TencentTrtcCloudPlugin() {}

TencentTrtcCloudPlugin::~TencentTrtcCloudPlugin() {}

void TencentTrtcCloudPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string methodName = method_call.method_name();

  if (methodName.compare("getPlatformVersion") == 0) {
    std::ostringstream version_stream;
    version_stream << "Windows ";
    if (IsWindows10OrGreater()) {
      version_stream << "10+";
    } else if (IsWindows8OrGreater()) {
      version_stream << "8";
    } else if (IsWindows7OrGreater()) {
      version_stream << "7";
    }
    result->Success(flutter::EncodableValue(version_stream.str()));
    return;
  }

  if(methodName.compare("sharedInstance") == 0) {
    isInit_ = true;
    sdk_manager_->sharedInstance(method_call, std::move(result));
    return;
  }

  // 未进行单例初始化
  if(!isInit_) {
    result->Success(nullptr);
    return;
  }

  if(methodName.compare("destroySharedInstance") == 0) {
    isInit_ = false;
    sdk_manager_->destroySharedInstance(method_call, std::move(result));
  } else if(methodName.compare("getSDKVersion") == 0) {
    sdk_manager_->getSDKVersion(method_call, std::move(result));
  } else if(methodName.compare("enterRoom") == 0) {
    sdk_manager_->enterRoom(method_call, std::move(result));
  } else if(methodName.compare("switchRoom") == 0) {
    sdk_manager_->switchRoom(method_call, std::move(result));
  } else if(methodName.compare("exitRoom") == 0) {
    sdk_manager_->exitRoom(method_call, std::move(result));
  } else if(methodName.compare("connectOtherRoom") == 0) {
    sdk_manager_->connectOtherRoom(method_call, std::move(result));
  } else if(methodName.compare("disconnectOtherRoom") == 0) {
    sdk_manager_->disconnectOtherRoom(method_call, std::move(result));
  } else if(methodName.compare("switchRole") == 0) {
    sdk_manager_->switchRole(method_call, std::move(result));
  } else if(methodName.compare("setDefaultStreamRecvMode") == 0) {
    sdk_manager_->setDefaultStreamRecvMode(method_call, std::move(result));
  } else if(methodName.compare("startPublishing") == 0) {
    sdk_manager_->startPublishing(method_call, std::move(result));
  } else if(methodName.compare("stopPublishing") == 0) {
    sdk_manager_->stopPublishing(method_call, std::move(result));
  } else if(methodName.compare("startPublishCDNStream") == 0) {
    sdk_manager_->startPublishCDNStream(method_call, std::move(result));
  } else if(methodName.compare("stopPublishCDNStream") == 0) {
    sdk_manager_->stopPublishCDNStream(method_call, std::move(result));
  } else if(methodName.compare("setMixTranscodingConfig") == 0) {
    sdk_manager_->setMixTranscodingConfig(method_call, std::move(result));
  } else if(methodName.compare("startLocalPreview") == 0) {
    sdk_manager_->startLocalPreview(method_call, std::move(result));
  } else if(methodName.compare("stopLocalPreview") == 0) {
    sdk_manager_->stopLocalPreview(method_call, std::move(result));
  } else if(methodName.compare("startRemoteView") == 0) {
    sdk_manager_->startRemoteView(method_call, std::move(result));
  } else if(methodName.compare("stopRemoteView") == 0) {
    sdk_manager_->stopRemoteView(method_call, std::move(result));
  } else if(methodName.compare("stopAllRemoteView") == 0) {
    sdk_manager_->stopAllRemoteView(method_call, std::move(result));
  } else if(methodName.compare("muteRemoteAudio") == 0) {
    sdk_manager_->muteRemoteAudio(method_call, std::move(result));
  } else if(methodName.compare("muteAllRemoteAudio") == 0) {
    sdk_manager_->muteAllRemoteAudio(method_call, std::move(result));
  } else if(methodName.compare("setRemoteAudioVolume") == 0) {
    sdk_manager_->setRemoteAudioVolume(method_call, std::move(result));
  } else if(methodName.compare("setAudioCaptureVolume") == 0) {
    sdk_manager_->setAudioCaptureVolume(method_call, std::move(result));
  } else if(methodName.compare("getAudioCaptureVolume") == 0) {
    sdk_manager_->getAudioCaptureVolume(method_call, std::move(result));
  } else if(methodName.compare("setAudioPlayoutVolume") == 0) {
    sdk_manager_->setAudioPlayoutVolume(method_call, std::move(result));
  } else if(methodName.compare("getAudioPlayoutVolume") == 0) {
    sdk_manager_->getAudioPlayoutVolume(method_call, std::move(result));
  } else if(methodName.compare("startLocalAudio") == 0) {
    sdk_manager_->startLocalAudio(method_call, std::move(result));
  } else if(methodName.compare("stopLocalAudio") == 0) {
    sdk_manager_->stopLocalAudio(method_call, std::move(result));
  } else if(methodName.compare("muteRemoteVideoStream") == 0) {
    sdk_manager_->muteRemoteVideoStream(method_call, std::move(result));
  } else if(methodName.compare("muteAllRemoteVideoStreams") == 0) {
    sdk_manager_->muteAllRemoteVideoStreams(method_call, std::move(result));
  } else if(methodName.compare("setVideoEncoderParam") == 0) {
    sdk_manager_->setVideoEncoderParam(method_call, std::move(result));
  } else if(methodName.compare("setNetworkQosParam") == 0) {
    sdk_manager_->setNetworkQosParam(method_call, std::move(result));
  } else if(methodName.compare("setLocalRenderParams") == 0) {
    sdk_manager_->setLocalRenderParams(method_call, std::move(result));
  } else if(methodName.compare("setRemoteRenderParams") == 0) {
    sdk_manager_->setRemoteRenderParams(method_call, std::move(result));
  } else if(methodName.compare("setVideoEncoderRotation") == 0) {
    sdk_manager_->setVideoEncoderRotation(method_call, std::move(result));
  } else if(methodName.compare("setVideoEncoderMirror") == 0) {
    sdk_manager_->setVideoEncoderMirror(method_call, std::move(result));
  } else if(methodName.compare("enableEncSmallVideoStream") == 0) {
    sdk_manager_->enableEncSmallVideoStream(method_call, std::move(result));
  } else if(methodName.compare("setRemoteVideoStreamType") == 0) {
    sdk_manager_->setRemoteVideoStreamType(method_call, std::move(result));
  } else if(methodName.compare("snapshotVideo") == 0) {
    sdk_manager_->snapshotVideo(method_call, std::move(result));
  } else if(methodName.compare("setLocalVideoRenderListener") == 0) {
    sdk_manager_->setLocalVideoRenderListener(method_call, std::move(result));
  } else if(methodName.compare("setRemoteVideoRenderListener") == 0) {
    sdk_manager_->setRemoteVideoRenderListener(method_call, std::move(result));
  } else if(methodName.compare("muteLocalAudio") == 0) {
    sdk_manager_->muteLocalAudio(method_call, std::move(result));
  } else if(methodName.compare("muteLocalVideo") == 0) {
    sdk_manager_->muteLocalVideo(method_call, std::move(result));
  } else if(methodName.compare("enableAudioVolumeEvaluation") == 0) {
    sdk_manager_->enableAudioVolumeEvaluation(method_call, std::move(result));
  } else if(methodName.compare("startAudioRecording") == 0) {
    sdk_manager_->startAudioRecording(method_call, std::move(result));
  } else if(methodName.compare("stopAudioRecording") == 0) {
    sdk_manager_->stopAudioRecording(method_call, std::move(result));
  } else if(methodName.compare("startLocalRecording") == 0) {
    sdk_manager_->startLocalRecording(method_call, std::move(result));
  } else if(methodName.compare("stopLocalRecording") == 0) {
    sdk_manager_->stopLocalRecording(method_call, std::move(result));
  } else if(methodName.compare("setSystemVolumeType") == 0) {
    sdk_manager_->setSystemVolumeType(method_call, std::move(result));
  } else if(methodName.compare("getDeviceManager") == 0) {
    sdk_manager_->getDeviceManager(method_call, std::move(result));
  } else if(methodName.compare("getBeautyManager") == 0) {
    sdk_manager_->getBeautyManager(method_call, std::move(result));
  } else if(methodName.compare("getAudioEffectManager") == 0) {
    sdk_manager_->getAudioEffectManager(method_call, std::move(result));
  } else if(methodName.compare("getScreenCaptureSources") == 0) {
    sdk_manager_->getScreenCaptureSources(method_call, std::move(result));
  } else if(methodName.compare("selectScreenCaptureTarget") == 0) {
    sdk_manager_->selectScreenCaptureTarget(method_call, std::move(result));
  } else if(methodName.compare("startScreenCapture") == 0) {
    sdk_manager_->startScreenCapture(method_call, std::move(result));
  } else if(methodName.compare("stopScreenCapture") == 0) {
    sdk_manager_->stopScreenCapture(method_call, std::move(result));
  } else if(methodName.compare("pauseScreenCapture") == 0) {
    sdk_manager_->pauseScreenCapture(method_call, std::move(result));
  } else if(methodName.compare("resumeScreenCapture") == 0) {
    sdk_manager_->resumeScreenCapture(method_call, std::move(result));
  } else if(methodName.compare("setWatermark") == 0) {
    sdk_manager_->setWatermark(method_call, std::move(result));
  } else if(methodName.compare("sendCustomCmdMsg") == 0) {
    sdk_manager_->sendCustomCmdMsg(method_call, std::move(result));
  } else if(methodName.compare("sendSEIMsg") == 0) {
    sdk_manager_->sendSEIMsg(method_call, std::move(result));
  } else if(methodName.compare("startSpeedTest") == 0) {
    sdk_manager_->startSpeedTest(method_call, std::move(result));
  } else if(methodName.compare("startSpeedTestWithParams") == 0) {
      sdk_manager_->startSpeedTestWithParams(method_call, std::move(result));
  } else if(methodName.compare("stopSpeedTest") == 0) {
    sdk_manager_->stopSpeedTest(method_call, std::move(result));
  } else if(methodName.compare("setLogLevel") == 0) {
    sdk_manager_->setLogLevel(method_call, std::move(result));
  } else if(methodName.compare("setConsoleEnabled") == 0) {
    sdk_manager_->setConsoleEnabled(method_call, std::move(result));
  } else if(methodName.compare("setLogDirPath") == 0) {
    sdk_manager_->setLogDirPath(method_call, std::move(result));
  } else if(methodName.compare("setLogCompressEnabled") == 0) {
    sdk_manager_->setLogCompressEnabled(method_call, std::move(result));
  } else if(methodName.compare("callExperimentalAPI") == 0) {
    sdk_manager_->callExperimentalAPI(method_call, std::move(result));
  } else if(methodName.compare("setBeautyStyle") == 0) {
    sdk_manager_->setBeautyStyle(method_call, std::move(result));
  } else if(methodName.compare("setBeautyLevel") == 0) {
    sdk_manager_->setBeautyLevel(method_call, std::move(result));
  } else if(methodName.compare("setWhitenessLevel") == 0) {
    sdk_manager_->setWhitenessLevel(method_call, std::move(result));
  } else if(methodName.compare("setRuddyLevel") == 0) {
    sdk_manager_->setRuddyLevel(method_call, std::move(result));
  } else if(methodName.compare("startPlayMusic") == 0) {
    sdk_manager_->startPlayMusic(method_call, std::move(result));
  } else if(methodName.compare("stopPlayMusic") == 0) {
    sdk_manager_->stopPlayMusic(method_call, std::move(result));
  } else if(methodName.compare("pausePlayMusic") == 0) {
    sdk_manager_->pausePlayMusic(method_call, std::move(result));
  } else if(methodName.compare("resumePlayMusic") == 0) {
    sdk_manager_->resumePlayMusic(method_call, std::move(result));
  } else if(methodName.compare("setMusicPublishVolume") == 0) {
    sdk_manager_->setMusicPublishVolume(method_call, std::move(result));
  } else if(methodName.compare("setMusicPlayoutVolume") == 0) {
    sdk_manager_->setMusicPlayoutVolume(method_call, std::move(result));
  } else if(methodName.compare("setAllMusicVolume") == 0) {
    sdk_manager_->setAllMusicVolume(method_call, std::move(result));
  } else if(methodName.compare("setMusicPitch") == 0) {
    sdk_manager_->setMusicPitch(method_call, std::move(result));
  } else if(methodName.compare("setMusicSpeedRate") == 0) {
    sdk_manager_->setMusicSpeedRate(method_call, std::move(result));
  } else if(methodName.compare("getMusicCurrentPosInMS") == 0) {
    sdk_manager_->getMusicCurrentPosInMS(method_call, std::move(result));
  } else if(methodName.compare("seekMusicToPosInMS") == 0) {
    sdk_manager_->seekMusicToPosInMS(method_call, std::move(result));
  } else if(methodName.compare("getMusicDurationInMS") == 0) {
    sdk_manager_->getMusicDurationInMS(method_call, std::move(result));
  } else if(methodName.compare("setVoiceReverbType") == 0) {
    sdk_manager_->setVoiceReverbType(method_call, std::move(result));
  } else if(methodName.compare("setVoiceChangerType") == 0) {
    sdk_manager_->setVoiceChangerType(method_call, std::move(result));
  } else if(methodName.compare("setVoiceCaptureVolume") == 0) {
    sdk_manager_->setVoiceCaptureVolume(method_call, std::move(result));
  } else if(methodName.compare("preloadMusic") == 0) {
    sdk_manager_->preloadMusic(method_call, std::move(result));
  } else if(methodName.compare("getDevicesList") == 0) {
    sdk_manager_->getDevicesList(method_call, std::move(result));
  } else if(methodName.compare("setCurrentDevice") == 0) {
    sdk_manager_->setCurrentDevice(method_call, std::move(result));
  } else if(methodName.compare("enableFollowingDefaultAudioDevice") == 0) {
    sdk_manager_->enableFollowingDefaultAudioDevice(method_call, std::move(result));
  } else if(methodName.compare("getCurrentDevice") == 0) {
    sdk_manager_->getCurrentDevice(method_call, std::move(result));
  } else if(methodName.compare("setCurrentDeviceVolume") == 0) {
    sdk_manager_->setCurrentDeviceVolume(method_call, std::move(result));
  } else if(methodName.compare("getCurrentDeviceVolume") == 0) {
    sdk_manager_->getCurrentDeviceVolume(method_call, std::move(result));
  } else if(methodName.compare("setCurrentDeviceMute") == 0) {
    sdk_manager_->setCurrentDeviceMute(method_call, std::move(result));
  } else if(methodName.compare("getCurrentDeviceMute") == 0) {
    sdk_manager_->getCurrentDeviceMute(method_call, std::move(result));
  } else if(methodName.compare("startMicDeviceTest") == 0) {
    sdk_manager_->startMicDeviceTest(method_call, std::move(result));
  } else if(methodName.compare("stopMicDeviceTest") == 0) {
    sdk_manager_->stopMicDeviceTest(method_call, std::move(result));
  } else if(methodName.compare("startSpeakerDeviceTest") == 0) {
    sdk_manager_->startSpeakerDeviceTest(method_call, std::move(result));
  } else if(methodName.compare("stopSpeakerDeviceTest") == 0) {
    sdk_manager_->stopSpeakerDeviceTest(method_call, std::move(result));
  } else if(methodName.compare("setApplicationPlayVolume") == 0) {
    sdk_manager_->setApplicationPlayVolume(method_call, std::move(result));
  } else if(methodName.compare("getApplicationPlayVolume") == 0) {
    sdk_manager_->getApplicationPlayVolume(method_call, std::move(result));
  } else if(methodName.compare("setApplicationMuteState") == 0) {
    sdk_manager_->setApplicationMuteState(method_call, std::move(result));
  } else if(methodName.compare("getApplicationMuteState") == 0) {
    sdk_manager_->getApplicationMuteState(method_call, std::move(result));
  } else if(methodName.compare("unregisterTexture") == 0) {
    sdk_manager_->unregisterTexture(method_call, std::move(result));
  } else if(methodName.compare("startSystemAudioLoopback") == 0) {
    sdk_manager_->startSystemAudioLoopback(method_call, std::move(result));
  } else if(methodName.compare("stopSystemAudioLoopback") == 0) {
    sdk_manager_->stopSystemAudioLoopback(method_call, std::move(result));
  } else if(methodName.compare("setSystemAudioLoopbackVolume") == 0) {
    sdk_manager_->setSystemAudioLoopbackVolume(method_call, std::move(result));
  }
  
  
  else {
    result->NotImplemented();
  }
}

}  // namespace

void TencentTrtcCloudPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  TencentTrtcCloudPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
