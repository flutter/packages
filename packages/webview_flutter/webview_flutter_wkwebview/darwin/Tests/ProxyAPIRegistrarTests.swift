// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

@Suite struct ProxyAPIRegistrarTests {
  @Test func logFlutterMethodFailureDoesNotThrowAnError() throws {
    let registrar = TestProxyApiRegistrar()

    withKnownIssue("Method should log a message and not throw an error.") {
      #expect(throws: (any Error).self) {
        try registrar.logFlutterMethodFailure(
          PigeonError(code: "code", message: "message", details: nil), methodName: "aMethod")
      }
    }
  }
}
