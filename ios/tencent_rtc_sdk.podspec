#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ffi_test.podspec` to validate before publishing.
#

# Single source of the underlying LiteAVSDK series/version; super_player follows these.
LITEAV_SUB_SPEC = 'professional'
LITEAV_SDK_VERSION = '13.6.21648'

LITEAV_POD_MAP = {
  'professional' => 'TXLiteAVSDK_Professional',
  'professional_premium' => 'TXLiteAVSDK_Professional_Player_Premium',
}.freeze

raise "[TencentRTC] invalid LITEAV_SUB_SPEC '#{LITEAV_SUB_SPEC}'" unless LITEAV_POD_MAP.key?(LITEAV_SUB_SPEC)

Pod::Spec.new do |s|
  s.name             = 'tencent_rtc_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter FFI plugin project.'
  s.description      = <<-DESC
A new Flutter FFI plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'tencent_rtc_sdk/Sources/**/*'
  s.dependency 'Flutter'
  s.dependency 'TXCustomBeautyProcesserPlugin', '1.0.2'
  # Activate the matching super_player subspec so its series follows rtc_sdk.
  s.dependency "super_player/#{LITEAV_SUB_SPEC}"
  s.platform = :ios, '12.0'
  s.static_framework = true
  s.project_header_files = 'tencent_rtc_sdk/Sources/tencent_rtc_sdk_c/include/**/*.h'

  s.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
        # SymbolDummy.m 以 "live_c_api/xxx.h" 相对路径引用 C API 头文件（SPM 结构下头文件位于 include/ 子目录）
        'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/tencent_rtc_sdk/Sources/tencent_rtc_sdk_c/include"',
  }
  
  if ENV['USE_LOCAL_LITEAV_SDK'] == 'TRUE'
    puts "[TencentRTC] USE_LOCAL_LITEAV_SDK=TRUE, remote version alignment is ignored"
    s.vendored_frameworks = 'tencent_rtc_sdk/Frameworks/TXLiteAVSDK_Professional.xcframework', 'tencent_rtc_sdk/Frameworks/TXSoundTouch.xcframework', 'tencent_rtc_sdk/Frameworks/TXFFmpeg.xcframework'
    s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/tencent_rtc_sdk/Frameworks/"',
                   'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/tencent_rtc_sdk/Frameworks/TXLiteAVSDK_Professional.xcframework/ios-arm64_armv7/TXLiteAVSDK_Professional.framework/Headers"' }
    s.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary', 'CoreMotion', 'MetalPerformanceShaders', 'MetalKit', 'SystemConfiguration', 'GLKit', 'CoreServices', 'ReplayKit', 'AudioToolbox', 'VideoToolbox', 'AVKit', 'CoreGraphics', 'ImageIO']
    s.ios.weak_frameworks = ['CoreML']
    s.library = 'c++', 'resolv', 'sqlite3', 'z'
  else
    s.dependency LITEAV_POD_MAP[LITEAV_SUB_SPEC], LITEAV_SDK_VERSION
    puts "[TencentRTC] dependency: #{LITEAV_POD_MAP[LITEAV_SUB_SPEC]} #{LITEAV_SDK_VERSION}"
  end

  s.swift_version = '5.0'
end
