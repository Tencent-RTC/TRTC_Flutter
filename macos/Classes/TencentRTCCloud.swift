//
//  TencentRTCCloud.swift
//  tencent_rtc_ffi
//
//  Created by vincepzhang on 2024/9/19.
//

import Cocoa
import FlutterMacOS
import TXLiteAVSDK_TRTC_Mac

private typealias TRTCCameraTestVideoFrameCallback = @convention(c) (
    UnsafePointer<UInt8>?, UInt32, Int32, UInt32, UInt32
) -> Void

@_silgen_name("trtc_camera_device_test_start")
private func trtc_camera_device_test_start(
    _ callback: TRTCCameraTestVideoFrameCallback?
) -> Int32

@_silgen_name("trtc_camera_device_test_stop")
private func trtc_camera_device_test_stop() -> Int32

private var g_cameraTestRender: TextureRender?

public class TencentRTCCloud: NSObject, FlutterPlugin {
    
    private let channel: FlutterMethodChannel
    private let videoViewChannel: TXCloudVideoViewChannel

    // Texture rendering (Dispatcher pattern, aligned with Android/iOS)
    private var remoteDispatcherMap: [String: TRTCVideoFrameDispatcher] = [:]
    private var localDispatcher: TRTCVideoFrameDispatcher?
    
    init(registrar: FlutterPluginRegistrar) {
        channel = FlutterMethodChannel(name: "TencentRTCffi", binaryMessenger: registrar.messenger)
        videoViewChannel = TXCloudVideoViewChannel(registrar: registrar)
        super.init()
        videoViewChannel.addDelegate(self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = TencentRTCCloud(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            TRTCCloud.sharedInstance()
            result(0)
        case "setLocalTextureRender":
            setLocalTextureRender(call: call, result: result)
        case "setRemoteTextureRender":
            setRemoteTextureRender(call: call, result: result)
        case "unsetLocalTextureRender":
            unsetLocalTextureRender(call: call, result: result)
        case "unsetRemoteTextureRender":
            unsetRemoteTextureRender(call: call, result: result)
        case "startCameraDeviceTest":
            startCameraDeviceTest(call: call, result: result)
        case "stopCameraDeviceTest":
            stopCameraDeviceTest(call: call, result: result)
        case "getCustomVideoFrameListener":
            getCustomVideoFrameListener(call: call, result: result)
        case "destroySharedInstance":
            destroySharedInstance(call: call, result: result)
        default:
            result(0)
        }
    }

    // MARK: - Texture Rendering (Dispatcher pattern, aligned with Android/iOS)

    private func setLocalTextureRender(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = Utils.getParamByKey(call: call, result: result, param: "viewId") as? Int64,
              let streamTypeRaw = Utils.getParamByKey(call: call, result: result, param: "streamType") as? Int else {
            return
        }
        guard let render = videoViewChannel.getRender(textureId: viewId) else {
            result(nil)
            return
        }
        let streamType = TRTCVideoStreamType(rawValue: streamTypeRaw) ?? .big

        if localDispatcher == nil {
            localDispatcher = TRTCVideoFrameDispatcher(userId: "local")
        }
        TRTCCloud.sharedInstance().setLocalVideoRenderDelegate(localDispatcher, pixelFormat: ._32BGRA, bufferType:
            .pixelBuffer)
        localDispatcher!.setRender(render, streamType: streamType)
        result(nil)
    }

    private func setRemoteTextureRender(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = Utils.getParamByKey(call: call, result: result, param: "viewId") as? Int64,
              let userId = Utils.getParamByKey(call: call, result: result, param: "userId") as? String,
              let streamTypeRaw = Utils.getParamByKey(call: call, result: result, param: "streamType") as? Int else {
            return
        }
        guard let render = videoViewChannel.getRender(textureId: viewId) else {
            result(nil)
            return
        }
        let streamType = TRTCVideoStreamType(rawValue: streamTypeRaw) ?? .big

        if remoteDispatcherMap[userId] == nil {
            remoteDispatcherMap[userId] = TRTCVideoFrameDispatcher(userId: userId)
        }
        let dispatcher = remoteDispatcherMap[userId]!
        TRTCCloud.sharedInstance().setRemoteVideoRenderDelegate(userId, delegate: dispatcher, pixelFormat: ._32BGRA,
            bufferType: .pixelBuffer)
        dispatcher.setRender(render, streamType: streamType)
        result(nil)
    }

    private func unsetLocalTextureRender(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let streamTypeRaw = Utils.getParamByKey(call: call, result: result, param: "streamType") as? Int else {
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

    private func unsetRemoteTextureRender(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let userId = Utils.getParamByKey(call: call, result: result, param: "userId") as? String,
              let streamTypeRaw = Utils.getParamByKey(call: call, result: result, param: "streamType") as? Int else {
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

    // MARK: - Camera Device Test (texture mode)

    private func startCameraDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let viewId = Utils.getParamByKey(call: call, result: result, param: "viewId") as? Int64,
              let render = videoViewChannel.getRender(textureId: viewId) else {
            result(-1)
            return
        }

        if g_cameraTestRender != nil {
           result(-1)
           return
        }

        g_cameraTestRender = render      // 强引用保活 + 供 C 回调转发定位

        let code = trtc_camera_device_test_start({ data, length, format, width, height in
            guard let data = data, let render = g_cameraTestRender else { return }
            render.onVideoBuffer(data, length: length, format: format, width: width, height: height)
        })

        // 启动失败（含已在运行被拒）时回滚，避免状态残留
        if code != 0 {
            g_cameraTestRender = nil
        }
        result(Int(code))
    }

    private func stopCameraDeviceTest(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let code = trtc_camera_device_test_stop()
        g_cameraTestRender = nil
        result(Int(code))
    }

    // MARK: - Lifecycle

    private func destroySharedInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if g_cameraTestRender != nil {
            _ = trtc_camera_device_test_stop()
            g_cameraTestRender = nil
        }
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
        TRTCCloud.destroySharedInstance()
        result(nil)
    }

    // MARK: - Live & Utility

    private func getCustomVideoFrameListener(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let textureId = arguments["textureId"] as? Int64 else {
            result(0)
            return
        }
        guard let observer = videoViewChannel.getRender(textureId: textureId) else {
            result(0)
            return
        }
        let observerPtr = Unmanaged.passUnretained(observer).toOpaque()
        result(Int(bitPattern: observerPtr))
    }

    private func removeRenderFromDispatchers(_ render: TextureRender) {
        if g_cameraTestRender === render {
            _ = trtc_camera_device_test_stop()
            g_cameraTestRender = nil
        }
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
}

extension TencentRTCCloud: TXCloudVideoViewChannelDelegate {
    func txCloudVideoViewChannel(_ channel: TXCloudVideoViewChannel, willDispose render: TextureRender) {
        removeRenderFromDispatchers(render)
    }
}
