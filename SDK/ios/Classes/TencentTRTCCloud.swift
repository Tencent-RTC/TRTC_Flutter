import Foundation
import TXCustomBeautyProcesserPlugin


public class TencentTRTCCloud: NSObject, FlutterPlugin {
    private static var customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory? = nil
    private static let beautyQueue = DispatchQueue(label: "live_beauty_queue")
    private static var cloudWrapper: TRTCCloudWrapper? =  nil


    public static func register(with registrar: FlutterPluginRegistrar) {
        cloudWrapper = TRTCCloudWrapper(registrar: registrar)
        
        let viewFactory = TRTCCloudVideoPlatformViewFactory(message: registrar.messenger())
        registrar.register(viewFactory,withId: TRTCCloudVideoPlatformViewFactory.SIGN)
    }
    
    @objc public static func register(customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory) {
        let updateBeautyWorkItem = DispatchWorkItem {
            self.customBeautyProcesserFactory = customBeautyProcesserFactory
        }
        beautyQueue.sync(execute: updateBeautyWorkItem)
    }
    
    public static func getBeautyInstance() -> ITXCustomBeautyProcesserFactory? {
        var customBeautyProcesserFactory: ITXCustomBeautyProcesserFactory? = nil
        let getBeautyWorkItem = DispatchWorkItem {
            customBeautyProcesserFactory = self.customBeautyProcesserFactory
        }
        beautyQueue.sync(execute: getBeautyWorkItem)
        return customBeautyProcesserFactory
    }
}
