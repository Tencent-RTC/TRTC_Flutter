// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

// MARK: - LiteAV 分包协商协议（见 docs/spm-migration-plan.md §3.5）
// 优先级：环境变量 LITEAV_SDK_SUB_SPEC > 插件自身 pubspec.yaml 顶层 `liteav.sub_spec` > 默认 professional
// 注意：修改分包配置后需 `flutter clean` 再构建（SPM manifest 求值有缓存）。

// 注意：各分包仓库版本线不同步（规划文档 §3.1），每个变体须各自标注可用版本。
let liteavVariantMap: [String: (package: String, product: String, version: String)] = [
    "professional": (package: "Professional_SwiftPM", product: "Professional_SwiftPM", version: "13.6.21648"),
    "professional_premium": (package: "Professional_Player_Premium_SwiftPM", product: "Professional_Player_Premium_SwiftPM", version: "13.4.21062"),
]
let liteavDefaultVariant = "professional"

func resolveLiteAVVariant() -> String {
    let allowed = Set(liteavVariantMap.keys)
    if let env = ProcessInfo.processInfo.environment["LITEAV_SDK_SUB_SPEC"] {
        if allowed.contains(env) { return env }
        FileHandle.standardError.write("[tencent_rtc_sdk] 忽略非法 LITEAV_SDK_SUB_SPEC=\(env)，回退 yaml/默认\n".data(using: .utf8)!)
    }
    // 自包目录向上最多 8 层查找含 liteav.sub_spec 的 pubspec.yaml（命中插件自身 pubspec，见规划文档 §3.5）
    var dir = FileManager.default.currentDirectoryPath
    for _ in 0..<8 {
        let candidate = dir + "/pubspec.yaml"
        if let content = try? String(contentsOfFile: candidate, encoding: .utf8),
           let match = content.range(of: #"(?m)^liteav:\s*\r?\n\s+sub_spec:\s*([a-z_]+)\s*$"#, options: .regularExpression) {
            let value = String(content[match].replacingOccurrences(of: #"(?m)^liteav:\s*\r?\n\s+sub_spec:\s*"#, with: "", options: .regularExpression)).trimmingCharacters(in: .whitespacesAndNewlines)
            if allowed.contains(value) { return value }
            FileHandle.standardError.write("[tencent_rtc_sdk] 忽略非法 liteav.sub_spec=\(value)，回退默认\n".data(using: .utf8)!)
        }
        let parent = (dir as NSString).deletingLastPathComponent
        if parent == dir { break }
        dir = parent
    }
    return liteavDefaultVariant
}

// FlutterFramework 本地包由新版 Flutter（3.44+ 默认 SPM 流程）构建时自动生成于 ../FlutterFramework；
// 实验期 Flutter（3.24–3.43）不生成该包，Flutter 符号在 App 链接期解析——条件依赖以兼容两代工具链。
let flutterFrameworkAvailable = FileManager.default.fileExists(atPath: "../FlutterFramework/Package.swift")

// MARK: - LiteAV 依赖组装（本地 / 远程二选一，与 podspec 的 USE_LOCAL_LITEAV_SDK 分支语义一致）
// 本地模式（内部开发）：环境变量 USE_LOCAL_LITEAV_SDK=TRUE 时链接包根 Frameworks/ 下的本地 xcframework
// （SPM 限制 binaryTarget 路径必须在包根内，故本地库唯一直放位置即此处；podspec 本地分支亦引用这里，单份双用）；
// 否则走远程 *_SwiftPM 仓库（分包协商见上方）。该脚本同时会删除下方 else 远程分支，将本地模式固化。
// ⚠️ 下方 if/else 行的写法与缩进不可改动（switch_to_local_sdk.sh 的 perl 正则依赖行首锚定）。
var packageDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/Tencent-RTC/TXCustomBeautyProcesserPlugin_SwiftPM.git", from: "1.0.2"),
]
var liteavDependencies: [Target.Dependency] = []
var liteavLinkerSettings: [LinkerSetting] = []
var localBinaryTargets: [Target] = []

if ProcessInfo.processInfo.environment["USE_LOCAL_LITEAV_SDK"] == "TRUE" {
    // 与 podspec 本地分支一致的三件套（SDK_TYPE=Professional；换 SDK_TYPE 时需同步改名）
    liteavDependencies = [
        .target(name: "TXLiteAVSDK_Professional"),
        .target(name: "TXSoundTouch"),
        .target(name: "TXFFmpeg"),
    ]
    localBinaryTargets = [
        .binaryTarget(name: "TXLiteAVSDK_Professional", path: "Frameworks/TXLiteAVSDK_Professional.xcframework"),
        .binaryTarget(name: "TXSoundTouch", path: "Frameworks/TXSoundTouch.xcframework"),
        .binaryTarget(name: "TXFFmpeg", path: "Frameworks/TXFFmpeg.xcframework"),
    ]
    // 与 podspec 本地分支的链接配置对齐（CoreML 原为 weak_frameworks；SPM 无 weak 声明，iOS 12+ 均含 CoreML，强链接可接受）
    liteavLinkerSettings = [
        .linkedFramework("AVFoundation"), .linkedFramework("Accelerate"), .linkedFramework("AssetsLibrary"),
        .linkedFramework("CoreMotion"), .linkedFramework("MetalPerformanceShaders"), .linkedFramework("MetalKit"),
        .linkedFramework("SystemConfiguration"), .linkedFramework("GLKit"), .linkedFramework("CoreServices"),
        .linkedFramework("ReplayKit"), .linkedFramework("AudioToolbox"), .linkedFramework("VideoToolbox"),
        .linkedFramework("AVKit"), .linkedFramework("CoreGraphics"), .linkedFramework("ImageIO"),
        .linkedFramework("CoreML"),
        .linkedLibrary("c++"), .linkedLibrary("resolv"), .linkedLibrary("sqlite3"), .linkedLibrary("z"),
    ]
} else {
    let liteav = liteavVariantMap[resolveLiteAVVariant()] ?? liteavVariantMap[liteavDefaultVariant]!
    let versionParts = liteav.version.split(separator: ".").compactMap { Int($0) }
    packageDependencies.append(.package(url: "https://github.com/Tencent-RTC/\(liteav.package).git", from: Version(versionParts[0], versionParts[1], versionParts[2])))
    liteavDependencies = [.product(name: liteav.product, package: liteav.package)]
}

var flutterTargetDependency: [Target.Dependency] = []
if flutterFrameworkAvailable {
    packageDependencies.append(.package(name: "FlutterFramework", path: "../FlutterFramework"))
    flutterTargetDependency.append(.product(name: "FlutterFramework", package: "FlutterFramework"))
}

let package = Package(
    name: "tencent_rtc_sdk",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "tencent-rtc-sdk", targets: ["tencent_rtc_sdk", "tencent_rtc_sdk_c"])
    ],
    dependencies: packageDependencies,
    targets: [
        .target(
            name: "tencent_rtc_sdk",
            dependencies: flutterTargetDependency + [
                .product(name: "TXCustomBeautyProcesserPlugin", package: "TXCustomBeautyProcesserPlugin_SwiftPM"),
            ] + liteavDependencies,
            linkerSettings: liteavLinkerSettings
        ),
        // C target：承载 SymbolDummy（强制链接 LiteAV FFI 符号）与 C API 公开头文件
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
