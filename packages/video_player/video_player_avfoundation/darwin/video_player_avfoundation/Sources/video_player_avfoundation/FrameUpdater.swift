// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

/// FrameUpdater is responsible for notifying the Flutter texture registry
/// when a new video frame is available.
class FrameUpdater {
  /// The Flutter texture registry used to notify about new frames.
  weak var registry: FlutterTextureRegistry?
  /// The texture identifier associated with the video output.
  var textureIdentifier: Int64 = 0
  /// The display link that drives frameUpdater.
  var displayLink: DisplayLink?
  /// The time interval between screen refresh updates. Display link duration is in an undefined state
  /// until displayLinkFired is called at least once so it should not be used directly.
  var frameDuration: CFTimeInterval = .zero

  init(registry: FlutterTextureRegistry) {
    self.registry = registry
  }

  /// Called when the display link fires.
  func displayLinkFired() {
    frameDuration = displayLink?.duration ?? .zero
    registry?.textureFrameAvailable(textureIdentifier)
  }
}
