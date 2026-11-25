// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

#if os(iOS)

  private class PlayerView: UIView {
    override class var layerClass: AnyClass {
      return AVPlayerLayer.self
    }

    var player: AVPlayer? {
      get {
        (layer as? AVPlayerLayer)?.player
      }
      set {
        (layer as? AVPlayerLayer)?.player = newValue
      }
    }

  }

  /// A class used to create a native video view that can be embedded in a Flutter app.
  /// This class wraps an AVPlayer instance and displays its video content.
  class NativeVideoView: NSObject, FlutterPlatformView {
    private let playerView: PlayerView

    /// Initializes a new instance of a native view.
    /// It creates a video view instance and sets the provided AVPlayer instance to it.
    init(player: AVPlayer?) {
      playerView = PlayerView()
      playerView.player = player
    }

    func view() -> UIView {
      return playerView
    }
  }

#else

  /// A class used to create a native video view that can be embedded in a Flutter app.
  /// This class wraps an AVPlayer instance and displays its video content.
  class NativeVideoView: NSView {
    /// Initializes a new instance of a native view.
    /// It creates a video view instance and sets the provided AVPlayer instance to it.
    init(player: AVPlayer?) {
      super.init(frame: .zero)
      self.wantsLayer = true
      (layer as? AVPlayerLayer)?.player = player
    }

    // This will never be used, but is required for NSView subclasses.
    required init?(coder: NSCoder) {
      super.init(coder: coder)
    }

    override func makeBackingLayer() -> CALayer {
      return AVPlayerLayer()
    }
  }

#endif
