// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@testable import camera_avfoundation

/// A mock implementation of `WritableData` that allows injecting a custom implementation
/// for writing to a file.
final class MockWritableData: WritableData {
  var writeToFileStub: ((String, Data.WritingOptions) throws -> Void)?

  func writeToPath(_ path: String, options: Data.WritingOptions) throws {
    if let stub = self.writeToFileStub {
      try stub(path, options)
    }
  }
}
