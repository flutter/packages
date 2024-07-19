#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'camera_avfoundation'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Camera'
  s.description      = <<-DESC
A Flutter plugin to use the camera from your Flutter app.
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/camera_avfoundation' }
  s.documentation_url = 'https://pub.dev/packages/camera_avfoundation'
  s.source_files = 'camera_avfoundation/Sources/camera_avfoundation/**/*.{h,m}'
  s.public_header_files = 'camera_avfoundation/Sources/camera_avfoundation/include/**/*.h'
  s.module_map = 'camera_avfoundation/Sources/camera_avfoundation/include/CameraPlugin.modulemap'
  s.dependency 'Flutter'

  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'camera_avfoundation_privacy' => ['camera_avfoundation/Sources/camera_avfoundation/Resources/PrivacyInfo.xcprivacy']}
end
