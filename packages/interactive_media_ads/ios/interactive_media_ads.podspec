#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint interactive_media_ads.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'interactive_media_ads'
  s.version          = '0.0.1'
  s.summary          = 'A plugin for Interactive Media Ads SDKs.'
  s.description      = <<-DESC
A Flutter plugin for using the Interactive Media Ads SDKs.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/interactive_media_ads/interactive_media_ads' }
  s.source_files = 'interactive_media_ads/Sources/interactive_media_ads/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'GoogleAds-IMA-iOS-SDK', '~> 3.23'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
  s.resource_bundles = {'interactive_media_ads_privacy' => ['interactive_media_ads/Sources/interactive_media_ads/Resources/PrivacyInfo.xcprivacy']}
end
