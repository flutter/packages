// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter

/// Completion handler for camera permission requests.
typealias CameraPermissionRequestCompletionHandler = (FlutterError?) -> Void

/// Manages camera and audio permission requests.
class CameraPermissionManager: NSObject {
  let permissionService: PermissionServicing

  init(permissionService: PermissionServicing) {
    self.permissionService = permissionService
    super.init()
  }

  /// Requests camera access permission.
  ///
  /// If it is the first time requesting camera access, a permission dialog will show up on the
  /// screen. Otherwise AVFoundation simply returns the user's previous choice, and in this case the
  /// user will have to update the choice in Settings app.
  ///
  /// @param handler if access permission is (or was previously) granted, completion handler will be
  /// called without error; Otherwise completion handler will be called with error. Handler can be
  /// called on an arbitrary dispatch queue.
  func requestCameraPermission(
    completionHandler handler: @escaping CameraPermissionRequestCompletionHandler
  ) {
    requestPermission(forAudio: false, handler: handler)
  }

  /// Requests audio access permission.
  ///
  /// If it is the first time requesting audio access, a permission dialog will show up on the
  /// screen. Otherwise AVFoundation simply returns the user's previous choice, and in this case the
  /// user will have to update the choice in Settings app.
  ///
  /// @param handler if access permission is (or was previously) granted, completion handler will be
  /// called without error; Otherwise completion handler will be called with error. Handler can be
  /// called on an arbitrary dispatch queue.
  func requestAudioPermission(
    completionHandler handler: @escaping CameraPermissionRequestCompletionHandler
  ) {
    requestPermission(forAudio: true, handler: handler)
  }

  private func requestPermission(
    forAudio: Bool,
    handler: @escaping CameraPermissionRequestCompletionHandler
  ) {
    let mediaType: AVMediaType = forAudio ? .audio : .video

    switch permissionService.authorizationStatus(for: mediaType) {
    case .authorized:
      handler(nil)

    case .denied:
      let flutterError: FlutterError
      if forAudio {
        flutterError = FlutterError(
          code: "AudioAccessDeniedWithoutPrompt",
          message:
            "User has previously denied the audio access request. Go to Settings to enable audio access.",
          details: nil
        )
      } else {
        flutterError = FlutterError(
          code: "CameraAccessDeniedWithoutPrompt",
          message:
            "User has previously denied the camera access request. Go to Settings to enable camera access.",
          details: nil
        )
      }
      handler(flutterError)

    case .restricted:
      let flutterError: FlutterError
      if forAudio {
        flutterError = FlutterError(
          code: "AudioAccessRestricted",
          message: "Audio access is restricted.",
          details: nil
        )
      } else {
        flutterError = FlutterError(
          code: "CameraAccessRestricted",
          message: "Camera access is restricted.",
          details: nil
        )
      }
      handler(flutterError)

    case .notDetermined:
      permissionService.requestAccess(for: mediaType) { granted in
        // handler can be invoked on an arbitrary dispatch queue.
        if granted {
          handler(nil)
        } else {
          let flutterError: FlutterError
          if forAudio {
            flutterError = FlutterError(
              code: "AudioAccessDenied",
              message: "User denied the audio access request.",
              details: nil
            )
          } else {
            flutterError = FlutterError(
              code: "CameraAccessDenied",
              message: "User denied the camera access request.",
              details: nil
            )
          }
          handler(flutterError)
        }
      }

    @unknown default:
      assertionFailure("Unknown authorization status")
    }
  }
}
