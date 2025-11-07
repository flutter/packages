// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import webview_flutter_wkwebview

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

class SecTrustProxyAPITests: XCTestCase {
  func createTrust(delegate: TestSecTrustProxyAPIDelegate) -> SecTrustWrapper {
    var trust: SecTrust?
    SecTrustCreateWithCertificates(
      [delegate.createDummyCertificate()] as AnyObject, SecPolicyCreateBasicX509(), &trust)

    return SecTrustWrapper(value: trust!)
  }

  func testEvaluateWithError() {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let expect = expectation(description: "Wait for setCookie.")
    let trust = createTrust(delegate: delegate)
    var resultValue: Bool?

    api.pigeonDelegate.evaluateWithError(pigeonApi: api, trust: trust) { result in
      switch result {
      case .success(let value):
        resultValue = value
      case .failure(_):
        break
      }
      expect.fulfill()
    }

    wait(for: [expect], timeout: 5.0)
    XCTAssertEqual(resultValue, true)
  }

  func testCopyExceptions() {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.copyExceptions(pigeonApi: api, trust: trust)

    XCTAssertEqual(value?.data, Data())
  }

  func testSetExceptions() {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.setExceptions(
      pigeonApi: api, trust: trust, exceptions: FlutterStandardTypedData(bytes: Data()))

    XCTAssertEqual(value, false)
  }

  func testGetTrustResult() {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.getTrustResult(pigeonApi: api, trust: trust)

    XCTAssertEqual(value?.result, SecTrustResultType.invalid)
    XCTAssertEqual(value?.resultCode, -1)
  }

  func testCopyCertificateChain() {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecTrustProxyAPIDelegate()
    let api = PigeonApiSecTrust(pigeonRegistrar: registrar, delegate: delegate)

    let trust = createTrust(delegate: delegate)
    let value = try? api.pigeonDelegate.copyCertificateChain(pigeonApi: api, trust: trust)

    XCTAssertEqual(value?.count, 1)
    XCTAssertNotNil(value?.first?.value)
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
