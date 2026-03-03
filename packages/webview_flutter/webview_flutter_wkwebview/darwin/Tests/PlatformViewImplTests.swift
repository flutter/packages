// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

class PlatformViewImplTests: XCTestCase {
  #if os(iOS)
    func testPlatformViewImplStoresViewWithAWeakReference() {
      var view: UIView? = UIView()
      let platformView = PlatformViewImpl(uiView: view!)

      XCTAssertEqual(view, platformView.view())

      view = nil
      XCTAssertNotEqual(view, platformView.view())
    }
  #endif
}
