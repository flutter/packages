// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import UIKit

/// The platform view type of the HLG preview. Must match the Dart side.
let hdrPreviewViewType = "plugins.flutter.io/camera_avfoundation/hdr_preview"

/// A view backed by an `AVCaptureVideoPreviewLayer`, which can display 10-bit HLG frames that the
/// Flutter texture path cannot carry.
final class HDRPreviewUIView: UIView {
  override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

  var previewLayer: AVCaptureVideoPreviewLayer {
    // `layerClass` guarantees the type.
    return layer as! AVCaptureVideoPreviewLayer
  }
}

/// Hosts an `HDRPreviewUIView` and connects its layer to the current camera.
final class HDRPreviewPlatformView: NSObject, FlutterPlatformView {
  private let previewView = HDRPreviewUIView()

  init(frame: CGRect, captureSessionQueue: DispatchQueue, cameraProvider: @escaping () -> Camera?) {
    super.init()
    previewView.frame = frame
    previewView.backgroundColor = .black
    previewView.previewLayer.videoGravity = .resizeAspectFill

    // Session changes must never block the main thread, so the connection is made on the capture
    // session queue, behind any `startRunning` call that is in progress. The camera is read there
    // too, because the plugin changes it on that queue.
    let layer = previewView.previewLayer
    captureSessionQueue.async {
      cameraProvider()?.attachPreviewLayer(layer)
    }
  }

  func view() -> UIView {
    return previewView
  }
}

/// Creates the platform views that show the HLG preview.
final class HDRPreviewViewFactory: NSObject, FlutterPlatformViewFactory {
  private let captureSessionQueue: DispatchQueue
  private let cameraProvider: () -> Camera?

  /// `cameraProvider` returns the plugin's current camera and is called on the capture session
  /// queue.
  init(captureSessionQueue: DispatchQueue, cameraProvider: @escaping () -> Camera?) {
    self.captureSessionQueue = captureSessionQueue
    self.cameraProvider = cameraProvider
    super.init()
  }

  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    return HDRPreviewPlatformView(
      frame: frame, captureSessionQueue: captureSessionQueue, cameraProvider: cameraProvider)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }
}
