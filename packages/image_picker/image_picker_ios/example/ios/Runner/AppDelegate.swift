// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import Photos
import UIKit
import os

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 14, *) {
      // Seed the photo library with at least one image for tests to operate on.
      let photoAddedKey = "PhotoAdded"
      let photoAdded = UserDefaults.standard.bool(forKey: photoAddedKey)
      let bundle = Bundle(for: Self.self)
      if !photoAdded,
        let jpgImageTall = bundle.url(forResource: "jpgImageTall", withExtension: "jpg")
      {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { _ in
          do {
            try PHPhotoLibrary.shared().performChangesAndWait {
              PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: jpgImageTall)
            }
            UserDefaults.standard.set(true, forKey: photoAddedKey)
          } catch {
            os_log(.error, "%{public}@", error.localizedDescription)
          }
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
