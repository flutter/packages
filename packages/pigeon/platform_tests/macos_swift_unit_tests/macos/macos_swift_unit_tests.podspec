#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint macos_swift_unit_tests.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'macos_swift_unit_tests'
  s.version          = '0.0.1'
  s.summary          = 'Fake library that uses pigeon for macos for testing.'
  s.description      = <<-DESC
Fake library that uses pigeon for macos for testing.

Use `pod lib lint` to run the tests.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'Flutter', :file => '../../../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }

  s.source           = { :http => 'https://github.com/flutter/packages' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/*.{swift}'
  end
end
