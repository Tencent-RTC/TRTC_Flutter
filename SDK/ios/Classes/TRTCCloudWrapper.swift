import Flutter
import TXLiteAVSDK_Professional


public class TRTCCloudWrapper: NSObject, TRTCCloudDelegate {
    public static let LISTENER_FUNC_NAME = "onListener"

    public static var cloudMap = [String: TRTCCloudWrapper]()
    
    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private var messager: FlutterBinaryMessenger {
        return registrar.messenger()
    }
    
    private let channelName: String
    private var cloudManager: CloudManager?
    private var listener: Listener?
	private var beautyManager: BeautyManager?
	private var deviceManager: DeviceManager?
	private var audioEffectManager: AudioEffectManager?
    
    private let basicMessageChannel: FlutterBasicMessageChannel
    
    init(registrar: FlutterPluginRegistrar) {
        channelName = "trtcCloudChannel"
        channel =  FlutterMethodChannel(name: "trtcCloudChannel", binaryMessenger: registrar.messenger())
        basicMessageChannel = FlutterBasicMessageChannel(name: channelName + "_basic_channel", binaryMessenger: registrar.messenger(), codec: FlutterJSONMessageCodec.sharedInstance())

        self.registrar = registrar
        super.init()
        TRTCCloudWrapper.cloudMap[channelName] = self
        self.channel.setMethodCallHandler({ [weak self] call, result in
            guard let self = self else { return }
            self.handle(call, result: result)
        })
    }
    
    init(channelName: String, registrar: FlutterPluginRegistrar, cloud: TRTCCloud) {
        channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
        basicMessageChannel = FlutterBasicMessageChannel(name: channelName + "_basic_channel", binaryMessenger: registrar.messenger(), codec: FlutterJSONMessageCodec.sharedInstance())
        cloudManager = CloudManager(registrar: registrar, channel: channel,channelName: channelName, basicChannel: basicMessageChannel, cloud: cloud)
        listener = Listener(channel: channel)
        cloudManager?.getTRTCCloud().delegate = listener
        
        self.registrar = registrar
        self.channelName = channelName
        super.init()
        
        channel.setMethodCallHandler({ [weak self] call, result in
            guard let self = self else { return }
            self.handle(call, result: result)
        })
    }
    
    public func getTRTCCloud() -> TRTCCloud {
        return cloudManager!.getTRTCCloud()
    }
	
	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		defer {
            Utils.txf_log_info(content: "TRTCCloudWrapper|channel=\(channelName)|method=\(call.method)|arguments: \(call.arguments as Any)")
		}
		
