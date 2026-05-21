// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

@testable import camera_avfoundation

/// Mock implementation of `AssetWriterInputPixelBufferAdaptor` protocol which allows injecting a custom
/// implementation.
final class MockAssetWriterInputPixelBufferAdaptor: NSObject, AssetWriterInputPixelBufferAdaptor {
  var appendStub: ((CVPixelBuffer, CMTime) -> Bool)?

  func append(_ pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool {
    appendStub?(pixelBuffer, presentationTime) ?? true
  }
}
