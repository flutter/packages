// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit
import UIKit

/// ProxyApi implementation for `WKWebViewUIExtensions`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class WebViewUIExtensionsProxyAPIDelegate : PigeonApiDelegateWKWebViewUIExtensions {
  func scrollView(pigeonApi: PigeonApiWKWebViewUIExtensions, pigeonInstance: WKWebView) -> UIScrollView {
    return pigeonInstance.scrollView
  }
}
