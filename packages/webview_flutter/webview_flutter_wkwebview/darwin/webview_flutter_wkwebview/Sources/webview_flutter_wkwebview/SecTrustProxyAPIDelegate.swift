// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
  import Foundation
#else
  #error("Unsupported platform.")
#endif
import Foundation

/// ProxyApi implementation for `SecTrust`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class SecTrustProxyAPIDelegate : PigeonApiDelegateSecTrust {
  func evaluateWithError(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> Bool {
    var error: Unmanaged<CFError>?
    let result = SecTrustEvaluateWithError(trust.value, &error)
    return result
  }

  func copyExceptions(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> FlutterStandardTypedData {
    return SecTrust.copyExceptions(trust: trust)
  }

  func setExceptions(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper, exceptions: FlutterStandardTypedData) throws -> Bool {
    return SecTrust.setExceptions(trust: trust, exceptions: exceptions)
  }

  func getTrustResult(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> GetTrustResultResponse {
    return SecTrust.getTrustResult(trust: trust)
  }

  func copyCertificateChain(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> [String] {
    return SecTrust.copyCertificateChain(trust: trust)
  }
}
