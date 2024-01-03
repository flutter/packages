// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart'
    as main_file;

void main() {
  group('webview_flutter_platform_interface', () {
    test(
      'ensures webview_flutter_platform_interface.dart exports classes in types directory',
      () {
        // ignore: unnecessary_statements
        main_file.JavaScriptConsoleMessage;
        // ignore: unnecessary_statements
        main_file.JavaScriptLogLevel;
        // ignore: unnecessary_statements
        main_file.JavaScriptMessage;
        // ignore: unnecessary_statements
        main_file.JavaScriptMode;
        // ignore: unnecessary_statements
        main_file.LoadRequestMethod;
        // ignore: unnecessary_statements
        main_file.NavigationDecision;
        // ignore: unnecessary_statements
        main_file.NavigationRequest;
        // ignore: unnecessary_statements
        main_file.NavigationRequestCallback;
        // ignore: unnecessary_statements
        main_file.PageEventCallback;
        // ignore: unnecessary_statements
        main_file.PlatformNavigationDelegateCreationParams;
        // ignore: unnecessary_statements
        main_file.PlatformWebViewControllerCreationParams;
        // ignore: unnecessary_statements
        main_file.PlatformWebViewCookieManagerCreationParams;
        // ignore: unnecessary_statements
        main_file.PlatformWebViewPermissionRequest;
        // ignore: unnecessary_statements
        main_file.PlatformWebViewWidgetCreationParams;
        // ignore: unnecessary_statements
        main_file.ProgressCallback;
        // ignore: unnecessary_statements
        main_file.WebViewPermissionResourceType;
        // ignore: unnecessary_statements
        main_file.WebResourceRequest;
        // ignore: unnecessary_statements
        main_file.WebResourceResponse;
        // ignore: unnecessary_statements
        main_file.WebResourceError;
        // ignore: unnecessary_statements
        main_file.WebResourceErrorCallback;
        // ignore: unnecessary_statements
        main_file.WebViewCookie;
        // ignore: unnecessary_statements
        main_file.WebResourceErrorType;
        // ignore: unnecessary_statements
        main_file.UrlChange;
      },
    );
  });
}
