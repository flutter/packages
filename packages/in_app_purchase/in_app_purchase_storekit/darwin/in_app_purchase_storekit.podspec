#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'in_app_purchase_storekit'
  s.version          = '0.0.1'
  s.summary          = 'Flutter In App Purchase iOS and macOS'
  s.description      = <<-DESC
A Flutter plugin for in-app purchases. Exposes APIs for making in-app purchases through the App Store.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/in_app_purchase/in_app_purchase_storekit' }
  # TODO(mvanbeusekom): update URL when in_app_purchase_storekit package is published.
  # Updating it before the package is published will cause a lint error and block the tree.
  s.documentation_url = 'https://pub.dev/packages/in_app_purchase'
  s.swift_version = '5.0'
  s.source_files = 'in_app_purchase_storekit/Sources/**/*.{h,m,swift}'
  s.public_header_files = 'in_app_purchase_storekit/Sources/in_app_purchase_storekit_objc/include/**/*.h'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.15'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'in_app_purchase_storekit_privacy' => ['in_app_purchase_storekit/Sources/in_app_purchase_storekit/Resources/PrivacyInfo.xcprivacy']}
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift',
    'LD_RUNPATH_SEARCH_PATHS' => '/usr/lib/swift',
  }
end
