//
//  CloudManager.swift
//  tencent_trtc_cloud
//
//  Created by 林智 on 2020/12/29.
//
import Cocoa
import FlutterMacOS
import Foundation
import TXLiteAVSDK_TRTC_Mac

class CloudManager {
    private let channel: FlutterMethodChannel
    private let tRegistrar: FlutterPluginRegistrar
    private let _textures: FlutterTextureRegistry
    
    init(registrar: FlutterPluginRegistrar, channel: FlutterMethodChannel){
        tRegistrar = registrar
        _textures = registrar.textures
        self.channel = channel
    }
    
	private var txCloudManager: TRTCCloud = TRTCCloud.sharedInstance()
	
	/**
	* 停止本地视频采集及预览
	*/
	public func stopLocalPreview(call: FlutterMethodCall, result: @escaping FlutterResult) {
        txCloudManager.stopLocalPreview()
		result(nil)
	}
	
	/**
	* 停止显示远端视频画面，同时不再拉取该远端用户的视频数据流
	* 调用此接口后，SDK 会停止接收该用户的远程视频流，同时会清理相关的视频显示资源。
	*/
	public func stopRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
			txCloudManager.stopRemoteView(userId, streamType: TRTCVideoStreamType(rawValue: streamType)!)
			result(nil)
		}
	}
	
	/**
	* 显示仪表盘
	*/
	public func showDebugView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mode = CommonUtils.getParamByKey(call: call, result: result, param: "mode") as? Int {
			txCloudManager.showDebugView(mode)
			result(nil)
		}
	}
	
	/**
	* 进入房间
	* 调用接口后，您会收到来自 TRTCCloudListener 中的 onEnterRoom(result) 回调：
	*/
	public func enterRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let param = JsonUtil.getDictionaryFromJSONString(jsonString: (CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String)!)
		let scene = ((call.arguments as! [String: Any])["scene"]) as? Int
		
		if let sdkAppId = param["sdkAppId"] as? UInt32,
		   let userId = param["userId"] as? String,
		   let userSig = param["userSig"] as? String,
		   let roomId = param["roomId"] as? UInt32,
		   let strRoomId = param["strRoomId"] as? String,
		   let role = param["role"] as? Int,
		   let streamId = param["streamId"] as? String,
		   let userDefineRecordId = param["userDefineRecordId"] as? String,
		   let privateMapKey = param["privateMapKey"] as? String,
		   let businessInfo = param["businessInfo"] as? String {
			let params = TRTCParams()
			params.sdkAppId = sdkAppId
			params.userId = userId
			params.userSig = userSig
			params.roomId = roomId
			params.strRoomId = strRoomId
			params.streamId = streamId
			params.userDefineRecordId = userDefineRecordId
			params.privateMapKey = privateMapKey
			params.bussInfo = businessInfo
			params.role = TRTCRoleType(rawValue: role)!
			
			txCloudManager.callExperimentalAPI("{\"api\": \"setFramework\", \"params\": {\"framework\": 7}}")
			txCloudManager.enterRoom(params, appScene: TRTCAppScene(rawValue: scene!)!)
			result(nil)
		}
	}
	
	/**
	* 离开房间
	*/
	public func exitRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.exitRoom()
		result(nil)
	}
	
	/**
	* 跨房通话
	*/
	public func connectOtherRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
			txCloudManager.connectOtherRoom(param)
			result(nil)
		}
	}
	
	/**
	* 退出跨房通话
	*/
	public func disconnectOtherRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.disconnectOtherRoom()
		result(nil)
	}
	
	/**
	* 切换房间
	*/
	public func switchRoom(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let config = JsonUtil.getDictionaryFromJSONString(jsonString: (CommonUtils.getParamByKey(call: call, result: result, param: "config") as? String)!)
		
		if let userSig = config["userSig"] as? String,
		   let roomId = config["roomId"] as? UInt32,
		   let strRoomId = config["strRoomId"] as? String,
		   let privateMapKey = config["privateMapKey"] as? String {
			let params = TRTCSwitchRoomConfig()
			params.userSig = userSig
			params.roomId = roomId
			params.strRoomId = strRoomId
			params.privateMapKey = privateMapKey
			
			txCloudManager.switchRoom(params)
			result(nil)
		}
	}
	
	/**
	* 切换角色，仅适用于直播场景（TRTC_APP_SCENE_LIVE 和 TRTC_APP_SCENE_VOICE_CHATROOM）
	*/
	public func switchRole(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let role = CommonUtils.getParamByKey(call: call, result: result, param: "role") as? Int {
			txCloudManager.switch(TRTCRoleType(rawValue: role)!)
			result(nil)
		}
	}
	
	/**
	* 设置音视频数据接收模式，需要在进房前设置才能生效
	*/
	public func setDefaultStreamRecvMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let autoRecvAudio = CommonUtils.getParamByKey(call: call, result: result, param: "autoRecvAudio") as? Bool,
		   let autoRecvVideo = CommonUtils.getParamByKey(call: call, result: result, param: "autoRecvVideo") as? Bool {
			txCloudManager.setDefaultStreamRecvMode(autoRecvAudio, video: autoRecvVideo)
			result(nil)
		}
	}
	
	/**
	* 静音/取消静音指定的远端用户的声音
	*/
	public func muteRemoteAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
			txCloudManager.muteRemoteAudio(userId, mute: mute)
			result(nil)
		}
	}
	
	/**
	* 静音/取消静音所有用户的声音
	*/
	public func muteAllRemoteAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
			txCloudManager.muteAllRemoteAudio(mute)
			result(nil)
		}
	}
	
	/**
	* 设置采集音量
	*/
	public func setAudioCaptureVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let volume = CommonUtils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txCloudManager.setAudioCaptureVolume(volume)
			result(nil)
		}
	}
    
	/**
	* 设置某个远程用户的播放音量
	*/
	public func setRemoteAudioVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let volume = CommonUtils.getParamByKey(call: call, result: result, param: "volume") as? Int32 {
			txCloudManager.setRemoteAudioVolume(userId, volume: volume)
			result(nil)
		}
	}
	
	/**
	* 设置播放音量
	*/
	public func setAudioPlayoutVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let volume = CommonUtils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txCloudManager.setAudioPlayoutVolume(volume)
			result(nil)
		}
	}
	
	/**
	* 获取采集音量
	*/
	public func getAudioCaptureVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let volume = txCloudManager.getAudioCaptureVolume()
		result(volume)
	}
	
	/**
	* 获取播放音量
	*/
	public func getAudioPlayoutVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let volume = txCloudManager.getAudioPlayoutVolume()
		result(volume)
	}
	
	/**
	* 开启本地音频的采集和上行
	*/
	public func startLocalAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let quality = CommonUtils.getParamByKey(call: call, result: result, param: "quality") as? Int {
			txCloudManager.startLocalAudio(TRTCAudioQuality(rawValue: quality)!)
			result(nil)
		}
	}
	
	/**
	* 关闭本地音频的采集和上行
	*/
	public func stopLocalAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.stopLocalAudio()
		result(nil)
	}
	
	/**
	* 本地视频渲染设置
	*/
	public func setLocalRenderParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
			let data = TRTCRenderParams()
			if dict["rotation"] != nil {
				data.rotation = TRTCVideoRotation(rawValue: dict["rotation"] as! Int)!
			}
			if dict["fillMode"] != nil {
				data.fillMode = TRTCVideoFillMode(rawValue: dict["fillMode"] as! Int)!
			}
			if dict["mirrorType"] != nil {
				data.mirrorType = TRTCVideoMirrorType(rawValue: dict["mirrorType"] as! UInt)!
			}
			txCloudManager.setLocalRenderParams(data)
			result(nil)
		}
	}
	
	/**
	* 远程视频渲染设置
	*/
	public func setRemoteRenderParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int,
		   let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
			let data = TRTCRenderParams()
			if dict["rotation"] != nil {
				data.rotation = TRTCVideoRotation(rawValue: dict["rotation"] as! Int)!
			}
			if dict["fillMode"] != nil {
				data.fillMode = TRTCVideoFillMode(rawValue: dict["fillMode"] as! Int)!
			}
			if dict["mirrorType"] != nil {
				data.mirrorType = TRTCVideoMirrorType(rawValue: dict["mirrorType"] as! UInt)!
			}
			txCloudManager.setRemoteRenderParams(userId, streamType: TRTCVideoStreamType(rawValue: streamType)!,  params: data)
			result(nil)
		}
	}
	
	/**
	* 停止显示所有远端视频画面，同时不再拉取远端用户的视频数据流
	*/
	public func stopAllRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.stopAllRemoteView()
		result(nil)
	}
	
	/**
	* 暂停/恢复接收指定的远端视频流
	*/
	public func muteRemoteVideoStream(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
			txCloudManager.muteRemoteVideoStream(userId, mute: mute)
			result(nil)
		}
	}
	
	/**
	* 暂停/恢复接收所有远端视频流
	*/
	public func muteAllRemoteVideoStreams(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
			txCloudManager.muteAllRemoteVideoStreams(mute)
			result(nil)
		}
	}
	
	/**
	* 设置视频编码器相关参数
	*/
	public func setVideoEncoderParam(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
			let data = TRTCVideoEncParam()
			if dict["videoBitrate"] != nil {
				data.videoBitrate = dict["videoBitrate"] as! Int32
			}
			if dict["videoResolution"] != nil {
				data.videoResolution = TRTCVideoResolution(rawValue: dict["videoResolution"] as! Int)!
			}
			if dict["videoResolutionMode"] != nil {
				data.resMode = TRTCVideoResolutionMode(rawValue: dict["videoResolutionMode"] as! Int)!
			}
			if dict["videoFps"] != nil {
				data.videoFps = dict["videoFps"] as! Int32
			}
			txCloudManager.setVideoEncoderParam(data)
			result(nil)
		}
	}
	
	/**
	* 开始向腾讯云的直播 CDN 推流
	*/
	public func startPublishing(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int,
		   let streamId = CommonUtils.getParamByKey(call: call, result: result, param: "streamId") as? String {
			txCloudManager.startPublishing(streamId, type: TRTCVideoStreamType(rawValue: streamType)!)
			result(nil)
			
		}
	}
	
	/**
	* 开始向腾讯云的直播 CDN 推流
	*/
	public func startPublishCDNStream(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let param = JsonUtil.getDictionaryFromJSONString(jsonString: (CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String)!)
		
		if let appId = param["appId"] as? Int32,
		   let bizId = param["bizId"] as? Int32,
		   let url = param["url"] as? String {
			let params = TRTCPublishCDNParam()
			params.appId = appId
			params.bizId = bizId
			params.url = url
			
			txCloudManager.startPublishCDNStream(params)
			result(nil)
		}
	}
	
	/**
	* 停止向腾讯云的直播 CDN 推流
	*/
	public func stopPublishCDNStream(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.stopPublishCDNStream()
		result(nil)
	}
	
	/**
	* 停止向腾讯云的直播 CDN 推流
	*/
	public func stopPublishing(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.stopPublishing()
		result(nil)
	}
	
	/**
	* 设置云端的混流转码参数
	*/
	public func setMixTranscodingConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let param = CommonUtils.getParamByKey(call: call, result: result, param: "config") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
			let backgroundImage = dict["backgroundImage"] as? String
			let streamId = dict["streamId"] as? String
			
			if let appId = dict["appId"] as? Int32,
			   let bizId = dict["bizId"] as? Int32,
			   let videoWidth = dict["videoWidth"] as? Int32,
			   let mode = dict["mode"] as? Int,
			   let videoHeight = dict["videoHeight"] as? Int32,
			   let videoFramerate = dict["videoFramerate"] as? Int32,
			   let videoGOP = dict["videoGOP"] as? Int32,
			   let backgroundColor = dict["backgroundColor"] as? Int32,
			   let videoBitrate = dict["videoBitrate"] as? Int32,
			   let audioBitrate = dict["audioBitrate"] as? Int32,
			   let audioSampleRate = dict["audioSampleRate"] as? Int32,
			   let audioChannels = dict["audioChannels"] as? Int32,
			   let mixUsers = dict["mixUsers"] as? Array<AnyObject> {
				
				let config = TRTCTranscodingConfig()
				var users: [TRTCMixUser] = []
				
				config.appId = appId
				config.bizId = bizId
				config.videoWidth = videoWidth
				config.mode = TRTCTranscodingConfigMode(rawValue: mode)!
				config.videoHeight = videoHeight
				config.videoFramerate = videoFramerate
				config.videoGOP = videoGOP
				config.backgroundImage = backgroundImage
				config.backgroundColor = backgroundColor
				config.videoBitrate = videoBitrate
				config.audioBitrate = audioBitrate
				config.audioSampleRate = audioSampleRate
				config.audioChannels = audioChannels
				config.streamId = streamId
				
				for item in mixUsers {
					let user = TRTCMixUser()
					user.userId = item["userId"] as! String
					user.roomID = item["roomId"] as? String
					user.rect = CGRect(x: item["x"] as! Int, y: item["y"] as! Int, width: item["width"] as! Int, height: item["height"] as! Int)
					user.zOrder = item["zOrder"] as! Int32
					user.streamType = TRTCVideoStreamType(rawValue: item["streamType"] as! Int)!
					user.pureAudio = false
					users.append(user)
				}
				
				config.mixUsers = users
				txCloudManager.setMix(config)
				
				result(nil)
			}
		}
	}
	
	/**
	* 设置网络流控相关参数
	*/
	public func setNetworkQosParam(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
			let param = TRTCNetworkQosParam()
			
			if !(dict["preference"] is NSNull) &&  dict["preference"] != nil {
				param.preference = TRTCVideoQosPreference(rawValue: dict["preference"] as! Int)!
			}
			if !(dict["controlMode"] is NSNull) &&  dict["controlMode"] != nil {
				param.controlMode = TRTCQosControlMode(rawValue: dict["controlMode"] as! Int)!
			}
			
			txCloudManager.setNetworkQosParam(param)
			result(nil)
		}
	}
	
	/**
	* 设置暂停推送本地视频时要推送的图片
	*/
	public func setVideoMuteImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let imageUrl = CommonUtils.getParamByKeyCanBeNull(call: call, result: result, param: "imageUrl") as? String
		if 	let fps = CommonUtils.getParamByKey(call: call, result: result, param: "fps") as? Int,
			   let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? String {
			if(imageUrl == nil) {
				// txCloudManager.setVideoMuteImage(nil, fps: fps)
			} else {
				if type == "local" {
                    
					let img = NSImage(contentsOfFile: self.getFlutterBundlePath(assetPath: imageUrl!)!)!
					txCloudManager.setVideoMuteImage(img, fps: fps)
				} else {
//					let queue = (label: "setVideoMuteImage")
//					queue.async {
//						let url: NSURL = NSURL(string: imageUrl!)!
//						let data: NDispatchQueueSData = NSData(contentsOf: url as URL)!
//						let img = UIImage(data: data as Data, scale: 1)!
////						self.txCloudManager.setVideoMuteImage(img, fps: fps)
//					}
                    let img = NSImage(contentsOfFile: self.getFlutterBundlePath(assetPath: imageUrl!)!)!
                    txCloudManager.setVideoMuteImage(img, fps: fps)
				}
			}
			result(nil)
		}
	}
	
	/**
	* 设置视频编码输出的画面方向，即设置远端用户观看到的和服务器录制的画面方向
	*/
	public func setVideoEncoderRotation(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let rotation = CommonUtils.getParamByKey(call: call, result: result, param: "rotation") as? Int {
			txCloudManager.setVideoEncoderRotation(TRTCVideoRotation(rawValue: rotation)!)
			result(nil)
		}
	}
	
	/**
	* 设置编码器输出的画面镜像模式
	*/
	public func setVideoEncoderMirror(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mirror = CommonUtils.getParamByKey(call: call, result: result, param: "mirror") as? Bool {
			txCloudManager.setVideoEncoderMirror(mirror)
			result(nil)
		}
	}
	
	/**
	* 设置重力感应的适应模式
	*/
	public func setGSensorMode(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mode = CommonUtils.getParamByKey(call: call, result: result, param: "mode") as? Int {
			txCloudManager.setGSensorMode(TRTCGSensorMode(rawValue: mode)!)
			result(nil)
		}
	}
	
	/**
	* 开启大小画面双路编码模式
	*/
	public func enableEncSmallVideoStream(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool,
		   let smallVideoEncParam = CommonUtils.getParamByKey(call: call, result: result, param: "smallVideoEncParam") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: smallVideoEncParam)
			let data = TRTCVideoEncParam()
			if !(dict["videoBitrate"] is NSNull) &&  dict["videoBitrate"] != nil {
				data.videoBitrate = dict["videoBitrate"] as! Int32
			}
			if !(dict["videoResolution"] is NSNull)  &&  dict["videoResolution"] != nil  {
				data.videoResolution = TRTCVideoResolution(rawValue: dict["videoResolution"] as! Int)!
			}
			if !(dict["videoResolutionMode"] is NSNull)  &&  dict["videoResolutionMode"] != nil  {
				data.resMode = TRTCVideoResolutionMode(rawValue: dict["videoResolutionMode"] as! Int)!
			}
			if !(dict["videoFps"] is NSNull)  &&  dict["videoFps"] != nil  {
				data.videoFps = dict["videoFps"] as! Int32
			}
			
			let ret = txCloudManager.enableEncSmallVideoStream(enable, withQuality: data)
			result(ret)
		}
	}
	
	/**
	* 选定观看指定 uid 的大画面或小画面
	*/
	public func setRemoteVideoStreamType(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
			txCloudManager.setRemoteVideoStreamType(userId, type: TRTCVideoStreamType(rawValue: streamType)!)
			result(nil)
		}
	}
	
	/**
	* 视频画面截图
	*/
	public func snapshotVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String
        if let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int,
           let path = CommonUtils.getParamByKey(call: call, result: result, param: "path") as? String {
            txCloudManager.snapshotVideo(userId!, type: TRTCVideoStreamType(rawValue: streamType)!, completionBlock: { [weak self] image in
                guard let self = self else { return }
                if(image == nil){
                    TencentTRTCCloud.invokeListener(channel: self.channel,
                                                    type: ListenerType.onSnapshotComplete,
                                                    params: ["errCode": -101,
                                                             "errMsg": "image not find",
                                                             "path": nil] as [String : Any?])
                    result(nil)
                    return
                }
                let destinationURL = URL(fileURLWithPath: path)
                var isOk:Bool = false
           
                if path.hasSuffix(".png") {
                    isOk =  image.pngWrite(to: destinationURL, options: .withoutOverwriting)
                }else{
                    isOk =  image.jpegWrite(to: destinationURL, options: .withoutOverwriting)
                }
                if(isOk){
                    TencentTRTCCloud.invokeListener(channel: self.channel,
                                                    type: ListenerType.onSnapshotComplete,
                                                    params: ["errCode": 0,
                                                             "path": path] as [String : Any])
                }else{
                    CommonUtils.logError(call: call, errCode: -1, errMsg: "write failed")
                    TencentTRTCCloud.invokeListener(channel: self.channel,
                                                    type: ListenerType.onSnapshotComplete,
                                                    params: ["errCode": -1,
                                                             "errMsg": "write failed",
                                                             "path": nil] as [String : Any?])
                }
            })
            result(nil)
        }
	}
	
	/**
	* 静音/取消静音本地的音频
	*/
	public func muteLocalAudio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
			txCloudManager.muteLocalAudio(mute)
			result(nil)
		}
	}
	
	/**
	* 暂停/恢复推送本地的视频数据
	*/
	public func muteLocalVideo(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
			txCloudManager.muteLocalVideo(mute)
			result(nil)
		}
	}
	
	/**
	* 启用音量大小提示
	*/
	public func enableAudioVolumeEvaluation(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let intervalMs = CommonUtils.getParamByKey(call: call, result: result, param: "intervalMs") as? UInt {
			txCloudManager.enableAudioVolumeEvaluation(intervalMs)
			result(nil)
		}
	}
	
	/**
	* 开始录音
	*/
	public func startAudioRecording(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
			let data = TRTCAudioRecordingParams()
			data.filePath = dict["filePath"] as! String
			result(txCloudManager.startAudioRecording(data))
		}
	}
	
	/**
	* 停止录音
	*/
	public func stopAudioRecording(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.stopAudioRecording()
		result(nil)
	}
	
    public func startLocalRecording(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let param = CommonUtils.getParamByKey(call: call, result: result, param: "param") as? String {
            let dict = JsonUtil.getDictionaryFromJSONString(jsonString: param)
            let data = TRTCLocalRecordingParams()
            data.filePath = dict["filePath"] as! String
            data.interval = dict["interval"] as! Int32
            data.recordType = TRTCRecordType(rawValue: dict["recordType"] as! UInt) ?? TRTCRecordType.both
            //result(txCloudManager.startLocalRecording(data))
        }
    }

    public func stopLocalRecording(call: FlutterMethodCall, result: @escaping FlutterResult) {
        //txCloudManager.stopLocalRecording()
        result(nil)
    }
    
    private func getFlutterBundlePath(assetPath:String) -> String?{
//        let imgKey = tRegistrar?.lookupKey(forAsset: assetPath)
//        var imgPath:String? = assetPath
//        if(imgKey != nil){
//           imgPath = Bundle.main.path(forResource: imgKey, ofType: nil)
//        }
        return assetPath
    }
    
	/**
	* 设置水印
	*/
	public func setWatermark(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let imageUrl = CommonUtils.getParamByKey(call: call, result: result, param: "imageUrl") as? String,
		   let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int,
		   let x = CommonUtils.getParamByKey(call: call, result: result, param: "x") as? String,
		   let y = CommonUtils.getParamByKey(call: call, result: result, param: "y") as? String,
		   let width = CommonUtils.getParamByKey(call: call, result: result, param: "width") as? String,
		   let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? String {
			
			let fx = CGFloat.init(Float.init(x)!)
			let fy = CGFloat.init(Float.init(y)!)
			let fwidth = CGFloat.init(Float.init(width)!)
			let rect = CGRect(x: fx, y: fy, width: fwidth, height: fwidth)
            if imageUrl.isEmpty {
                txCloudManager.setWatermark(nil, streamType: TRTCVideoStreamType.init(rawValue: streamType) ?? .big, rect: rect)
                result(nil)
                return
            }
            if type == "local" {
				txCloudManager.setWatermark(NSImage.init(contentsOfFile: self.getFlutterBundlePath(assetPath: imageUrl)!),
                                            streamType: TRTCVideoStreamType.init(rawValue: streamType) ?? .big,
                                            rect: rect)
			} else {
                txCloudManager.setWatermark(NSImage.init(contentsOfFile: self.getFlutterBundlePath(assetPath: imageUrl)!),
                                            streamType: TRTCVideoStreamType.init(rawValue: streamType) ?? .big,
                                            rect: rect)
            
			}
			
			result(nil)
		}
	}
	
	/**
	* 开始应用内的屏幕分享（该接口仅支持 iOS 13.0 及以上的 iPhone 和 iPad）
	*/
	public func startScreenCaptureInApp(call: FlutterMethodCall, result: @escaping FlutterResult){
		if let encParams = CommonUtils.getParamByKey(call: call, result: result, param: "encParams") as? String {
			let dict = JsonUtil.getDictionaryFromJSONString(jsonString: encParams)
			let data = TRTCVideoEncParam()
			if dict["videoResolution"] != nil {
				data.videoResolution = TRTCVideoResolution(rawValue: dict["videoResolution"] as! Int)!
			}
			if dict["videoFps"] != nil {
				data.videoFps = dict["videoFps"] as! Int32
			}
			if dict["videoBitrate"] != nil {
				data.videoBitrate = dict["videoBitrate"] as! Int32
			}
			if dict["enableAdjustRes"] != nil {
				data.enableAdjustRes = dict["enableAdjustRes"] as! Bool
			}
			if #available(iOS 13.0,*){
				//txCloudManager.startScreenCapture(inApp:data)
			}
		}else{
			if #available(iOS 13.0,*){
				//txCloudManager.startScreenCapture(inApp:nil)
			}
		}
		result(nil)
	}
	
	/**
	* 开始全系统的屏幕分享（该接口支持 iOS 11.0 及以上的 iPhone 和 iPad）
	*/
	public func startScreenCaptureByReplaykit(call: FlutterMethodCall, result: @escaping FlutterResult){
		// let appGroup = CommonUtils.getParamByKey(call: call, result: result, param: "appGroup") as! String
		// if let encParams = CommonUtils.getParamByKey(call: call, result: result, param: "encParams") as? String {
		// 	let dict = JsonUtil.getDictionaryFromJSONString(jsonString: encParams)
		// 	let data = TRTCVideoEncParam()
		// 	if dict["videoResolution"] != nil {
		// 		data.videoResolution = TRTCVideoResolution(rawValue: dict["videoResolution"] as! Int)!
		// 	}
		// 	if dict["videoFps"] != nil {
		// 		data.videoFps = dict["videoFps"] as! Int32
		// 	}
		// 	if dict["videoBitrate"] != nil {
		// 		data.videoBitrate = dict["videoBitrate"] as! Int32
		// 	}
		// 	if dict["enableAdjustRes"] != nil {
		// 		data.enableAdjustRes = dict["enableAdjustRes"] as! Bool
		// 	}
		// 	if #available(iOS 11.0,*){
		// 		//txCloudManager.startScreenCapture(byReplaykit:data,appGroup:appGroup)
		// 	}
		// }else{
		// 	if #available(iOS 11.0,*){
		// 		//txCloudManager.startScreenCapture(byReplaykit:nil,appGroup:appGroup)
		// 	}
		// }
		result(nil)
	}

	/**
	* 开始桌面端屏幕分享（该接口仅支持 Mac OS 桌面系统）.不支持
	*/
	public func startScreenCapture(call: FlutterMethodCall, result: @escaping FlutterResult){
		//txCloudManager.startScreenCapture()
		result(nil)
	}

	/**
	* 停止屏幕采集
	*/
	public func stopScreenCapture(call: FlutterMethodCall, result: @escaping FlutterResult){
		if #available(iOS 11.0,*){
			result(txCloudManager.stopScreenCapture())
		}else{
			result(-1)
		}
	}

	/**
	* 暂停屏幕分享
	*/
	public func pauseScreenCapture(call: FlutterMethodCall, result: @escaping FlutterResult){
		if #available(iOS 11.0,*){
			result(txCloudManager.pauseScreenCapture())
		}else{
			result(-1)
		}
	}

	/**
	* 恢复屏幕分享
	*/
	public func resumeScreenCapture(call: FlutterMethodCall, result: @escaping FlutterResult){
		if #available(iOS 11.0,*){
			result(txCloudManager.resumeScreenCapture())
		}else{
			result(-1)
		}
	}

	/**
	* 发送自定义消息给房间内所有用户
	*/
	public func sendCustomCmdMsg(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let cmdID = CommonUtils.getParamByKey(call: call, result: result, param: "cmdID") as? Int,
		   let dataStr = CommonUtils.getParamByKey(call: call, result: result, param: "data") as? String,
		   let reliable = CommonUtils.getParamByKey(call: call, result: result, param: "reliable") as? Bool,
		   let ordered = CommonUtils.getParamByKey(call: call, result: result, param: "ordered") as? Bool {
			let nsdata = dataStr.data(using: String.Encoding.utf8)
			result(txCloudManager.sendCustomCmdMsg(cmdID, data: nsdata!, reliable: reliable, ordered: ordered))
		}
	}
	
	/**
	* 将小数据量的自定义数据嵌入视频帧中
	*/
	public func sendSEIMsg(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if  let dataStr = CommonUtils.getParamByKey(call: call, result: result, param: "data") as? String,
			let repeatCount = CommonUtils.getParamByKey(call: call, result: result, param: "repeatCount") as? Int32 {
			let nsdata = dataStr.data(using: String.Encoding.utf8)
			result(txCloudManager.sendSEIMsg(nsdata!, repeatCount: repeatCount))
		}
	}
	
	/**
	* 开始进行网络测速（视频通话期间请勿测试，以免影响通话质量）
	*/
	public func startSpeedTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let sdkAppId = CommonUtils.getParamByKey(call: call, result: result, param: "sdkAppId") as? UInt32,
		   let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		   let userSig = CommonUtils.getParamByKey(call: call, result: result, param: "userSig") as? String {
			txCloudManager.startSpeedTest(sdkAppId, userId: userId, userSig: userSig, completion: { [weak self] result, completedCount, totalCount in
                guard let self = self else { return }
                TencentTRTCCloud.invokeListener(channel: self.channel, type: ListenerType.onSpeedTest,
						params: ["currentResult": ["quality":(result as TRTCSpeedTestResult).quality.rawValue,
                                                   "success":(result as TRTCSpeedTestResult).success,
                                                   "errMsg":(result as TRTCSpeedTestResult).errMsg,
                                                   "ip":(result as TRTCSpeedTestResult).ip,
                                                   "upLostRate":Double((result as TRTCSpeedTestResult).upLostRate),
                                                   "downLostRate":Double((result as TRTCSpeedTestResult).downLostRate),
                                                   "rtt":(result as TRTCSpeedTestResult).rtt,
                                                   "availableUpBandwidth":(result as TRTCSpeedTestResult).availableUpBandwidth,
                                                   "availableDownBandwidth":(result as TRTCSpeedTestResult).availableDownBandwidth,] as [String : Any],
                                 "finishedCount":completedCount,
                                 "totalCount":totalCount] as [String : Any])
			})
			result(nil)
		}
	}
    
    public func startSpeedTestWithParams(call: FlutterMethodCall, result: @escaping FlutterResult) {
        var returnValue: Int32 = -1;
        if let dict = CommonUtils.getParamByKey(call: call, result: result, param: "params") as? [String: Any] {
            if let sdkAppId = dict["sdkAppId"] as? UInt32,
               let userId = dict["userId"] as? String,
               let userSig = dict["userSig"] as? String,
               let expectedUpBandwidth = dict["expectedUpBandwidth"] as? Int,
               let expectedDownBandwidth = dict["expectedDownBandwidth"] as? Int,
               let scene = dict["scene"] as? Int {
                let data = TRTCSpeedTestParams()
                
                data.sdkAppId = sdkAppId
                data.userId = userId
                data.userSig = userSig
                data.expectedDownBandwidth = expectedDownBandwidth
                data.expectedUpBandwidth = expectedUpBandwidth
                if let testScene = TRTCSpeedTestScene(rawValue: UInt(scene)) {
                    data.scene = testScene
                }
                
                returnValue = txCloudManager.startSpeedTest(data)
            }
        }
        result(returnValue)
    }
	
	/**
	* 停止服务器测速
	*/
	public func stopSpeedTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
		txCloudManager.stopSpeedTest()
		result(nil)
	}
    
    /**
    * 调用实验性 API 接口
    */
    public func callExperimentalAPI(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let jsonStr = CommonUtils.getParamByKey(call: call, result: result, param: "jsonStr") as? String {
            txCloudManager.callExperimentalAPI(jsonStr)
            result(nil)
        }
    }
    
     /**
    * 设置本地视频的自定义渲染回调。
    */
    public func setLocalVideoRenderListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let frontCamera = CommonUtils.getParamByKey(call: call, result: result, param: "isFront") as? Bool {
            var textureID :Int64? = 0
            txCloudManager.startLocalPreview(nil)
            let render:TencentVideoTextureRender = TencentVideoTextureRender(frameCallback: ({ [weak self] in
                guard let self = self else { return }
                self._textures.textureFrameAvailable(textureID!)
            }), isLocal:true)
			//flutter macos 只支持BGRA，这里需要把nv12格式转为BGRA。但是原生暂时还不支持BGRA
            txCloudManager.setLocalVideoProcessDelegete(render, pixelFormat:._NV12, bufferType: .pixelBuffer)
            //setLocalVideoRenderDelegate, 图片可以出来, 但印象中是有内存泄漏的
            //txCloudManager.setLocalVideoRenderDelegate(render, pixelFormat:._32BGRA, bufferType: .pixelBuffer)
            textureID = self._textures.register(render)
            NSLog("------------ setLocalVideoProcessDelegete  textureID: %lld", textureID ?? "---")
            result(textureID)
        }
    }

    /**
    * 设置远端视频的自定义渲染回调。
    */
    public func setRemoteVideoRenderListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = CommonUtils.getParamByKey(call: call, result: result, param: "userId") as? String,
		let streamType = CommonUtils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
            var textureID :Int64? = 0
            txCloudManager.startRemoteView(userId,streamType: .big, view: nil)
            let render:TencentVideoTextureRender = TencentVideoTextureRender(frameCallback: ({ [weak self] in
                guard let self = self else { return }
                self._textures.textureFrameAvailable(textureID!)
            }),isLocal:false)
            //flutter macos 只支持BGRA
            txCloudManager.setRemoteVideoRenderDelegate(userId,delegate:render, pixelFormat: ._NV12, bufferType: .pixelBuffer)
			textureID = self._textures.register(render)
            NSLog("------------ setRemoteVideoRenderDelegate  textureID: %lld", textureID ?? "---")
            result(textureID)
        }
    }
    
    public func unregisterTexture(call: FlutterMethodCall, result: @escaping FlutterResult){
        if let textureID = CommonUtils.getParamByKey(call: call, result: result, param: "textureID") as? Int64 {
            do {
                self._textures.unregisterTexture(textureID)
            } catch {
                NSLog("------------ unregisterTexture error  ", textureID )
            }
            result(nil)
        }
    }
    
    public func startSystemAudioLoopback(call: FlutterMethodCall, result: @escaping FlutterResult) {
        txCloudManager.startSystemAudioLoopback();
        result(nil)
    }
    
    public func stopSystemAudioLoopback(call: FlutterMethodCall, result: @escaping FlutterResult) {
        txCloudManager.stopSystemAudioLoopback();
        result(nil)
    }
    
    public func setSystemAudioLoopbackVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let volume = CommonUtils.getParamByKey(call: call, result: result, param: "volume") as? UInt32 {
            txCloudManager.setSystemAudioLoopbackVolume(volume);
        }
        result(nil)
    }
}
