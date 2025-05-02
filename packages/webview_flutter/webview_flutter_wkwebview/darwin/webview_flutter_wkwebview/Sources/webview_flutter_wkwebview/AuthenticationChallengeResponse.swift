// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// Data class used to respond to auth challenges from `WKNavigationDelegate`.
///
/// The `webView(_:didReceive:completionHandler:)` method in `WKNavigationDelegate`
/// responds with a completion handler that takes two values. The wrapper returns this class instead to handle
/// this scenario.
class AuthenticationChallengeResponse {
  let disposition: URLSession.AuthChallengeDisposition
  let credential: URLCredential?

  init(disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) {
    self.disposition = disposition
    self.credential = credential
  }
}
