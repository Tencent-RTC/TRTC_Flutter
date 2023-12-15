import UIKit
import Flutter
import tencent_trtc_cloud
import TXCustomBeautyProcesserPlugin
import TXLiteAVSDK_Professional

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var channel: FlutterMethodChannel?
    
    override func application(_ application: UIApplication,
                              didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        lazy var customBeautyInstance: TRTCVideoCustomPreprocessor = {
            let customBeautyInstance = TRTCVideoCustomPreprocessor()
            customBeautyInstance.brightness = 0.5
            return customBeautyInstance
        }()
        TencentTRTCCloud.register(customBeautyProcesserFactory: customBeautyInstance)
        GeneratedPluginRegistrant.register(with: self)
        
        // Access the onCapturedAudioFrame interface Step 1: Use MethodChannel to turn on or off custom audio processing
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("Invalid root view controller")
        }
        channel = FlutterMethodChannel(name: "TRCT_FLUTTER_EXAMPLE", binaryMessenger: controller.binaryMessenger)
        channel?.setMethodCallHandler({ [weak self] call, result in
            guard let self = self else { return }
            switch (call.method) {
            case "enableTRTCAudioFrameDelegate":
                self.enableTRTCAudioFrameDelegate(call: call, result: result)
                break
            case "disableTRTCAudioFrameDelegate":
                self.disableTRTCAudioFrameDelegate(call: call, result: result)
                break
            default:
                break
            }
        })
        //Objective-C:
        //      FlutterViewController *controller = (FlutterViewController *)self.window.rootViewController;
        //      FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:@"TRCT_FLUTTER_EXAMPLE" binaryMessenger:[controller binaryMessenger]];
        //      [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        //          if ([@"enableTRTCAudioFrameDelegate" isEqualToString:call.method]) {
        //              [self enableTRTCAudioFrameDelegate:call result:result];
        //          } else if ([@"disableTRTCAudioFrameDelegate" isEqualToString:call.method]) {
        //              [self disableTRTCAudioFrameDelegate:call result:result];
        //          }
        //      }];
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Access the onCapturedAudioFrame interface Step 2.1 : set AudioFrameDelegate
    let listener = AudioFrameProcessListener()
    func enableTRTCAudioFrameDelegate(call: FlutterMethodCall, result: FlutterResult) {
        TRTCCloud.sharedInstance().setAudioFrameDelegate(listener)
        result(nil)
    }
    // Access the onCapturedAudioFrame interface Step 2.2 : remove AudioFrameDelegate
    func disableTRTCAudioFrameDelegate(call: FlutterMethodCall, result: FlutterResult) {
        TRTCCloud.sharedInstance().setAudioFrameDelegate(nil)
        result(nil)
    }
    //Objective-C:
    //    AudioFrameProcessListener *listener = [AudioFrameProcessListener new];
    //    - (void)enableTRTCAudioFrameDelegate:(FlutterMethodCall *)call result:(FlutterResult)result {
    //        [[TRTCCloud sharedInstance] setAudioFrameDelegate:listener];
    //        result(nil);
    //    }
    //
    //    - (void)disableTRTCAudioFrameDelegate:(FlutterMethodCall *)call result:(FlutterResult)result {
    //        [[TRTCCloud sharedInstance] setAudioFrameDelegate:nil];
    //        result(nil);
    //    }
    
}

// Access the onCapturedAudioFrame interface Step 3: get audio frame & handle your business
class AudioFrameProcessListener: NSObject, TRTCAudioFrameDelegate {
    func onCapturedAudioFrame(_ frame: TRTCAudioFrame) {
        //MARK: TODO
        print("TRTCAudioFrameDelegate onCapturedAudioFrame \(frame)")
    }
}
//Objective-C:
//@interface AudioFrameProcessListener : NSObject <TRTCAudioFrameDelegate>
//@end
//
//@implementation AudioFrameProcessListener
//- (void)onCapturedAudioFrame:(TRTCAudioFrame *)frame {
//    //MARK: TODO
//    NSLog(@"TRTCAudioFrameDelegate onCapturedAudioFrame %@", frame);
//}
//@end

extension TRTCVideoCustomPreprocessor: ITXCustomBeautyProcesserFactory {
    public func createCustomBeautyProcesser() -> ITXCustomBeautyProcesser {
        return self
    }
    
    public func destroyCustomBeautyProcesser() {
        invalidateBindedTexture()
    }
}

extension TRTCVideoCustomPreprocessor: ITXCustomBeautyProcesser {
    public func getSupportedPixelFormat() -> ITXCustomBeautyPixelFormat {
        return .Texture2D
    }
    
    public func getSupportedBufferType() -> ITXCustomBeautyBufferType {
        return .Texture
    }
    
    public func onProcessVideoFrame(srcFrame: ITXCustomBeautyVideoFrame, dstFrame: ITXCustomBeautyVideoFrame) -> ITXCustomBeautyVideoFrame {
        let outPutTextureId = processTexture(srcFrame.textureId, width: UInt32(srcFrame.width), height: UInt32(srcFrame.height))
        dstFrame.textureId = outPutTextureId
        return dstFrame
    }
}
