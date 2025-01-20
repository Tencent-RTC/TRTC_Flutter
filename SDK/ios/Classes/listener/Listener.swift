//
//  Listener.swift
//  tencent_im_sdk_plugin
//

import Foundation
import TXLiteAVSDK_Professional

class Listener: NSObject, TRTCCloudDelegate {

    let channel: FlutterMethodChannel

    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

	/**
	* 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示。
	*/
	 func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable: Any]?) {
         Utils.invokeListener(channel: channel, type: ListenerType.onError, params: ["errCode": errCode.rawValue, "errMsg": errMsg ?? "", "extraInfo": extInfo as Any])
	}
	
	/**
	* 警告回调，用于告知您一些非严重性问题，例如出现了卡顿或者可恢复的解码失败。
	*/
	 func onWarning(_ warningCode: TXLiteAVWarning, warningMsg: String?, extInfo: [AnyHashable: Any]?) {
         Utils.invokeListener(channel: channel, type: ListenerType.onWarning, params: ["warningCode": warningCode.rawValue, "warningMsg": warningMsg  ?? "", "extraInfo": extInfo as Any])
	}
	
	/**
	* 已加入房间的回调
	*/
	 func onEnterRoom(_ result: Int) {
         Utils.invokeListener(channel: channel, type: ListenerType.onEnterRoom, params: result)
	}
	
	/**
	* 离开房间的事件回调
	*/
	 func onExitRoom(_ reason: Int) {
         Utils.invokeListener(channel: channel, type: ListenerType.onExitRoom, params: reason)
	}
	
	/**
	* 切换角色的事件回调
	*/
	 func onSwitchRole(_ errCode: TXLiteAVError, errMsg: String?) {
         Utils.invokeListener(channel: channel, type: ListenerType.onSwitchRole, params: ["errCode": errCode.rawValue,
                                                                                  "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 请求跨房通话（主播 PK）的结果回调
	*/
	 func onConnectOtherRoom(_ userId: String, errCode: TXLiteAVError, errMsg: String?) {
         Utils.invokeListener(channel: channel, type: ListenerType.onConnectOtherRoom, params: ["userId": userId,
                                                                                        "errCode": errCode.rawValue,
                                                                                        "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 切换房间 (switchRoom) 的结果回调
	*/
	 func onSwitchRoom(_ errCode: TXLiteAVError, errMsg: String?) {
         Utils.invokeListener(channel: channel, type: ListenerType.onSwitchRoom, params: ["errCode": errCode.rawValue,
                                                                                  "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 结束跨房通话（主播 PK）的结果回调
	*/
	 func onDisconnectOtherRoom(_ errCode: TXLiteAVError, errMsg: String?) {
         Utils.invokeListener(channel: channel, type: ListenerType.onDisConnectOtherRoom, params: ["errCode": errCode.rawValue,
                                                                                           "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 有用户加入当前房间
	*/
	 func onRemoteUserEnterRoom(_ userId: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onRemoteUserEnterRoom, params: userId)
	}
	
	/**
	* 有用户离开当前房间
	*/
	 func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        Utils.invokeListener(channel: channel, type: ListenerType.onRemoteUserLeaveRoom, params: ["userId": userId,
                                                                                           "reason": reason] as [String : Any])
	}
	
	/**
	* 有用户上传视频数据
	*/
	 func onUserVideoAvailable(_ userId: String, available: Bool) {
        Utils.invokeListener(channel: channel, type: ListenerType.onUserVideoAvailable, params: ["userId": userId,
                                                                                          "available": available] as [String : Any])
	}
	
	/**
	* 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
	*/
	 func onUserSubStreamAvailable(_ userId: String, available: Bool) {
        Utils.invokeListener(channel: channel, type: ListenerType.onUserSubStreamAvailable, params: ["userId": userId,
                                                                                              "available": available] as [String : Any])
	}
	
	/**
	* 远端用户是否存在可播放的音频数据
	*/
	 func onUserAudioAvailable(_ userId: String, available: Bool) {
        Utils.invokeListener(channel: channel, type: ListenerType.onUserAudioAvailable, params: ["userId": userId,
                                                                                          "available": available] as [String : Any])
	}
	
	/**
	* 开始渲染本地或远程用户的首帧画面。
	*/
	 func onFirstVideoFrame(_ userId: String, streamType: TRTCVideoStreamType, width: Int32, height: Int32) {
        Utils.invokeListener(channel: channel, type: ListenerType.onFirstVideoFrame, params: ["userId": userId,
                                                                                       "streamType": streamType.rawValue,
                                                                                       "width": width,
                                                                                       "height": height] as [String : Any])
	}
	
	/**
	* 开始播放远程用户的首帧音频（本地声音暂不通知）
	*/
	 func onFirstAudioFrame(_ userId: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onFirstAudioFrame, params: userId)
	}
	
	/**
	* 首帧本地视频数据已经被送出
	*/
	 func onSendFirstLocalVideoFrame(_ streamType: TRTCVideoStreamType) {
		Utils.invokeListener(channel: channel, type: ListenerType.onSendFirstLocalVideoFrame, params: streamType.rawValue)
	}
	
	/**
	* 首帧本地音频数据已经被送出
	*/
	 func onSendFirstLocalAudioFrame() {
		Utils.invokeListener(channel: channel, type: ListenerType.onSendFirstLocalAudioFrame, params: nil)
	}
	
	/**
	* 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。
	*/
	 func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
		var array: [Any] = []
		
		for item in remoteQuality {
            array.append(["userId": item.userId ?? "",
                          "quality": item.quality.rawValue] as [String : Any])
		}
		
		Utils.invokeListener(channel: channel, type: ListenerType.onNetworkQuality, params: [
			"localQuality": [
				"userId": localQuality.userId ?? "",
				"quality": localQuality.quality.rawValue
            ] as [String : Any],
			"remoteQuality": array
        ] as [String : Any])
	}
	
	/**
	* 技术指标统计回调
	*/
	 func onStatistics(_ statistics: TRTCStatistics) {
		var localArray: [Any] = []
		var remoteArray: [Any] = []
		
		for item in statistics.localStatistics {
			localArray.append([
				"width": item.width,
				"height": item.height,
				"frameRate": item.frameRate,
				"videoBitrate": item.videoBitrate,
				"audioSampleRate": item.audioSampleRate,
				"audioBitrate": item.audioBitrate,
				"streamType": item.streamType.rawValue,
                "audioCaptureState": item.audioCaptureState
            ] as [String : Any])
		}
		
		for item in statistics.remoteStatistics {
			remoteArray.append([
				"userId": item.userId ?? "",
                "audioPacketLoss": item.audioPacketLoss,
                "videoPacketLoss": item.videoPacketLoss,
				"finalLoss": item.finalLoss,
				"width": item.width,
				"height": item.height,
				"frameRate": item.frameRate,
				"videoBitrate": item.videoBitrate,
				"audioSampleRate": item.audioSampleRate,
				"audioBitrate": item.audioBitrate,
				"jitterBufferDelay": item.jitterBufferDelay,
                "point2PointDelay": item.point2PointDelay,
				"audioTotalBlockTime": item.audioTotalBlockTime,
				"audioBlockRate": item.audioBlockRate,
				"videoTotalBlockTime": item.videoTotalBlockTime,
				"videoBlockRate": item.videoBlockRate,
                "remoteNetworkUplinkLoss": item.remoteNetworkUplinkLoss,
                "remoteNetworkRTT": item.remoteNetworkRTT,
				"streamType": item.streamType.rawValue
            ] as [String : Any])
		}
		Utils.invokeListener(channel: channel, type: ListenerType.onStatistics, params: [
			"upLoss": statistics.upLoss,
			"downLoss": statistics.downLoss,
			"appCpu": statistics.appCpu,
			"systemCpu": statistics.systemCpu,
			"rtt": statistics.rtt,
            "gatewayRtt": statistics.gatewayRtt,
			"receiveBytes": statistics.receivedBytes,
			"sendBytes": statistics.sentBytes,
			"localArray": localArray,
			"remoteArray": remoteArray
        ] as [String : Any])
	}
    
    public func onSpeedTestResult(_ result: TRTCSpeedTestResult) {
        Utils.invokeListener(channel: self.channel, type: ListenerType.onSpeedTestResult,
                                params: ["result": ["availableDownBandwidth":(result as TRTCSpeedTestResult).availableDownBandwidth,
                                                           "availableUpBandwidth":(result as TRTCSpeedTestResult).availableUpBandwidth,
                                                           "downJitter":(result as TRTCSpeedTestResult).downJitter,
                                                           "downLostRate": Double((result as TRTCSpeedTestResult).downLostRate),
                                                           "errMsg":(result as TRTCSpeedTestResult).errMsg,
                                                           "ip":(result as TRTCSpeedTestResult).ip,
                                                           "quality":(result as TRTCSpeedTestResult).quality.rawValue,
                                                           "rtt":(result as TRTCSpeedTestResult).rtt,
                                                           "success":(result as TRTCSpeedTestResult).success,
                                                           "upJitter":(result as TRTCSpeedTestResult).upJitter,
                                                           "upLostRate":Double((result as TRTCSpeedTestResult).upLostRate)
                                                          ] as [String : Any]
                                        ] as [String : Any])
    }
	
	/**
	* SDK 跟服务器的连接断开
	*/
	 func onConnectionLost() {
		Utils.invokeListener(channel: channel, type: ListenerType.onConnectionLost, params: nil)
	}
	
	/**
	* SDK 尝试重新连接到服务器
	*/
	 func onTryToReconnect() {
		Utils.invokeListener(channel: channel, type: ListenerType.onTryToReconnect, params: nil)
	}
	
	/**
	* SDK 跟服务器的连接恢复
	*/
	 func onConnectionRecovery() {
		Utils.invokeListener(channel: channel, type: ListenerType.onConnectionRecovery, params: nil)
	}
	
	/**
	* 摄像头准备就绪
	*/
	 func onCameraDidReady() {
		Utils.invokeListener(channel: channel, type: ListenerType.onCameraDidReady, params: nil)
	}
	
	/**
	* 麦克风准备就绪
	*/
	 func onMicDidReady() {
		Utils.invokeListener(channel: channel, type: ListenerType.onMicDidReady, params: nil)
	}
	
	/**
	* 音频路由发生变化（仅 iOS），音频路由即声音由哪里输出（扬声器或听筒）
	*/
	 func onAudioRouteChanged(_ route: TRTCAudioRoute, from fromRoute: TRTCAudioRoute) {
		Utils.invokeListener(channel: channel, type: ListenerType.onAudioRouteChanged, params: ["route": route.rawValue, "fromRoute": fromRoute.rawValue])
	}
	
	
	/**
	* 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量
	*/
	 func onUserVoiceVolume(_ userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
		var userVolumeArray: [Any] = []
		for item in userVolumes {
			userVolumeArray.append([
				"userId": (item.userId == nil) ? "" : (item.userId!),
				"volume": item.volume
            ] as [String : Any])
		}
		
        Utils.invokeListener(channel: channel, type: ListenerType.onUserVoiceVolume, params: ["userVolumes": userVolumeArray,
                                                                                       "totalVolume": totalVolume] as [String : Any])
	}
	
	/**
	* 收到自定义消息回调
	*/
	 func onRecvCustomCmdMsgUserId(_ userId: String, cmdID: Int, seq: UInt32, message: Data) {
		Utils.invokeListener(channel: channel, type: ListenerType.onRecvCustomCmdMsg, params: [
			"userId": userId,
			"cmdID": cmdID,
			"seq": seq,
			"message": (String(data: message, encoding: String.Encoding.utf8) as String?) ?? ""
        ] as [String : Any])
	}
	
	/**
	* 自定义消息丢失回调
	*/
	 func onMissCustomCmdMsgUserId(_ userId: String, cmdID: Int, errCode: Int, missed: Int) {
		Utils.invokeListener(channel: channel, type: ListenerType.onMissCustomCmdMsg, params: [
			"userId": userId,
			"cmdID": cmdID,
			"errCode": errCode,
			"missed": missed
        ] as [String : Any])
	}
	
	/**
	* 收到 SEI 消息的回调
	*/
	 func onRecvSEIMsg(_ userId: String, message: Data) {
		Utils.invokeListener(channel: channel, type: ListenerType.onRecvSEIMsg, params: [
			"userId": userId,
			"message": (String(data: message, encoding: String.Encoding.utf8) as String?) ?? ""
		])
	}
	
	/**
	* 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
	*/
	 func onStartPublishing(_ err: Int32, errMsg: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onStartPublishing, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
	*/
	 func onStopPublishing(_ err: Int32, errMsg: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onStopPublishing, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
	*/
	 func onStartPublishCDNStream(_ err: Int32, errMsg: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onStartPublishCDNStream, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
	*/
	 func onStopPublishCDNStream(_ err: Int32, errMsg: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onStopPublishCDNStream, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。
	*/
	 func onSetMixTranscodingConfig(_ err: Int32, errMsg: String) {
		Utils.invokeListener(channel: channel, type: ListenerType.onSetMixTranscodingConfig, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 播放音效结束回调
	*/
	 func onAudioEffectFinished(_ effectId: Int32, code: Int32) {
		Utils.invokeListener(channel: channel, type: ListenerType.onAudioEffectFinished, params: [
			"effectId": effectId,
			"errCode": code
		])
	}
	
	/**
	* 当屏幕分享开始时，SDK 会通过此回调通知
	*/
	 func onScreenCaptureStarted() {
		Utils.invokeListener(channel: channel, type: ListenerType.onScreenCaptureStarted, params:nil)
	}

	/**
	* 当屏幕分享暂停时，SDK 会通过此回调通知
	*/
	 func onScreenCapturePaused(_ reason:Int32) {
		Utils.invokeListener(channel: channel, type: ListenerType.onScreenCapturePaused, params:reason)
	}

	/**
	* 当屏幕分享恢复时，SDK 会通过此回调通知
	*/
	 func onScreenCaptureResumed(_ reason:Int32) {
		Utils.invokeListener(channel: channel, type: ListenerType.onScreenCaptureResumed, params:reason)
	}

	/**
	* 当屏幕分享停止时，SDK 会通过此回调通知
	*/
	 func onScreenCaptureStoped(_ reason:Int32) {
		Utils.invokeListener(channel: channel, type: ListenerType.onScreenCaptureStoped, params:reason)
	}
    
    /**
     * 当本地录制任务已经开始时，SDK 会通过此回调通知
     */
    func onLocalRecordBegin(_ errCode: Int, storagePath: String) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onLocalRecordBegin,
                                        params: ["errCode": errCode,
                                                 "storagePath": storagePath])
    }
    
    /**
     * 当本地录制任务进行时，SDK 会周期性通过此回调通知
     * 您可以在 startLocalRecording 时设定本事件回调的抛出间隔。
     */
    func onLocalRecording(_ duration: Int, storagePath: String) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onLocalRecording,
                                        params: ["duration": duration,
                                                 "storagePath": storagePath])
    }

    /**
     *  当您开启分片录制时，每完成一个分片，SDK 会通过此回调通知
     */
    func onLocalRecordFragment(_ storagePath: String) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onLocalRecordFragment,
                                        params: ["storagePath": storagePath])
    }

  

    /**
     * 当本地录制任务已经结束，SDK 会通过此回调通知
     */
    func onLocalRecordComplete(_ errCode: Int, storagePath: String) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onLocalRecordComplete,
                                        params: ["errCode": errCode,
                                                 "storagePath": storagePath])
    }
    
	
    func onStartPublishMediaStream(_ taskId: String, code: Int32, message: String, extraInfo: [AnyHashable : Any]?) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onStartPublishMediaStream,
                                        params: ["taskId": taskId,
                                                 "code": code,
                                                 "message": message,
                                                 "extraInfo": extraInfo ?? [:],] as [String : Any])
    }
    
    func onUpdatePublishMediaStream(_ taskId: String, code: Int32, message: String, extraInfo: [AnyHashable : Any]?) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onUpdatePublishMediaStream,
                                        params: ["taskId": taskId,
                                                 "code": code,
                                                 "message": message,
                                                 "extraInfo": extraInfo ?? [:],] as [String : Any])
    }
    
    func onStopPublishMediaStream(_ taskId: String, code: Int32, message: String, extraInfo: [AnyHashable : Any]?) {
        Utils.invokeListener(channel: channel,
                                        type: ListenerType.onStopPublishMediaStream,
                                        params: ["taskId": taskId,
                                                 "code": code,
                                                 "message": message,
                                                 "extraInfo": extraInfo ?? [:],] as [String : Any])
    }
}
