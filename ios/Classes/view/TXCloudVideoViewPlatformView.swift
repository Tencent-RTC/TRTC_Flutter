//
//  TRTCPlatformView.swift
//  tencent_rtc_ffi
//
//  Created by iveshe on 2024/9/19.
//

import Flutter
import Foundation
import TXLiteAVSDK_Professional

class TXCloudVideoViewPlatformView : NSObject, FlutterPlatformView  {
    private var renderView : UIView
    private var frame : CGRect
    private var channel : FlutterMethodChannel
    
    init(_ frame : CGRect,_ messager: FlutterBinaryMessenger,_ viewId: Int64) {
        self.frame = frame
        self.renderView = UIView()
        self.channel = FlutterMethodChannel(name: "TRTCPlatformView_\(viewId)", binaryMessenger: messager)
        super.init()
        
        self.channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            self.onMethodCall(call: call, result: result)
        }
    }
    
    func view() -> UIView {
        return renderView
    }
    
    private func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "getTXView":
                let viewPtr = Unmanaged.passUnretained(self.renderView).toOpaque()
                let viewPtrValue = Int64(bitPattern: UInt64(UInt(bitPattern: viewPtr)))
                result(viewPtrValue)
                break
	        case "getViewId":
                let viewPtr = Unmanaged.passUnretained(self.renderView).toOpaque()
                let viewPtrValue = Int64(bitPattern: UInt64(UInt(bitPattern: viewPtr)))
                result(viewPtrValue)
                break
            case "deleteTXView":
                result(nil)
                break
            default:
                break
            }
        }
}
