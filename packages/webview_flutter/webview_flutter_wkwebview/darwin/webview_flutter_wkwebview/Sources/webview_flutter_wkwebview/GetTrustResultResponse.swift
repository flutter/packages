// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Darwin
import Security

/// Data class used to respond to `SecTrustGetTrustResult`.
///
/// The native method needs to return two values, so this custom class is
/// created to support this.
class GetTrustResultResponse {
  let result: SecTrustResultType
  let resultCode: OSStatus

  init(result: SecTrustResultType, resultCode: OSStatus) {
    self.result = result
    self.resultCode = resultCode
  }
}
