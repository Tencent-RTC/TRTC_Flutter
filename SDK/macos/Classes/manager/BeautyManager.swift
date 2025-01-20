
//
//  BeautyManager.swift
//  tencent_trtc_cloud
//
//  Created by 林智 on 2020/12/24.
//
import Cocoa
import FlutterMacOS
import Foundation
import TXLiteAVSDK_TRTC_Mac

class BeautyManager {
    private var tRegistrar: FlutterPluginRegistrar?
    init(registrar: FlutterPluginRegistrar?){
        tRegistrar = registrar
    }
    
	private var txBeautyManager: TXBeautyManager = TRTCCloud.sharedInstance().getBeautyManager()
	
	/**
	* 设置美颜（磨皮）算法
	* TXBeautyStyleSmooth, TXBeautyStyleNature, TXBeautyStylePitu
	*/
	public func setBeautyStyle(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let beautyStyle = CommonUtils.getParamByKey(call: call, result: result, param: "beautyStyle") as? Int {
			txBeautyManager.setBeautyStyle(TXBeautyStyle(rawValue: beautyStyle)!)
			result(nil)
		}
	}
	
	/**
	* 设置美颜级别
	*/
	public func setBeautyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let beautyLevel = CommonUtils.getParamByKey(call: call, result: result, param: "beautyLevel") as? Int {
			txBeautyManager.setBeautyLevel(Float(beautyLevel))
			result(nil)
		}
	}
	
	/**
	* 设置美白级别
	*/
	public func setWhitenessLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let whitenessLevel = CommonUtils.getParamByKey(call: call, result: result, param: "whitenessLevel") as? Int {
			txBeautyManager.setWhitenessLevel(Float(whitenessLevel))
			result(nil)
		}
	}
	
	/**
	* 开启清晰度增强
	*/
	public func enableSharpnessEnhancement(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Bool {
			txBeautyManager.enableSharpnessEnhancement(enable)
			result(nil)
		}
	}
	
	/**
	* 设置红润级别
	*/
	public func setRuddyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let ruddyLevel = CommonUtils.getParamByKey(call: call, result: result, param: "ruddyLevel") as? Float {
			txBeautyManager.setRuddyLevel(ruddyLevel)
			result(nil)
		}
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
	* 设置指定素材滤镜特效
	* image 指定素材，即颜色查找表图片。必须使用 png 格式
	*/
	public func setFilter(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let imageUrl = CommonUtils.getParamByKey(call: call, result: result, param: "imageUrl") as? String,
		   let type = CommonUtils.getParamByKey(call: call, result: result, param: "type") as? String {
			
			if type == "local" {
                let img = NSImage(contentsOfFile:self.getFlutterBundlePath(assetPath:imageUrl)!)!

				txBeautyManager.setFilter(img)
			} else {
//				let queue = DispatchQueue(label: "setFilter")
//				queue.async {
//					let url: NSURL = NSURL(string: imageUrl)!
//					let data: NSData = NSData(contentsOf: url as URL)!
////					let img = UIImage(data: data as Data, scale: 1)!
//
//				}
                let img = NSImage(contentsOfFile:self.getFlutterBundlePath(assetPath:imageUrl)!)!
                txBeautyManager.setFilter(img)
			}
			
			result(nil)
		}
	}
	
	/**
	* 设置滤镜浓度
	*/
	public func setFilterStrength(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let strength = CommonUtils.getParamByKey(call: call, result: result, param: "strength") as? String {
			txBeautyManager.setFilterStrength(Float(strength)!)
			result(nil)
		}
	}
	
	/**
	* TODO: 设置大眼级别，该接口仅在 企业版 SDK 中生效
	*/
	public func setEyeScaleLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setEyeScaleLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置瘦脸级别，该接口仅在 企业版 SDK 中生效
	*/
	public func setFaceSlimLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setFaceSlimLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置 V 脸级别，该接口仅在 企业版 SDK 中生效
	*/
	public func setFaceVLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setFaceVLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置下巴拉伸或收缩，该接口仅在 企业版 SDK 中生效
	*/
	public func setChinLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setChinLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置短脸级别，该接口仅在 企业版 SDK 中生效
	*/
	public func setFaceShortLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setFaceShortLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置瘦鼻级别，该接口仅在 企业版 SDK 中生效
	*/
	public func setNoseSlimLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setNoseSlimLevel(enable)
//
//            result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO：设置亮眼 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setEyeLightenLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setEyeLightenLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO：设置白牙 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setToothWhitenLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setToothWhitenLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置祛皱 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setWrinkleRemoveLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setWrinkleRemoveLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置祛眼袋 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setPounchRemoveLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setPounchRemoveLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置法令纹 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setSmileLinesRemoveLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setSmileLinesRemoveLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置发际线 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setForeheadLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setForeheadLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置眼距 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setEyeDistanceLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setEyeDistanceLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置眼角 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setEyeAngleLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setEyeAngleLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置嘴型 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setMouthShapeLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setMouthShapeLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置鼻翼 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setNoseWingLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setNoseWingLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置鼻子位置 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setNosePositionLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setNosePositionLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置嘴唇厚度 ，该接口仅在 企业版 SDK 中生效
	*/
	public func setLipsThicknessLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setLipsThicknessLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
	
	/**
	* TODO: 设置脸型，该接口仅在 企业版 SDK 中生效
	*/
	public func setFaceBeautyLevel(call: FlutterMethodCall, result: @escaping FlutterResult) {
//		if let enable = CommonUtils.getParamByKey(call: call, result: result, param: "enable") as? Float {
//			//txBeautyManager.setFaceBeautyLevel(enable)
//			result(nil)
//		}
        result(nil)
	}
}
