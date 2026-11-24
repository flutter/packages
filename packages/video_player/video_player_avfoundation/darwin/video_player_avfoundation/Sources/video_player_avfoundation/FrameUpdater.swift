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
  private(set) weak var registry: FlutterTextureRegistry?
  /// The texture identifier associated with the video output.
  var textureIdentifier: Int64 = 0
  /// The display link that drives frameUpdater.
  weak var displayLink: DisplayLink?
  /// The time interval between screen refresh updates.
  private var frameDurationInternal: CFTimeInterval = .zero
  /// Controls access to frameDurationInternal
  private let frameDurationLock = NSLock()

  init(registry: FlutterTextureRegistry) {
    self.registry = registry
  }

  /// The time interval between screen refresh updates.
  ///
  /// This is intended to be written from the main thread, and accessed from the
  /// engine's raster thread, so it is internally locked.
  private(set) var frameDuration: CFTimeInterval {
    get {
      return frameDurationLock.withLock { frameDurationInternal }
    }
    set {
      frameDurationLock.withLock { frameDurationInternal = newValue }
    }
  }

  /// Called when the display link fires.
  func displayLinkFired() {
    let duration = displayLink?.duration ?? .zero
    // Only set the duration if it has changed, to minimize lock contention.
    // It is safe to read the internal value without a lock here since this is
    // the only place where it is changed.
    if duration != frameDurationInternal {
      frameDuration = duration
    }
    registry?.textureFrameAvailable(textureIdentifier)
  }
}
