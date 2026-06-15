// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
  import Foundation
#else
  #error("Unsupported platform.")
#endif

open class ProxyAPIRegistrar: CrossFileDarwinApisPigeonProxyApiRegistrar {
  init(
    binaryMessenger: FlutterBinaryMessenger,
  ) {
    super.init(binaryMessenger: binaryMessenger, apiDelegate: ProxyAPIDelegate())
  }

  // Log when a Flutter method receives an error from Dart.
  func logFlutterMethodFailure(_ error: PigeonError, methodName: String) {
    NSLog(
      "\(String(describing: error)): Error returned from calling \(methodName): \(String(describing: error.message))"
    )
    NSLog("%@", Thread.callStackSymbols.joined(separator: "\n"))
  }

  /// Handles calling a Flutter method on the main thread.
  func dispatchOnMainThread(
    execute work:
      @escaping (
        _ onFailure: @escaping (_ methodName: String, _ error: PigeonError) -> Void
      ) -> Void
  ) {
    DispatchQueue.main.async {
      work { methodName, error in
        self.logFlutterMethodFailure(error, methodName: methodName)
      }
    }
  }
}

/// Implementation of `CrossFileDarwinApisPigeonProxyApiDelegate` that provides each ProxyApi delegate implementation.
class ProxyAPIDelegate: CrossFileDarwinApisPigeonProxyApiDelegate {
  func pigeonApiAssetResourceReader(_ registrar: CrossFileDarwinApisPigeonProxyApiRegistrar)
    -> PigeonApiAssetResourceReader
  {
    return PigeonApiAssetResourceReader(
      pigeonRegistrar: registrar, delegate: AssetResourceReaderAPIDelegate())
  }
}
