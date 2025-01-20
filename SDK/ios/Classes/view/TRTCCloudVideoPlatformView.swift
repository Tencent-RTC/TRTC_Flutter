import TXLiteAVSDK_Professional
import Flutter


class TRTCCloudVideoPlatformViewFactory : NSObject,FlutterPlatformViewFactory{

    static let SIGN = "trtcCloudChannelView"
	private var message : FlutterBinaryMessenger
	
	init(message : FlutterBinaryMessenger) {
		self.message = message
	}
	
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        Utils.txf_log_info(content: "TRTCCloudVideoPlatformView| create new TRTCCloudVideoPlatformView, viewId: \(viewId)")
        let view = TRTCCloudVideoPlatformView(frame,self.message,viewId)
		
//		// 绑定方法监听
//		FlutterMethodChannel(
//			name: "\(TRTCCloudVideoPlatformViewFactory.SIGN)_\(viewId)",
//			binaryMessenger: message
//		).setMethodCallHandler(view.handle)
		
		return view
	}
}

class TRTCCloudVideoPlatformView : NSObject,FlutterPlatformView{
	private var remoteView : UIView
	private var frame : CGRect
    private let channel: FlutterMethodChannel?
    private var trtcCloud: TRTCCloud?
	init(_ frame : CGRect,_ messager: FlutterBinaryMessenger,_ viewId: Int64) {
		self.frame = frame
		self.remoteView = UIView()
        self.channel = FlutterMethodChannel(name: "trtcCloudChannelView_\(viewId)", binaryMessenger: messager)
        super.init()
        self.channel?.setMethodCallHandler({ [weak self] call, result in
            guard let self = self else { return }
            self.handle(call, result: result)
        })
	}
	
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let channelName = Utils.getParamByKey(call: call, result: result, param: "channelName") as? String {
            Utils.txf_log_info(content: "TRTCCloudVideoPlatformView|channel=\(channelName)|method=\(call.method)|arguments: \(call.arguments as Any)")
            trtcCloud = TRTCCloudWrapper.cloudMap[channelName]!.getTRTCCloud()
            switch call.method {
            case "startRemoteView":
                self.startRemoteView(call: call, result: result)
                break
            case "startLocalPreview":
                self.startLocalPreview(call: call, result: result)
                break
            case "updateLocalView":
                self.updateLocalView(call: call, result: result)
                break
            case "updateRemoteView":
                self.updateRemoteView(call: call, result: result)
                break
            default:
                result(FlutterMethodNotImplemented)
            }
        }
	}
	
    func view() -> UIView {
		return remoteView
	}
	
	deinit {
        if channel != nil {
            channel?.setMethodCallHandler(nil)
        }
	}
	
    func startRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = Utils.getParamByKey(call: call, result: result, param: "userId") as? String, 
      	let streamType = Utils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
            if let cloud = trtcCloud {
                cloud.startRemoteView(userId, streamType: TRTCVideoStreamType(rawValue: streamType) ?? .big, view: self.remoteView)
                result(nil)
            }
		}
	}
	
    func startLocalPreview(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let frontCamera = Utils.getParamByKey(call: call, result: result, param: "frontCamera") as? Bool{
            if let cloud = trtcCloud {
                cloud.startLocalPreview(frontCamera, view: self.remoteView)
                result(nil)
            }
		}
	}

    func updateLocalView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let cloud = trtcCloud {
            cloud.updateLocalView(self.remoteView)
            result(nil)
        }
    }

    func updateRemoteView(call: FlutterMethodCall, result: @escaping FlutterResult) {
		if let userId = Utils.getParamByKey(call: call, result: result, param: "userId") as? String, 
			let streamType = Utils.getParamByKey(call: call, result: result, param: "streamType") as? Int {
            if let cloud = trtcCloud {
                cloud.updateRemoteView(self.remoteView, streamType: TRTCVideoStreamType(rawValue: streamType) ?? .big, forUser: userId)
                result(nil)
            }
		}
    }
}