		switch call.method {
		case "sharedInstance":
			sharedInstance(call: call, result: result)
			break
		case "destroySharedInstance":
			destroySharedInstance(call: call, result: result)
			break
        case "createSubCloud":
            guard let cloudManager = cloudManager else { return }
            cloudManager.createSubCloud(call: call, result: result)
            break;
        case "destroySubCloud":
            guard let cloudManager = cloudManager else { return }
            cloudManager.destroySubCloud(call: call, result: result)
            break;
		case "enterRoom":
            guard let cloudManager = cloudManager else { return }
			cloudManager.enterRoom(call: call, result: result)
			break
		case "exitRoom":
            guard let cloudManager = cloudManager else { return }
			cloudManager.exitRoom(call: call, result: result)
			break
		case "switchRoom":
            guard let cloudManager = cloudManager else { return }
			cloudManager.switchRoom(call: call, result: result)
			break
		case "connectOtherRoom":
            guard let cloudManager = cloudManager else { return }
			cloudManager.connectOtherRoom(call: call, result: result)
			break
		case "disconnectOtherRoom":
            guard let cloudManager = cloudManager else { return }
			cloudManager.disconnectOtherRoom(call: call, result: result)
			break
		case "switchRole":
            guard let cloudManager = cloudManager else { return }
			cloudManager.switchRole(call: call, result: result)
			break
		case "setDefaultStreamRecvMode":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setDefaultStreamRecvMode(call: call, result: result)
			break
		case "enableCustomVideoProcess":
            guard let cloudManager = cloudManager else { return }
			cloudManager.enableCustomVideoProcess(call: call, result: result)
			break
		case "stopLocalPreview":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopLocalPreview(call: call, result: result)
			break
		case "muteRemoteAudio":
            guard let cloudManager = cloudManager else { return }
			cloudManager.muteRemoteAudio(call: call, result: result)
			break
		case "muteAllRemoteAudio":
            guard let cloudManager = cloudManager else { return }
			cloudManager.muteAllRemoteAudio(call: call, result: result)
			break
		case "setRemoteAudioVolume":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setRemoteAudioVolume(call: call, result: result)
			break
		case "setAudioCaptureVolume":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setAudioCaptureVolume(call: call, result: result)
			break
		case "getAudioCaptureVolume":
            guard let cloudManager = cloudManager else { return }
			cloudManager.getAudioCaptureVolume(call: call, result: result)
			break
		case "setAudioPlayoutVolume":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setAudioPlayoutVolume(call: call, result: result)
			break
		case "getAudioPlayoutVolume":
            guard let cloudManager = cloudManager else { return }
			cloudManager.getAudioPlayoutVolume(call: call, result: result)
			break
		case "stopRemoteView":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopRemoteView(call: call, result: result)
			break
		case "startLocalAudio":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startLocalAudio(call: call, result: result)
			break
		case "stopLocalAudio":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopLocalAudio(call: call, result: result)
			break
		case "setLocalRenderParams":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setLocalRenderParams(call: call, result: result)
			break
		case "setRemoteRenderParams":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setRemoteRenderParams(call: call, result: result)
			break
		case "stopAllRemoteView":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopAllRemoteView(call: call, result: result)
			break
		case "muteRemoteVideoStream":
            guard let cloudManager = cloudManager else { return }
			cloudManager.muteRemoteVideoStream(call: call, result: result)
			break
		case "muteAllRemoteVideoStreams":
            guard let cloudManager = cloudManager else { return }
			cloudManager.muteAllRemoteVideoStreams(call: call, result: result)
			break
		case "setVideoEncoderParam":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setVideoEncoderParam(call: call, result: result)
			break
		case "startPublishing":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startPublishing(call: call, result: result)
			break
		case "stopPublishing":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopPublishing(call: call, result: result)
			break
		case "startPublishCDNStream":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startPublishCDNStream(call: call, result: result)
			break
		case "stopPublishCDNStream":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopPublishCDNStream(call: call, result: result)
			break
		case "setMixTranscodingConfig":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setMixTranscodingConfig(call: call, result: result)
			break
		case "setNetworkQosParam":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setNetworkQosParam(call: call, result: result)
			break
		case "setVideoEncoderRotation":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setVideoEncoderRotation(call: call, result: result)
			break
		case "setVideoMuteImage":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setVideoMuteImage(call: call, result: result)
			break
		case "setVideoEncoderMirror":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setVideoEncoderMirror(call: call, result: result)
			break
		case "setGSensorMode":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setGSensorMode(call: call, result: result)
			break
		case "enableEncSmallVideoStream":
            guard let cloudManager = cloudManager else { return }
			cloudManager.enableEncSmallVideoStream(call: call, result: result)
			break
		case "setRemoteVideoStreamType":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setRemoteVideoStreamType(call: call, result: result)
			break
		case "snapshotVideo":
            guard let cloudManager = cloudManager else { return }
			cloudManager.snapshotVideo(call: call, result: result)
			break
		case "muteLocalAudio":
            guard let cloudManager = cloudManager else { return }
			cloudManager.muteLocalAudio(call: call, result: result)
			break
		case "muteLocalVideo":
            guard let cloudManager = cloudManager else { return }
			cloudManager.muteLocalVideo(call: call, result: result)
			break
		case "enableAudioVolumeEvaluation":
            guard let cloudManager = cloudManager else { return }
			cloudManager.enableAudioVolumeEvaluation(call: call, result: result)
			break
		case "startAudioRecording":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startAudioRecording(call: call, result: result)
			break
		case "stopAudioRecording":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopAudioRecording(call: call, result: result)
			break
		case "startLocalRecording":
            guard let cloudManager = cloudManager else { return }
            cloudManager.startLocalRecording(call: call, result: result)
            break
        case "stopLocalRecording":
            guard let cloudManager = cloudManager else { return }
            cloudManager.stopLocalRecording(call: call, result: result)
            break
		case "startRemoteView":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startRemoteView(call: call, result: result)
			break
		case "startLocalPreview":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startLocalPreview(call: call, result: result)
			break
        case "setSystemAudioLoopbackVolume":
            guard let cloudManager = cloudManager else { return }
            cloudManager.setSystemAudioLoopbackVolume(call: call, result: result)
            break
        case "setAudioFrameListener":
            guard let cloudManager = cloudManager else { return }
            cloudManager.setAudioFrameListener(call: call, result: result)
            break
		case "switchCamera":
            guard let deviceManager = deviceManager else { return }
			deviceManager.switchCamera(call: call, result: result)
			break
		case "isFrontCamera":
			guard let deviceManager = deviceManager else { return }
            deviceManager.isFrontCamera(call: call, result: result)
			break
		case "getCameraZoomMaxRatio":
			guard let deviceManager = deviceManager else { return }
            deviceManager.getCameraZoomMaxRatio(call: call, result: result)
			break
		case "setCameraZoomRatio":
			guard let deviceManager = deviceManager else { return }
            deviceManager.setCameraZoomRatio(call: call, result: result)
			break
		case "enableCameraAutoFocus":
			guard let deviceManager = deviceManager else { return }
            deviceManager.enableCameraAutoFocus(call: call, result: result)
			break
		case "enableCameraTorch":
			guard let deviceManager = deviceManager else { return }
            deviceManager.enableCameraTorch(call: call, result: result)
			break
		case "setCameraFocusPosition":
			guard let deviceManager = deviceManager else { return }
            deviceManager.setCameraFocusPosition(call: call, result: result)
			break
		case "isAutoFocusEnabled":
			guard let deviceManager = deviceManager else { return }
            deviceManager.isAutoFocusEnabled(call: call, result: result)
			break
		case "setSystemVolumeType":
			guard let deviceManager = deviceManager else { return }
            deviceManager.setSystemVolumeType(call: call, result: result)
			break
		case "setAudioRoute":
			guard let deviceManager = deviceManager else { return }
            deviceManager.setAudioRoute(call: call, result: result)
			break
		case "getBeautyManager":
			self.getBeautyManager(call: call, result: result)
			break
		case "getDeviceManager":
			self.getDeviceManager(call: call, result: result)
			break
		case "getAudioEffectManager":
			self.getAudioEffectManager(call: call, result: result)
			break
		case "setWatermark":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setWatermark(call: call, result: result)
			break
		case "startScreenCaptureInApp":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startScreenCaptureInApp(call: call, result: result)
			break
		case "startScreenCaptureByReplaykit":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startScreenCaptureByReplaykit(call: call, result: result)
			break
		case "startScreenCapture":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startScreenCapture(call: call, result: result)
			break
		case "stopScreenCapture":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopScreenCapture(call: call, result: result)
			break
		case "pauseScreenCapture":
            guard let cloudManager = cloudManager else { return }
			cloudManager.pauseScreenCapture(call: call, result: result)
			break
		case "resumeScreenCapture":
            guard let cloudManager = cloudManager else { return }
			cloudManager.resumeScreenCapture(call: call, result: result)
			break
		// case "sendCustomVideoData":
		// 	cloudManager!.sendCustomVideoData(call: call, result: result)
		// 	break
		case "sendCustomCmdMsg":
            guard let cloudManager = cloudManager else { return }
			cloudManager.sendCustomCmdMsg(call: call, result: result)
			break
		case "sendSEIMsg":
            guard let cloudManager = cloudManager else { return }
			cloudManager.sendSEIMsg(call: call, result: result)
			break
		case "startSpeedTest":
            guard let cloudManager = cloudManager else { return }
			cloudManager.startSpeedTest(call: call, result: result)
			break
        case "startSpeedTestWithParams":
            guard let cloudManager = cloudManager else { return }
            cloudManager.startSpeedTestWithParams(call: call, result: result)
            break
		case "stopSpeedTest":
            guard let cloudManager = cloudManager else { return }
			cloudManager.stopSpeedTest(call: call, result: result)
			break
		case "setLocalVideoRenderListener":
            guard let cloudManager = cloudManager else { return }
      		cloudManager.setLocalVideoRenderListener(call: call, result: result)
			break
		case "setLocalVideoProcessListener":
            guard let cloudManager = cloudManager else { return }
			cloudManager.setLocalVideoProcessListener(call: call, result: result)
			break
		case "setRemoteVideoRenderListener":
            guard let cloudManager = cloudManager else { return }
            cloudManager.setRemoteVideoRenderListener(call: call, result: result)
			break
        case "unregisterTexture":
            guard let cloudManager = cloudManager else { return }
            cloudManager.unregisterTexture(call: call, result: result)
            break
		case "getSDKVersion":
			self.getSDKVersion(call: call, result: result)
			break
		case "setLogCompressEnabled":
			self.setLogCompressEnabled(call: call, result: result)
			break
		case "setLogDirPath":
			self.setLogDirPath(call: call, result: result)
			break
		case "setLogLevel":
			self.setLogLevel(call: call, result: result)
			break
		case "callExperimentalAPI":
            guard let cloudManager = cloudManager else { return }
            cloudManager.callExperimentalAPI(call: call, result: result)
			break
		case "setConsoleEnabled":
			self.setConsoleEnabled(call: call, result: result)
			break
		case "showDebugView":
            guard let cloudManager = cloudManager else { return }
			cloudManager.showDebugView(call: call, result: result)
			break
        case "startPublishMediaStream":
            guard let cloudManager = cloudManager else { return }
            cloudManager.startPublishMediaStream(call: call, result: result)
            break
        case "updatePublishMediaStream":
            guard let cloudManager = cloudManager else { return }
            cloudManager.updatePublishMediaStream(call: call, result: result)
            break
        case "stopPublishMediaStream":
            guard let cloudManager = cloudManager else { return }
            cloudManager.stopPublishMediaStream(call: call, result: result)
            break
		case "setBeautyStyle":
            guard let beautyManager = beautyManager else { return }
			beautyManager.setBeautyStyle(call: call, result: result)
			break
		case "setBeautyLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setBeautyLevel(call: call, result: result)
			break
		case "setWhitenessLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setWhitenessLevel(call: call, result: result)
			break
		case "enableSharpnessEnhancement":
			guard let beautyManager = beautyManager else { return }
            beautyManager.enableSharpnessEnhancement(call: call, result: result)
			break
		case "setRuddyLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setRuddyLevel(call: call, result: result)
			break
		case "setFilter":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setFilter(call: call, result: result)
			break
		case "setFilterStrength":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setFilterStrength(call: call, result: result)
			break
		case "setEyeScaleLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setEyeScaleLevel(call: call, result: result)
			break
		case "setFaceSlimLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setFaceSlimLevel(call: call, result: result)
			break
		case "setFaceVLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setFaceVLevel(call: call, result: result)
			break
		case "setChinLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setChinLevel(call: call, result: result)
			break
		case "setFaceShortLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setFaceShortLevel(call: call, result: result)
			break
		case "setNoseSlimLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setNoseSlimLevel(call: call, result: result)
			break
		case "setEyeLightenLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setEyeLightenLevel(call: call, result: result)
			break
		case "setToothWhitenLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setToothWhitenLevel(call: call, result: result)
			break
		case "setWrinkleRemoveLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setWrinkleRemoveLevel(call: call, result: result)
			break
		case "setPounchRemoveLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setPounchRemoveLevel(call: call, result: result)
			break
		case "setSmileLinesRemoveLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setSmileLinesRemoveLevel(call: call, result: result)
			break
		case "setForeheadLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setForeheadLevel(call: call, result: result)
			break
		case "setEyeDistanceLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setEyeDistanceLevel(call: call, result: result)
			break
		case "setEyeAngleLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setEyeAngleLevel(call: call, result: result)
			break
		case "setMouthShapeLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setMouthShapeLevel(call: call, result: result)
			break
		case "setNoseWingLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setNoseWingLevel(call: call, result: result)
			break
		case "setNosePositionLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setNosePositionLevel(call: call, result: result)
			break
		case "setLipsThicknessLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setLipsThicknessLevel(call: call, result: result)
			break
		case "setFaceBeautyLevel":
			guard let beautyManager = beautyManager else { return }
            beautyManager.setFaceBeautyLevel(call: call, result: result)
			break
		case "enableVoiceEarMonitor":
            guard let audioEffectManager = audioEffectManager else { return }
			audioEffectManager.enableVoiceEarMonitor(call: call, result: result)
			break
		case "setVoiceEarMonitorVolume":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setVoiceEarMonitorVolume(call: call, result: result)
			break
		case "setVoiceReverbType":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setVoiceReverbType(call: call, result: result)
			break
		case "setVoiceChangerType":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setVoiceChangerType(call: call, result: result)
			break
		case "setVoiceCaptureVolume":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setVoiceCaptureVolume(call: call, result: result)
			break
		case "setMusicObserver":
			// self.setMusicObserver(call: call, result: result)
			break
		case "startPlayMusic":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.startPlayMusic(call: call, result: result)
			break
		case "stopPlayMusic":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.stopPlayMusic(call: call, result: result)
			break
		case "pausePlayMusic":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.pausePlayMusic(call: call, result: result)
			break
		case "resumePlayMusic":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.resumePlayMusic(call: call, result: result)
			break
		case "setMusicPublishVolume":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setMusicPublishVolume(call: call, result: result)
			break
		case "setMusicPlayoutVolume":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setMusicPlayoutVolume(call: call, result: result)
			break
		case "setAllMusicVolume":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setAllMusicVolume(call: call, result: result)
			break
		case "setMusicPitch":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setMusicPitch(call: call, result: result)
			break
		case "setMusicSpeedRate":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setMusicSpeedRate(call: call, result: result)
			break
		case "getMusicCurrentPosInMS":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.getMusicCurrentPosInMS(call: call, result: result)
			break
		case "seekMusicToPosInMS":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.seekMusicToPosInMS(call: call, result: result)
			break
		case "getMusicDurationInMS":
			guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.getMusicDurationInMS(call: call, result: result)
			break
        case "setVoicePitch":
            guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.setVoicePitch(call: call, result: result)
            break
        case "preloadMusic":
            guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.preloadMusic(call: call, result: result)
            break
		default:
            Utils.txf_log_error(content: "TRTCCloudWrapper|channel=\(channelName)|method=\(call.method)|arguments=\(call.arguments as Any)|error={errCode: -1, errMsg: method not Implemented}")
			result(FlutterMethodNotImplemented)
		}
	}
	
	/**
	* 启用或禁用控制台日志打印
	*/
	public func setConsoleEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enabled = Utils.getParamByKey(call: call, result: result, param: "enabled") as? Bool {
			TRTCCloud.setConsoleEnabled(enabled)
			result(nil)
		}
	}
	
	/**
	* 启用或禁用 Log 的本地压缩。
	*/
	public func setLogCompressEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enabled = Utils.getParamByKey(call: call, result: result, param: "enabled") as? Bool {
			TRTCCloud.setLogCompressEnabled(enabled)
			result(nil)
		}
	}
	
	/**
	* 启用或禁用 Log 的本地压缩。
	*/
	public func setLogDirPath(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let path = Utils.getParamByKey(call: call, result: result, param: "path") as? String {
			TRTCCloud.setLogDirPath(path)
			result(nil)
		}
	}
	
	/**
	* 设置 Log 输出级别
	*/
	public func setLogLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let level = Utils.getParamByKey(call: call, result: result, param: "level") as? Int {
            TRTCCloud.setLogLevel(TRTCLogLevel(rawValue: level) ?? .none)
			result(nil)
		}
	}
	
	/**
	* 创建 TRTCCloud 单例
	*/
	public func sharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
		listener = Listener(channel: channel)
        let cloud = TRTCCloud.sharedInstance()
        cloudManager = CloudManager(registrar: registrar, channel: channel,channelName: channelName, basicChannel: basicMessageChannel, cloud: cloud)
        TRTCCloudWrapper.cloudMap[channelName] = self
        TRTCCloud.sharedInstance().delegate = listener
		result(nil)
	}
	
	/**
	* 销毁 TRTCCloud 单例
	*/
	public func destroySharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TRTCCloudWrapper.cloudMap[channelName] = nil
		TRTCCloud.sharedInstance().delegate = nil
		TRTCCloud.destroySharedIntance()
		listener = nil
		beautyManager = nil
		cloudManager = nil
		deviceManager = nil
		audioEffectManager = nil
		result(nil)
	}
    
    public func release(channelName: String) {
        TRTCCloudWrapper.cloudMap[channelName]?.channel.setMethodCallHandler(nil)
        TRTCCloudWrapper.cloudMap[channelName] = nil
        listener = nil
        beautyManager = nil
        cloudManager = nil
        deviceManager = nil
        audioEffectManager = nil
    }
	
	/**
	* 获取美颜管理对象
	*/
	public func getBeautyManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
        beautyManager = BeautyManager(registrar: registrar, cloud: cloudManager!.getTRTCCloud())
		result(nil)
	}
	
	/**
	* 获取设备管理对象
	*/
	public func getDeviceManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		deviceManager = DeviceManager(cloud: cloudManager!.getTRTCCloud())
		result(nil)
	}
	
	/**
	* 获取音效管理对象
	*/
	public func getAudioEffectManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
        audioEffectManager = AudioEffectManager(channel: channel, cloud: cloudManager!.getTRTCCloud())
		result(nil)
	}
		
	/**
	* 获取 SDK 版本信息
	*/
	public func getSDKVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(TRTCCloud.getSDKVersion())
	}
}
