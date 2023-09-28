// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SafariServices

typealias OpenInSafariVCResponse = (Result<Bool, Error>) -> Void

final class URLLaunchSession: NSObject, SFSafariViewControllerDelegate {

  private let completion: OpenInSafariVCResponse
  private let url: URL
  let safari: SFSafariViewController
  var didFinish: (() -> Void)?

  init(url: URL, completion: @escaping OpenInSafariVCResponse) {
    self.url = url
    self.completion = completion
    self.safari = SFSafariViewController(url: url)
    super.init()
    self.safari.delegate = self
  }

  func safariViewController(
    _ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool
  ) {
    if didLoadSuccessfully {
      completion(Result.success(true))
    } else {
      completion(
        Result.failure(
          GeneralError(code: "Error", message: "Error while launching \(url)", details: nil)))
    }
  }

  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
    didFinish?()
  }

  func close() {
    safariViewControllerDidFinish(safari)
  }
}
