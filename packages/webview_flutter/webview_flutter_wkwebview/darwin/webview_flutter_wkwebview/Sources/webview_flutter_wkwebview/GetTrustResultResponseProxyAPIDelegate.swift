// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `GetTrustResultResponse`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class GetTrustResultResponseProxyAPIDelegate: PigeonApiDelegateGetTrustResultResponse {
  func result(pigeonApi: PigeonApiGetTrustResultResponse, pigeonInstance: GetTrustResultResponse)
    throws -> DartSecTrustResultType
  {
    switch pigeonInstance.result {
    case .unspecified:
      return .unspecified
    case .proceed:
      return .proceed
    case .deny:
      return .deny
    case .recoverableTrustFailure:
      return .recoverableTrustFailure
    case .fatalTrustFailure:
      return .fatalTrustFailure
    case .otherError:
      return .otherError
    case .invalid:
      return .invalid
    case .confirm:
      return .confirm
    @unknown default:
      return .unknown
    }
  }

  func resultCode(
    pigeonApi: PigeonApiGetTrustResultResponse, pigeonInstance: GetTrustResultResponse
  ) throws -> Int64 {
    return Int64(pigeonInstance.resultCode)
  }
}
