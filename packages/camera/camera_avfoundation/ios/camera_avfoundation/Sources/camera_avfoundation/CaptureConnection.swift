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
  var videoOrientation: AVCaptureVideoOrientation { get set }

  /// Corresponds to the `inputPorts` property of `AVCaptureConnection`
  var inputPorts: [AVCaptureInput.Port] { get }

  /// Corresponds to the `supportsVideoMirroring` property of `AVCaptureConnection`
  var isVideoMirroringSupported: Bool { get }

  /// Corresponds to the `supportsVideoOrientation` property of `AVCaptureConnection`
  var isVideoOrientationSupported: Bool { get }
}

extension AVCaptureConnection: CaptureConnection {}
