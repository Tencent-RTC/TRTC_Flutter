//
//  Util.swift
//  tencent_rtc_sdk
//
//  Created by iveshe on 2024/9/20.
//
import Flutter
import Foundation



public class Utils{
    /**
     * 获得参数，不存在则中断
     */
    public static func getParamByKey(call: FlutterMethodCall, param : String, result: @escaping FlutterResult) -> Any? {
                let value = (call.arguments as! [String:Any])[param]
        
        if value == nil{
            result(
                FlutterError(code: "-1001",  message: "Error",details: "Can not find `\(param)`")
                        )
        }
        
        return value
    }
    
    public static func getValueInMap(map: [String: Any], key: String, result: @escaping FlutterResult) -> Any? {
                let value = map[key]
        
        if value == nil {
            result(
                FlutterError(code: "-1001",  message: "Error",details: "Can not find `\(key)`")
                        )
        }
        
        return value
    }
    
    
    /**
    * 获得参数，不存在返回nil
    */
    public static func getParamByKeyCanBeNull(call: FlutterMethodCall, param : String, result:
        @escaping FlutterResult) -> Any? {
                let value = (call.arguments as! [String:Any])[param]
        
        if value is NSNull || value == nil {
            return nil
        }
        
        return value
    }
    
}
