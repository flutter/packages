// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// ProxyApi implementation for `SecCertificate`.
///
/// This class may handle instantiating native object instances that are attached to a Dart instance
/// or handle method calls on the associated native class or an instance of that class.
class SecCertificateProxyAPIDelegate: PigeonApiDelegateSecCertificate {
  func copyData(pigeonApi: PigeonApiSecCertificate, certificate: SecCertificateWrapper) throws
    -> FlutterStandardTypedData
  {
    let data = secCertificateCopyData(certificate.value)
    return FlutterStandardTypedData(bytes: data as Data)
  }

  // Overridable for testing.
  internal func secCertificateCopyData(_ certificate: SecCertificate) -> CFData {
    return SecCertificateCopyData(certificate)
  }
}
