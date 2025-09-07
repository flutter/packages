#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'camera_avfoundation'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Camera'
  s.description      = <<-DESC
A Flutter plugin to use the camera from your Flutter app.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/camera_avfoundation' }
  s.documentation_url = 'https://pub.dev/packages/camera_avfoundation'
  # Combine camera_avfoundation and camera_avfoundation_objc sources into a single pod, unlike
  # SwiftPM, where separate Swift and Objective-C targets are required.
  s.source_files = 'camera_avfoundation/Sources/camera_avfoundation*/**/*.{h,m,swift}'
  s.public_header_files = 'camera_avfoundation/Sources/camera_avfoundation_objc/include/**/*.h'
  s.swift_version = '5.0'
  s.xcconfig = {
     'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
     'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.dependency 'Flutter'

  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'camera_avfoundation_privacy' => ['camera_avfoundation/Sources/camera_avfoundation/Resources/PrivacyInfo.xcprivacy']}
end
