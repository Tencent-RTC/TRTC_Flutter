//
//  Listener.swift
//  tencent_im_sdk_plugin
//
//  Created by 林智 on 2020/12/18.
//

import Foundation
import TXLiteAVSDK_TRTC_Mac

class Listener: NSObject, TRTCCloudDelegate {

    let channel: FlutterMethodChannel
        
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

	/**
	* 错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示。
	*/
	public func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable: Any]?) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onError, params: ["errCode": errCode.rawValue, "errMsg": errMsg ?? "", "extraInfo": extInfo as Any])
	}
	
	/**
	* 警告回调，用于告知您一些非严重性问题，例如出现了卡顿或者可恢复的解码失败。
	*/
	public func onWarning(_ warningCode: TXLiteAVWarning, warningMsg: String?, extInfo: [AnyHashable: Any]?) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onWarning, params: ["warningCode": warningCode.rawValue, "warningMsg": warningMsg  ?? "", "extraInfo": extInfo as Any])
	}
	
	/**
	* 已加入房间的回调
	*/
	public func onEnterRoom(_ result: Int) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onEnterRoom, params: result)
	}
	
	/**
	* 离开房间的事件回调
	*/
	public func onExitRoom(_ reason: Int) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onExitRoom, params: reason)
	}
	
	/**
	* 切换角色的事件回调
	*/
	public func onSwitchRole(_ errCode: TXLiteAVError, errMsg: String?) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onSwitchRole, params: ["errCode": errCode.rawValue,
                                                                                  "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 请求跨房通话（主播 PK）的结果回调
	*/
	public func onConnectOtherRoom(_ userId: String, errCode: TXLiteAVError, errMsg: String?) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onConnectOtherRoom, params: ["userId": userId,
                                                                                        "errCode": errCode.rawValue,
                                                                                        "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 切换房间 (switchRoom) 的结果回调
	*/
	public func onSwitchRoom(_ errCode: TXLiteAVError, errMsg: String?) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onSwitchRoom, params: ["errCode": errCode.rawValue,
                                                                                  "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 结束跨房通话（主播 PK）的结果回调
	*/
	public func onDisconnectOtherRoom(_ errCode: TXLiteAVError, errMsg: String?) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onDisConnectOtherRoom, params: ["errCode": errCode.rawValue,
                                                                                           "errMsg": errMsg ?? ""] as [String : Any])
	}
	
	/**
	* 有用户加入当前房间
	*/
	public func onRemoteUserEnterRoom(_ userId: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onRemoteUserEnterRoom, params: userId)
	}
	
	/**
	* 有用户离开当前房间
	*/
	public func onRemoteUserLeaveRoom(_ userId: String, reason: Int) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onRemoteUserLeaveRoom, params: ["userId": userId,
                                                                                           "reason": reason] as [String : Any])
	}
	
	/**
	* 有用户上传视频数据
	*/
	public func onUserVideoAvailable(_ userId: String, available: Bool) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onUserVideoAvailable, params: ["userId": userId,
                                                                                          "available": available] as [String : Any])
	}
	
	/**
	* 远端用户是否存在可播放的辅路画面（一般用于屏幕分享）
	*/
	public func onUserSubStreamAvailable(_ userId: String, available: Bool) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onUserSubStreamAvailable, params: ["userId": userId,
                                                                                              "available": available] as [String : Any])
	}
	
	/**
	* 远端用户是否存在可播放的音频数据
	*/
	public func onUserAudioAvailable(_ userId: String, available: Bool) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onUserAudioAvailable, params: ["userId": userId,
                                                                                          "available": available] as [String : Any])
	}
	
	/**
	* 开始渲染本地或远程用户的首帧画面。
	*/
	public func onFirstVideoFrame(_ userId: String, streamType: TRTCVideoStreamType, width: Int32, height: Int32) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onFirstVideoFrame, params: ["userId": userId,
                                                                                       "streamType": streamType.rawValue,
                                                                                       "width": width,
                                                                                       "height": height] as [String : Any])
	}
	
	/**
	* 开始播放远程用户的首帧音频（本地声音暂不通知）
	*/
	public func onFirstAudioFrame(_ userId: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onFirstAudioFrame, params: userId)
	}
	
	/**
	* 首帧本地视频数据已经被送出
	*/
	public func onSendFirstLocalVideoFrame(_ streamType: TRTCVideoStreamType) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onSendFirstLocalVideoFrame, params: streamType.rawValue)
	}
	
	/**
	* 首帧本地音频数据已经被送出
	*/
	public func onSendFirstLocalAudioFrame() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onSendFirstLocalAudioFrame, params: nil)
	}
    
    public func onSystemAudioLoopbackError(_ err: TXLiteAVError) {
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onSystemAudioLoopbackError, params: ["errCode": err.rawValue] as [String : Any])
    }
	
	/**
	* 网络质量：该回调每2秒触发一次，统计当前网络的上行和下行质量。
	*/
	public func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
		var array: [Any] = []
		
		for item in remoteQuality {
            array.append(["userId": item.userId ?? "",
                          "quality": item.quality.rawValue] as [String : Any])
		}
		
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onNetworkQuality, params: [
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
	public func onStatistics(_ statistics: TRTCStatistics) {
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
				"streamType": item.streamType.rawValue
            ] as [String : Any])
		}
		
		for item in statistics.remoteStatistics {
			remoteArray.append([
				"userId": item.userId ?? "",
				"finalLoss": item.finalLoss,
				"width": item.width,
				"height": item.height,
				"frameRate": item.frameRate,
				"videoBitrate": item.videoBitrate,
				"audioSampleRate": item.audioSampleRate,
				"audioBitrate": item.audioBitrate,
				"jitterBufferDelay": item.jitterBufferDelay,
				"audioTotalBlockTime": item.audioTotalBlockTime,
				"audioBlockRate": item.audioBlockRate,
				"videoTotalBlockTime": item.videoTotalBlockTime,
				"videoBlockRate": item.videoBlockRate,
				"streamType": item.streamType.rawValue
            ] as [String : Any])
		}
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onStatistics, params: [
			"upLoss": statistics.upLoss,
			"downLoss": statistics.downLoss,
			"appCpu": statistics.appCpu,
			"systemCpu": statistics.systemCpu,
			"rtt": statistics.rtt,
			"receivedBytes": statistics.receivedBytes,
			"sendBytes": statistics.sentBytes,
			"localArray": localArray,
			"remoteArray": remoteArray
        ] as [String : Any])
	}
	
	/**
	* SDK 跟服务器的连接断开
	*/
	public func onConnectionLost() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onConnectionLost, params: nil)
	}
    
    public func onSpeedTestResult(_ result: TRTCSpeedTestResult) {
        TencentTRTCCloud.invokeListener(channel: self.channel, type: ListenerType.onSpeedTestResult,
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
	* SDK 尝试重新连接到服务器
	*/
	public func onTryToReconnect() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onTryToReconnect, params: nil)
	}
	
	/**
	* SDK 跟服务器的连接恢复
	*/
	public func onConnectionRecovery() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onConnectionRecovery, params: nil)
	}
	
	/**
	* 摄像头准备就绪
	*/
	public func onCameraDidReady() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onCameraDidReady, params: nil)
	}
	
	/**
	* 麦克风准备就绪
	*/
	public func onMicDidReady() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onMicDidReady, params: nil)
	}
	
    public func onDevice(_ deviceId: String, type deviceType: TRTCMediaDeviceType, stateChanged state: Int) {
        var params:[String:Any] = [:]
        params["device_id"] = deviceId
        params["type"] = deviceType
        params["state"] = state
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onDeviceChange, params: ["params":params])
    }
	/**
	* 音频路由发生变化（仅 iOS），音频路由即声音由哪里输出（扬声器或听筒）
	*/
	public func onAudioRouteChanged(_ route: TRTCAudioRoute, from fromRoute: TRTCAudioRoute) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onAudioRouteChanged, params: ["newRoute": route.rawValue, "oldRoute": fromRoute.rawValue])
	}
	
	/**
	* 用于提示音量大小的回调，包括每个 userId 的音量和远端总音量
	*/
	public func onUserVoiceVolume(_ userVolumes: [TRTCVolumeInfo], totalVolume: Int) {
		var userVolumeArray: [Any] = []
		for item in userVolumes {
			userVolumeArray.append([
				"userId": (item.userId == nil) ? "" : (item.userId!),
				"volume": item.volume
            ] as [String : Any])
		}
		
        TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onUserVoiceVolume, params: ["userVolumes": userVolumeArray,
                                                                                       "totalVolume": totalVolume] as [String : Any])
	}
	
	/**
	* 收到自定义消息回调
	*/
	public func onRecvCustomCmdMsgUserId(_ userId: String, cmdID: Int, seq: UInt32, message: Data) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onRecvCustomCmdMsg, params: [
			"userId": userId,
			"cmdID": cmdID,
			"seq": seq,
			"message": String(data: message, encoding: String.Encoding.utf8) as String? as Any
		])
	}
	
	/**
	* 自定义消息丢失回调
	*/
	public func onMissCustomCmdMsgUserId(_ userId: String, cmdID: Int, errCode: Int, missed: Int) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onMissCustomCmdMsg, params: [
			"userId": userId,
			"cmdID": cmdID,
			"errCode": errCode,
			"missed": missed
        ] as [String : Any])
	}
	
	/**
	* 收到 SEI 消息的回调
	*/
	public func onRecvSEIMsg(_ userId: String, message: Data) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onRecvSEIMsg, params: [
			"userId": userId,
			"message": String(data: message, encoding: String.Encoding.utf8) as String? as Any
		])
	}
	
	/**
	* 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
	*/
	public func onStartPublishing(_ err: Int32, errMsg: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onStartPublishing, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
	*/
	public func onStopPublishing(_ err: Int32, errMsg: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onStopPublishing, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 开始向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 startPublishing() 接口
	*/
	public func onStartPublishCDNStream(_ err: Int32, errMsg: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onStartPublishCDNStream, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 停止向腾讯云的直播 CDN 推流的回调，对应于 TRTCCloud 中的 stopPublishing() 接口
	*/
	public func onStopPublishCDNStream(_ err: Int32, errMsg: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onStopPublishCDNStream, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 设置云端的混流转码参数的回调，对应于 TRTCCloud 中的 setMixTranscodingConfig() 接口。
	*/
	public func onSetMixTranscodingConfig(_ err: Int32, errMsg: String) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onSetMixTranscodingConfig, params: [
			"errCode": err,
			"errMsg": errMsg
        ] as [String : Any])
	}
	
	/**
	* 播放音效结束回调
	*/
	public func onAudioEffectFinished(_ effectId: Int32, code: Int32) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onAudioEffectFinished, params: [
			"effectId": effectId,
			"errCode": code
		])
	}
	
	/**
	* 当屏幕分享开始时，SDK 会通过此回调通知
	*/
	public func onScreenCaptureStarted() {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onScreenCaptureStarted, params:nil)
	}

	/**
	* 当屏幕分享暂停时，SDK 会通过此回调通知
	*/
	public func onScreenCapturePaused(_ reason:Int32) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onScreenCapturePaused, params:reason)
	}

	/**
	* 当屏幕分享恢复时，SDK 会通过此回调通知
	*/
	public func onScreenCaptureResumed(_ reason:Int32) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onScreenCaptureResumed, params:reason)
	}

	/**
	* 当屏幕分享停止时，SDK 会通过此回调通知
	*/
	public func onScreenCaptureStoped(_ reason:Int32) {
		TencentTRTCCloud.invokeListener(channel: channel, type: ListenerType.onScreenCaptureStoped, params:reason)
	}
}
