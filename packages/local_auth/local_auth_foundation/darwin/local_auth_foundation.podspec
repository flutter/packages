#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'local_auth_foundation'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Local Auth'
  s.description      = <<-DESC
This Flutter plugin provides means to perform local, on-device authentication of the user.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/local_auth' }
  s.documentation_url = 'https://pub.dev/packages/local_auth_foundation'
  s.source_files = 'Classes/**/*'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.14'
  s.ios.xcconfig = {
      'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
      'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
    }
  s.swift_version = '5.0'
end
