Pod::Spec.new do |spec|
  spec.name         = 'TXLiteAVSDK_TRTC'
  spec.version      = '8.0.9613'
  spec.platform     = :ios 
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
			:text => <<-LICENSE
				copyright 2017 tencent Ltd. All rights reserved.
				LICENSE
			 }
  spec.homepage     = 'https://cloud.tencent.com/product/mlvb'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/454/7876'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXLiteAVSDK for TRTC Edition.'
  spec.ios.framework = ['AVFoundation', 'Accelerate']
  spec.library = 'c++', 'resolv'
  spec.requires_arc = true

  spec.source = { :http => 'https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/temp/TXLiteAVSDK_TRTC_iOS_8.0.9613_SDK.zip' }
  spec.preserve_paths = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework'
  spec.source_files = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework/Headers/*.h'
  spec.public_header_files = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework/Headers/*.h'
  spec.vendored_frameworks = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework'
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework/Headers/'}

  # spec.source = { :file => '.' }
  # spec.preserve_paths = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework'
  # spec.source_files = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework/Headers/*.h'
  # spec.public_header_files = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework/Headers/*.h'
  # spec.vendored_frameworks = 'TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework'
  # spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC/TXLiteAVSDK_TRTC.framework/Headers/'}

  # 启用静态库
  # spec.static_framework = true
end
