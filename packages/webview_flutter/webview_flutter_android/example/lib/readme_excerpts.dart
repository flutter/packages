// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Example function for README demonstration of Payment Request API.
Future<void> enablePaymentRequest() async {
  final PlatformWebViewController controller = PlatformWebViewController(
    AndroidWebViewControllerCreationParams(),
  );
  final AndroidWebViewController androidController =
      controller as AndroidWebViewController;
  // #docregion payment_request_example
  final bool paymentRequestEnabled = await androidController
      .isWebViewFeatureSupported(WebViewFeatureType.paymentRequest);

  if (paymentRequestEnabled) {
    await androidController.setPaymentRequestEnabled(true);
  }
  // #enddocregion payment_request_example
}
