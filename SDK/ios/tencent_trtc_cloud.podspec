#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tencent_trtc_cloud.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tencent_trtc_cloud'
  s.version          = '10.7'
  s.summary          = '腾讯云实时音视频插件'
  s.description      = <<-DESC
腾讯云实时音视频插件
                       DESC
  s.homepage         = 'https://github.com/xx/xx'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'xx' => 'xx@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  # 启用静态库
  s.static_framework = true

  # 资源导入
  s.vendored_frameworks = '**/*.framework'

  s.public_header_files = 'Classes/**/*.h'

  # SDK 依赖
  # s.dependency 'TXLiteAVSDK_Live', '9.9.11217'
  s.dependency 'TXLiteAVSDK_Professional'
  s.dependency 'TXCustomBeautyProcesserPlugin', '1.0.2'
end

