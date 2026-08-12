//
//  TRTCVideoFrameDispatcher.swift
//  Pods
//
//  Created by iveshe on 2026/4/13.
//


import Foundation
import TXLiteAVSDK_Professional

class TRTCVideoFrameDispatcher: NSObject, TRTCVideoRenderDelegate {

    private let userId: String
    private var renders: [Int: TRTCTextureRender] = [:]
    private let lock = NSLock()

    init(userId: String) {
        self.userId = userId
    }

    func getUserId() -> String {
        return userId
    }

    func getRender(streamType: TRTCVideoStreamType) -> TRTCTextureRender? {
        lock.lock()
        defer { lock.unlock() }
        return renders[streamType.rawValue]
    }

    func setRender(_ render: TRTCTextureRender, streamType: TRTCVideoStreamType) {
        lock.lock()
        defer { lock.unlock() }
        renders[streamType.rawValue] = render
    }

    func removeRender(streamType: TRTCVideoStreamType) {
        lock.lock()
        defer { lock.unlock() }
        renders.removeValue(forKey: streamType.rawValue)
    }

    func onRenderWillDispose(_ render: TRTCTextureRender) {
        lock.lock()
        defer { lock.unlock() }
        renders = renders.filter { $0.value !== render }
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return renders.isEmpty
    }

    func disposeAll() {
        lock.lock()
        defer { lock.unlock() }
        renders.removeAll()
    }

    func onRenderVideoFrame(_ frame: TRTCVideoFrame, userId: String?, streamType: TRTCVideoStreamType) {
        lock.lock()
        let render = renders[streamType.rawValue]
        lock.unlock()
        render?.onVideoFrame(frame)
    }
}
