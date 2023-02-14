#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint alternate_language_test_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'alternate_language_test_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Alternate-language Pigeon test plugin'
  s.description      = <<-DESC
A plugin to test Pigeon generation for secondary languages (e.g., Java, Objective-C).
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../../../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/pigeon' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
