import Flutter
import Foundation
import TXLiteAVSDK_Professional

class TRTCTextureRender: NSObject, FlutterTexture {

    private weak var textures: FlutterTextureRegistry?
    private var channel: FlutterMethodChannel?

    private var latestPixelBuffer: CVPixelBuffer?
    private let bufferLock = NSLock()

    private(set) var textureId: Int64 = -1

    private var textureWidth: UInt32 = 0
    private var textureHeight: UInt32 = 0

    init(textureRegistry: FlutterTextureRegistry, messenger: FlutterBinaryMessenger) {
        self.textures = textureRegistry
        super.init()
        textureId = textureRegistry.register(self)
        self.channel = FlutterMethodChannel(name: "tencent_rtc_texture_\(textureId)", binaryMessenger: messenger)
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
        bufferLock.unlock()

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
            self.textures?.textureFrameAvailable(self.textureId)
        }
    }

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
}
