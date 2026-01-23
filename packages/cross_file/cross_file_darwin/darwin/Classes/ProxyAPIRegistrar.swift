// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Foundation

/// Implementation of `CrossFileDarwinApisPigeonProxyApiRegistrar` that provides any additional resources needed by API implementations.
open class ProxyAPIRegistrar: CrossFileDarwinApisPigeonProxyApiRegistrar {
  init(binaryMessenger: FlutterBinaryMessenger) {
    super.init(binaryMessenger: binaryMessenger, apiDelegate: ProxyAPIDelegate())
  }

  func createConstructorNullError(type: Any.Type, parameters: [String: Any?]) -> PigeonError {
    return PigeonError(
      code: "ConstructorReturnedNullError",
      message: "Failed to instantiate `\(String(describing: type))` with parameters: \(parameters)",
      details: nil)
  }
}

/// Implementation of `WebKitLibraryPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation.
open class ProxyAPIDelegate: CrossFileDarwinApisPigeonProxyApiDelegate {
  func pigeonApiFileHandle(_ registrar: CrossFileDarwinApisPigeonProxyApiRegistrar)
    -> PigeonApiFileHandle
  {
    return PigeonApiFileHandle(pigeonRegistrar: registrar, delegate: FileHandleProxyAPIDelegate())
  }
}
