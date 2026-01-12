// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import camera_avfoundation

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Mock implementation of `FLTAssetWriterInputPixelBufferAdaptor` protocol which allows injecting a custom
/// implementation.
final class MockAssetWriterInputPixelBufferAdaptor: NSObject, FLTAssetWriterInputPixelBufferAdaptor
{
  var appendStub: ((CVPixelBuffer, CMTime) -> Bool)?

  func append(_ pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool {
    appendStub?(pixelBuffer, presentationTime) ?? true
  }
}
