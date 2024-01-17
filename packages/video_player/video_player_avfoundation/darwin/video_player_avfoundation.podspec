#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'video_player_avfoundation'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Video Player'
  s.description      = <<-DESC
A Flutter plugin for playing back video on a Widget surface.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/video_player/video_player_avfoundation' }
  s.documentation_url = 'https://pub.dev/packages/video_player'
  s.source_files = 'Classes/*'
  s.ios.source_files = 'Classes/ios/*'
  s.osx.source_files = 'Classes/macos/*'
  s.public_header_files = 'Classes/**/*.h'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'video_player_avfoundation_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
