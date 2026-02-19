#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
Pod::Spec.new do |s|
  s.name             = 'cross_file_darwin'
  s.version          = '0.0.1'
  s.summary          = 'A cross platform file Plugin for Flutter.'
  s.description      = <<-DESC
A Flutter plugin that provides access to files.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/cross_file/cross_file_darwin' }
  s.documentation_url = 'https://pub.dev/packages/cross_file'
  s.source_files = 'cross_file_darwin/Sources/cross_file_darwin/**/*.swift'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  s.resource_bundles = {'cross_file_darwin_privacy' => ['cross_file_darwin/Sources/cross_file_darwin/Resources/PrivacyInfo.xcprivacy']}
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.swift_version = '5.0'
end
