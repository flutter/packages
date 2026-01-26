// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import UIKit

// Import Objective-C part of the implementation when SwiftPM is used.
#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

/// Gets AVCaptureFlashMode from FCPPlatformFlashMode.
/// mode - flash mode.
func getAVCaptureFlashMode(for mode: FCPPlatformFlashMode) -> AVCaptureDevice.FlashMode {
  switch mode {
  case .off:
    return .off
  case .auto:
    return .auto
  case .always:
    return .on
  case .torch:
    assertionFailure("This mode cannot be converted, and requires custom handling.")
    return .off
  @unknown default:
    assertionFailure("Unknown flash mode")
    return .off
  }
}

/// Gets UIDeviceOrientation from its Pigeon representation.
/// orientation - the Pigeon device orientation.
func getUIDeviceOrientation(
  for orientation: FCPPlatformDeviceOrientation
) -> UIDeviceOrientation {
  switch orientation {
  case .portraitDown:
    return .portraitUpsideDown
  case .landscapeLeft:
    return .landscapeLeft
  case .landscapeRight:
    return .landscapeRight
  case .portraitUp:
    return .portrait
  @unknown default:
    assertionFailure("Unknown device orientation")
    return .portrait
  }
}

/// Gets a Pigeon representation of UIDeviceOrientation.
/// orientation - the UIDeviceOrientation.
func getPigeonDeviceOrientation(
  for orientation: UIDeviceOrientation
) -> FCPPlatformDeviceOrientation {
  switch orientation {
  case .portraitUpsideDown:
    return .portraitDown
  case .landscapeLeft:
    return .landscapeLeft
  case .landscapeRight:
    return .landscapeRight
  case .portrait:
    return .portraitUp
  default:
    return .portraitUp
  }
}

/// Gets pixel format from its Pigeon representation.
/// imageFormat - the Pigeon image format.
func getPixelFormat(for imageFormat: FCPPlatformImageFormatGroup) -> OSType {
  switch imageFormat {
  case .bgra8888:
    return kCVPixelFormatType_32BGRA
  case .yuv420:
    return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
  @unknown default:
    assertionFailure("Unknown image format")
    return kCVPixelFormatType_32BGRA
  }
}
