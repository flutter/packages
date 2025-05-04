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
  s.source_files = 'google_sign_in_ios/Sources/google_sign_in_ios/**/*.{h,m}'
  s.public_header_files = 'google_sign_in_ios/Sources/google_sign_in_ios/include/**/*.h'
  s.module_map = 'google_sign_in_ios/Sources/google_sign_in_ios/include/FLTGoogleSignInPlugin.modulemap'

  # AppAuth and GTMSessionFetcher are GoogleSignIn transitive dependencies.
  # Depend on versions which defines modules.
  s.dependency 'AppAuth', '>= 1.7.4'
  s.dependency 'GTMSessionFetcher', '>= 3.4.0'
  s.dependency 'GoogleSignIn', '~> 7.1'
  s.static_framework = true
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

  # google_sign_in_ios does not contain Swift files. For some reason, there
  # is a "pod lib lint" warning unless swift_version is set. This seems related to
  # GoogleSignIn depending a Swift pod (GTMAppAuth).
  s.swift_version = '5.0'

  s.resource_bundles = {'google_sign_in_ios_privacy' => ['google_sign_in_ios/Sources/google_sign_in_ios/Resources/PrivacyInfo.xcprivacy']}
end
