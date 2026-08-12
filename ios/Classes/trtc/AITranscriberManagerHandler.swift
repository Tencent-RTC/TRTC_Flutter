//
//  AITranscriberManagerHandler.swift
//  tencent_rtc_sdk
//

import Flutter
import Foundation
import TXLiteAVSDK_Professional

class AITranscriberManagerHandler: NSObject, AITranscriberListener {
    private let channel: FlutterMethodChannel
    private var transcriberManager: AITranscriberManager?
    private var isListenerAdded = false
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }
    
    func release() {
        if let manager = transcriberManager, isListenerAdded {
            manager.remove(self)
            isListenerAdded = false
        }
        transcriberManager = nil
    }
    
    private func getTranscriberManager() -> AITranscriberManager? {
        if transcriberManager == nil {
            transcriberManager = TRTCCloud.sharedInstance().getAITranscriberManager()
        }
        return transcriberManager
    }
    
    private func ensureListenerAdded() {
        if !isListenerAdded {
            if let manager = getTranscriberManager() {
                manager.add(self)
                isListenerAdded = true
            }
        }
    }
    
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> Bool {
        switch call.method {
        case "startRealtimeTranscriber":
            startRealtimeTranscriber(call, result: result)
            return true
        case "stopRealtimeTranscriber":
            stopRealtimeTranscriber(call, result: result)
            return true
        case "pauseReceivingTranscriberMessage":
            pauseReceivingTranscriberMessage(call, result: result)
            return true
        case "resumeReceivingTranscriberMessage":
            resumeReceivingTranscriberMessage(call, result: result)
            return true
        case "addTranscriberListener":
            addTranscriberListener(call, result: result)
            return true
        case "removeTranscriberListener":
            removeTranscriberListener(call, result: result)
            return true
        default:
            return false
        }
    }
    
    private func startRealtimeTranscriber(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        ensureListenerAdded()
        
        let params = TranscriberParams()
        
        if let transcriberRobotId = Utils.getParamByKeyCanBeNull(call: call, param: "transcriberRobotId", result:
            result) as? String {
            params.transcriberRobotId = transcriberRobotId
        }
        
        if let sourceLanguage = Utils.getParamByKeyCanBeNull(call: call, param: "sourceLanguage", result:
            result) as? String {
            params.sourceLanguage = sourceLanguage
        }
        
        if let userIds = Utils.getParamByKeyCanBeNull(call: call, param: "userIdsToTranscribe", result:
            result) as? [String] {
            params.userIdsToTranscribe = userIds
        }
        
        if let translationLanguages = Utils.getParamByKeyCanBeNull(call: call, param: "translationLanguages", result:
            result) as? [String] {
            params.translationLanguages = translationLanguages
        }
        
        getTranscriberManager()?.startRealtimeTranscriber(params)
        result(nil)
    }
    
    private func stopRealtimeTranscriber(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let transcriberRobotId = Utils.getParamByKeyCanBeNull(call: call, param: "transcriberRobotId", result:
            result) as? String ?? ""
        getTranscriberManager()?.stopRealtimeTranscriber(transcriberRobotId)
        result(nil)
    }
    
    private func pauseReceivingTranscriberMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getTranscriberManager()?.pauseReceivingMessage()
        result(nil)
    }
    
    private func resumeReceivingTranscriberMessage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        getTranscriberManager()?.resumeReceivingMessage()
        result(nil)
    }
    
    private func addTranscriberListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        ensureListenerAdded()
        result(nil)
    }
    
    private func removeTranscriberListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let manager = getTranscriberManager(), isListenerAdded {
            manager.remove(self)
            isListenerAdded = false
        }
        result(nil)
    }
    
    // MARK: - AITranscriberListener
    
    func onRealtimeTranscriberStarted(_ roomId: String, transcriberRobotId: String) {
        DispatchQueue.main.async { [weak self] in
            self?.channel.invokeMethod("onRealtimeTranscriberStarted", arguments: [
                "roomId": roomId,
                "transcriberRobotId": transcriberRobotId,
            ])
        }
    }
    
    func onReceiveTranscriberMessage(_ roomId: String, message: TranscriberMessage) {
        DispatchQueue.main.async { [weak self] in
            let messageMap: [String: Any] = [
                "segmentId": message.segmentId ?? "",
                "speakerUserId": message.speakerUserId ?? "",
                "sourceText": message.sourceText ?? "",
                "translationTexts": message.translationTexts ?? [:],
                "timestamp": message.timestamp,
                "isCompleted": message.isCompleted,
            ]
            
            self?.channel.invokeMethod("onReceiveTranscriberMessage", arguments: [
                "roomId": roomId,
                "message": messageMap,
            ])
        }
    }
    
    func onRealtimeTranscriberStopped(_ roomId: String, transcriberRobotId: String, reason: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.channel.invokeMethod("onRealtimeTranscriberStopped", arguments: [
                "roomId": roomId,
                "transcriberRobotId": transcriberRobotId,
                "reason": reason,
            ])
        }
    }
    
    func onRealtimeTranscriberError(_ roomId: String, transcriberRobotId: String, error: Int, errorInfo: String) {
        DispatchQueue.main.async { [weak self] in
            self?.channel.invokeMethod("onRealtimeTranscriberError", arguments: [
                "roomId": roomId,
                "transcriberRobotId": transcriberRobotId,
                "error": error,
                "errorInfo": errorInfo,
            ])
        }
    }
}
