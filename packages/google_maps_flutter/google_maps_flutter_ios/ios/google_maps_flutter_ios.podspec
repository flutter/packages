#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'google_maps_flutter_ios'
  s.version          = '0.0.1'
  s.summary          = 'Google Maps for Flutter'
  s.description      = <<-DESC
A Flutter plugin that provides a Google Maps widget.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/google_maps_flutter/google_maps_flutter/ios' }
  s.documentation_url = 'https://pub.dev/packages/google_maps_flutter_ios'
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.module_map = 'Classes/google_maps_flutter_ios.modulemap'
  s.dependency 'Flutter'
  # Allow any version up to the next breaking change after the latest version that
  # has been confirmed to be compatible via an example in examples/. See discussion
  # in https://github.com/flutter/flutter/issues/86820 for why this should be as
  # broad as possible.
  # Versions earlier than 8.4 can't be supported because that's the first version
  # that supports privacy manifests.
  s.dependency 'GoogleMaps', '>= 8.4', '< 10.0'
  # Google-Maps-iOS-Utils 5.x supports GoogleMaps 8.x and iOS 14.0+
  # Google-Maps-iOS-Utils 6.x supports GoogleMaps 9.x and iOS 15.0+
  s.dependency 'Google-Maps-iOS-Utils', '>= 5.0', '< 7.0'
  s.static_framework = true
  s.platform = :ios, '14.0'
  # "Google-Maps-iOS-Utils" is static and contains Swift classes.
  # Find the Swift runtime when these plugins are built as libraries without `use_frameworks!`
  s.swift_version = '5.0'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(inherited) $(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '$(inherited) /usr/lib/swift',
  }
  s.resource_bundles = {'google_maps_flutter_ios_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
