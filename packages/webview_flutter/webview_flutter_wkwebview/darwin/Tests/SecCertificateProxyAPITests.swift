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

class SecCertificateProxyAPITests: XCTestCase {
  func createDummyCertificate() -> SecCertificate {
    let url = FlutterAssetManager().urlForAsset("assets/test_cert.der")!
    let certificateData = NSData(contentsOf: url)

    return SecCertificateCreateWithData(nil, certificateData!)!
  }

  func testCopyData() {
    let registrar = TestProxyApiRegistrar()
    let delegate = TestSecCertificateProxyAPIDelegate()
    let api = PigeonApiSecCertificate(pigeonRegistrar: registrar, delegate: delegate)

    let value = try? api.pigeonDelegate.copyData(
      pigeonApi: api, certificate: SecCertificateWrapper(value: createDummyCertificate()))

    XCTAssertEqual(value?.data, delegate.data)
  }
}

class TestSecCertificateProxyAPIDelegate: SecCertificateProxyAPIDelegate {
  let data = Data()

  override func secCertificateCopyData(_ certificate: SecCertificate) -> CFData {
    return data as CFData
  }
}
