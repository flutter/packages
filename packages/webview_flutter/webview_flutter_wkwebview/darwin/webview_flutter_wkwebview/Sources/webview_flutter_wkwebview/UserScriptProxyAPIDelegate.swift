// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import WebKit

/// ProxyApi implementation for `WKUserScript`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class UserScriptProxyAPIDelegate: PigeonApiDelegateWKUserScript {
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiWKUserScript, source: String, injectionTime: UserScriptInjectionTime,
    isForMainFrameOnly: Bool
  ) throws -> WKUserScript {
    var nativeInjectionTime: WKUserScriptInjectionTime
    switch injectionTime {
    case .atDocumentStart:
      nativeInjectionTime = .atDocumentStart
    case .atDocumentEnd:
      nativeInjectionTime = .atDocumentEnd
    case .unknown:
      throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createUnknownEnumError(
        withEnum: injectionTime)
    }
    return WKUserScript(
      source: source, injectionTime: nativeInjectionTime, forMainFrameOnly: isForMainFrameOnly)
  }

  func source(pigeonApi: PigeonApiWKUserScript, pigeonInstance: WKUserScript) throws -> String {
    return pigeonInstance.source
  }

  func injectionTime(pigeonApi: PigeonApiWKUserScript, pigeonInstance: WKUserScript) throws
    -> UserScriptInjectionTime
  {
    switch pigeonInstance.injectionTime {
    case .atDocumentStart:
      return .atDocumentStart
    case .atDocumentEnd:
      return .atDocumentEnd
    @unknown default:
      return .unknown
    }
  }

  func isForMainFrameOnly(pigeonApi: PigeonApiWKUserScript, pigeonInstance: WKUserScript) throws
    -> Bool
  {
    return pigeonInstance.isForMainFrameOnly
  }
}
