// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct ProxyAPIRegistrarTests {
  // Method should log a message and not throw an error. DO NOT add 'throws' to this
  // test, as it is here to enforce that the method doesn't throw.
  @Test func logFlutterMethodFailureDoesNotThrowAnError() {
    let registrar = TestProxyApiRegistrar()

    registrar.logFlutterMethodFailure(
      PigeonError(code: "code", message: "message", details: nil), methodName: "aMethod")
  }
}
