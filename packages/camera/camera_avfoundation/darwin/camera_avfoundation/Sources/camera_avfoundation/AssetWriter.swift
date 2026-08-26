// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Foundation

/// A protocol that is a direct passthrough to `AVAssetWriter`. It is used to allow for mocking
/// `AVAssetWriter` in tests.
protocol AssetWriter: NSObjectProtocol {
  var status: AVAssetWriter.Status { get }
  var error: Error? { get }

  func startWriting() -> Bool
  func finishWriting(completionHandler handler: @escaping @Sendable () -> Void)
  func startSession(atSourceTime startTime: CMTime)
  func add(_ input: AVAssetWriterInput)
}

/// A protocol that is a direct passthrough to `AVAssetWriterInput`. It is used to allow for mocking
/// `AVAssetWriterInput` in tests.
protocol AssetWriterInput: NSObjectProtocol {
  /// The underlying `AVAssetWriterInput` instance. This exists so that the input
  /// can be extracted when adding to an AVAssetWriter.
  var avInput: AVAssetWriterInput { get }

  var expectsMediaDataInRealTime: Bool { get set }
  var isReadyForMoreMediaData: Bool { get }

  func append(_ sampleBuffer: CMSampleBuffer) -> Bool
}

/// A protocol that is a direct passthrough to `AVAssetWriterInputPixelBufferAdaptor`. It is used to
/// allow for mocking `AVAssetWriterInputPixelBufferAdaptor` in tests.
protocol AssetWriterInputPixelBufferAdaptor: NSObjectProtocol {
  func append(_ pixelBuffer: CVPixelBuffer, withPresentationTime presentationTime: CMTime) -> Bool
}

extension AVAssetWriter: AssetWriter {}

extension AVAssetWriterInput: AssetWriterInput {
  var avInput: AVAssetWriterInput { self }
}

extension AVAssetWriterInputPixelBufferAdaptor: AssetWriterInputPixelBufferAdaptor {}
