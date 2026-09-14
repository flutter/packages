#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint swift_concurrency_test_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'swift_concurrency_test_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Pigeon test plugin for Swift strict concurrency'
  s.description      = <<-DESC
  A plugin to test Pigeon generation with Swift strict concurrency.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../../../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/pigeon' }
  s.source_files = 'swift_concurrency_test_plugin/Sources/swift_concurrency_test_plugin/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.ios.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '6.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'SWIFT_VERSION' => '6.0', 'SWIFT_STRICT_CONCURRENCY' => 'complete' }
end
