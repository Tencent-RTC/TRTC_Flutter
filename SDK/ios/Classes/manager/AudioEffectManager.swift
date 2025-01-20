//
//  AudioEffectManager.swift
//  tencent_trtc_cloud
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
import TXLiteAVSDK_Professional

class AudioEffectManager {
    
    let channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel, cloud: TRTCCloud) {
        self.channel = channel
        txAudioEffectManager = cloud.getAudioEffectManager()
    }

	private var txAudioEffectManager: TXAudioEffectManager
	
	/**
	* 开始播放背景音乐
	*/
	public func startPlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let musicParam = Utils.getParamByKey(call: call, result: result, param: "musicParam") as? String {
			let musicParam = JsonUtil.getDictionaryFromJSONString(jsonString: musicParam)
			let param = TXAudioMusicParam()
			
			param.id = musicParam["id"] as! Int32
			param.path = musicParam["path"] as! String
			param.loopCount = musicParam["loopCount"] as! Int
			param.publish = musicParam["publish"] as! Bool
			param.isShortFile = musicParam["isShortFile"] as! Bool
			param.startTimeMS = musicParam["startTimeMS"] as! Int
			param.endTimeMS = musicParam["endTimeMS"] as! Int
			
			txAudioEffectManager.startPlayMusic(param, onStart: { [weak self] (errCode) -> Void in
                guard let self = self else { return }
                Utils.invokeListener(channel: self.channel,
                                                type: ListenerType.onMusicObserverStart,
                                                params: ["id": param.id,
                                                         "errCode": errCode] as [String : Any])
				
			}, onProgress: { [weak self] (progressMs, durationMs) -> Void in
                guard let self = self else { return }
                Utils.invokeListener(channel: self.channel,
                                                type: ListenerType.onMusicObserverPlayProgress,
                                                params: ["id": param.id,
                                                         "curPtsMS": progressMs,
                                                         "durationMS": durationMs] as [String : Any])
				
			}, onComplete: { [weak self] (errCode) -> Void in
                guard let self = self else { return }
                Utils.invokeListener(channel: self.channel,
                                                type: ListenerType.onMusicObserverComplete,
                                                params: ["id": param.id,
                                                         "errCode": errCode] as [String : Any])
			})
			result(true)
		}
	}
	
	/**
	* 开启耳返
	*/
	public func enableVoiceEarMonitor(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = Utils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
			txAudioEffectManager.enableVoiceEarMonitor(enable)
			result(nil)
		}
	}
	
	/**
	* 设置耳返音量
	*/
	public func setVoiceEarMonitorVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let volume = Utils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txAudioEffectManager.setVoiceEarMonitorVolume(volume)
			result(nil)
		}
	}
	
	/**
	* 设置人声的混响效果（KTV、小房间、大会堂、低沉、洪亮...）
	*/
	public func setVoiceReverbType(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let type = Utils.getParamByKey(call: call, result: result, param: "type") as? Int {
			txAudioEffectManager.setVoiceReverbType(TXVoiceReverbType(rawValue: type)!)
			result(nil)
		}
	}
	
	/**
	* 设置人声的变声特效（萝莉、大叔、重金属、外国人...）
	*/
	public func setVoiceChangerType(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let type = Utils.getParamByKey(call: call, result: result, param: "type") as? Int {
			txAudioEffectManager.setVoiceChangerType(TXVoiceChangeType(rawValue: type)!)
			result(nil)
		}
	}
	
	/**
	* 设置麦克风采集人声的音量
	*/
	public func setVoiceCaptureVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let volume = Utils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txAudioEffectManager.setVoiceVolume(volume)
			result(nil)
		}
	}
	
	/**
	* 停止播放背景音乐
	*/
	public func stopPlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32 {
			txAudioEffectManager.stopPlayMusic(id)
			result(nil)
		}
	}
	
	/**
	* 暂停播放背景音乐
	*/
	public func pausePlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32 {
			txAudioEffectManager.pausePlayMusic(id)
			result(nil)
		}
	}
	
	/**
	* 恢复播放背景音乐
	*/
	public func resumePlayMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32 {
			txAudioEffectManager.resumePlayMusic(id)
			result(nil)
		}
	}
	
	/**
	* 设置背景音乐的远端音量大小，即主播可以通过此接口设置远端观众能听到的背景音乐的音量大小。
	*/
	public func setMusicPublishVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32,
		   let volume = Utils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txAudioEffectManager.setMusicPublishVolume(id, volume: volume)
			result(nil)
		}
	}
	
	/**
	* 设置背景音乐的本地音量大小，即主播可以通过此接口设置主播自己本地的背景音乐的音量大小。
	* volume 音量大小，100为正常音量，取值范围为0 - 100；默认值：100
	*/
	public func setMusicPlayoutVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32,
		   let volume = Utils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txAudioEffectManager.setMusicPlayoutVolume(id, volume: volume)
			result(nil)
		}
	}
	
	/**
	* 设置全局背景音乐的本地和远端音量的大小
	*/
	public func setAllMusicVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let volume = Utils.getParamByKey(call: call, result: result, param: "volume") as? Int {
			txAudioEffectManager.setAllMusicVolume(volume)
			result(nil)
		}
	}
	
	/**
	* 调整背景音乐的音调高低
	* pitch	音调，默认值是0.0f，范围是：[-1 ~ 1] 之间的浮点数
	*/
	public func setMusicPitch(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let volume = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32,
		   let pitch = Double.init((Utils.getParamByKey(call: call, result: result, param: "pitch") as? String)!) {
			txAudioEffectManager.setMusicPitch(volume, pitch: pitch)
			result(nil)
		}
	}
	
	/**
	* 调整背景音乐的变速效果
	* speedRate	速度，默认值是1.0f，范围是：[0.5 ~ 2] 之间的浮点数
	*/
	public func setMusicSpeedRate(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32,
		   let speedRate = Double.init((Utils.getParamByKey(call: call, result: result, param: "speedRate") as? String)!) {
			txAudioEffectManager.setMusicSpeedRate(id, speedRate: speedRate)
			result(nil)
		}
	}
	
	/**
	* 获取背景音乐当前的播放进度（单位：毫秒）
	*/
	public func getMusicCurrentPosInMS(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32 {
			let ms = txAudioEffectManager.getMusicCurrentPos(inMS: id)
			result(ms)
		}
	}
	
	/**
	* 设置背景音乐的播放进度（单位：毫秒）
	*/
	public func seekMusicToPosInMS(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let id = Utils.getParamByKey(call: call, result: result, param: "id") as? Int32,
		   let pts = Utils.getParamByKey(call: call, result: result, param: "pts") as? Int {
			txAudioEffectManager.seekMusicToPos(inMS: id, pts: pts)
			result(nil)
		}
	}
	
	/**
	* 获取景音乐文件的总时长（单位：毫秒）
	*/
	public func getMusicDurationInMS(call: FlutterMethodCall, result: @escaping FlutterResult) {
		let path = Utils.getParamByKeyCanBeNull(call: call, result: result, param: "path") as? String
		let res = txAudioEffectManager.getMusicDuration(inMS: path != nil ? path! : "")
		result(res)
	}
    
    public func setVoicePitch(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let pitch = Utils.getParamByKey(call: call, result: result, param: "pitch") as? Double {
            txAudioEffectManager.setVoicePitch(pitch)
            result(nil)
        }
    }
    
    public func preloadMusic(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let musicParam = Utils.getParamByKey(call: call, result: result, param: "preloadParam") as? String {
            let musicParam = JsonUtil.getDictionaryFromJSONString(jsonString: musicParam)
            let param = TXAudioMusicParam()

            if let id = musicParam["id"] as? Int32 { param.id = id }
            if let path = musicParam["path"] as? String { param.path = path }
            if let loopCount = musicParam["loopCount"] as? Int { param.loopCount = loopCount }
            if let publish = musicParam["publish"] as? Bool { param.publish = publish }
            if let isShortFile = musicParam["isShortFile"] as? Bool { param.isShortFile = isShortFile }
            if let startTimeMS = musicParam["startTimeMS"] as? Int { param.startTimeMS = startTimeMS }
            if let endTimeMS = musicParam["endTimeMS"] as? Int { param.endTimeMS = endTimeMS }
            
            txAudioEffectManager.preloadMusic(param, onProgress: { [weak self] (progress) -> Void in
                guard let self = self else { return }
                self.channel.invokeMethod("onMusicPreloadObserver",
                                     arguments: JsonUtil.toJson(["type": "onLoadProgress",
                                                                 "id": param.id,
                                                                 "progress": progress] as [String : Any]))
                
            }, onError: { [weak self] (errCode) -> Void in
                guard let self = self else { return }
                self.channel.invokeMethod("onMusicPreloadObserver",
                                     arguments: JsonUtil.toJson(["type": "onLoadError",
                                                                 "id": param.id,
                                                                 "errCode": errCode] as [String : Any]))
            })
            result(nil)
        }
    }
}
