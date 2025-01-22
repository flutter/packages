#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'quick_actions_ios'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Quick Actions'
  s.description      = <<-DESC
This Flutter plugin allows you to manage and interact with the application's home screen quick actions.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/quick_actions' }
  s.documentation_url = 'https://pub.dev/packages/quick_actions'
  s.swift_version = '5.0'
  s.source_files = 'quick_actions_ios/Sources/quick_actions_ios/*.swift'
  s.xcconfig = {
     'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
     'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'quick_actions_ios_privacy' => ['quick_actions_ios/Sources/quick_actions_ios/Resources/PrivacyInfo.xcprivacy']}
end
