#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'path_provider_foundation'
  s.version          = '0.0.1'
  s.summary          = 'An iOS and macOS implementation of the path_provider plugin.'
  s.description      = <<-DESC
  An iOS and macOS implementation of the Flutter plugin for getting commonly used locations on the filesystem.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider_foundation'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/path_provider/path_provider_foundation' }
  s.source_files = 'path_provider_foundation/Sources/path_provider_foundation/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.ios.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
  s.resource_bundles = {'path_provider_foundation_privacy' => ['path_provider_foundation/Sources/path_provider_foundation/Resources/PrivacyInfo.xcprivacy']}
end
