// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Mock implementation of `FLTAssetWriterInputPixelBufferAdaptor` protocol which allows injecting a custom
/// implementation.
final class MockAssetWriterInputPixelBufferAdaptor: NSObject, FLTAssetWriterInputPixelBufferAdaptor
{
  var appendStub: ((CVPixelBuffer, CMTime) -> Bool)?

  func append(_ pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool {
    appendStub?(pixelBuffer, presentationTime) ?? true
  }
}
