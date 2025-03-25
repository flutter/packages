// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

extension WKFrameInfo {
  // It's possible that `WKFrameInfo.request` can be a nil value despite the Swift code considering
  // it to be nonnull. This causes a crash when accessing the value with Swift. Accessing the value
  // this way prevents the crash when the value is nil.
  //
  // See https://github.com/flutter/flutter/issues/163549 and https://developer.apple.com/forums/thread/77888.
  var maybeRequest: URLRequest? {
    return self.perform(#selector(getter:WKFrameInfo.request))?.takeUnretainedValue()
      as! URLRequest?
  }
}

/// ProxyApi implementation for `WKFrameInfo`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class FrameInfoProxyAPIDelegate: PigeonApiDelegateWKFrameInfo {
  func isMainFrame(pigeonApi: PigeonApiWKFrameInfo, pigeonInstance: WKFrameInfo) throws -> Bool {
    return pigeonInstance.isMainFrame
  }

  func request(pigeonApi: PigeonApiWKFrameInfo, pigeonInstance: WKFrameInfo) throws
    -> URLRequestWrapper?
  {
    let request = pigeonInstance.maybeRequest
    if let request = request {
      return URLRequestWrapper(request)
    }
    return nil
  }
}
