#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'google_maps_flutter_ios_sdk10'
  s.version          = '0.0.1'
  s.summary          = 'Google Maps for Flutter'
  s.description      = <<-DESC
A Flutter plugin that provides a Google Maps widget.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/google_maps_flutter/google_maps_flutter_ios_sdk10' }
  s.documentation_url = 'https://pub.dev/packages/google_maps_flutter_ios_sdk10'
  s.source_files = 'google_maps_flutter_ios_sdk10/Sources/google_maps_flutter_ios_sdk10/**/*.{h,m}'
  s.public_header_files = 'google_maps_flutter_ios_sdk10/Sources/google_maps_flutter_ios_sdk10/include/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'GoogleMaps', '~> 10.0'
  # 6.1.3 was the first version to support GoogleMaps 10.x.
  s.dependency 'Google-Maps-iOS-Utils', '~> 6.1.3'
  s.static_framework = true
  s.platform = :ios, '16.0'
  # "Google-Maps-iOS-Utils" is static and contains Swift classes.
  # Find the Swift runtime when these plugins are built as libraries without `use_frameworks!`
  s.swift_version = '5.9'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(inherited) $(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) /usr/lib/swift',
    # To handle the difference in framework names between CocoaPods and Swift Package Manager.
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) FGM_USING_COCOAPODS=1',
  }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'google_maps_flutter_ios_sdk10_privacy' => ['google_maps_flutter_ios_sdk10/Sources/google_maps_flutter_ios_sdk10/Resources/PrivacyInfo.xcprivacy']}
end
