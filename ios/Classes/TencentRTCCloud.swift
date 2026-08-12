//
//  TencentRTCCloud.swift
//  tencent_rtc_ffi
//
//  Created by iveshe on 2024/9/19.
//

import Flutter
import Foundation
import TXLiteAVSDK_Professional
import TXCustomBeautyProcesserPlugin

public class TencentRTCCloud: NSObject, FlutterPlugin {
    private static var customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory? = nil
    private static let beautyQueue = DispatchQueue(label: "live_beauty_queue")
    
    private static var cloudManager: TRTCCloudManager?
    private static var videoViewChannel: TXCloudVideoViewChannel?
    @objc public static var sObserver: V2TXLivePusherObserver?

    /// Vod module entry: owns the TencentVodPlugin / TencentVodPlayer / TencentVodDownload
    /// MethodChannels and routes player / download / PiP events.
    ///
    /// In multi-FlutterEngine setups `register(with:)` is invoked multiple times.
    /// A per-engine handler is stored keyed by messenger identity so that a later
    /// registration does not overwrite the earlier one.
    private static var vodHandlers: [ObjectIdentifier: VodMethodChannelHandler] = [:]

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

        // Mount the Vod module. Create a per-engine handler and store it keyed by messenger
        // to prevent a later registration from releasing an earlier handler via ARC.
        let handler = VodMethodChannelHandler(registrar: registrar)
        let key = ObjectIdentifier(registrar.messenger() as AnyObject)
        vodHandlers[key] = handler

        // Register as a FlutterPlugin so that applicationWillTerminate is delivered.
        // Register only once to avoid multiple destroy() calls in multi-engine setups.
        if !appDelegateRegistered {
            appDelegateRegistered = true
            let instance = TencentRTCCloud()
            registrar.addApplicationDelegate(instance)
        }
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        // Dispose every engine's vod handler on process exit.
        for (_, h) in TencentRTCCloud.vodHandlers {
            h.applicationWillTerminate()
        }
        TencentRTCCloud.vodHandlers.removeAll()
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
