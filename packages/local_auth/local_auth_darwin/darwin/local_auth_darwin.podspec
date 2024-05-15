#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'local_auth_darwin'
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
  s.documentation_url = 'https://pub.dev/packages/local_auth_darwin'
  s.source_files = 'local_auth_darwin/Sources/local_auth_darwin/**/*.{h,m}'
  s.public_header_files = 'local_auth_darwin/Sources/local_auth_darwin/include/**/*.h'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'local_auth_darwin_privacy' => ['local_auth_darwin/Sources/local_auth_darwin/Resources/PrivacyInfo.xcprivacy']}
end
