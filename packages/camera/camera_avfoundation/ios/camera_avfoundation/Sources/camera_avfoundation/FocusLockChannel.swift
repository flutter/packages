// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// yuvrecorder patch: exposes a side method channel that locks the active
// AVCaptureDevice's focus at infinity via setFocusModeLocked(lensPosition: 1.0)
// (lensPosition 1.0 = farthest focal point = optical infinity).

import AVFoundation
import Flutter

#if canImport(camera_avfoundation_objc)
  import camera_avfoundation_objc
#endif

final class FocusLockChannel: NSObject {
  static let channelName = "dev.aircraft.yuvrecorder/camera_focus"

  private let channel: FlutterMethodChannel
  private weak var cameraPlugin: CameraPlugin?
  private let captureSessionQueue: DispatchQueue

  init(
    messenger: FlutterBinaryMessenger,
    cameraPlugin: CameraPlugin,
    captureSessionQueue: DispatchQueue
  ) {
    self.channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
    self.cameraPlugin = cameraPlugin
    self.captureSessionQueue = captureSessionQueue
    super.init()
    self.channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
  }

  func tearDown() {
    channel.setMethodCallHandler(nil)
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "lockFocusAtInfinity":
      lockFocusAtInfinity(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func lockFocusAtInfinity(result: @escaping FlutterResult) {
    captureSessionQueue.async { [weak self] in
      guard let cam = self?.cameraPlugin?.camera as? FLTCam else {
        result(
          FlutterError(code: "no_camera", message: "Camera is not initialized yet.", details: nil))
        return
      }
      let device = cam.captureDevice.device
      guard device.isFocusModeSupported(.locked),
        device.isLockingFocusWithCustomLensPositionSupported
      else {
        result(
          FlutterError(
            code: "unsupported",
            message: "Device does not support locking focus at a custom lens position.",
            details: nil))
        return
      }
      do {
        try device.lockForConfiguration()
      } catch {
        result(FlutterError(code: "lock_failed", message: error.localizedDescription, details: nil))
        return
      }
      // lensPosition 1.0 = farthest = infinity.
      device.setFocusModeLocked(lensPosition: 1.0) { _ in
        device.unlockForConfiguration()
        result(nil)
      }
    }
  }
}
