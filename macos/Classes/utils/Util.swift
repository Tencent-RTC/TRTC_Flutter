//
//  Util.swift
//  tencent_rtc_sdk
//
//  Created by iveshe on 2024/9/20.
//
import FlutterMacOS
import Foundation



public class Utils{
    /**
     * 获得参数，不存在则中断
     */
    public static func getParamByKey(call: FlutterMethodCall, result: @escaping FlutterResult, param : String) -> Any? {
                let value = (call.arguments as! [String:Any])[param]
        
        if value == nil{
            result(
                FlutterError(code: "-1001",  message: "Error",details: "Can not find `\(param)`")
                        )
        }
        
        return value
    }
    
    
    /**
    * 获得参数，不存在返回nil
    */
    public static func getParamByKeyCanBeNull(call: FlutterMethodCall, result: @escaping FlutterResult, param :
        String) -> Any? {
                let value = (call.arguments as! [String:Any])[param]
        
        if value is NSNull || value == nil {
            return nil
        }
        
        return value
    }
    
}
