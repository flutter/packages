// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import SafariServices

typealias OpenInSafariCompletionHandler = (Result<Bool, Error>) -> Void

final class URLLaunchSession: NSObject, SFSafariViewControllerDelegate {

  private let completion: OpenInSafariCompletionHandler
  private let url: URL
  let safariViewController: SFSafariViewController
  var didFinish: (() -> Void)?

  init(url: URL, completion: @escaping OpenInSafariCompletionHandler) {
    self.url = url
    self.completion = completion
    self.safariViewController = SFSafariViewController(url: url)
    super.init()
    self.safariViewController.delegate = self
  }

  func safariViewController(
    _ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool
  ) {
    if didLoadSuccessfully {
      completion(.success(true))
    } else {
      completion(
        .failure(
          FlutterError(code: "Error", message: "Error while launching \(url)", details: nil))
      )
    }
  }

  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
    didFinish?()
  }

  func close() {
    safariViewControllerDidFinish(safariViewController)
  }
}
