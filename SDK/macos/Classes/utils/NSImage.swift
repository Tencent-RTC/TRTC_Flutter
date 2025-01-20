//
//  NSImage.swift
//  tencent_trtc_cloud
//
//  Created by Gavin wang on 2021/6/23.
//

import Foundation
extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    var jpegData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
    func jpegWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try jpegData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
