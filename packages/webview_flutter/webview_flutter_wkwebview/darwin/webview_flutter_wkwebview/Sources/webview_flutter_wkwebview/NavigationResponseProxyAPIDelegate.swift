// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKNavigationResponse`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class NavigationResponseProxyAPIDelegate: PigeonApiDelegateWKNavigationResponse {
  func response(pigeonApi: PigeonApiWKNavigationResponse, pigeonInstance: WKNavigationResponse)
    throws -> URLResponse
  {
    return pigeonInstance.response
  }

  func isForMainFrame(
    pigeonApi: PigeonApiWKNavigationResponse, pigeonInstance: WKNavigationResponse
  ) throws -> Bool {
    return pigeonInstance.isForMainFrame
  }
}
