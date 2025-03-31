// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: unnecessary_statements

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as main_file;

void main() {
  test(
    'ensures webview_flutter_platform_interface.dart exports classes in types directory',
    () {
      main_file.JavaScriptConsoleMessage;
      main_file.JavaScriptLogLevel;
      main_file.JavaScriptMessage;
      main_file.JavaScriptMode;
      main_file.LoadRequestMethod;
      main_file.NavigationDecision;
      main_file.NavigationRequest;
      main_file.NavigationRequestCallback;
      main_file.PageEventCallback;
      main_file.PlatformNavigationDelegateCreationParams;
      main_file.PlatformWebViewControllerCreationParams;
      main_file.PlatformWebViewCookieManagerCreationParams;
      main_file.PlatformWebViewPermissionRequest;
      main_file.PlatformWebViewWidgetCreationParams;
      main_file.ProgressCallback;
      main_file.WebViewPermissionResourceType;
      main_file.WebResourceRequest;
      main_file.WebResourceResponse;
      main_file.WebResourceError;
      main_file.WebResourceErrorCallback;
      main_file.WebViewCookie;
      main_file.WebResourceErrorType;
      main_file.UrlChange;
    },
  );
}
