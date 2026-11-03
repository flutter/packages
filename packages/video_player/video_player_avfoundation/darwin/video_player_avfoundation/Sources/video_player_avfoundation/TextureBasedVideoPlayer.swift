// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

#if canImport(video_player_avfoundation_objc)
  import video_player_avfoundation_objc
#endif

/// A subclass of VideoPlayer that adds functionality related to texture-based view as a way of
/// displaying the video in the app. It manages the CALayer associated with the Flutter view,
/// updates frames, and handles display link callbacks.
/// If you need to display a video using platform view, use VideoPlayer instead.
class TextureBasedVideoPlayer: VideoPlayer, FlutterTexture {

  // The updater that drives callbacks to the engine to indicate that a new frame is ready.
  private let frameUpdater: FVPFrameUpdater
  // The display link that drives frameUpdater.
  private var displayLink: FVPDisplayLink?
  // The latest buffer obtained from video output. This is stored so that it can be returned from
  // copyPixelBuffer again if nothing new is available, since the engine has undefined behavior when
  // returning NULL.
  private var latestPixelBuffer: CVPixelBuffer?
  // The time that represents when the next frame displays.
  private var targetTime: CFTimeInterval = 0
  // Whether to enqueue textureFrameAvailable from copyPixelBuffer.
  private var selfRefresh = true
  // The time that represents the start of average frame duration measurement.
  private var startTime: CFTimeInterval = 0
  // The number of frames since the start of average frame duration measurement.
  private var framesCount: Int = 0
  // The latest frame duration since there was significant change.
  private var latestDuration: CFTimeInterval = 0
  // Whether a new frame needs to be provided to the engine regardless of the current play/pause state
  // (e.g., after a seek while paused). If true, the display link should continue to run until the next
  // frame is successfully provided.
  private var waitingForFrame = false

  /// The AVPlayerLayer used to display the video content.
  /// This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
  /// (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
  /// video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
  /// invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
  /// for issue #1, and restore the correct width and height for issue #2.
  private(set) var playerLayer: AVPlayerLayer?

  /// Initializes a new instance of TextureBasedVideoPlayer with the given player item,
  /// frame updater, display link, AV factory, and view provider.
  init(
    playerItem: WrappedAVPlayerItem,
    frameUpdater: FVPFrameUpdater,
    displayLink: FVPDisplayLink,
    avFactory: WrappedAVObjectFactory,
    viewProvider: FVPViewProvider
  ) {
    self.frameUpdater = frameUpdater
    self.displayLink = displayLink
    self.frameUpdater.displayLink = displayLink
    super.init(playerItem: playerItem, avFactory: avFactory, viewProvider: viewProvider)

    // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
    // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
    // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
    // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
    // for issue #1, and restore the correct width and height for issue #2.
    let layer = AVPlayerLayer(player: player)
    #if os(iOS)
      let flutterLayer = viewProvider.viewController?.view.layer
    #else
      let flutterLayer = viewProvider.view?.layer
    #endif
    playerLayer = layer
    flutterLayer?.addSublayer(layer)
  }

  /// Sets the texture Identifier for the frame updater. This method should be called once the texture
  /// identifier is obtained from the texture registry.
  func setTextureIdentifier(_ textureIdentifier: Int64) {
    frameUpdater.textureIdentifier = textureIdentifier

    // Ensure that the first frame is drawn once available, even if the video isn't played, since
    // the engine is now expecting the texture to be populated.
    expectFrame()
  }

  /// Ensures that the frame updater runs until a frame is rendered, regardless of play/pause state.
  private func expectFrame() {
    waitingForFrame = true
    displayLink?.running = true
  }

  // MARK: Overrides

  @MainActor override func updatePlayingState() {
    super.updatePlayingState()
    // If the texture is still waiting for an expected frame, the display link needs to keep
    // running until it arrives regardless of the play/pause state.
    displayLink?.running = isPlaying || waitingForFrame
  }

