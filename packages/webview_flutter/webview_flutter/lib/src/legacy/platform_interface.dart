// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Re-export the classes from the webview_flutter_platform_interface through
/// the `platform_interface.dart` file so we don't accidentally break any
/// non-endorsed existing implementations of the interface.
library;

export 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart'
    show
        AutoMediaPlaybackPolicy,
        CreationParams,
        JavascriptChannel,
        JavascriptChannelRegistry,
        JavascriptMessage,
        JavascriptMessageHandler,
        JavascriptMode,
        WebResourceError,
        WebResourceErrorType,
        WebSetting,
        WebSettings,
        WebViewCookie,
        WebViewPlatform,
        WebViewPlatformCallbacksHandler,
        WebViewPlatformController,
        WebViewPlatformCreatedCallback,
        WebViewRequest,
        WebViewRequestMethod;
