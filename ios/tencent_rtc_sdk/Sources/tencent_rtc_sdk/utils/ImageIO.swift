//
//  ImageSaver.swift
//  Pods
//
//  Created by iveshe on 2025/4/10.
//
import UIKit
import UniformTypeIdentifiers

struct SaveResult {
    let code: TRTCFlutterErrorCode
    let message: String
    let path: String
}

class ImageIO {
    
    static func save(image: UIImage, path: String = "", succ: @escaping (String) -> Void, fail:
        @escaping (Int, String) -> Void) {
        guard let cgImage = image.cgImage else {
            fail(TRTCFlutterErrorCode.invalidImageData.rawValue, "Invalid UIImage (possibly deallocated)")
            return
        }
        
        let targetURL: URL
        if path.isEmpty {
            targetURL = generateDefaultURL()
        } else {
            do {
                targetURL = try resolveURL(for: path)
            } catch {
                fail(TRTCFlutterErrorCode.invalidParameter.rawValue,
                    "Path resolution failed: \(error.localizedDescription)")
                return
            }
        }
        
        guard isPathSafe(targetURL) else {
            fail(TRTCFlutterErrorCode.invalidParameter.rawValue,  "Path is unsafe: \(targetURL.path)")
            return
        }
        
        if FileManager.default.fileExists(atPath: targetURL.path) {
            fail(TRTCFlutterErrorCode.fileAlreadyExists.rawValue, "File already exists: \(targetURL.path)")
            return
        }
        
        guard createParentDirectory(for: targetURL) else {
            // swiftlint:disable:next line_length
            fail(TRTCFlutterErrorCode.parentDirCreateFail.rawValue, "Failed to create parent directory: \(targetURL.deletingLastPathComponent().path)")
            return
        }
        
        guard let format = parseImageFormat(from: targetURL) else {
            fail(TRTCFlutterErrorCode.unsupportedFormat.rawValue, "Only .jpg/.jpeg and .png formats are supported")
            return
        }
        
        guard let data = format == .jpeg ? image.jpegData(compressionQuality: 0.9) : image.pngData() else {
            fail(TRTCFlutterErrorCode.ioError.rawValue, "Failed to convert image data")
            return
        }
        
        do {
            try data.write(to: targetURL, options: [.atomic])
            succ(targetURL.path)
            return
        } catch {
            fail(TRTCFlutterErrorCode.ioError.rawValue, "Write failed: \(error.localizedDescription)")
            return
        }
    }

    static func loadImageFromSandbox(
        atPath path: String,
        success: @escaping (UIImage) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let handleFailure = { (error: TRTCFlutterErrorCode) in
                let message: String
                switch error {
                case .invalidParameter:
                    message = "File path is empty"
                case .fileNotExist:
                    message = "File does not exist at path: \(path)"
                case .isDirectory:
                    message = "Path is a directory: \(path)"
                case .permissionDenied:
                    message = "Path is not readable: \(path)"
                case .invalidImageData:
                    message = "Failed to parse image data: \(path)"
                case .zeroSizeImage:
                    message = "Invalid image size (0x0): \(path)"
                default:
                    message = "An unknown error occurred while loading the image"
                }
                
                DispatchQueue.main.async {
                    TRTCLogger.error(content: "errCode: \(error.rawValue), errMsg: \(message)")
                }
            }
            
            guard !path.isEmpty else {
                handleFailure(.invalidParameter)
                return
            }
            
            let fileManager = FileManager.default
            var isDirectory: ObjCBool = false
            
            guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
                handleFailure(.fileNotExist)
                return
            }
            
            guard !isDirectory.boolValue else {
                handleFailure(.isDirectory)
                return
            }
            
            guard fileManager.isReadableFile(atPath: path) else {
                handleFailure(.permissionDenied)
                return
            }
            
            guard let image = UIImage(contentsOfFile: path) else {
                handleFailure(.invalidImageData)
                return
            }
            
            guard image.size.width > 0 && image.size.height > 0 else {
                handleFailure(.zeroSizeImage)
                return
            }
            
            DispatchQueue.main.async {
                success(image)
            }
        }
    }

    
    // MARK: - Private Helpers
    
    private static func errorResult(_ code: TRTCFlutterErrorCode, _ message: String) -> SaveResult {
        SaveResult(code: code, message: message, path: "")
    }
    
    private static func generateDefaultURL() -> URL {
        // swiftlint:disable:next force_unwrapping
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let randomName = UUID().uuidString + ".jpg"
        return cachesDir.appendingPathComponent(randomName)
    }
    
    private static func resolveURL(for path: String) throws -> URL {
        let pathComponents = path.components(separatedBy: "/").filter { !$0.isEmpty }
        guard !pathComponents.isEmpty else {
            throw NSError(domain: "Invalid path format", code: 0, userInfo: nil)
        }
        
        let sandboxURL: URL
        switch pathComponents[0].lowercased() {
        case "library":
            sandboxURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        case "documents":
            sandboxURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        case "caches":
            sandboxURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        case "tmp":
            sandboxURL = FileManager.default.temporaryDirectory
        default:
            throw NSError(domain: "Illegal root directory name", code: 0, userInfo: nil)
        }
        
        return pathComponents.dropFirst().reduce(sandboxURL) { $0.appendingPathComponent($1) }
    }
    
    private static func isPathSafe(_ url: URL) -> Bool {
        url.standardized.path == url.path
    }
    
    private static func createParentDirectory(for url: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                   withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
    
    private static func parseImageFormat(from url: URL) -> ImageFormat? {
        switch url.pathExtension.lowercased() {
        case "jpg", "jpeg": return .jpeg
        case "png": return .png
        default: return nil
        }
    }
    
    private enum ImageFormat {
        case jpeg
        case png
    }
}
