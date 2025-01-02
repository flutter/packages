#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'file_selector_macos'
  s.version          = '0.0.1'
  s.summary          = 'macOS implementation of file_selector.'
  s.description      = <<-DESC
Displays native macOS open and save panels.
                       DESC
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.homepage         = 'https://github.com/flutter/packages/tree/main/packages/file_selector'
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/file_selector/file_selector_macos' }
  s.source_files     = 'file_selector_macos/Sources/file_selector_macos/**/*.swift'
  s.resource_bundles = {'file_selector_macos_privacy' => ['file_selector_macos/Sources/file_selector_macos/Resources/PrivacyInfo.xcprivacy']}
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
