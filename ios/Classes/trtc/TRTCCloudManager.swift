//
//  TRTCCloudManager.swift
//  tencent_rtc_sdk
//
//  Created by iveshe on 2025/5/6.
//

import Flutter
import Foundation
import TXLiteAVSDK_Professional
import TXCustomBeautyProcesserPlugin

class TRTCCloudManager {
    let channel: FlutterMethodChannel
    private let videoViewChannel: TXCloudVideoViewChannel
    private var beautyProcesser: ITXCustomBeautyProcesser? = nil
    private var localProcessVideoFrame:ProcessVideoFrame?
    private var transcriberHandler: AITranscriberManagerHandler?
    private var remoteDispatcherMap: [String: TRTCVideoFrameDispatcher] = [:]
    private var localDispatcher: TRTCVideoFrameDispatcher?
    
    init(channel: FlutterMethodChannel, videoViewChannel: TXCloudVideoViewChannel) {
        self.channel = channel
        self.videoViewChannel = videoViewChannel
        self.transcriberHandler = AITranscriberManagerHandler(channel: channel)
        self.videoViewChannel.addDelegate(self)
        self.channel.setMethodCallHandler({[weak self] call, result in
            guard let self = self else { return }
            self.handle(call, result: result)
        })
    }

    deinit {
        videoViewChannel.removeDelegate(self)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let handler = transcriberHandler, handler.handleMethodCall(call, result: result) {
            return
        }
        
        switch (call.method) {
        case "initialize":
            result(nil)
        case "setLocalTextureRender":
            setLocalTextureRender(call, result: result)
        case "setRemoteTextureRender":
            setRemoteTextureRender(call, result: result)
        case "unsetLocalTextureRender":
            unsetLocalTextureRender(call, result: result)
        case "unsetRemoteTextureRender":
            unsetRemoteTextureRender(call, result: result)
        case "enableVideoProcessByNative":
            enableVideoProcessByNative(call, result: result)
        case "snapshotVideo":
            snapshotVideo(call, result: result)
        case "setVideoMuteImage":
            setVideoMuteImage(call, result: result)
        case "setWatermark":
            setWatermark(call, result: result)
        case "startScreenCapture":
            startScreenCapture(call, result: result)
        case "startScreenCaptureByReplaykit":
            startScreenCaptureByReplaykit(call, result: result)
        case "getCustomVideoProcessListener":
            getCustomVideoProcessListener(call, result: result)
        case "destroySharedInstance":
            destroySharedInstance(call, result: result)
        case "setRenderSize":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    private func snapshotVideo(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let userId = Utils.getParamByKey(call: call, param: "userId", result: result) as? String,
           let streamType = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int,
           let sourceType = Utils.getParamByKey(call: call, param: "sourceType", result: result) as? Int,
           let path = Utils.getParamByKey(call: call, param: "path", result: result) as? String {
            TRTCCloud.sharedInstance().snapshotVideo(userId, type: TRTCVideoStreamType(rawValue: streamType) ?? .big,
                sourceType: TRTCSnapshotSourceType(rawValue: UInt(sourceType)) ?? .capture) { [weak self] image in
                guard let self = self else {return}
                DispatchQueue.global().async {
                    ImageIO.save(image: image, path: path, succ: {
                        succPath in
                        self.sendListenerToDart(userId: userId, path: succPath, code: 0, message: "success")
                    }, fail: {
                        code, message in
                        self.sendListenerToDart(userId: userId, path: "", code: code, message: message)
                    })
                }
            }
        }
        result(nil)
    }
    
    private func setVideoMuteImage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let imagePath = Utils.getParamByKey(call: call, param: "imagePath", result: result) as? String,
            let fps = Utils.getParamByKey(call: call, param: "fps", result: result) as? Int {
            ImageIO.loadImageFromSandbox(atPath: imagePath, success: {
                image in
                TRTCCloud.sharedInstance().setVideoMuteImage(image, fps: fps)
            })
        }
        result(nil)
    }
    
    private func setWatermark(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let imagePath = Utils.getParamByKey(call: call, param: "imagePath", result: result) as? String,
            let streamType = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int,
            let x = Utils.getParamByKey(call: call, param: "x", result: result) as? Double,
            let y = Utils.getParamByKey(call: call, param: "y", result: result) as? Double,
            let width = Utils.getParamByKey(call: call, param: "width", result: result) as? Double {
            
                        let rect = CGRect(x: x, y: y, width: width, height: 0)
            ImageIO.loadImageFromSandbox(atPath: imagePath, success: { image in
                TRTCCloud.sharedInstance().setWatermark(image, streamType: TRTCVideoStreamType(rawValue:
                    streamType) ?? .big, rect: rect)
            })
        }
        result(nil)
    }
    
    private func enableVideoProcessByNative(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let enable = Utils.getParamByKey(call: call, param: "enable", result: result) as? Bool {
            guard let customBeautyInstance = TencentRTCCloud.getBeautyProcesserFactory() else {
                result(nil)
                return
            }
            
            if enable {
                if self.beautyProcesser == nil {
                    self.beautyProcesser = customBeautyInstance.createCustomBeautyProcesser()
                }
                // swiftlint:disable:next force_unwrapping
                let pixelFormat = self.beautyProcesser!.getSupportedPixelFormat()
                // swiftlint:disable:next force_unwrapping
                let bufferType = self.beautyProcesser!.getSupportedBufferType()
                let v2PixelFormat = ObjectUtils.convertToTRTCPixelFormat(beautyPixelFormat: pixelFormat)
                let v2BufferType = ObjectUtils.convertToTRTCBufferType(beautyBufferType: bufferType)
                // swiftlint:disable:next force_unwrapping
                localProcessVideoFrame = ProcessVideoFrame(self.beautyProcesser!)
                let code = TRTCCloud.sharedInstance().setLocalVideoProcessDelegete(localProcessVideoFrame, pixelFormat:
                    v2PixelFormat,
                                                        bufferType: v2BufferType)
                result(code)
            } else {
                if self.beautyProcesser != nil {
                    self.beautyProcesser = nil
                    customBeautyInstance.destroyCustomBeautyProcesser()
                }
                let code = TRTCCloud.sharedInstance().setLocalVideoProcessDelegete(nil, pixelFormat: ._Unknown,
                    bufferType: .unknown)
                result(code)
            }
        }
    }
    
    private func startScreenCapture(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let streamType = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int,
           let encParamMap = Utils.getParamByKey(call: call, param: "encParam", result: result) as? [String: Any] {
            let encParam = TRTCVideoEncParam()
            if let videoResolution = Utils.getValueInMap(map: encParamMap, key: "videoResolution", result:
                result) as? Int,
               let videoResolutionMode = Utils.getValueInMap(map: encParamMap, key: "videoResolutionMode", result:
                   result) as? Int,
               let videoFps = Utils.getValueInMap(map: encParamMap, key: "videoFps", result: result) as? Int32,
               let videoBitrate = Utils.getValueInMap(map: encParamMap, key: "videoBitrate", result: result) as? Int32,
               let minVideoBitrate = Utils.getValueInMap(map: encParamMap, key: "minVideoBitrate", result:
                   result) as? Int32,
               let enableAdjustRes = Utils.getValueInMap(map: encParamMap, key: "enableAdjustRes", result:
                   result) as? Bool {
                encParam.videoResolution = TRTCVideoResolution(rawValue: videoResolution) ?? ._1280_720
                encParam.resMode = TRTCVideoResolutionMode(rawValue: videoResolutionMode) ?? .portrait
                encParam.minVideoBitrate = minVideoBitrate
                encParam.videoFps = videoFps
                encParam.videoBitrate = videoBitrate
                encParam.enableAdjustRes = enableAdjustRes
                
                if #available(iOS 13.0, *) {
                    TRTCCloud.sharedInstance().startScreenCapture(inApp: TRTCVideoStreamType(rawValue:
                        streamType) ?? .sub, encParam: encParam)
                    result(0)
                } else {
                    result(FlutterError(code: "-1002", message: "Error", details: "The current iOS version does not support"))
                }
            }
        }
    }
    
