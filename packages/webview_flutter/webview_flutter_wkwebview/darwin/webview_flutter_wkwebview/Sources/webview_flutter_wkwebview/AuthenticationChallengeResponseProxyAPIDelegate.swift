// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// ProxyApi implementation for `AuthenticationChallengeResponse`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class AuthenticationChallengeResponseProxyAPIDelegate:
  PigeonApiDelegateAuthenticationChallengeResponse
{
  func pigeonDefaultConstructor(
    pigeonApi: PigeonApiAuthenticationChallengeResponse,
    disposition: UrlSessionAuthChallengeDisposition, credential: URLCredential?
  ) throws -> AuthenticationChallengeResponse {
    let nativeDisposition: URLSession.AuthChallengeDisposition

    switch disposition {
    case .useCredential:
      nativeDisposition = .useCredential
    case .performDefaultHandling:
      nativeDisposition = .performDefaultHandling
    case .cancelAuthenticationChallenge:
      nativeDisposition = .cancelAuthenticationChallenge
    case .rejectProtectionSpace:
      nativeDisposition = .rejectProtectionSpace
    case .unknown:
      throw (pigeonApi.pigeonRegistrar as! ProxyAPIRegistrar).createUnknownEnumError(
        withEnum: disposition)
    }

    return AuthenticationChallengeResponse(disposition: nativeDisposition, credential: credential)
  }

  func createAsync(
    pigeonApi: PigeonApiAuthenticationChallengeResponse,
    disposition: UrlSessionAuthChallengeDisposition, credential: URLCredential?,
    completion: @escaping (Result<AuthenticationChallengeResponse, Error>) -> Void
  ) {
    completion(
      Result.success(
        try! pigeonDefaultConstructor(
          pigeonApi: pigeonApi, disposition: disposition, credential: credential)))
  }

  func disposition(
    pigeonApi: PigeonApiAuthenticationChallengeResponse,
    pigeonInstance: AuthenticationChallengeResponse
  ) throws -> UrlSessionAuthChallengeDisposition {
    switch pigeonInstance.disposition {
    case .useCredential:
      return .useCredential
    case .performDefaultHandling:
      return .performDefaultHandling
    case .cancelAuthenticationChallenge:
      return .cancelAuthenticationChallenge
    case .rejectProtectionSpace:
      return .rejectProtectionSpace
    @unknown default:
      return .unknown
    }
  }

  func credential(
    pigeonApi: PigeonApiAuthenticationChallengeResponse,
    pigeonInstance: AuthenticationChallengeResponse
  ) throws -> URLCredential? {
    return pigeonInstance.credential
  }
}
