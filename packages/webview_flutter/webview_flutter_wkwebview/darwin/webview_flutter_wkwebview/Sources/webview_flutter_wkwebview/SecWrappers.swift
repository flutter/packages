// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Security

/// Wrapper for `SecTrust`.
///
/// Corefoundation types don't support being casted in Swift and will always succeed
/// by default. This wrapper is used to make the class compatible with generated pigeon
/// code. All instances of `SecTrust`should be replaced with this.
class SecTrustWrapper {
  let value: SecTrust

  init(value: SecTrust) {
    self.value = value
  }
}

/// Wrapper for `SecCertificate`.
///
/// Corefoundation types don't support being casted in Swift and will always succeed
/// by default. This wrapper is used to make the class compatible with generated pigeon
/// code. All instances of `SecCertificate`should be replaced with this.
class SecCertificateWrapper {
  let value: SecCertificate

  init(value: SecCertificate) {
    self.value = value
  }
}
