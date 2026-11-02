// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// A protocol which is a direct passthrough to `AVCaptureConnection`. It exists to allow replacing
/// `AVCaptureConnection` in tests.
protocol CaptureConnection: NSObjectProtocol {
  /// Corresponds to the `isVideoMirrored` property of `AVCaptureConnection`
  var isVideoMirrored: Bool { get set }

  /// Corresponds to the `videoOrientation` property of `AVCaptureConnection`
  @available(iOS, deprecated: 17.0, renamed: "videoRotationAngle")
  var videoOrientation: AVCaptureVideoOrientation { get set }

  /// Corresponds to the `videoRotationAngle` property of `AVCaptureConnection`
  @available(iOS 17.0, *)
  var videoRotationAngle: CGFloat { get set }

  /// Corresponds to the `inputPorts` property of `AVCaptureConnection`
  var inputPorts: [AVCaptureInput.Port] { get }

  /// Corresponds to the `supportsVideoMirroring` property of `AVCaptureConnection`
  var isVideoMirroringSupported: Bool { get }

  /// Corresponds to the `supportsVideoOrientation` property of `AVCaptureConnection`
  @available(iOS, deprecated: 17.0, renamed: "isVideoRotationAngleSupported(_:)")
  var isVideoOrientationSupported: Bool { get }

  /// Corresponds to the `isVideoRotationAngleSupported(_:)` method of `AVCaptureConnection`
  @available(iOS 17.0, *)
  func isVideoRotationAngleSupported(_ videoRotationAngle: CGFloat) -> Bool

  /// Corresponds to the preferredVideoStabilizationMode property of `AVCaptureConnection`
  var preferredVideoStabilizationMode: AVCaptureVideoStabilizationMode { get set }

}

extension AVCaptureConnection: CaptureConnection {}
