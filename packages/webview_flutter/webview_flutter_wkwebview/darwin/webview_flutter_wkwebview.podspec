#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'webview_flutter_wkwebview'
  s.version          = '0.0.1'
  s.summary          = 'A WebView Plugin for Flutter.'
  s.description      = <<-DESC
A Flutter plugin that provides a WebView widget.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/packages'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/packages/tree/main/packages/webview_flutter/webview_flutter_wkwebview' }
  s.documentation_url = 'https://pub.dev/packages/webview_flutter'
  s.source_files = 'webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/**/*.{h,m}'
  s.public_header_files = 'webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/include/**/*.h'
  s.module_map = 'webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/include/FlutterWebView.modulemap'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '12.0'
  s.osx.deployment_target = '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'webview_flutter_wkwebview_privacy' => ['webview_flutter_wkwebview/Sources/webview_flutter_wkwebview/Resources/PrivacyInfo.xcprivacy']}
end
