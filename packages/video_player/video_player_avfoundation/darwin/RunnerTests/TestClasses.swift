// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Testing
import video_player_avfoundation_objc

@testable import video_player_avfoundation

#if os(iOS)
  import Flutter
  import UIKit
#else
  import FlutterMacOS
#endif

/// An AVPlayer subclass that records method call parameters for inspection.
// TODO(stuartmorgan): Replace with a protocol like the other classes.
@MainActor final class InspectableAVPlayer: AVPlayer {
  private(set) nonisolated(unsafe) var beforeTolerance: NSNumber?
  private(set) nonisolated(unsafe) var afterTolerance: NSNumber?
  private(set) nonisolated(unsafe) var lastSeekTime: CMTime = .invalid

  override func seek(
    to time: CMTime,
    toleranceBefore: CMTime,
    toleranceAfter: CMTime,
    completionHandler: @escaping @Sendable (Bool) -> Void
  ) {
    beforeTolerance = NSNumber(value: toleranceBefore.value)
    afterTolerance = NSNumber(value: toleranceAfter.value)
    lastSeekTime = time
    super.seek(
      to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter,
      completionHandler: completionHandler)
  }
}

final class TestAsset: WrappedAVAsset {
  private let duration: CMTime
  private let tracks: [AVAssetTrack]
  var continuation: CheckedContinuation<Void, Never>?

  var loadedValue = false

  init(
    duration: CMTime = CMTime.zero,
    tracks: [AVAssetTrack] = [],
    continuation: CheckedContinuation<Void, Never>? = nil
  ) {
    self.duration = duration
    self.tracks = tracks
    self.continuation = continuation
  }

  func load<T>(_ property: AVAsyncProperty<AVAsset, T>, isolation: isolated (any Actor)?)
    async throws -> T
  {
    loadedValue = true
    continuation?.resume()
    continuation = nil
    if let tracks = tracks as? T {
      return tracks
    }
    if let duration = duration as? T {
      return duration
    }
    fatalError("Unimplemented property in stub")
  }
}

final class StubPlayerItem: WrappedAVPlayerItem {
  let asset: WrappedAVAsset
  var videoComposition: AVVideoComposition?

  init(asset: WrappedAVAsset = TestAsset()) {
    self.asset = asset
  }
}

final class StubBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(
    onChannel channel: String,
    message: Data?,
    binaryReply callback: FlutterBinaryReply? = nil
  ) {}
  func setMessageHandlerOnChannel(
    _ channel: String,
    binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    return 0
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

final class TestTextureRegistry: NSObject, FlutterTextureRegistry {
  private(set) var registeredTexture = false
  private(set) var unregisteredTexture = false
  private(set) var textureFrameAvailableCount = 0

  func register(_ texture: FlutterTexture) -> Int64 {
    registeredTexture = true
    return 1
  }

  func unregisterTexture(_ textureId: Int64) {
    if textureId != 1 {
      Issue.record("Unregistering texture with wrong ID")
    }
    unregisteredTexture = true
  }

  func textureFrameAvailable(_ textureId: Int64) {
    if textureId != 1 {
      Issue.record("Texture frame available with wrong ID")
    }
    textureFrameAvailableCount += 1
  }
}

final class StubViewProvider: NSObject, FVPViewProvider {
  #if os(iOS)
    var viewController: UIViewController?
    init(viewController: UIViewController? = nil) {
      self.viewController = viewController
      super.init()
    }
  #else
    var view: NSView?
    init(view: NSView? = nil) {
      self.view = view
      super.init()
    }
  #endif
}

final class StubAssetProvider: NSObject, FVPAssetProvider {
  func lookupKey(forAsset asset: String) -> String? {
    return asset
  }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String? {
    return asset
  }
}

final class TestPixelBufferSource: PixelBufferSource {
  var pixelBuffer: CVPixelBuffer?
  let videoOutput: AVPlayerItemVideoOutput

  init() {
    videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      kCVPixelBufferIOSurfacePropertiesKey as String: [:] as [String: String],
    ])
  }

  func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime {
    return CMTimeMakeWithSeconds(hostTimeInSeconds, preferredTimescale: 1000)
  }

  func hasNewPixelBuffer(forItemTime itemTime: CMTime) -> Bool {
    return pixelBuffer != nil
  }

  func copyPixelBuffer(
    forItemTime itemTime: CMTime,
    itemTimeForDisplay: UnsafeMutablePointer<CMTime>?
  ) -> CVPixelBuffer? {
    let buffer = pixelBuffer
    // Ownership is transferred to the caller.
    pixelBuffer = nil
    return buffer
  }
}

