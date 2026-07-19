// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Testing

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

@Suite struct SecTrustProxyAPITests {
  func createTrust(delegate: TestSecTrustProxyAPIDelegate) -> SecTrustWrapper {
    var trust: SecTrust?
    SecTrustCreateWithCertificates(
      [delegate.createDummyCertificate()] as AnyObject, SecPolicyCreateBasicX509(), &trust)

    return SecTrustWrapper(value: trust!)
  }

  @Test func evaluateWithError() async throws {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let resultValue: Bool = try await withCheckedThrowingContinuation { continuation in
      let trust = createTrust(delegate: delegate)
      api.pigeonDelegate.evaluateWithError(pigeonApi: api, trust: trust) { result in
        switch result {
        case .success(let value):
          continuation.resume(returning: value)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
    #expect(resultValue == true)
  }

  @Test func copyExceptions() throws {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.copyExceptions(pigeonApi: api, trust: trust)

    #expect(value?.data == Data())
  }

  @Test func setExceptions() throws {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.setExceptions(
      pigeonApi: api, trust: trust, exceptions: FlutterStandardTypedData(bytes: Data()))

    #expect(value == false)
  }

  @Test func getTrustResult() throws {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.getTrustResult(pigeonApi: api, trust: trust)

    #expect(value?.result == SecTrustResultType.invalid)
    #expect(value?.resultCode == -1)
  }

  @Test func copyCertificateChain() throws {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.copyCertificateChain(pigeonApi: api, trust: trust)

    #expect(value?.count == 1)
    #expect(value?.first?.value != nil)
  }
}

class TestSecTrustProxyAPIDelegate: SecTrustProxyAPIDelegate {
  func createDummyCertificate() -> SecCertificate {
    let url = FlutterAssetManager().urlForAsset("assets/test_cert.der")!
    let certificateData = NSData(contentsOf: url)

    return SecCertificateCreateWithData(nil, certificateData!)!
  }

  override func secTrustEvaluateWithError(
    _ trust: SecTrust, _ error: UnsafeMutablePointer<CFError?>?
  ) -> Bool {
    return true
  }

  override func secTrustCopyExceptions(_ trust: SecTrust) -> CFData? {
    return Data() as CFData
  }

  override func secTrustSetExceptions(_ trust: SecTrust, _ exceptions: CFData?) -> Bool {
    return false
  }

  override func secTrustGetTrustResult(
    _ trust: SecTrust, _ result: UnsafeMutablePointer<SecTrustResultType>
  ) -> OSStatus {
    result.pointee = SecTrustResultType.invalid
    return -1
  }

  override func secTrustCopyCertificateChain(_ trust: SecTrust) -> CFArray? {
    if #available(iOS 15.0, *) {
      return [createDummyCertificate()] as CFArray
    }

    return nil
  }
}
