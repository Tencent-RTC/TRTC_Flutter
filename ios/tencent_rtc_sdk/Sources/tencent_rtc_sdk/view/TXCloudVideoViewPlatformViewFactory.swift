//
//  TRTCPlatformViewFactory.swift
//  tencent_rtc_ffi
//
//  Created by iveshe on 2024/9/19.
//
import Flutter
import Foundation

class TXCloudVideoViewPlatformViewFactory : NSObject, FlutterPlatformViewFactory {
    private var message : FlutterBinaryMessenger
    
    init(message: FlutterBinaryMessenger) {
        self.message = message
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args:
        Any?) -> any FlutterPlatformView {
        let view = TXCloudVideoViewPlatformView(frame, self.message, viewId)
        return view
    }
}
