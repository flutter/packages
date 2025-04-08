// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Mock implementation of `FLTAssetWriter` protocol which allows injecting a custom
/// implementation.
final class MockAssetWriter: NSObject, FLTAssetWriter {
  var statusStub: (() -> AVAssetWriter.Status)?
  var startWritingStub: (() -> Bool)?
  var finishWritingStub: ((() -> Void) -> Void)?

  var status: AVAssetWriter.Status {
    return statusStub?() ?? .unknown
  }

  var error: Error? = nil

  func startWriting() -> Bool {
    return startWritingStub?() ?? true
  }

  func finishWriting(completionHandler handler: @escaping () -> Void) {
    finishWritingStub?(handler)
  }

  func startSession(atSourceTime startTime: CMTime) {}

  func add(_ input: AVAssetWriterInput) {}
}
