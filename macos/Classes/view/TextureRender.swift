//
//  TextureRender.swift
//  Pods
//
//  Created by vincepzhang on 2024/10/16.
//

import FlutterMacOS
import TXLiteAVSDK_TRTC_Mac

class TextureRender: NSObject, FlutterTexture, V2TXLivePlayerObserver {

    private weak var textures: FlutterTextureRegistry?
    private var channel: FlutterMethodChannel?

    private var latestPixelBuffer: CVPixelBuffer?
    private let bufferLock = NSLock()

    private(set) var textureId: Int64 = -1

    private var textureWidth: UInt32 = 0
    private var textureHeight: UInt32 = 0

    init(registrar: FlutterPluginRegistrar) {
        let textureRegistry = registrar.textures
        self.textures = textureRegistry
        super.init()
        textureId = textureRegistry.register(self)
        self.channel = FlutterMethodChannel(name: "tencent_rtc_texture_\(textureId)", binaryMessenger:
            registrar.messenger)
    }

    func getTextureId() -> Int64 {
        return textureId
    }

    // MARK: - FlutterTexture

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        bufferLock.lock()
        defer { bufferLock.unlock() }
        if let buffer = latestPixelBuffer {
            return Unmanaged.passRetained(buffer)
        }
        return nil
    }

    // MARK: - Frame input (called by TRTCVideoFrameDispatcher)

    func onVideoFrame(_ frame: TRTCVideoFrame) {
        guard let pixelBuffer = frame.pixelBuffer else { return }

        bufferLock.lock()
        let widthChanged = frame.width != textureWidth || frame.height != textureHeight
        if widthChanged {
            textureWidth = frame.width
            textureHeight = frame.height
        }
        latestPixelBuffer = pixelBuffer
        let currentTextureId = textureId
        bufferLock.unlock()

        guard currentTextureId >= 0 else { return }

        if widthChanged {
            let w = frame.width
            let h = frame.height
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.textureId >= 0 else { return }
                self.channel?.invokeMethod("updateVideoAspectRatio", arguments: ["width": w, "height": h])
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.textureId >= 0 else { return }
            self.textures?.textureFrameAvailable(currentTextureId)
        }
    }

    // MARK: - V2TXLivePlayerObserver

    public func onRenderVideoFrame(_: any V2TXLivePlayerProtocol, frame videoFrame: V2TXLiveVideoFrame) {
        guard videoFrame.pixelFormat == V2TXLivePixelFormat.BGRA32,
              videoFrame.bufferType == V2TXLiveBufferType.nsData else {
            return
        }
        guard videoFrame.width > 0, videoFrame.height > 0 else {
            return
        }

        let frameWidth = UInt32(videoFrame.width)
        let frameHeight = UInt32(videoFrame.height)

        guard let data = videoFrame.data else { return }

        let expectedSize = Int(frameWidth * frameHeight * 4)
        guard data.count >= expectedSize else { return }

        let nsData = data as NSData
        guard let pixelBuffer = createPixelBufferFromBGRA32Data(data: nsData, width: Int(frameWidth), height:
            Int(frameHeight)) else {
            return
        }

        bufferLock.lock()
        let widthChanged = frameWidth != textureWidth || frameHeight != textureHeight
        if widthChanged {
            textureWidth = frameWidth
            textureHeight = frameHeight
        }
        latestPixelBuffer = pixelBuffer
        let currentTextureId = textureId
        bufferLock.unlock()

        guard currentTextureId >= 0 else { return }

        if widthChanged {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.textureId >= 0 else { return }
                self.channel?.invokeMethod("updateVideoAspectRatio",
                    arguments: ["width": frameWidth, "height": frameHeight])
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.textureId >= 0 else { return }
            self.textures?.textureFrameAvailable(currentTextureId)
        }
    }

    // MARK: - Dispose

    func dispose() {
        if textureId >= 0 {
            textures?.unregisterTexture(textureId)
            textureId = -1
        }
        bufferLock.lock()
        latestPixelBuffer = nil
        bufferLock.unlock()
        channel = nil
    }

    // MARK: - Private Methods

    private func createPixelBufferFromBGRA32Data(data: NSData, width: Int, height: Int) -> CVPixelBuffer? {
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let expectedDataSize = height * bytesPerRow

        guard data.length >= expectedDataSize else { return nil }

        var pixelBuffer: CVPixelBuffer?

        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferMetalCompatibilityKey as String: true,
            kCVPixelBufferBytesPerRowAlignmentKey as String: 64,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, width, height,
            kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        let lockFlags: CVPixelBufferLockFlags = []
        guard CVPixelBufferLockBaseAddress(buffer, lockFlags) == kCVReturnSuccess else { return nil }
        defer { CVPixelBufferUnlockBaseAddress(buffer, lockFlags) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else { return nil }

        let actualBytesPerRow = CVPixelBufferGetBytesPerRow(buffer)

        if actualBytesPerRow != bytesPerRow {
            let sourcePtr = data.bytes.assumingMemoryBound(to: UInt8.self)
            let destPtr = baseAddress.assumingMemoryBound(to: UInt8.self)
            for row in 0 ..< height {
                memcpy(destPtr + (row * actualBytesPerRow), sourcePtr + (row * bytesPerRow), bytesPerRow)
            }
        } else {
            memcpy(baseAddress, data.bytes, expectedDataSize)
        }

        return buffer
    }
}
