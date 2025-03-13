// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import SafariServices

typealias OpenInSafariCompletionHandler = (Result<InAppLoadResult, Error>) -> Void

/// A session responsible for launching a URL in Safari and handling its events.
final class URLLaunchSession: NSObject, SFSafariViewControllerDelegate {

  private let completion: OpenInSafariCompletionHandler
  private let url: URL

  /// The Safari view controller used for displaying the URL.
  let safariViewController: SFSafariViewController

  // A closure to be executed after the Safari view controller finishes.
  var didFinish: (() -> Void)?

  /// Initializes a new URLLaunchSession with the provided URL and completion handler.
  ///
  /// - Parameters:
  ///   - url: The URL to be opened in Safari.
  ///   - completion: The completion handler to be called after attempting to open the URL.
  init(url: URL, completion: @escaping OpenInSafariCompletionHandler) {
    self.url = url
    self.completion = completion
    self.safariViewController = SFSafariViewController(url: url)
    super.init()
    self.safariViewController.delegate = self
  }

  /// Called when the Safari view controller completes the initial load.
  ///
  /// - Parameters:
  ///   - controller: The Safari view controller.
  ///   - didLoadSuccessfully: Indicates if the initial load was successful.
  func safariViewController(
    _ controller: SFSafariViewController,
    didCompleteInitialLoad didLoadSuccessfully: Bool
  ) {
    if didLoadSuccessfully {
      completion(.success(.success))
    } else {
      completion(.success(.failedToLoad))
    }
  }

  /// Called when the user finishes using the Safari view controller.
  ///
  /// - Parameter controller: The Safari view controller.
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
    didFinish?()
  }

  /// Closes the Safari view controller.
  func close() {
    safariViewControllerDidFinish(safariViewController)
  }
}
