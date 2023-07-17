#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint test_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'test_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Pigeon test plugin'
  s.description      = <<-DESC
  A plugin to test Pigeon generation for primary languages.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'BSD', :file => '../../../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/pigeon' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