    private func getCustomVideoProcessListener(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if TencentRTCCloud.sObserver == nil {
            result(0)
            return
        }
        // swiftlint:disable:next force_unwrapping
        let observerPtr = Unmanaged.passUnretained(TencentRTCCloud.sObserver!).toOpaque()
        result(Int(bitPattern: observerPtr))
    }

    private func startScreenCaptureByReplaykit(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let streamType = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int,
           let appGroup = Utils.getParamByKey(call: call, param: "appGroup", result: result) as? String,
           let encParamMap = Utils.getParamByKey(call: call, param: "encParam", result: result) as? [String: Any] {
            let encParam = TRTCVideoEncParam()
            if let videoResolution = Utils.getValueInMap(map: encParamMap, key: "videoResolution", result:
                result) as? Int,
               let videoResolutionMode = Utils.getValueInMap(map: encParamMap, key: "videoResolutionMode", result:
                   result) as? Int,
               let videoFps = Utils.getValueInMap(map: encParamMap, key: "videoFps", result: result) as? Int32,
               let videoBitrate = Utils.getValueInMap(map: encParamMap, key: "videoBitrate", result: result) as? Int32,
               let minVideoBitrate = Utils.getValueInMap(map: encParamMap, key: "minVideoBitrate", result:
                   result) as? Int32,
               let enableAdjustRes = Utils.getValueInMap(map: encParamMap, key: "enableAdjustRes", result:
                   result) as? Bool {
                encParam.videoResolution = TRTCVideoResolution(rawValue: videoResolution) ?? ._1280_720
                encParam.resMode = TRTCVideoResolutionMode(rawValue: videoResolutionMode) ?? .portrait
                encParam.minVideoBitrate = minVideoBitrate
                encParam.videoFps = videoFps
                encParam.videoBitrate = videoBitrate
                encParam.enableAdjustRes = enableAdjustRes
                
                if #available(iOS 13.0, *) {
                    TRTCCloud.sharedInstance().startScreenCapture(byReplaykit: TRTCVideoStreamType(rawValue:
                        streamType) ?? .sub, encParam: encParam, appGroup: appGroup)
                    result(0)
                } else {
                    result(FlutterError(code: "-1002", message: "Error", details: "The current iOS version does not support"))
                }
            }
        }
    }
    
    private func sendListenerToDart(userId: String, path: String, code: Int, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.channel.invokeMethod("onSnapshotComplete", arguments: [
                "userId": userId,
                "path": path,
                "errCode": code,
                "errMsg": message,
            ])
        }
    }
    
    private func setLocalTextureRender(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = Utils.getParamByKey(call: call, param: "viewId", result: result) as? Int64,
              let streamTypeRaw = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int else {
            return
        }
        guard let render = videoViewChannel.getRender(viewId: viewId) else {
            result(nil)
            return
        }
        let streamType = TRTCVideoStreamType(rawValue: streamTypeRaw) ?? .big

        if localDispatcher == nil {
            localDispatcher = TRTCVideoFrameDispatcher(userId: "local")
        }
        TRTCCloud.sharedInstance().setLocalVideoRenderDelegate(localDispatcher, pixelFormat: ._32BGRA, bufferType:
            .pixelBuffer)
        // swiftlint:disable:next force_unwrapping
        localDispatcher!.setRender(render, streamType: streamType)
        result(nil)
    }

    private func setRemoteTextureRender(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = Utils.getParamByKey(call: call, param: "viewId", result: result) as? Int64,
              let userId = Utils.getParamByKey(call: call, param: "userId", result: result) as? String,
              let streamTypeRaw = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int else {
            return
        }
        guard let render = videoViewChannel.getRender(viewId: viewId) else {
            result(nil)
            return
        }
        let streamType = TRTCVideoStreamType(rawValue: streamTypeRaw) ?? .big

        if remoteDispatcherMap[userId] == nil {
            remoteDispatcherMap[userId] = TRTCVideoFrameDispatcher(userId: userId)
        }
        // swiftlint:disable:next force_unwrapping
        let dispatcher = remoteDispatcherMap[userId]!
        TRTCCloud.sharedInstance().setRemoteVideoRenderDelegate(userId, delegate: dispatcher, pixelFormat: ._32BGRA,
            bufferType: .pixelBuffer)
        dispatcher.setRender(render, streamType: streamType)
        result(nil)
    }

    private func unsetLocalTextureRender(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let streamTypeRaw = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int else {
            return
        }
        let streamType = TRTCVideoStreamType(rawValue: streamTypeRaw) ?? .big
        if let dispatcher = localDispatcher {
            dispatcher.removeRender(streamType: streamType)
            if dispatcher.isEmpty {
                TRTCCloud.sharedInstance().setLocalVideoRenderDelegate(nil, pixelFormat: ._32BGRA, bufferType:
                    .pixelBuffer)
                localDispatcher = nil
            }
        }
        result(nil)
    }

    private func unsetRemoteTextureRender(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userId = Utils.getParamByKey(call: call, param: "userId", result: result) as? String,
              let streamTypeRaw = Utils.getParamByKey(call: call, param: "streamType", result: result) as? Int else {
            return
        }
        let streamType = TRTCVideoStreamType(rawValue: streamTypeRaw) ?? .big
        if let dispatcher = remoteDispatcherMap[userId] {
            dispatcher.removeRender(streamType: streamType)
            if dispatcher.isEmpty {
                TRTCCloud.sharedInstance().setRemoteVideoRenderDelegate(userId, delegate: nil, pixelFormat: ._32BGRA,
                    bufferType: .pixelBuffer)
                remoteDispatcherMap.removeValue(forKey: userId)
            }
        }
        result(nil)
    }

    private func removeRenderFromDispatchers(_ render: TRTCTextureRender) {
        if let dispatcher = localDispatcher {
            dispatcher.onRenderWillDispose(render)
            if dispatcher.isEmpty {
                TRTCCloud.sharedInstance().setLocalVideoRenderDelegate(nil, pixelFormat: ._32BGRA, bufferType:
                    .pixelBuffer)
                localDispatcher = nil
            }
        }
        remoteDispatcherMap.values.forEach { $0.onRenderWillDispose(render) }
        let emptyUserIds = remoteDispatcherMap.filter { $0.value.isEmpty }.map { $0.key }
        for userId in emptyUserIds {
            TRTCCloud.sharedInstance().setRemoteVideoRenderDelegate(userId, delegate: nil, pixelFormat: ._32BGRA,
                bufferType: .pixelBuffer)
            remoteDispatcherMap.removeValue(forKey: userId)
        }
    }

    private func releaseTextureRenderDelegates() {
        localDispatcher?.disposeAll()
        if localDispatcher != nil {
            TRTCCloud.sharedInstance().setLocalVideoRenderDelegate(nil, pixelFormat: ._32BGRA, bufferType: .pixelBuffer)
            localDispatcher = nil
        }
        for (userId, dispatcher) in remoteDispatcherMap {
            dispatcher.disposeAll()
            TRTCCloud.sharedInstance().setRemoteVideoRenderDelegate(userId, delegate: nil, pixelFormat: ._32BGRA,
                bufferType: .pixelBuffer)
        }
        remoteDispatcherMap.removeAll()
    }

    private func destroySharedInstance(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        releaseTextureRenderDelegates()
        transcriberHandler?.release()
        TRTCCloud.destroySharedInstance()
        result(nil)
    }
}

extension TRTCCloudManager: TXCloudVideoViewChannelDelegate {
    func txCloudVideoViewChannel(_ channel: TXCloudVideoViewChannel, willDispose render: TRTCTextureRender) {
        removeRenderFromDispatchers(render)
    }
}
