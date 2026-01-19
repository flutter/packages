// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Implementation of `CrossFileDarwinApisPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation
/// and any additional resources needed by an implementation.
open class ProxyApiDelegate: CrossFileDarwinApisPigeonProxyApiDelegate {
  /// Creates an error when the constructor of a class returns null.
  func createConstructorNullError(type: Any.Type, parameters: [String: Any?]) -> PigeonError {
    return PigeonError(
      code: "ConstructorReturnedNullError",
      message: "Failed to instantiate `\(String(describing: type))` with parameters: \(parameters)",
      details: nil)
  }

  func pigeonApiFileHandle(_ registrar: CrossFileDarwinApisPigeonProxyApiRegistrar)
    -> PigeonApiFileHandle
  {
    return PigeonApiFileHandle(pigeonRegistrar: registrar, delegate: FileHandleProxyAPIDelegate())
  }
}
