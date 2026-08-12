//
//  Constants.swift
//  tencent_rtc_sdk
//
//  Created by iveshe on 2025/5/7.
//

import Foundation

// swiftlint:disable number_separator
enum TRTCFlutterErrorCode: Int {
    // MARK: - success
    case success = 0
    
    // MARK: - Common Errors (-6000~6099)
    case invalidParameter = -6001
    case permissionDenied = -6002
    
    // MARK: - File system errors (-6100~6199)
    case fileNotExist        = -6101
    case isDirectory         = -6102
    case fileAlreadyExists   = -6103
    case storageUnmounted    = -6104
    case parentDirCreateFail = -6105
    case ioError             = -6106
    
    // MARK: - Data validation errors (-6200~6299)
    case emptyData          = -6201
    case invalidImageData   = -6202
    case zeroSizeImage      = -6203
    case unsupportedFormat  = -6204
}
