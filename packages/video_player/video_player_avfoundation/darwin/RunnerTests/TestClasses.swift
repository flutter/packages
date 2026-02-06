// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest
import video_player_avfoundation

#if os(iOS)
  import Flutter
  import UIKit
#else
  import FlutterMacOS
#endif

/// An AVPlayer subclass that records method call parameters for inspection.
// TODO(stuartmorgan): Replace with a protocol like the other classes.
@MainActor class InspectableAVPlayer: AVPlayer {
  private(set) nonisolated(unsafe) var beforeTolerance: NSNumber?
  private(set) nonisolated(unsafe) var afterTolerance: NSNumber?
  private(set) nonisolated(unsafe) var lastSeekTime: CMTime = .invalid

  override func seek(
    to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime,
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

class TestAsset: NSObject, FVPAVAsset {
  let duration: CMTime
  let tracks: [AVAssetTrack]?

  var loadedTracksAsynchronously = false

  init(duration: CMTime = CMTime.zero, tracks: [AVAssetTrack]? = nil) {
    self.duration = duration
    self.tracks = tracks
    super.init()
  }

  func statusOfValue(forKey key: String, error outError: NSErrorPointer) -> AVKeyValueStatus {
    return tracks == nil ? .loading : .loaded
  }

  func loadValuesAsynchronously(forKeys keys: [String], completionHandler handler: (() -> Void)?) {
    handler?()
  }

  @available(macOS 12.0, iOS 15.0, *)
  func loadTracks(
    withMediaType mediaType: AVMediaType,
    completionHandler: @escaping ([AVAssetTrack]?, Error?) -> Void
  ) {
    loadedTracksAsynchronously = true
    completionHandler(tracks, nil)
  }

  func tracks(withMediaType mediaType: AVMediaType) -> [AVAssetTrack] {
    return tracks ?? []
  }
}

class StubPlayerItem: NSObject, FVPAVPlayerItem {
  let asset: FVPAVAsset
  var videoComposition: AVVideoComposition?

  init(asset: FVPAVAsset = TestAsset()) {
    self.asset = asset
    super.init()
  }
}

class StubBinaryMessenger: NSObject, FlutterBinaryMessenger {
  func send(onChannel channel: String, message: Data?) {}
  func send(
    onChannel channel: String, message: Data?, binaryReply callback: FlutterBinaryReply? = nil
  ) {}
  func setMessageHandlerOnChannel(
    _ channel: String, binaryMessageHandler handler: FlutterBinaryMessageHandler? = nil
  ) -> FlutterBinaryMessengerConnection {
    return 0
  }
  func cleanUpConnection(_ connection: FlutterBinaryMessengerConnection) {}
}

class TestTextureRegistry: NSObject, FlutterTextureRegistry {
  private(set) var registeredTexture = false
  private(set) var unregisteredTexture = false
  private(set) var textureFrameAvailableCount = 0

  func register(_ texture: FlutterTexture) -> Int64 {
    registeredTexture = true
    return 1
  }

  func unregisterTexture(_ textureId: Int64) {
    if textureId != 1 {
      XCTFail("Unregistering texture with wrong ID")
    }
    unregisteredTexture = true
  }

  func textureFrameAvailable(_ textureId: Int64) {
    if textureId != 1 {
      XCTFail("Texture frame available with wrong ID")
    }
    textureFrameAvailableCount += 1
  }
}

class StubViewProvider: NSObject, FVPViewProvider {
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

class StubAssetProvider: NSObject, FVPAssetProvider {
  func lookupKey(forAsset asset: String) -> String? {
    return asset
  }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String? {
    return asset
  }
}

class TestPixelBufferSource: NSObject, FVPPixelBufferSource {
  var pixelBuffer: CVPixelBuffer?
  let videoOutput: AVPlayerItemVideoOutput

  override init() {
    videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [
      kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
      kCVPixelBufferIOSurfacePropertiesKey as String: [:] as [String: String],
    ])
    super.init()
  }

  func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime {
    return CMTimeMakeWithSeconds(hostTimeInSeconds, preferredTimescale: 1000)
  }

  func hasNewPixelBuffer(forItemTime itemTime: CMTime) -> Bool {
    return pixelBuffer != nil
  }

  func copyPixelBuffer(
    forItemTime itemTime: CMTime, itemTimeForDisplay: UnsafeMutablePointer<CMTime>?
  ) -> CVPixelBuffer? {
    let buffer = pixelBuffer
    // Ownership is transferred to the caller.
    pixelBuffer = nil
    return buffer
  }
}

#if os(iOS)
  class TestAudioSession: NSObject, FVPAVAudioSession {
    var category: AVAudioSession.Category = .ambient
    var categoryOptions: AVAudioSession.CategoryOptions = []
    private(set) var setCategoryCalled = false

    func setCategory(
      _ category: AVAudioSession.Category,
      with options: AVAudioSession.CategoryOptions
    ) throws {
      setCategoryCalled = true
      self.category = category
      self.categoryOptions = options
    }
  }
#endif

class StubFVPAVFactory: NSObject, FVPAVFactory {
  let player: AVPlayer
  let playerItem: FVPAVPlayerItem
  let pixelBufferSource: FVPPixelBufferSource?
  #if os(iOS)
    var audioSession: FVPAVAudioSession
  #endif

  init(
    player: AVPlayer? = nil,
    playerItem: FVPAVPlayerItem? = nil,
    pixelBufferSource: FVPPixelBufferSource? = nil
  ) {
    let dummyURL = URL(string: "https://flutter.dev")!
    self.player =
      player
      ?? AVPlayer(playerItem: AVPlayerItem(url: dummyURL))
    self.playerItem = playerItem ?? StubPlayerItem()
    self.pixelBufferSource = pixelBufferSource
    #if os(iOS)
      self.audioSession = TestAudioSession()
    #endif
    super.init()
  }

  func urlAsset(with url: URL, options: [String: Any]?) -> FVPAVAsset {
    return playerItem.asset
  }

  func playerItem(with asset: FVPAVAsset) -> FVPAVPlayerItem {
    return playerItem
  }

  func player(with playerItem: FVPAVPlayerItem) -> AVPlayer {
    return self.player
  }

  func videoOutput(pixelBufferAttributes attributes: [String: Any]) -> FVPPixelBufferSource {
    return pixelBufferSource ?? TestPixelBufferSource()
  }

  #if os(iOS)
    func sharedAudioSession() -> FVPAVAudioSession {
      return audioSession
    }
  #endif
}

class StubFVPDisplayLink: NSObject, FVPDisplayLink {
  var running: Bool = false
  var duration: CFTimeInterval {
    return 1.0 / 60.0
  }
}

class StubFVPDisplayLinkFactory: NSObject, FVPDisplayLinkFactory {
  let displayLink = StubFVPDisplayLink()
  var fireDisplayLink: (() -> Void)?

  func displayLink(with viewProvider: FVPViewProvider, callback: @escaping () -> Void)
    -> FVPDisplayLink
  {
    fireDisplayLink = callback
    return displayLink
  }
}

class StubEventListener: NSObject, FVPVideoEventListener {
  var initializationExpectation: XCTestExpectation?
  private(set) var initializationDuration: Int64 = 0
  private(set) var initializationSize: CGSize = .zero

  init(initializationExpectation: XCTestExpectation? = nil) {
    self.initializationExpectation = initializationExpectation
    super.init()
  }

  func videoPlayerDidComplete() {}
  func videoPlayerDidEndBuffering() {}
  func videoPlayerDidError(withMessage errorMessage: String) {}
  func videoPlayerDidInitialize(withDuration duration: Int64, size: CGSize) {
    initializationExpectation?.fulfill()
    initializationDuration = duration
    initializationSize = size
  }
  func videoPlayerDidSetPlaying(_ playing: Bool) {}
  func videoPlayerDidStartBuffering() {}
  func videoPlayerDidUpdateBufferRegions(_ regions: [[NSNumber]]!) {}
  func videoPlayerWasDisposed() {}
}

class StubTexture: NSObject, FlutterTexture {
  func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    return nil
  }
}
