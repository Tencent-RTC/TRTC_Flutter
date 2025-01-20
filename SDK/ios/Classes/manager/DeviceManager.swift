//
//  DeviceManager.swift
//  tencent_trtc_cloud
//
//  Created by 林智 on 2020/12/24.
//

import Foundation
import TXLiteAVSDK_Professional

class DeviceManager {
	private var txDeviceManager: TXDeviceManager
	
    
    init(cloud: TRTCCloud) {
        txDeviceManager = cloud.getDeviceManager()
    }
    
	/**
	* 切换摄像头
	*/
	public func switchCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let isFrontCamera = Utils.getParamByKey(call: call, result: result, param: "isFrontCamera") as? Bool {
			txDeviceManager.switchCamera(isFrontCamera)
			result(nil)
		}
        result(nil)
	}
	
	/**
	* 查询是前置摄像头
	*/
	public func isFrontCamera(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(txDeviceManager.isFrontCamera())
	}
	
	/**
	* 查询摄像头最大缩放率
	*/
	public func getCameraZoomMaxRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(Int(txDeviceManager.getCameraZoomMaxRatio()))
	}
	
	/**
	* 设置摄像头缩放率
	*/
	public func setCameraZoomRatio(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let value = Utils.getParamByKey(call: call, result: result, param: "value") as? Double {
			let ret = txDeviceManager.setCameraZoomRatio(CGFloat(value))
			result(ret)
		}
        result(nil)
	}
	
	/**
	* 设置摄像头缩放率
	*/
	public func enableCameraAutoFocus(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = Utils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
			result(txDeviceManager.enableCameraAutoFocus(enable))
		}
        result(nil)
	}
	
	/**
	* 设置摄像头闪光灯，开启后置摄像头才有效果
	*/
	public func enableCameraTorch(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = Utils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
			txDeviceManager.enableCameraTorch(enable)
			result(nil)
		}
        result(nil)
	}
	
	/**
	* 设置对焦位置
	*/
	public func setCameraFocusPosition(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let x = Utils.getParamByKey(call: call, result: result, param: "x") as? Int,
		   let y = Utils.getParamByKey(call: call, result: result, param: "y") as? Int {
			txDeviceManager.setCameraFocusPosition(CGPoint(x: CGFloat(x), y: CGFloat(y)))
			result(nil)
		}
        result(nil)
	}
	
	/**
	* 查询摄像头是否自动对焦
	*/
	public func isAutoFocusEnabled(call: FlutterMethodCall, result: @escaping FlutterResult) {
		result(txDeviceManager.isAutoFocusEnabled())
	}
	
	/**
	* 设置通话时使用的系统音量类型
	*/
	public func setSystemVolumeType(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let type = Utils.getParamByKey(call: call, result: result, param: "type") as? Int {
			txDeviceManager.setSystemVolumeType(TXSystemVolumeType(rawValue: type)!)
			result(nil)
		}
        result(nil)
	}
	
	/**
	* 设置音频路由
	*/
	public func setAudioRoute(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let route = Utils.getParamByKey(call: call, result: result, param: "route") as? Int {
			txDeviceManager.setAudioRoute(TXAudioRoute(rawValue: route)!)
			result(nil)
		}
        result(nil)
	}
}
