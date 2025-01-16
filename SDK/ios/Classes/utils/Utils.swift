import Flutter
import TXLiteAVSDK_Professional
import TXCustomBeautyProcesserPlugin

public class Utils{
	/**
	* 获得参数，不存在则中断
	*/
	public static func getParamByKey(call: FlutterMethodCall, result: @escaping FlutterResult, param : String) -> Any? {
		let value = (call.arguments as! [String:Any])[param];
		
		if value == nil{
			result(
				FlutterError(code: "-1001",  message: "Error",details: "Can not find `\(param)`")
			);
		}
		
		return value
	}
    
    static func invokeListener(channel: FlutterMethodChannel, type: ListenerType, params: Any?) {
        var resultParams: [String: Any] = [:]
        resultParams["type"] = type
        if let p = params { resultParams["params"] = p }
        DispatchQueue.main.async {
            channel.invokeMethod(TRTCCloudWrapper.LISTENER_FUNC_NAME, arguments: JsonUtil.toJson(resultParams))
        }
    }
	
	/**
	* 获得参数，不存在返回nil
	*/
	public static func getParamByKeyCanBeNull(call: FlutterMethodCall, result: @escaping FlutterResult, param : String) -> Any? {
		let value = (call.arguments as! [String:Any])[param];
		
		if value is NSNull || value == nil {
			return nil
		}
		
		return value
	}
	
	static func txf_log_info(file: String = #file,
							 line: Int = #line,
							 function: String = #function,
							 content: String) {
        let message = "TRTCCloudPlugin \(content)"
		txf_log_swift(TXE_LOG_INFO, file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), message.cString(using: .utf8))
	}
	 
	static func txf_log_error(file: String = #file,
							  line: Int = #line,
							  function: String = #function,
							  content: String) {
        let message = "TRTCCloudPlugin \(content)"
		txf_log_swift(TXE_LOG_ERROR, file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), message.cString(using: .utf8))
	}
	
}

@objc
public class ConvertBeautyFrame: NSObject {
    
    public static func convertToV2LiveBufferType(beautyBufferType: ITXCustomBeautyBufferType) -> V2TXLiveBufferType {
        switch beautyBufferType {
        case .Unknown:
            return .unknown
        case .PixelBuffer:
            return .pixelBuffer
        case .Data:
            return .nsData
        case .Texture:
            return .texture
        }
    }
        
    public static func convertToTRTCBufferType(beautyBufferType: ITXCustomBeautyBufferType) -> TRTCVideoBufferType {
        switch beautyBufferType {
        case .Unknown:
            return .unknown
        case .PixelBuffer:
            return .pixelBuffer
        case .Data:
            return .nsData
        case .Texture:
            return .texture
        }
    }
    
    public static func convertToV2LivePixelFormat(beautyPixelFormat: ITXCustomBeautyPixelFormat) -> V2TXLivePixelFormat {
        switch beautyPixelFormat {
        case .Unknown:
            return .unknown
        case .I420:
            return .I420
        case .Texture2D:
            return .texture2D
        case .BGRA:
            return .BGRA32
        case .NV12:
            return .NV12
        }
    }
    
    public static func convertToTRTCPixelFormat(beautyPixelFormat: ITXCustomBeautyPixelFormat) -> TRTCVideoPixelFormat {
        switch beautyPixelFormat {
        case .Unknown:
            return ._Unknown
        case .I420:
            return ._I420
        case .Texture2D:
            return ._Texture_2D
        case .BGRA:
            return ._32BGRA
        case .NV12:
            return ._NV12
        }
    }
    
    public static func convertV2VideoFrame(v2VideoFrame: V2TXLiveVideoFrame) -> ITXCustomBeautyVideoFrame {
        let beautyVideoFrame = ITXCustomBeautyVideoFrame()
        beautyVideoFrame.data = v2VideoFrame.data
        beautyVideoFrame.pixelBuffer = v2VideoFrame.pixelBuffer
        beautyVideoFrame.width = UInt(v2VideoFrame.width)
        beautyVideoFrame.height = UInt(v2VideoFrame.height)
        beautyVideoFrame.textureId = v2VideoFrame.textureId
        switch v2VideoFrame.rotation {
        case .rotation0:
            beautyVideoFrame.rotation = .rotation_0
        case .rotation90:
            beautyVideoFrame.rotation = .rotation_90
        case .rotation180:
            beautyVideoFrame.rotation = .rotation_180
        case .rotation270:
            beautyVideoFrame.rotation = .rotation_270
        default:
            beautyVideoFrame.rotation = .rotation_0
        }
        
        switch v2VideoFrame.pixelFormat {
        case .unknown:
            beautyVideoFrame.pixelFormat = .Unknown
        case .I420:
            beautyVideoFrame.pixelFormat = .I420
        case .texture2D:
            beautyVideoFrame.pixelFormat = .Texture2D
        case .BGRA32:
            beautyVideoFrame.pixelFormat = .BGRA
        case .NV12:
            beautyVideoFrame.pixelFormat = .NV12
        default:
            beautyVideoFrame.pixelFormat = .Unknown
        }
        
        beautyVideoFrame.bufferType = ITXCustomBeautyBufferType(rawValue: v2VideoFrame.bufferType.rawValue) ?? .Unknown
        return beautyVideoFrame
    }
    
    public static func convertTRTCVideoFrame(trtcVideoFrame: TRTCVideoFrame) -> ITXCustomBeautyVideoFrame {
        let beautyVideoFrame = ITXCustomBeautyVideoFrame()
        beautyVideoFrame.data = trtcVideoFrame.data
        beautyVideoFrame.pixelBuffer = trtcVideoFrame.pixelBuffer
        beautyVideoFrame.width = UInt(trtcVideoFrame.width)
        beautyVideoFrame.height = UInt(trtcVideoFrame.height)
        beautyVideoFrame.textureId = trtcVideoFrame.textureId
        
        switch trtcVideoFrame.rotation {
        case ._0:
            beautyVideoFrame.rotation = .rotation_0
        case ._90:
            beautyVideoFrame.rotation = .rotation_90
        case ._180:
            beautyVideoFrame.rotation = .rotation_180
        case ._270:
            beautyVideoFrame.rotation = .rotation_270
        default:
            beautyVideoFrame.rotation = .rotation_0
        }
        
        switch trtcVideoFrame.pixelFormat {
        case ._Unknown:
            beautyVideoFrame.pixelFormat = .Unknown
        case ._I420:
            beautyVideoFrame.pixelFormat = .I420
        case ._Texture_2D:
            beautyVideoFrame.pixelFormat = .Texture2D
        case ._32BGRA:
            beautyVideoFrame.pixelFormat = .BGRA
        case ._NV12:
            beautyVideoFrame.pixelFormat = .NV12
        default:
            beautyVideoFrame.pixelFormat = .Unknown
        }
        
        beautyVideoFrame.bufferType = ITXCustomBeautyBufferType(rawValue: trtcVideoFrame.bufferType.rawValue) ?? .Unknown
        beautyVideoFrame.timestamp = trtcVideoFrame.timestamp
        return beautyVideoFrame
    }
}
