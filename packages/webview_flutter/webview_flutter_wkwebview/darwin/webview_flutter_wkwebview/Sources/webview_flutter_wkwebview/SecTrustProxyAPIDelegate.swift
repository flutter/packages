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
    var error: CFError?
    let result = secTrustEvaluateWithError(trust.value, &error)
    if let error = error {
      throw PigeonError(code: CFErrorGetDomain(error) as String, message: CFErrorCopyDescription(error) as String, details: nil)
    }
    return result
  }

  func copyExceptions(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> FlutterStandardTypedData? {
    let data = secTrustCopyExceptions(trust.value)
    if let data = data {
      return FlutterStandardTypedData(bytes: data as Data)
    }
    
    return nil
  }

  func setExceptions(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper, exceptions: FlutterStandardTypedData?) throws -> Bool {
    let data: CFData? = exceptions != nil ? exceptions!.data as CFData : nil
    return secTrustSetExceptions(trust.value, data)
  }

  func getTrustResult(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> GetTrustResultResponse {
    var result = SecTrustResultType.invalid
    let status = secTrustGetTrustResult(trust.value, &result)
    return GetTrustResultResponse(result: result, resultCode: status)
  }

  func copyCertificateChain(pigeonApi: PigeonApiSecTrust, trust: SecTrustWrapper) throws -> [SecCertificateWrapper]? {
    if #available(iOS 15.0, *) {
      let array = secTrustCopyCertificateChain(trust.value) as Array?
      if let array = array {
        var certificateList: [SecCertificateWrapper] = []
        for certificate in array {
          certificateList.append(SecCertificateWrapper(value: certificate as! SecCertificate))
        }
        return certificateList
      }
    } else {
      let count = secTrustGetCertificateCount(trust.value)
      if count > 0 {
        var certificateList: [SecCertificateWrapper] = []
        for index in 0..<count {
          let certificate = secTrustGetCertificateAtIndex(trust.value, index)
          certificateList.append(SecCertificateWrapper(value: certificate!))
        }
        return certificateList
      }
    }
    
    return nil
  }
  
  // Overridable for testing.
  internal func secTrustEvaluateWithError(_ trust: SecTrust, _ error: UnsafeMutablePointer<CFError?>?) -> Bool {
    return SecTrustEvaluateWithError(trust, error)
  }
  
  // Overridable for testing.
  internal func secTrustCopyExceptions(_ trust: SecTrust) -> CFData? {
    return SecTrustCopyExceptions(trust)
  }
  
  // Overridable for testing.
  internal func secTrustSetExceptions(_ trust: SecTrust, _ exceptions: CFData?) -> Bool {
    return SecTrustSetExceptions(trust, exceptions)
  }
  
  // Overridable for testing.
  internal func secTrustGetTrustResult(_ trust: SecTrust, _ result: UnsafeMutablePointer<SecTrustResultType>) -> OSStatus {
    return SecTrustGetTrustResult(trust, result)
  }
  
  // Overridable for testing.
  internal func secTrustCopyCertificateChain(_ trust: SecTrust) -> CFArray? {
    if #available(iOS 15.0, *) {
      return SecTrustCopyCertificateChain(trust)
    }
    
    return nil
  }
  
  // Overridable for testing.
  internal func secTrustGetCertificateCount(_ trust: SecTrust) -> CFIndex {
    return SecTrustGetCertificateCount(trust)
  }
  
  // Overridable for testing.
  internal func secTrustGetCertificateAtIndex(_ trust: SecTrust, _ ix: CFIndex) -> SecCertificate? {
    return SecTrustGetCertificateAtIndex(trust, ix)
  }
}
