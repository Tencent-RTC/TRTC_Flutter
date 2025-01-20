//
//  DeviceManager.swift
//  tencent_trtc_cloud
//
//  Created by 林智 on 2020/12/24.
//
import Cocoa
import FlutterMacOS
import Foundation
import TXLiteAVSDK_TRTC_Mac

class DeviceManager {

    let channel: FlutterMethodChannel
        
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

	private var txDeviceManager: TXDeviceManager = TRTCCloud.sharedInstance().getDeviceManager()
	
	/**
	* 切换摄像头
	*/
	public func switchCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let isFrontCamera = CommonUtils.getParamByKey(call: call, result: result, param: "isFrontCamera") as? Bool {
//			//txDeviceManager.switchCamera(isFrontCamera)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* 查询是前置摄像头
	*/
	public func isFrontCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(false)
	}
	
	/**
	* 查询摄像头最大缩放率
	*/
	public func getCameraZoomMaxRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(Int(0))
	}
	
	/**
	* 设置摄像头缩放率
	*/
	public func setCameraZoomRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
// 		if let value = CommonUtils.getParamByKey(call: call, result: result, param: "value") as? String {
// //			let ret = txDeviceManager.setCameraZoomRatio(CGFloat(Int(Float(value)!)))
// 			result(0)
// 		}
		result(0)
	}
	
	/**
	* 设置摄像头缩放率
	*/
	public func enableCameraAutoFocus(call: FlutterMethodCall, result: @escaping FlutterResult) {
		// if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
		// 	result(0)
		// }
		result(0)
	}
	
	/**
	* 设置摄像头闪光灯，开启后置摄像头才有效果
	*/
	public func enableCameraTorch(call: FlutterMethodCall, result: @escaping FlutterResult) {
		// if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
		// 	//txDeviceManager.enableCameraTorch(enable)
		// 	result(nil)
		// }
		result(nil)
	}
	
	/**
	* 设置对焦位置
	*/
	public func setCameraFocusPosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
// 		if let x = CommonUtils.getParamByKey(call: call, result: result, param: "x") as? Int,
// 		   let y = CommonUtils.getParamByKey(call: call, result: result, param: "y") as? Int {
// //			txDeviceManager.setCameraFocusPosition(CGPoint(x: CGFloat(x), y: CGFloat(y)))
// 			result(nil)
// 		}
		result(nil)
	}
	
	/**
	* 查询摄像头是否自动对焦
	*/
	public func isAutoFocusEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
        //txDeviceManager.isAutoFocusEnabled()
		result(false)
	}
	
	/**
	* 设置通话时使用的系统音量类型
	*/
	public func setSystemVolumeType(call: FlutterMethodCall, result: @escaping FlutterResult) {
// 		if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int {
// //			txDeviceManager.setSystemVolumeType(TXSystemVolumeType(rawValue: type)!)
// 			result(nil)
// 		}
		result(nil)
	}
	/**
	* 设置音频路由
	*/
	public func setAudioRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
		// if let route = CommonUtils.getParamByKey(call: call, result: result, param: "route") as? Int {
		// 	//txDeviceManager.setAudioRoute(TXAudioRoute(rawValue: route)!)
		// 	result(nil)
		// }
		result(nil)
	}
    
    //pc 相关接口
    public func getDevicesList(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int{
            let devicesList:[TXMediaDeviceInfo]? =  txDeviceManager.getDevicesList(TXMediaDeviceType(rawValue: type)!)
            var ls:[[String: Any]] = []
            var devCount = 0
            if(devicesList != nil){
                devicesList?.forEach({ (item:TXMediaDeviceInfo) in
                    var obj: [String: Any] = [:]
                    obj["deviceId"] = item.deviceId
                    //obj["type"] = item.type
                    obj["deviceName"] = item.deviceName
                    devCount = devCount + 1
                    ls.append(obj)
                })
            }
            result(["deviceList":ls,
                    "count":devCount] as [String : Any])
        }
    }
    
    public func enableFollowingDefaultAudioDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int,
           let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
            txDeviceManager.enable(followingDefaultAudioDevice: TXMediaDeviceType(rawValue: type)!, enable: enable)
        }
        result(nil)
    }
    
    public func setCurrentDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int,
           let deviceId = CommonUtils.getParamByKey(call: call, result: result, param: "deviceId") as? String {
            let isOk = txDeviceManager.setCurrentDevice(TXMediaDeviceType(rawValue: type)!, deviceId: deviceId)
            result(isOk)
        }
    }
    
    public func getCurrentDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int{
            let deviceInfo:TXMediaDeviceInfo? = txDeviceManager.getCurrentDevice(TXMediaDeviceType(rawValue: type)!)
            if(deviceInfo != nil ){
                result(["deviceId":deviceInfo!.deviceId,"deviceName":deviceInfo!.deviceName])
            }
            else {
                result(nil)
            }
        }
    }
    
    public func setCurrentDeviceVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int,
           let volume = CommonUtils.getParamByKey(call: call, result: result, param: "volume") as? Int {
           let isOk = txDeviceManager.setCurrentDeviceVolume(type, deviceType: TXMediaDeviceType(rawValue: volume)!)
            result(isOk)
        }
    }
    
    public func getCurrentDeviceVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int{
            let isOk = txDeviceManager.getCurrentDeviceVolume(TXMediaDeviceType(rawValue: type)!)
            result(isOk)
        }
    }
    
    public func setCurrentDeviceMute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int,
           let mute = CommonUtils.getParamByKey(call: call, result: result, param: "mute") as? Bool {
            let isOk = txDeviceManager.setCurrentDeviceMute(mute, deviceType: TXMediaDeviceType(rawValue: type)!)
            result(isOk)
        }
    }
    
    public func getCurrentDeviceMute(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? Int{
            let isOk = txDeviceManager.getCurrentDeviceMute(TXMediaDeviceType(rawValue: type)!)
            result(isOk)
        }
    }
    
    public func startMicDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let interval = CommonUtils.getParamByKey(call: call, result: result, param: "interval") as? Int{
            let isOk = txDeviceManager.startMicDeviceTest(interval,testEcho:{ [weak self] volume in
                guard let self = self else { return }
                TencentTRTCCloud.invokeListener(channel: self.channel, type: ListenerType.onTestMicVolume, params: volume)
            })
            result(isOk)
        }
    }
    
    public func stopMicDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(txDeviceManager.stopMicDeviceTest())
    }
    
    public func startSpeakerDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let filePath = CommonUtils.getParamByKey(call: call, result: result, param: "filePath") as? String{
            let isOk = txDeviceManager.startSpeakerDeviceTest(filePath, onVolumeChanged: { [weak self] volume, isLastFrame in
                guard let self = self else { return }
                TencentTRTCCloud.invokeListener(channel: self.channel, type: ListenerType.onTestSpeakerVolume, params: [volume])
            })
            result(isOk)
        }
    }
    
    public func stopSpeakerDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(txDeviceManager.stopSpeakerDeviceTest())
    }
    // macos 无
    public func setApplicationPlayVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
    
    // macos 无
    public func getApplicationPlayVolume(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
    // macos 无
    public func setApplicationMuteState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
    // macos 无
    public func getApplicationMuteState(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(nil)
    }
}
