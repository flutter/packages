// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import UIKit
#endif

@Suite @MainActor struct PlatformViewImplTests {
  #if os(iOS)
    @Test func platformViewImplStoresViewWithAWeakReference() throws {
      var view: UIView? = UIView()
      let platformView = PlatformViewImpl(uiView: view!)

      #expect(platformView.uiView != nil)

      view = nil
      #expect(platformView.uiView == nil)
    }
  #endif
}
