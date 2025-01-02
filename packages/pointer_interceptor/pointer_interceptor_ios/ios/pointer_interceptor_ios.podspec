#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pointer_interceptor_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pointer_interceptor_ios'
  s.version          = '0.0.1'
  s.summary          = 'Implementation of pointer_interceptor for iOS.'
  s.description      = <<-DESC
This Flutter plugin provides means to prevent gestures from being swallowed by PlatformView on iOS.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/pointer_interceptor/pointer_interceptor_ios' }
  s.source_files = 'pointer_interceptor_ios/Sources/pointer_interceptor_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.resource_bundles = {'pointer_interceptor_ios_privacy' => ['pointer_interceptor_ios/Sources/pointer_interceptor_ios/PrivacyInfo.xcprivacy']}
end
