// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import UIKit

/// Gets AVCaptureFlashMode from PlatformFlashMode.
/// mode - flash mode.
func getAVCaptureFlashMode(for mode: PlatformFlashMode) -> AVCaptureDevice.FlashMode {
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
  for orientation: PlatformDeviceOrientation
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
) -> PlatformDeviceOrientation {
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
func getPixelFormat(for imageFormat: PlatformImageFormatGroup) -> OSType {
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

/// Gets video stabilization mode from its Pigeon representation.
/// videoStabilizationMode - the Pigeon video stabilization mode.
func getAvCaptureVideoStabilizationMode(
  _ videoStabilizationMode: PlatformVideoStabilizationMode
) -> AVCaptureVideoStabilizationMode {

  switch videoStabilizationMode {
  case .off:
    return .off
  case .standard:
    return .standard
  case .cinematic:
    return .cinematic
  case .cinematicExtended:
    if #available(iOS 13.0, *) {
      return .cinematicExtended
    } else {
      return .cinematic
    }
  @unknown default:
    return .off
  }
}
