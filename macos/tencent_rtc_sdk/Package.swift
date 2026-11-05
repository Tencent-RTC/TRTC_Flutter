// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

// FlutterFramework 本地包由新版 Flutter（3.44+ 默认 SPM 流程）构建时自动生成于 ../FlutterFramework；
// 实验期 Flutter（3.24–3.43）不生成该包，Flutter 符号在 App 链接期解析——条件依赖以兼容两代工具链。
let flutterFrameworkAvailable = FileManager.default.fileExists(atPath: "../FlutterFramework/Package.swift")

// MARK: - LiteAV 依赖组装（本地 / 远程二选一，与 iOS 的 USE_LOCAL_LITEAV_SDK 分支语义一致）
// 本地模式（内部开发）：环境变量 USE_LOCAL_LITEAV_SDK=TRUE 时链接包根 Frameworks/ 下的本地 xcframework
// （SPM 限制 binaryTarget 路径必须在包根内，故本地库唯一直放位置即此处；podspec 本地分支亦引用这里，单份双用）；
// 否则走远程 TRTC_Mac_SwiftPM 仓库（要求 swift-tools 6.0（Xcode 16+）、最低 macOS 10.13）。
// 该脚本同时会删除下方 else 远程分支，将本地模式固化。
// ⚠️ 下方 if/else 行的写法与缩进不可改动（switch_to_local_sdk.sh 的 perl 正则依赖行首锚定）。
var packageDependencies: [Package.Dependency] = []
var liteavDependencies: [Target.Dependency] = []
var liteavLinkerSettings: [LinkerSetting] = []
var localBinaryTargets: [Target] = []

if ProcessInfo.processInfo.environment["USE_LOCAL_LITEAV_SDK"] == "TRUE" {
    // 与 ci/live/build_app.sh 本地 macOS 三件套一致
    liteavDependencies = [
        .target(name: "TXLiteAVSDK_TRTC_Mac"),
        .target(name: "TXSoundTouch"),
        .target(name: "TXFFmpeg"),
    ]
    localBinaryTargets = [
        .binaryTarget(name: "TXLiteAVSDK_TRTC_Mac", path: "Frameworks/TXLiteAVSDK_TRTC_Mac.xcframework"),
        .binaryTarget(name: "TXSoundTouch", path: "Frameworks/TXSoundTouch.xcframework"),
        .binaryTarget(name: "TXFFmpeg", path: "Frameworks/TXFFmpeg.xcframework"),
    ]
    // 与 podspec 的 frameworks 配置对齐（macOS podspec 无 weak_frameworks / 额外链接库）
    liteavLinkerSettings = [
        .linkedFramework("CoreGraphics"), .linkedFramework("ImageIO"), .linkedFramework("Accelerate"),
        .linkedFramework("MetalKit"), .linkedFramework("MetalPerformanceShaders"),
    ]
} else {
    packageDependencies.append(.package(url: "https://github.com/Tencent-RTC/TRTC_Mac_SwiftPM.git", from: "13.6.21648"))
    liteavDependencies = [.product(name: "TRTC_Mac_SwiftPM", package: "TRTC_Mac_SwiftPM")]
}

var flutterTargetDependency: [Target.Dependency] = []
if flutterFrameworkAvailable {
    packageDependencies.append(.package(name: "FlutterFramework", path: "../FlutterFramework"))
    flutterTargetDependency.append(.product(name: "FlutterFramework", package: "FlutterFramework"))
}

let package = Package(
    name: "tencent_rtc_sdk",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(name: "tencent-rtc-sdk", targets: ["tencent_rtc_sdk", "tencent_rtc_sdk_c"])
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "tencent_rtc_sdk",
            dependencies: flutterTargetDependency + liteavDependencies,
            linkerSettings: liteavLinkerSettings
        ),
        // C target：承载 SymbolDummy / CameraDeviceTestBridge（强制链接 LiteAV FFI 符号）与 C API 公开头文件
        .target(
            name: "tencent_rtc_sdk_c",
            dependencies: liteavDependencies,
            publicHeadersPath: "include",
            // 头文件间存在跨子目录的不带前缀引用（CocoaPods 时代靠拍平 header search path 解决）
            cSettings: [
                .headerSearchPath("include/live_c_api"),
                .headerSearchPath("include/trtc_c_api"),
            ]
        ),
    ] + localBinaryTargets
)
