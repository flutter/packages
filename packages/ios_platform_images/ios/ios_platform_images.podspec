#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ios_platform_images.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ios_platform_images'
  s.version          = '0.0.1'
  s.summary          = 'Flutter iOS Platform Images'
  s.description      = <<-DESC
A Flutter plugin to share images between Flutter and iOS.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/ios_platform_images' }
  s.documentation_url = 'https://pub.dev/packages/ios_platform_images'
  s.source_files = 'Classes/**/*.swift'
  s.source_files = 'ios_platform_images/Sources/ios_platform_images/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.xcconfig = {
     'DEFINES_MODULE' => 'YES',
     'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
     'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
  s.resource_bundles = {'ios_platform_images_privacy' => ['ios_platform_images/Sources/ios_platform_images/Resources/PrivacyInfo.xcprivacy']}
end
