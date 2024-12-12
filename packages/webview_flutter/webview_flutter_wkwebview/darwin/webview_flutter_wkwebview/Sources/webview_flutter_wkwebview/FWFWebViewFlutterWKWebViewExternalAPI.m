// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/webview_flutter_wkwebview/FWFWebViewFlutterWKWebViewExternalAPI.h"
#import "webview_flutter_wkwebview-Swift.h"

@implementation FWFWebViewFlutterWKWebViewExternalAPI
+ (nullable WKWebView *)webViewForIdentifier:(long)identifier
                          withPluginRegistry:(id<FlutterPluginRegistry>)registry {
  return [WebViewFlutterWKWebViewExternalAPI webViewForIdentifier:@(identifier) withPluginRegistry:registry];
}
@end