  @MainActor override func seek(to position: Int64) async throws {
    let previousCMTime = player.currentTime()
    try await super.seek(to: position)
    if self.player.currentTime() != previousCMTime {
      // Ensure that a frame is drawn once available, even if currently paused. In theory a
      // race is possible here where the new frame has already drawn by the time this code
      // runs, and the display link stays on indefinitely, but that should be relatively
      // harmless. This must use the display link rather than just informing the engine that a
      // new frame is available because the seek completing doesn't guarantee that the pixel
      // buffer is already available.
      self.expectFrame()
    }
  }

  @MainActor override func dispose() {
    super.dispose()

    playerLayer?.removeFromSuperlayer()

    displayLink?.running = false
    displayLink = nil
  }

  // MARK: FlutterTexture

  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    // If the difference between target time and current time is longer than this fraction of frame
    // duration then reset target time.
    let resetThreshold = 0.5

    // Ensure video sampling at regular intervals. This function is not called at exact time intervals
    // so CACurrentMediaTime returns irregular timestamps which causes missed video frames. The range
    // outside of which targetTime is reset should be narrow enough to make possible lag as small as
    // possible and at the same time wide enough to avoid too frequent resets which would lead to
    // irregular sampling.
    // TODO: Ideally there would be a targetTimestamp of display link used by the flutter engine.
    // https://github.com/flutter/flutter/issues/159087
    let currentTime = CACurrentMediaTime()
    let duration = frameUpdater.frameDuration
    if abs(targetTime - currentTime) > duration * resetThreshold {
      targetTime = currentTime
    }
    targetTime += duration

    var buffer: CVPixelBuffer?
    let outputItemTime = pixelBufferSource.itemTime(forHostTime: targetTime)
    if pixelBufferSource.hasNewPixelBuffer(forItemTime: outputItemTime) {
      buffer = pixelBufferSource.copyPixelBuffer(
        forItemTime: outputItemTime,
        itemTimeForDisplay: nil)
      if let buffer = buffer {
        latestPixelBuffer = buffer
      }
    }

    if waitingForFrame && buffer != nil {
      waitingForFrame = false
      // If the display link was only running temporarily to pick up a new frame while the video was
      // paused, stop it again.
      if !isPlaying {
        displayLink?.running = false
      }
    }

    // Calling textureFrameAvailable only from within displayLinkFired would require a non-trivial
    // solution to minimize missed video frames due to race between displayLinkFired, copyPixelBuffer
    // and place where is _textureFrameAvailable reset to false in the flutter engine.
    // TODO: Ideally FlutterTexture would support mode of operation where the copyPixelBuffer is
    // called always or some other alternative, instead of on demand by calling textureFrameAvailable.
    // https://github.com/flutter/flutter/issues/159162
    if displayLink?.running ?? false && selfRefresh {
      // The number of frames over which to measure average frame duration.
      let windowSize = 10
      // If measured average frame duration is shorter than this fraction of frame duration obtained
      // from display link then rely solely on refreshes from display link.
      let durationThreshold = 0.5
      // If duration changes by this fraction or more then reset average frame duration measurement.
      let resetFraction = 0.01

      if abs(duration - latestDuration) >= latestDuration * resetFraction {
        startTime = currentTime
        framesCount = 0
        latestDuration = duration
      }
      if framesCount == windowSize {
        let averageDuration = (currentTime - startTime) / Double(windowSize)
        if averageDuration < duration * durationThreshold {
          NSLog(
            "Warning: measured average duration between frames is unexpectedly short (%f/%f), "
              + "please report this to https://github.com/flutter/flutter/issues.",
            averageDuration, duration)
          selfRefresh = false
        }
        startTime = currentTime
        framesCount = 0
      }
      framesCount += 1

      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        frameUpdater.registry?.textureFrameAvailable(
          frameUpdater.textureIdentifier)
      }
    }

    if let buffer = latestPixelBuffer {
      // Add a retain for the engine, since the engine expects an owning reference.
      return Unmanaged.passRetained(buffer)
    }
    return nil
  }

  /// Called when the texture is unregistered.
  /// This method is used to clean up resources associated with the texture.
  func onTextureUnregistered(_ texture: any FlutterTexture) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      if !disposed {
        dispose()
      }
    }
  }

}
