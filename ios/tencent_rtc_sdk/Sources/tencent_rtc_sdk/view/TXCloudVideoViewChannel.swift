//
//  TXCloudVideoViewChannel.swift
//  Pods
//
//  Created by iveshe on 2026/5/21.
//

import Flutter
import Foundation

protocol TXCloudVideoViewChannelDelegate: AnyObject {
    func txCloudVideoViewChannel(_ channel: TXCloudVideoViewChannel, willDispose render: TRTCTextureRender)
}

class TXCloudVideoViewChannel {
    private static let channelName = "TXCloudVideoViewChannel"

    private let channel: FlutterMethodChannel
    private let registrar: FlutterPluginRegistrar
    private let textures: FlutterTextureRegistry
    private let delegates = NSHashTable<AnyObject>.weakObjects()

    private var renderMap: [String: TRTCTextureRender] = [:]

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        self.textures = registrar.textures()
        self.channel = FlutterMethodChannel(name: TXCloudVideoViewChannel.channelName, binaryMessenger: registrar.messenger())
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

    func getRender(viewId: Int64) -> TRTCTextureRender? {
        return renderMap[String(viewId)]
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
            createTextureView(call, result: result)
        case "disposeTextureView":
            disposeTextureView(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func createTextureView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let render = TRTCTextureRender(textureRegistry: textures, messenger: registrar.messenger())
        let textureId = render.textureId
        renderMap[String(textureId)] = render
        result(textureId)
    }

    private func disposeTextureView(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let textureId = Utils.getParamByKey(call: call, param: "textureId", result: result) as? Int64 else {
            return
        }
        let key = String(textureId)
        guard let render = renderMap.removeValue(forKey: key) else {
            result(nil)
            return
        }

        notifyRenderWillDispose(render)
        render.dispose()
        result(nil)
    }

    private func notifyRenderWillDispose(_ render: TRTCTextureRender) {
        for delegate in delegates.allObjects {
            (delegate as? TXCloudVideoViewChannelDelegate)?.txCloudVideoViewChannel(self, willDispose: render)
        }
    }
}
