import FlutterMacOS

public class CommonUtils{
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
	public static func getParamByKeyCanBeNull(call: FlutterMethodCall, result: @escaping FlutterResult, param : String) -> Any? {
		let value = (call.arguments as! [String:Any])[param]
		
		if value is NSNull || value == nil {
			return nil
		}
		
		return value
	}
	
	static func txf_log_info(file: String = #file,
							 line: Int = #line,
							 function: String = #function,
							 content: String) {
		txf_log_swift(TXE_LOG_INFO, file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), content.cString(using: .utf8))
	}
	
	static func txf_log_error(file: String = #file,
							  line: Int = #line,
							  function: String = #function,
							  content: String) {
		txf_log_swift(TXE_LOG_ERROR, file.cString(using: .utf8), Int32(line), function.cString(using: .utf8), content.cString(using: .utf8))
	}
	
	
	static func logFlutterMethodCall(_ call: FlutterMethodCall) {
		let noAgrs = {
			CommonUtils.txf_log_info(content: "method=\(call.method)|arguments: nil")
		}
		
		if let args = call.arguments as? Dictionary<String, Any> {
			var argsInfo = ""
			for paramter in args.keys {
				if let value = args[paramter] {
					argsInfo.append("\(paramter):\(value), ")
				}
			}
			if argsInfo.count > 0 {
				txf_log_info(content: "method=\(call.method)|arguments: {\(argsInfo.cString(using: .utf8))}")
			} else {
				noAgrs()
			}
		} else {
			noAgrs()
		}
	}
	
	static func logError(call: FlutterMethodCall, errCode: Int, errMsg: String) {
		let noAgrs = {
			CommonUtils.txf_log_error(content: "method=\(call.method)|arguments=nil|error={errCode: \(errCode), errMsg: \(errMsg)}")
		}
		
		if let args = call.arguments as? Dictionary<String, Any> {
			var argsInfo = ""
			for paramter in args.keys {
				if let value = args[paramter] {
					argsInfo.append("\(paramter):\(value), ")
				}
			}
			if argsInfo.count > 0 {
				txf_log_error(content: "method=\(call.method)|arguments={\(argsInfo.cString(using: .utf8))}|error={errCode: \(errCode), errMsg: \(errMsg)}")
			} else {
				noAgrs()
			}
		} else {
			noAgrs()
		}
	}
}
