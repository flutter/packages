#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'google_sign_in_ios'
  s.version          = '0.0.1'
  s.summary          = 'Google Sign-In plugin for Flutter'
  s.description      = <<-DESC
Enables Google Sign-In in Flutter apps.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages/tree/main/packages/google_sign_in'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/google_sign_in/google_sign_in_ios' }
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.module_map = 'Classes/FLTGoogleSignInPlugin.modulemap'
  s.dependency 'GoogleSignIn', '~> 7.0.0'
  s.static_framework = true
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'google_sign_in_ios_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
