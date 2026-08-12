#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tencent_rtc_sdk.podspec` to validate before publishing.
#

Pod::Spec.new do |s|
   s.name             = 'tencent_rtc_sdk'
   s.version          = '10.4'
   s.summary          = '腾讯云实时音视频插件'
   s.description      = <<-DESC
   腾讯云实时音视频插件.
                         DESC
   s.homepage         = 'http://example.com'
   s.license          = { :file => '../LICENSE' }
   s.author           = { 'Your Company' => 'email@example.com' }
   s.source           = { :path => '.' }
   s.source_files     = 'Classes/**/*'
   s.dependency 'FlutterMacOS'

   s.platform = :osx, '10.11'
   # s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
   # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
   s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
   s.swift_version = '5.0'

   # 启用静态库
   s.static_framework = true

   # 资源导入
   s.vendored_frameworks = '**/*.framework'
	 s.project_header_files = 'Classes/**/*.h'

  s.public_header_files = 'Classes/**/*.h'
  
  s.frameworks = 'CoreGraphics', 'ImageIO',
                 'Accelerate', 'MetalKit', 'MetalPerformanceShaders'
  
  # SDK 依赖
  s.dependency 'TXLiteAVSDK_TRTC_Mac', '13.4.21067'

end
