// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

/// Implementation of `WKScriptMessageHandler` that calls to Dart in callback methods.
class ScriptMessageHandlerImpl: NSObject, WKScriptMessageHandler {
  let api: PigeonApiProtocolWKScriptMessageHandler

  init(api: PigeonApiProtocolWKScriptMessageHandler) {
    self.api = api
  }

  func userContentController(
    _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
  ) {
    api.didReceiveScriptMessage(
      pigeonInstance: self, controller: userContentController, message: message
    ) { _ in }
  }
}

/// ProxyApi implementation for `WKScriptMessageHandler`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ScriptMessageHandlerProxyAPIDelegate: PigeonApiDelegateWKScriptMessageHandler {
  func pigeonDefaultConstructor(pigeonApi: PigeonApiWKScriptMessageHandler) throws
    -> WKScriptMessageHandler
  {
    return ScriptMessageHandlerImpl(api: pigeonApi)
  }
}