#if os(iOS)
  final class TestAudioSession: WrappedAVAudioSession {
    var category: AVAudioSession.Category = .ambient
    var categoryOptions: AVAudioSession.CategoryOptions = []
    private(set) var setCategoryCalled = false

    func setCategory(
      _ category: AVAudioSession.Category,
      options: AVAudioSession.CategoryOptions
    ) throws {
      setCategoryCalled = true
      self.category = category
      self.categoryOptions = options
    }
  }
#endif

final class StubAVFactory: NSObject, WrappedAVObjectFactory {
  let player: AVPlayer
  let playerItem: WrappedAVPlayerItem
  let pixelBufferSource: PixelBufferSource?
  private(set) var lastOutputSettings: [String: Any]?
  #if os(iOS)
    var audioSession: WrappedAVAudioSession
  #endif

  init(
    player: AVPlayer? = nil,
    playerItem: WrappedAVPlayerItem? = nil,
    pixelBufferSource: PixelBufferSource? = nil,
    assetURL: String? = nil,
  ) {
    let url = URL(string: assetURL ?? "https://flutter.dev")!
    self.player =
      player
      ?? AVPlayer(playerItem: AVPlayerItem(url: url))
    self.playerItem = playerItem ?? StubPlayerItem()
    self.pixelBufferSource = pixelBufferSource
    #if os(iOS)
      self.audioSession = TestAudioSession()
    #endif
    super.init()
  }

  func urlAsset(with url: URL, options: [String: Any]?) -> WrappedAVAsset {
    return playerItem.asset
  }

  func playerItem(with asset: WrappedAVAsset) -> WrappedAVPlayerItem {
    return playerItem
  }

  func player(with playerItem: WrappedAVPlayerItem) -> AVPlayer {
    return self.player
  }

  func videoOutput(outputSettings: [String: Any]) -> PixelBufferSource {
    lastOutputSettings = outputSettings
    return pixelBufferSource ?? TestPixelBufferSource()
  }

  #if os(iOS)
    func sharedAudioSession() -> WrappedAVAudioSession {
      return audioSession
    }
  #endif
}

final class StubFVPDisplayLink: NSObject, FVPDisplayLink {
  var running: Bool = false
  var duration: CFTimeInterval {
    return 1.0 / 60.0
  }
}

final class StubFVPDisplayLinkFactory: DisplayLinkFactory {
  let displayLink = StubFVPDisplayLink()
  var fireDisplayLink: (() -> Void)?

  func displayLink(
    with viewProvider: FVPViewProvider,
    callback: @escaping () -> Void
  ) -> FVPDisplayLink {
    fireDisplayLink = callback
    return displayLink
  }
}

final class StubEventListener: NSObject, FVPVideoEventListener {
  var onInitialized: (() -> Void)?
  private(set) var initializationDuration: Int64 = 0
  private(set) var initializationSize: CGSize = .zero

  init(onInitialized: (() -> Void)? = nil) {
    self.onInitialized = onInitialized
    super.init()
  }

  func videoPlayerDidComplete() {}
  func videoPlayerDidEndBuffering() {}
  func videoPlayerDidError(withMessage errorMessage: String) {}
  func videoPlayerDidInitialize(withDuration duration: Int64, size: CGSize) {
    onInitialized?()
    initializationDuration = duration
    initializationSize = size
  }
  func videoPlayerDidSetPlaying(_ playing: Bool) {}
  func videoPlayerDidStartBuffering() {}
  func videoPlayerDidUpdateBufferRegions(_ regions: [[NSNumber]]) {}
  func videoPlayerWasDisposed() {}
}

final class StubTexture: NSObject, FlutterTexture {
  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return nil
  }
}
