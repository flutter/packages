// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

class TestProxyApiRegistrar: ProxyAPIRegistrar {
  init() {
    super.init(binaryMessenger: TestBinaryMessenger(), bundle: TestBundle())
  }

  override func dispatchOnMainThread(
    execute work: @escaping (@escaping (String, PigeonError) -> Void) -> Void
  ) {
    work { _, _ in }
  }
}

class TestBundle: Bundle, @unchecked Sendable {
  override func url(forResource name: String?, withExtension ext: String?) -> URL? {
    return URL(string: "assets/www/index.html")!
  }
}
