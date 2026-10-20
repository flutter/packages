// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKUserContentController`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class UserContentControllerProxyAPIDelegate: PigeonApiDelegateWKUserContentController {
  func addScriptMessageHandler(
    pigeonApi: PigeonApiWKUserContentController, pigeonInstance: WKUserContentController,
    handler: WKScriptMessageHandler, name: String
  ) throws {
    pigeonInstance.add(handler, name: name)
  }

  func removeScriptMessageHandler(
    pigeonApi: PigeonApiWKUserContentController, pigeonInstance: WKUserContentController,
    name: String
  ) throws {
    pigeonInstance.removeScriptMessageHandler(forName: name)
  }

  func removeAllScriptMessageHandlers(
    pigeonApi: PigeonApiWKUserContentController, pigeonInstance: WKUserContentController
  ) throws {
    pigeonInstance.removeAllScriptMessageHandlers()
  }

  func addUserScript(
    pigeonApi: PigeonApiWKUserContentController, pigeonInstance: WKUserContentController,
    userScript: WKUserScript
  ) throws {
    pigeonInstance.addUserScript(userScript)
  }

  func removeAllUserScripts(
    pigeonApi: PigeonApiWKUserContentController, pigeonInstance: WKUserContentController
  ) throws {
    pigeonInstance.removeAllUserScripts()
  }
}
