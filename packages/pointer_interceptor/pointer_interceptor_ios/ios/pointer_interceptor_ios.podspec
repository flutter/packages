#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint pointer_interceptor_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'pointer_interceptor_ios'
  s.version          = '0.0.1'
  s.summary          = 'Pointer Interceptor IOS'
  s.description      = <<-DESC
This Flutter plugin provides means to prevent gestures from being swallowed by PlatformView on iOS.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/pointer_interceptor/pointer_interceptor_ios' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
