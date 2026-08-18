// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import GoogleMaps
import UIKit

/// Defines a map view used for testing key-value observing.
class PartiallyMockedMapView: GMSMapView {
  /// The number of times that the `frame` KVO has been added.
  private(set) var frameObserverCount: Int = 0

  /// True if animateWithCameraUpdate: was called.
  var didAnimateCamera: Bool = false

  override func addObserver(
    _ observer: NSObject,
    forKeyPath keyPath: String,
    options: NSKeyValueObservingOptions = [],
    context: UnsafeMutableRawPointer?
  ) {
    super.addObserver(observer, forKeyPath: keyPath, options: options, context: context)
    if keyPath == "frame" {
      frameObserverCount += 1
    }
  }

  override func removeObserver(_ observer: NSObject, forKeyPath keyPath: String) {
    super.removeObserver(observer, forKeyPath: keyPath)
    if keyPath == "frame" {
      frameObserverCount -= 1
    }
  }

  override func animate(with cameraUpdate: GMSCameraUpdate) {
    super.animate(with: cameraUpdate)
    didAnimateCamera = true
  }
}
