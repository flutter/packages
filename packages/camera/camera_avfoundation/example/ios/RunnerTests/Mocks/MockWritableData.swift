// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A mock implementation of `FLTWritableData` that allows injecting a custom implementation
/// for writing to a file.
final class MockWritableData: NSObject, FLTWritableData {
  /// A stub that replaces the default implementation of `write(toFile,options).`.
  var writeToFileStub: ((String, NSData.WritingOptions) throws -> Void)?

  func write(toFile path: String, options writeOptionsMask: NSData.WritingOptions) throws {
    if let stub = self.writeToFileStub {
      return try stub(path, writeOptionsMask)
    }
  }
}
