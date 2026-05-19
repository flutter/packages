// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

/// A protocol which abstracts the file writing operation implemented in `Data`.
/// It exists to allow replacing `Data` in tests.
protocol WritableData {
  func writeToPath(
    _ path: String,
    options: Data.WritingOptions
  ) throws
}

extension Data: WritableData {
  func writeToPath(_ path: String, options: Data.WritingOptions) throws {
    try write(to: URL(fileURLWithPath: path), options: options)
  }
}
