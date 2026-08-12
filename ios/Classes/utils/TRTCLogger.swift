//
//  File.swift
//  tencent_rtc_sdk
//
//  Created by iveshe on 2025/5/7.
//

import Foundation
import TXLiteAVSDK_Professional

class TRTCLogger {
    static func info(file: String = #file,
                            line: Int = #line,
                            function: String = #function,
                            content: String) {
        let message = "TRTCCloudPlugin \(content)"
        txf_log(module: "TRTCCloudPlugin", level: 0, file: file, line: line, message: message)
    }
         
    static func error(file: String = #file,
                            line: Int = #line,
                            function: String = #function,
                            content: String) {
        let message = "TRTCCloudPlugin \(content)"
        txf_log(module: "", level: 2, file: file, line: line, message: message)
    }
    
    static func txf_log(module: String, level: Int, file: String, line: Int, message: String) {
            let params: [String: Any] = [
                "level": level,
                "file": file,
                "line": line,
                "message": message,
            ]
            
            let jsonValue: [String: Any] = [
                "api": "TuikitLog",
                "params": params,
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonValue, options: []),
                    let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("JSON serialization failed")
                return
            }
            
            TRTCCloud.sharedInstance().callExperimentalAPI(jsonString)
        }
}
