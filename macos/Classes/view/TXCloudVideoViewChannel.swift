//
//  TXCloudVideoViewChannel.swift
//  tencent_rtc_sdk
//

import FlutterMacOS
import Foundation

protocol TXCloudVideoViewChannelDelegate: AnyObject {
    func txCloudVideoViewChannel(_ channel: TXCloudVideoViewChannel, willDispose render: TextureRender)
}

class TXCloudVideoViewChannel {
    private static let channelName = "TXCloudVideoViewChannel"

    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private let delegates = NSHashTable<AnyObject>.weakObjects()

    private var renderMap: [String: TextureRender] = [:]

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.channel = FlutterMethodChannel(name: TXCloudVideoViewChannel.channelName, binaryMessenger: registrar.messenger)
        self.channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            self.handle(call, result: result)
        }
    }

    func addDelegate(_ delegate: TXCloudVideoViewChannelDelegate) {
        delegates.add(delegate)
    }

    func removeDelegate(_ delegate: TXCloudVideoViewChannelDelegate) {
        delegates.remove(delegate)
    }

    func getRender(textureId: Int64) -> TextureRender? {
        return renderMap[String(textureId)]
    }

    func disposeAll() {
        for render in renderMap.values {
            notifyRenderWillDispose(render)
            render.dispose()
        }
        renderMap.removeAll()
    }

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "createTextureView":
            result(createTextureView())
        case "disposeTextureView":
            disposeTextureView(call: call, result: result)
        case "getTextureId":
            result(getTextureId())
        case "getSurfaceId":
            result(0)
        case "unregisterTexture":
            unregisterTexture(call: call, result: result)
        case "setRenderSize":
            result(0)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func createTextureView() -> Int64 {
        let render = TextureRender(registrar: registrar)
        let textureId = render.getTextureId()
        renderMap[String(textureId)] = render
        return textureId
    }

    private func disposeTextureView(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let textureId = Utils.getParamByKey(call: call, result: result, param: "textureId") as? Int64 else {
            return
        }
        disposeTexture(textureId: textureId)
        result(nil)
    }

    private func getTextureId() -> Int64 {
        return createTextureView()
    }

    private func unregisterTexture(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let textureId = arguments["textureId"] as? Int64 else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "textureId is required", details: nil))
            return
        }
        disposeTexture(textureId: textureId)
        result(nil)
    }

    private func disposeTexture(textureId: Int64) {
        let key = String(textureId)
        guard let render = renderMap.removeValue(forKey: key) else {
            return
        }
        notifyRenderWillDispose(render)
        render.dispose()
    }

    private func notifyRenderWillDispose(_ render: TextureRender) {
        for delegate in delegates.allObjects {
            (delegate as? TXCloudVideoViewChannelDelegate)?.txCloudVideoViewChannel(self, willDispose: render)
        }
    }
}
