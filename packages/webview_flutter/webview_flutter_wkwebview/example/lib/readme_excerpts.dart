// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Example function for README demonstration of the gesture blocking policy.
PlatformWebViewWidgetCreationParams createParamsWithoutGestureBlocking(
  PlatformWebViewController controller,
) {
  // #docregion gesture_blocking_policy_example
  final params = WebKitWebViewWidgetCreationParams(
    controller: controller,
    gestureBlockingPolicy: .doNotBlockGesture,
  );
  // #enddocregion gesture_blocking_policy_example
  return params;
}
