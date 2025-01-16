import Cocoa
import FlutterMacOS
import TXLiteAVSDK_TRTC_Mac

public class TencentTRTCCloud: NSObject, FlutterPlugin ,TRTCCloudDelegate{
    
    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    
    private var cloudManager: CloudManager?
    private var listener: Listener?
    private var beautyManager: BeautyManager?
    private var deviceManager: DeviceManager?
    private var audioEffectManager: AudioEffectManager?

	private static let LISTENER_FUNC_NAME = "onListener"
    
    init(registrar: FlutterPluginRegistrar) {
        self.channel =  FlutterMethodChannel(name: "trtcCloudChannel", binaryMessenger: registrar.messenger)
        self.registrar = registrar
        super.init()
    }
	
	public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = TencentTRTCCloud(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
	}
	
	public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
		defer {
			CommonUtils.logFlutterMethodCall(call)
		}
		
		switch call.method {
		case "sharedInstance":
			sharedInstance(call: call, result: result)
			break
		case "destroySharedInstance":
			destroySharedInstance(call: call, result: result)
			break
        case "getBeautyManager":
            getBeautyManager(call: call, result: result)
            break
        case "getDeviceManager":
            getDeviceManager(call: call, result: result)
            break
        case "getAudioEffectManager":
            getAudioEffectManager(call: call, result: result)
            break
        case "getSDKVersion":
            getSDKVersion(call: call, result: result)
            break
        case "setLogCompressEnabled":
            setLogCompressEnabled(call: call, result: result)
            break
        case "setLogDirPath":
            setLogDirPath(call: call, result: result)
            break
        case "setLogLevel":
            setLogLevel(call: call, result: result)
            break
        case "setConsoleEnabled":
            setConsoleEnabled(call: call, result: result)
            break

        //MARK: cloudManager
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
        case "setRemoteVideoRenderListener":
            guard let cloudManager = cloudManager else { return }
            cloudManager.setRemoteVideoRenderListener(call: call, result: result)
            break
        case "unregisterTexture":
            guard let cloudManager = cloudManager else { return }
            cloudManager.unregisterTexture(call: call, result: result)
            break
        case "callExperimentalAPI":
            guard let cloudManager = cloudManager else { return }
            cloudManager.callExperimentalAPI(call: call, result: result)
            break
        case "showDebugView":
            guard let cloudManager = cloudManager else { return }
            cloudManager.showDebugView(call: call, result: result)
            break
        case "startSystemAudioLoopback":
            guard let cloudManager = cloudManager else { return }
            cloudManager.startSystemAudioLoopback(call: call, result: result)
            break
        case "stopSystemAudioLoopback":
            guard let cloudManager = cloudManager else { return }
            cloudManager.stopSystemAudioLoopback(call: call, result: result)
            break
        case "setSystemAudioLoopbackVolume":
            guard let cloudManager = cloudManager else { return }
            cloudManager.setSystemAudioLoopbackVolume(call: call, result: result)
            break

        //MARK: deviceManager
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
        case "enableFollowingDefaultAudioDevice":
            guard let deviceManager = deviceManager else {return}
            deviceManager.enableFollowingDefaultAudioDevice(call: call, result: result)
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
        case "getDevicesList":
            guard let deviceManager = deviceManager else { return }
            deviceManager.getDevicesList(call: call, result: result)
            break
        case "setCurrentDevice":
            guard let deviceManager = deviceManager else { return }
            deviceManager.setCurrentDevice(call: call, result: result)
            break
        case "getCurrentDevice":
            guard let deviceManager = deviceManager else { return }
            deviceManager.getCurrentDevice(call: call, result: result)
            break
        case "setCurrentDeviceVolume":
            guard let deviceManager = deviceManager else { return }
            deviceManager.setCurrentDeviceVolume(call: call, result: result)
            break
        case "getCurrentDeviceVolume":
            guard let deviceManager = deviceManager else { return }
            deviceManager.getCurrentDeviceVolume(call: call, result: result)
            break
        case "setCurrentDeviceMute":
            guard let deviceManager = deviceManager else { return }
            deviceManager.setCurrentDeviceMute(call: call, result: result)
            break
        case "getCurrentDeviceMute":
            guard let deviceManager = deviceManager else { return }
            deviceManager.getCurrentDeviceMute(call: call, result: result)
            break
        case "startMicDeviceTest":
            guard let deviceManager = deviceManager else { return }
            deviceManager.startMicDeviceTest(call: call, result: result)
            break
        case "stopMicDeviceTest":
            guard let deviceManager = deviceManager else { return }
            deviceManager.stopMicDeviceTest(call: call, result: result)
            break
        case "startSpeakerDeviceTest":
            guard let deviceManager = deviceManager else { return }
            deviceManager.startSpeakerDeviceTest(call: call, result: result)
            break
        case "stopSpeakerDeviceTest":
            guard let deviceManager = deviceManager else { return }
            deviceManager.stopSpeakerDeviceTest(call: call, result: result)
            break
        case "setApplicationPlayVolume":
            guard let deviceManager = deviceManager else { return }
            deviceManager.setApplicationPlayVolume(call: call, result: result)
            break
        case "getApplicationPlayVolume":
            guard let deviceManager = deviceManager else { return }
            deviceManager.getApplicationPlayVolume(call: call, result: result)
            break
        case "setApplicationMuteState":
            guard let deviceManager = deviceManager else { return }
            deviceManager.setApplicationMuteState(call: call, result: result)
            break
        case "getApplicationMuteState":
            guard let deviceManager = deviceManager else { return }
            deviceManager.getApplicationMuteState(call: call, result: result)
            break
            
        //MARK: beautyManager
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
            
        //MARK: audioEffectManager
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
        case "preloadMusic":
            guard let audioEffectManager = audioEffectManager else { return }
            audioEffectManager.preloadMusic(call: call, result: result)
            break
		default:
			CommonUtils.logError(call: call, errCode: -1, errMsg: "method not Implemented")
			result(FlutterMethodNotImplemented)
		}
	}
	
	/**
	* 启用或禁用控制台日志打印
	*/
	public func setConsoleEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enabled = CommonUtils.getParamByKey(call: call, result: result, param: "enabled") as? Bool {
			TRTCCloud.setConsoleEnabled(enabled)
			result(nil)
		}
	}

	/**
	* 启用或禁用 Log 的本地压缩。
	*/
	public func setLogCompressEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enabled = CommonUtils.getParamByKey(call: call, result: result, param: "enabled") as? Bool {
			TRTCCloud.setLogCompressEnabled(enabled)
			result(nil)
		}
	}
	
	/**
	* 启用或禁用 Log 的本地压缩。
	*/
	public func setLogDirPath(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let path = CommonUtils.getParamByKey(call: call, result: result, param: "path") as? String {
			TRTCCloud.setLogDirPath(path)
			result(nil)
		}
	}
	
	/**
	* 设置 Log 输出级别
	*/
	public func setLogLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let level = CommonUtils.getParamByKey(call: call, result: result, param: "level") as? Int {
			TRTCCloud.setLogLevel(TRTCLogLevel(rawValue: level)!)
			result(nil)
		}
	}
	
	/**
	* 创建 TRTCCloud 单例
	*/
	public func sharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
		listener = Listener(channel: channel)
        cloudManager = CloudManager(registrar: registrar, channel: channel)
		TRTCCloud.sharedInstance().delegate = listener
		
		result(nil)
	}
	
	/**
	* 销毁 TRTCCloud 单例
	*/
	public func destroySharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
		listener = nil
		beautyManager = nil
		cloudManager = nil
		deviceManager = nil
		audioEffectManager = nil
		TRTCCloud.sharedInstance().delegate = nil
		TRTCCloud.destroySharedInstance()
		
		result(nil)
	}
	
	/**
	* 获取美颜管理对象
	*/
	public func getBeautyManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		beautyManager = BeautyManager(registrar: registrar)
		result(nil)
	}
	
	/**
	* 获取设备管理对象
	*/
	public func getDeviceManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		deviceManager = DeviceManager(channel: channel)
		result(nil)
	}
	
	/**
	* 获取音效管理对象
	*/
	public func getAudioEffectManager(call: FlutterMethodCall, result: @escaping FlutterResult) {
		audioEffectManager = AudioEffectManager(channel: channel)
		result(nil)
	}
		
	/**
	* 获取 SDK 版本信息
	*/
	public func getSDKVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(TRTCCloud.getSDKVersion())
	}
    
    /**
    * 监听回调
    */
    static func invokeListener(channel: FlutterMethodChannel, type: ListenerType, params: Any?) {
        var resultParams: [String: Any] = [:]
        resultParams["type"] = type
        if let p = params {
            resultParams["params"] = p
        }
        channel.invokeMethod(TencentTRTCCloud.LISTENER_FUNC_NAME, arguments: JsonUtil.toJson(resultParams))
    }
}
