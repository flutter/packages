// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKScriptMessage`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class ScriptMessageProxyAPIDelegate: PigeonApiDelegateWKScriptMessage {
  func name(pigeonApi: PigeonApiWKScriptMessage, pigeonInstance: WKScriptMessage) throws -> String {
    return pigeonInstance.name
  }

  func body(pigeonApi: PigeonApiWKScriptMessage, pigeonInstance: WKScriptMessage) throws -> Any? {
    return pigeonInstance.body
  }
}
