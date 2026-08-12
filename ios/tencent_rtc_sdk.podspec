#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ffi_test.podspec` to validate before publishing.
#
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

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.resources = ['Classes/vod/TXResource/**/*']
  s.dependency 'Flutter'
  s.dependency 'TXCustomBeautyProcesserPlugin', '1.0.2'
  s.platform = :ios, '12.0'
  s.static_framework = true
  s.project_header_files = 'Classes/**/*.h, Classes/*.h'

    # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
        'DEFINES_MODULE' => 'YES',
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  
  if ENV['USE_LOCAL_LITEAV_SDK'] == 'TRUE'
    s.vendored_frameworks = 'Frameworks/TXLiteAVSDK_Professional.xcframework', 'Frameworks/TXSoundTouch.xcframework', 'Frameworks/TXFFmpeg.xcframework'
    s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '${PODS_ROOT}/../../../sdk/ios/Frameworks/',
                   'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/../../../sdk/ios/Frameworks/TXLiteAVSDK_Professional.xcframework/ios-arm64_armv7/TXLiteAVSDK_Professional.framework/Headers' }
    s.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary', 'CoreMotion', 'MetalPerformanceShaders', 'MetalKit', 'SystemConfiguration', 'GLKit', 'CoreServices', 'ReplayKit', 'AudioToolbox', 'VideoToolbox', 'AVKit', 'CoreGraphics', 'ImageIO']
    s.ios.weak_frameworks = ['CoreML']
    s.library = 'c++', 'resolv', 'sqlite3', 'z'
  else
    s.dependency 'TXLiteAVSDK_Professional', '13.4.21067'
  end

  s.swift_version = '5.0'
end
