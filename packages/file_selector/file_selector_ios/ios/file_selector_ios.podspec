#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint file_selector_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'file_selector_ios'
  s.version          = '0.0.1'
  s.summary          = 'iOS implementation of file_selector.'
  s.description      = <<-DESC
Displays the native iOS document picker.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages/tree/main/packages/file_selector'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/file_selector/file_selector_ios' }
  s.source_files = 'file_selector_ios/Sources/file_selector_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.resource_bundles = {'file_selector_ios_privacy' => ['file_selector_ios/Sources/file_selector_ios/Resources/PrivacyInfo.xcprivacy']}
end
