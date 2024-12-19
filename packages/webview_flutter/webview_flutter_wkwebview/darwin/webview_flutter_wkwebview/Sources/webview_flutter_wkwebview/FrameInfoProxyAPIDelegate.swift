// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKFrameInfo`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FrameInfoProxyAPIDelegate: PigeonApiDelegateWKFrameInfo {
  func isMainFrame(pigeonApi: PigeonApiWKFrameInfo, pigeonInstance: WKFrameInfo) throws -> Bool {
    return pigeonInstance.isMainFrame
  }

  func request(pigeonApi: PigeonApiWKFrameInfo, pigeonInstance: WKFrameInfo) throws
    -> URLRequestWrapper
  {
    return URLRequestWrapper(pigeonInstance.request)
  }
}
