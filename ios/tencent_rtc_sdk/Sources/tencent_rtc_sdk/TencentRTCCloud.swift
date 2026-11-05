//
//  TencentRTCCloud.swift
//  tencent_rtc_ffi
//
//  Created by iveshe on 2024/9/19.
//

import Flutter
import Foundation
#if canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#elseif canImport(TXLiteAVSDK_Professional_Player_Premium)
import TXLiteAVSDK_Professional_Player_Premium
#elseif canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Live)
import TXLiteAVSDK_Live
#elseif canImport(TXLiteAVSDK_Player_Premium)
import TXLiteAVSDK_Player_Premium
#elseif canImport(TXLiteAVSDK_Player)
import TXLiteAVSDK_Player
#endif
import TXCustomBeautyProcesserPlugin

public class TencentRTCCloud: NSObject, FlutterPlugin {
    private static var customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory? = nil
    private static let beautyQueue = DispatchQueue(label: "live_beauty_queue")
    
    private static var cloudManager: TRTCCloudManager?
    private static var videoViewChannel: TXCloudVideoViewChannel?
    @objc public static var sObserver: V2TXLivePusherObserver?

    /// Whether TencentRTCCloud has been registered as an ApplicationDelegate.
    /// Done only once so that `applicationWillTerminate` fires a single time.
    private static var appDelegateRegistered = false

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "TencentRTCffi", binaryMessenger: registrar.messenger())
        let videoViewChannel = TXCloudVideoViewChannel(registrar: registrar)
        self.videoViewChannel = videoViewChannel
        cloudManager = TRTCCloudManager(channel: channel, videoViewChannel: videoViewChannel)
        
        let viewFactory = TXCloudVideoViewPlatformViewFactory(message: registrar.messenger())
        registrar.register(viewFactory,withId: "TXCloudVideoViewPlatformView")

        // Register as a FlutterPlugin so that applicationWillTerminate is delivered.
        // Register only once to avoid multiple destroy() calls in multi-engine setups.
        if !appDelegateRegistered {
            appDelegateRegistered = true
            let instance = TencentRTCCloud()
            registrar.addApplicationDelegate(instance)
        }
    }
    
    public static func getBeautyProcesserFactory() -> ITXCustomBeautyProcesserFactory? {
        var result: ITXCustomBeautyProcesserFactory?
            beautyQueue.sync {
                result = self.customBeautyProcesserFactory
            }
        return result
    }
    
    @objc public static func setBeautyProcesserFactory(factory: ITXCustomBeautyProcesserFactory) {
        customBeautyProcesserFactory = factory
    }
}
