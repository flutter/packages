// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UniformTypeIdentifiers

@testable import image_picker_ios

/// A `PickerItem` stand-in that does not require constructing a `PHPickerResult`.
final class FakePickerItem: NSObject, PickerItem {
  let itemProvider: NSItemProvider
  let assetIdentifier: String?

  init(itemProvider: NSItemProvider, assetIdentifier: String?) {
    self.itemProvider = itemProvider
    self.assetIdentifier = assetIdentifier
  }
}

/// NSItemProvider that reports image conformance but fails to load data.
final class FailingDataItemProvider: NSItemProvider {
  let loadError: Error

  init(error: Error) {
    self.loadError = error
    super.init()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
    true
  }

  override func loadDataRepresentation(
    forTypeIdentifier typeIdentifier: String,
    completionHandler: @escaping @Sendable (Data?, (any Error)?) -> Void
  ) -> Progress {
    completionHandler(nil, loadError)
    return Progress()
  }
}

/// NSItemProvider that reports movie conformance and optionally loads a file URL.
final class MovieItemProvider: NSItemProvider {
  let movieURL: URL?
  let loadError: Error?

  init(movieURL: URL? = nil, loadError: Error? = nil) {
    self.movieURL = movieURL
    self.loadError = loadError
    super.init()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool {
    typeIdentifier == UTType.movie.identifier
  }

  override var registeredTypeIdentifiers: [String] {
    [UTType.movie.identifier]
  }

  override func loadFileRepresentation(
    forTypeIdentifier typeIdentifier: String,
    completionHandler: @escaping @Sendable (URL?, (any Error)?) -> Void
  ) -> Progress {
    completionHandler(movieURL, loadError)
    return Progress()
  }
}
