// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Testing
@preconcurrency import video_player_avfoundation

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

@MainActor struct VideoPlayerTests {

  let mp4TestURI = "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
  let hlsTestURI = "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
  let mp3AudioTestURI = "https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3"
  let hlsAudioTestURI =
    "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee_audio_only.m3u8"

  @Test func blankVideoBugWithEncryptedVideoStreamAndInvertedAspectRatioBugForSomeVideoStream()
    throws
  {
    // This is to fix 2 bugs: 1. blank video for encrypted video streams on iOS 16
    // (https://github.com/flutter/flutter/issues/111457) and 2. swapped width and height for some
    // video streams (not just iOS 16).  (https://github.com/flutter/flutter/issues/109116). An
    // invisible AVPlayerLayer is used to overwrite the protection of pixel buffers in those streams
    // for issue #1, and restore the correct width and height for issue #2.
    #if os(iOS)
      let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
      let viewController = UIViewController()
      viewController.view = view
      let viewProvider = StubViewProvider(viewController: viewController)
    #else
      let view = NSView(frame: NSRect(x: 0, y: 0, width: 10, height: 10))
      view.wantsLayer = true
      let viewProvider = StubViewProvider(view: view)
    #endif
    let videoPlayerPlugin = createInitializedPlugin(viewProvider: viewProvider)

    var error: FlutterError?
    let identifiers = try #require(
      videoPlayerPlugin.createTexturePlayer(
        with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error))
    #expect(error == nil)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPTextureBasedVideoPlayer

    #expect(player.playerLayer.superlayer == view.layer)
  }

  @Test func playerForPlatformViewDoesNotRegisterTexture() {
    let textureRegistry = TestTextureRegistry()
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let videoPlayerPlugin = createInitializedPlugin(
      displayLinkFactory: stubDisplayLinkFactory,
      textureRegistry: textureRegistry)

    var error: FlutterError?
    videoPlayerPlugin.createPlatformViewPlayer(
      with: FVPCreationOptions.make(withUri: hlsTestURI, httpHeaders: [:]), error: &error)
    #expect(error == nil)

    #expect(!textureRegistry.registeredTexture)
  }

  @Test func seekToWhilePausedStartsDisplayLinkTemporarily() async throws {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
    // the player via the plugin instead of directly to include that logic in the test.
    let videoPlayerPlugin = createInitializedPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory)

    var error: FlutterError?
    let identifiers = try #require(
      videoPlayerPlugin.createTexturePlayer(
        with: FVPCreationOptions.make(withUri: hlsTestURI, httpHeaders: [:]), error: &error))
    #expect(error == nil)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPTextureBasedVideoPlayer

    // Ensure that the video playback is paused before seeking.
    player.pauseWithError(&error)
    #expect(error == nil)

    await asyncSeekTo(player: player, time: 1234)

    // Seeking to a new position should start the display link temporarily.
    #expect(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    stubDisplayLinkFactory.fireDisplayLink?()
    player.copyPixelBuffer()
    // Since a frame was found, and the video is paused, the display link should be paused again.
    #expect(!stubDisplayLinkFactory.displayLink.running)
  }

  @Test func initStartsDisplayLinkTemporarily() {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = createInitializedPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory)

    var error: FlutterError?
    let identifiers = videoPlayerPlugin.createTexturePlayer(
      with: FVPCreationOptions.make(withUri: hlsTestURI, httpHeaders: [:]), error: &error)
    #expect(error == nil)

    // Init should start the display link temporarily.
    #expect(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer
    stubDisplayLinkFactory.fireDisplayLink?()
    player.copyPixelBuffer()
    // Since a frame was found, and the video is paused, the display link should be paused again.
    #expect(!stubDisplayLinkFactory.displayLink.running)
  }

  @Test func seekToWhilePlayingDoesNotStopDisplayLink() async {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = createInitializedPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory)

    var error: FlutterError?
    let identifiers = videoPlayerPlugin.createTexturePlayer(
      with: FVPCreationOptions.make(withUri: hlsTestURI, httpHeaders: [:]), error: &error)
    #expect(error == nil)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer

    // Ensure that the video is playing before seeking.
    player.playWithError(&error)
    #expect(error == nil)

    await asyncSeekTo(player: player, time: 1234)

    #expect(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    stubDisplayLinkFactory.fireDisplayLink?()
    // Since the video was playing, the display link should not be paused after getting a buffer.
    #expect(stubDisplayLinkFactory.displayLink.running)
  }

  @Test func pauseWhileWaitingForFrameDoesNotStopDisplayLink() {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
    // the player via the plugin instead of directly to include that logic in the test.
    let videoPlayerPlugin = createInitializedPlugin(displayLinkFactory: stubDisplayLinkFactory)

    var error: FlutterError?
    let identifiers = videoPlayerPlugin.createTexturePlayer(
      with: FVPCreationOptions.make(withUri: hlsTestURI, httpHeaders: [:]), error: &error)
    #expect(error == nil)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer

    // Run a play/pause cycle to force the pause codepath to run completely.
    player.playWithError(&error)
    #expect(error == nil)
    player.pauseWithError(&error)
    #expect(error == nil)

    // Since a buffer hasn't been available yet, the pause should not have stopped the display link.
    #expect(stubDisplayLinkFactory.displayLink.running)
  }

  @Test func deregistersFromPlayer() throws {
    let videoPlayerPlugin = createInitializedPlugin()

    var error: FlutterError?
    let identifiers = try #require(
      videoPlayerPlugin.createTexturePlayer(
        with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error))
    #expect(error == nil)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPVideoPlayer

    player.disposeWithError(&error)
    #expect(error == nil)
    #expect(videoPlayerPlugin.playersByIdentifier.count == 0)
  }

  @Test func bufferingStateFromPlayer() async throws {
    // TODO(stuartmorgan): Rewrite this test to use stubs, instead of running for 10
    // seconds with a real player and hoping to get buffer status updates.
    let realObjectFactory = FVPDefaultAVFactory()
    let videoPlayerPlugin = createInitializedPlugin(avFactory: realObjectFactory)

    var error: FlutterError?
    let identifiers = try #require(
      videoPlayerPlugin.createTexturePlayer(
        with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error))
    #expect(error == nil)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPVideoPlayer
    let avPlayer = player.player
    avPlayer.play()

    let eventSink: FlutterEventSink = { event in
      guard let event = event as? [String: Any], let eventType = event["event"] as? String else {
        return
      }
      if eventType == "bufferingEnd" {
        #expect(avPlayer.currentItem!.isPlaybackLikelyToKeepUp)
      }
      if eventType == "bufferingStart" {
        #expect(!avPlayer.currentItem!.isPlaybackLikelyToKeepUp)
      }
    }
    (player.eventListener as? FlutterStreamHandler)?.onListen(
      withArguments: nil, eventSink: eventSink)

    // Load for a while to let some buffer events happen.
    try await Task.sleep(nanoseconds: 10 * 1_000_000_000)
  }

  private func durationApproximatelyEquals(_ actual: Int64, _ expected: Int64, tolerance: Int64)
    -> Bool
  {
    return abs(actual - expected) < tolerance
  }

  @Test func videoControls() async throws {
    let eventListener = try await sanityTestURI(mp4TestURI)
    #expect(eventListener.initializationSize.height == 720)
    #expect(eventListener.initializationSize.width == 1280)
    #expect(durationApproximatelyEquals(eventListener.initializationDuration, 4000, tolerance: 200))
  }

  @Test func audioControls() async throws {
    let eventListener = try await sanityTestURI(mp3AudioTestURI)
    #expect(eventListener.initializationSize.height == 0)
    #expect(eventListener.initializationSize.width == 0)
    #expect(durationApproximatelyEquals(eventListener.initializationDuration, 5400, tolerance: 200))
  }

  @Test func hLSControls() async throws {
    let eventListener = try await sanityTestURI(hlsTestURI)
    #expect(eventListener.initializationSize.height == 720)
    #expect(eventListener.initializationSize.width == 1280)
    #expect(durationApproximatelyEquals(eventListener.initializationDuration, 4000, tolerance: 200))
  }

  @Test(.disabled("Flaky"), .bug("https://github.com/flutter/flutter/issues/164381"))
  func audioOnlyHLSControls() async throws {
    let eventListener = try await sanityTestURI(hlsAudioTestURI)
    #expect(eventListener.initializationSize.height == 0)
    #expect(eventListener.initializationSize.width == 0)
    #expect(durationApproximatelyEquals(eventListener.initializationDuration, 4000, tolerance: 200))
  }

  #if os(iOS)
    @Test func transformFixOrientationUp() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform.identity
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == 0)
      #expect(t.ty == 0)
    }

    @Test func transformFixOrientationDown() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == size.width)
      #expect(t.ty == size.height)
    }

    @Test func transformFixOrientationLeft() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == 0)
      #expect(t.ty == size.width)
    }

    @Test func transformFixOrientationRight() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == size.height)
      #expect(t.ty == 0)
    }

    @Test func transformFixOrientationUpMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == size.width)
      #expect(t.ty == 0)
    }

    @Test func transformFixOrientationDownMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == 0)
      #expect(t.ty == size.height)
    }

    @Test func transformFixOrientationLeftMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == size.height)
      #expect(t.ty == size.width)
    }

    @Test func transformFixOrientationRightMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      #expect(t.tx == 0)
      #expect(t.ty == 0)
    }
  #endif

  @Test func seekToleranceWhenNotSeekingToEnd() async {
    let inspectableAVPlayer = InspectableAVPlayer()
    let stubAVFactory = StubFVPAVFactory(player: inspectableAVPlayer)
    let player = FVPVideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    player.eventListener = listener

    await asyncSeekTo(player: player, time: 1234)

    #expect(inspectableAVPlayer.beforeTolerance?.intValue == 0)
    #expect(inspectableAVPlayer.afterTolerance?.intValue == 0)
  }

  @Test func seekToleranceWhenSeekingToEnd() async {
    let inspectableAVPlayer = InspectableAVPlayer()
    let stubAVFactory = StubFVPAVFactory(player: inspectableAVPlayer)
    let player = FVPVideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    player.eventListener = listener

    await asyncSeekTo(player: player, time: 0)

    #expect((inspectableAVPlayer.beforeTolerance?.intValue ?? 0) > 0)
    #expect((inspectableAVPlayer.afterTolerance?.intValue ?? 0) > 0)
  }

  /// Sanity checks a video player playing the given URL with the actual AVPlayer. This is essentially
  /// a mini integration test of the player component.
  ///
  /// Returns the stub event listener to allow tests to inspect the call state.
  func sanityTestURI(_ testURI: String) async throws -> StubEventListener {
    let realObjectFactory = FVPDefaultAVFactory()
    let testURL = try #require(URL(string: testURI))
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    let listener = StubEventListener()
    await withCheckedContinuation { initialized in
      listener.initializationContinuation = initialized
      player.eventListener = listener
    }

    // Starts paused.
    let avPlayer = player.player
    #expect(avPlayer.rate == 0)
    #expect(avPlayer.volume == 1)
    #expect(avPlayer.timeControlStatus == .paused)

    // Change playback speed.
    var error: FlutterError?
    player.setPlaybackSpeed(2, error: &error)
    #expect(error == nil)
    player.playWithError(&error)
    #expect(error == nil)
    #expect(avPlayer.rate == 2)
    #expect(avPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate)

    // Volume
    player.setVolume(0.1, error: &error)
    #expect(error == nil)
    #expect(avPlayer.volume == 0.1)

    return listener
  }

  // Checks whether [AVPlayer rate] KVO observations are correctly detached.
  // - https://github.com/flutter/flutter/issues/124937
  //
  // Failing to de-register results in a crash in [AVPlayer willChangeValueForKey:].
  @Test func doesNotCrashOnRateObservationAfterDisposal() async throws {
    let realObjectFactory = FVPDefaultAVFactory()

    var avPlayer: AVPlayer? = nil
    weak var weakPlayer: FVPVideoPlayer? = nil

    // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
    try autoreleasepool {
      let videoPlayerPlugin = createInitializedPlugin(avFactory: realObjectFactory)

      var error: FlutterError?
      let identifiers = try #require(
        videoPlayerPlugin.createTexturePlayer(
          with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error))
      #expect(error == nil)

      let player = videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPVideoPlayer
      weakPlayer = player
      avPlayer = player.player

      player.disposeWithError(&error)
      #expect(error == nil)
    }

    // Wait for the weak pointer to be invalidated, indicating that the player has been deallocated.
    let checkInterval = 0.1
    let maxTries = Int64(30 / checkInterval)
    for _ in 1...maxTries {
      if weakPlayer == nil {
        break
      }
      try await Task.sleep(nanoseconds: UInt64(checkInterval * 1_000_000_000))
    }

    await MainActor.run {
      avPlayer?.willChangeValue(forKey: "rate")
      avPlayer?.didChangeValue(forKey: "rate")
    }
    // No assertions needed. Lack of crash is a success.
  }

  // During the hot reload:
  //  1. `[FVPVideoPlayer onTextureUnregistered:]` gets called.
  //  2. `[FVPVideoPlayerPlugin initialize:]` gets called.
  //
  // Both of these methods dispatch [FVPVideoPlayer dispose] on the main thread
  // leading to a possible crash when de-registering observers twice.
  @Test func hotReloadDoesNotCrash() async throws {
    weak var weakPlayer: FVPVideoPlayer? = nil

    // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
    try autoreleasepool {
      let videoPlayerPlugin = createInitializedPlugin(avFactory: StubFVPAVFactory())

      var error: FlutterError?
      let identifiers = try #require(
        videoPlayerPlugin.createTexturePlayer(
          with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error))
      #expect(error == nil)

      let player =
        videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPTextureBasedVideoPlayer
      weakPlayer = player

      player.onTextureUnregistered(StubTexture())

      videoPlayerPlugin.initialize(&error)
      #expect(error == nil)
    }

    // Wait for the weak pointer to be invalidated, indicating that the player has been deallocated.
    let checkInterval = 0.1
    let maxTries = Int64(30 / checkInterval)
    for _ in 1...maxTries {
      if weakPlayer == nil {
        break
      }
      try await Task.sleep(nanoseconds: UInt64(checkInterval * 1_000_000_000))
    }
    // No assertions needed. Lack of crash is a success.
  }

  @Test func failedToLoadVideoEventShouldBeAlwaysSent() async {
    // Use real objects to test a real failure flow.
    let realObjectFactory = FVPDefaultAVFactory()
    let videoPlayerPlugin = createInitializedPlugin(avFactory: realObjectFactory)

    var error: FlutterError?
    let identifiers = videoPlayerPlugin.createTexturePlayer(
      with: FVPCreationOptions.make(withUri: "", httpHeaders: [:]), error: &error)
    #expect(error == nil)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPVideoPlayer

    await withCheckedContinuation { continuation in
      // TODO(stuartmorgan): Update this test to instead use a mock listener, and add separate unit
      // tests of FVPEventBridge.
      let eventSink: FlutterEventSink = { event in
        if event is FlutterError {
          continuation.resume()
        }
      }
      (player.eventListener as? FlutterStreamHandler)?.onListen(
        withArguments: nil, eventSink: eventSink)
    }
  }

  @Test func updatePlayingStateShouldNotResetRate() async {
    let realObjectFactory = FVPDefaultAVFactory()
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: URL(string: mp4TestURI)!, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { initialized in
      let listener = StubEventListener(initializationContinuation: initialized)
      player.eventListener = listener
    }

    var error: FlutterError?
    player.setPlaybackSpeed(2, error: &error)
    #expect(error == nil)
    player.playWithError(&error)
    #expect(error == nil)
    #expect(player.player.rate == 2)
  }

  @Test func playerShouldNotDropEverySecondFrame() {
    let textureRegistry = TestTextureRegistry()
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = createInitializedPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory,
      textureRegistry: textureRegistry)

    var error: FlutterError?
    let identifiers = videoPlayerPlugin.createTexturePlayer(
      with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error)
    #expect(error == nil)
    let playerIdentifier = identifiers!.playerId
    let player =
      videoPlayerPlugin.playersByIdentifier[playerIdentifier] as! FVPTextureBasedVideoPlayer

    func addFrame() {
      var bufferRef: CVPixelBuffer?
      CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
      mockVideoOutput.pixelBuffer = bufferRef
    }

    addFrame()
    stubDisplayLinkFactory.fireDisplayLink?()
    player.copyPixelBuffer()
    #expect(textureRegistry.textureFrameAvailableCount == 1)

    addFrame()
    stubDisplayLinkFactory.fireDisplayLink?()
    player.copyPixelBuffer()
    #expect(textureRegistry.textureFrameAvailableCount == 2)
  }

  @Test func videoOutputIsAddedWhenAVPlayerIsInitialized() async throws {
    let realObjectFactory = FVPDefaultAVFactory()
    let videoPlayerPlugin = createInitializedPlugin(avFactory: realObjectFactory)

    var error: FlutterError?
    let identifiers = try #require(
      videoPlayerPlugin.createTexturePlayer(
        with: FVPCreationOptions.make(withUri: mp4TestURI, httpHeaders: [:]), error: &error))
    #expect(error == nil)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! FVPVideoPlayer

    let listener = StubEventListener()
    await withCheckedContinuation { initialized in
      listener.initializationContinuation = initialized
      player.eventListener = listener
    }

    let item = player.player.currentItem!
    // Video output is added as soon as the status becomes ready to play.
    #expect(item.outputs.count == 1)
  }

  #if os(iOS)
    @Test func videoPlayerShouldNotOverwritePlayAndRecordNorDefaultToSpeaker() {
      let stubFactory = StubFVPAVFactory()
      let audioSession = TestAudioSession()
      stubFactory.audioSession = audioSession
      audioSession.category = .playAndRecord
      audioSession.categoryOptions = .defaultToSpeaker
      let videoPlayerPlugin = createInitializedPlugin(avFactory: stubFactory)

      var error: FlutterError?
      videoPlayerPlugin.setMixWithOthers(true, error: &error)
      #expect(error == nil)
      #expect(audioSession.category == .playAndRecord)
      #expect(audioSession.categoryOptions.contains(.defaultToSpeaker))
      #expect(audioSession.categoryOptions.contains(.mixWithOthers))
    }

    @Test func setMixWithOthersShouldNoOpWhenNoChangesAreRequired() {
      let stubFactory = StubFVPAVFactory()
      let audioSession = TestAudioSession()
      stubFactory.audioSession = audioSession
      audioSession.category = .playAndRecord
      audioSession.categoryOptions = [.mixWithOthers, .defaultToSpeaker]
      let videoPlayerPlugin = createInitializedPlugin(avFactory: stubFactory)

      var error: FlutterError?
      videoPlayerPlugin.setMixWithOthers(true, error: &error)
      #expect(error == nil)
      #expect(!audioSession.setCategoryCalled)
    }
  #endif

  // MARK: - Audio Track Tests

  // Tests getAudioTracks with a regular MP4 video file using real AVFoundation.
  // Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
  @Test func getAudioTracksWithRealMP4Video() async throws {
    let realObjectFactory = FVPDefaultAVFactory()
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: URL(string: mp4TestURI)!, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { initialized in
      let listener = StubEventListener(initializationContinuation: initialized)
      player.eventListener = listener
    }

    // Now test getAudioTracks
    var error: FlutterError?
    let result = try #require(player.getAudioTracks(&error))
    #expect(error == nil)

    // Regular MP4 files do not have media selection groups for audio.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    #expect(result.count == 0)

    player.disposeWithError(&error)
  }

  // Tests getAudioTracks with an HLS stream using real AVFoundation.
  // HLS streams use media selection groups for audio track selection.
  @Test func getAudioTracksWithRealHLSStream() async throws {
    let realObjectFactory = FVPDefaultAVFactory()
    let hlsURL = URL(string: hlsTestURI)!

    let player = FVPVideoPlayer(
      playerItem: playerItem(with: hlsURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { initialized in
      let listener = StubEventListener(initializationContinuation: initialized)
      player.eventListener = listener
    }

    // Now test getAudioTracks
    var error: FlutterError?
    let result = try #require(player.getAudioTracks(&error))
    #expect(error == nil)

    // For HLS streams with multiple audio options, we get media selection tracks.
    // The bee.m3u8 stream may or may not have multiple audio tracks.
    // We verify the method returns valid data without crashing.
    for track in result {
      #expect(track.displayName != nil)
      #expect(track.index >= 0)
    }

    player.disposeWithError(&error)
  }

  // Tests that getAudioTracks returns valid data for audio-only files.
  // Regular audio files do not have media selection groups, so getAudioTracks returns an empty array.
  @Test func getAudioTracksWithRealAudioFile() async throws {
    // TODO(stuartmorgan): Add more use of protocols in FVPVideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = FVPDefaultAVFactory()
    let audioURL = URL(string: mp3AudioTestURI)!

    let player = FVPVideoPlayer(
      playerItem: playerItem(with: audioURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { initialized in
      let listener = StubEventListener(initializationContinuation: initialized)
      player.eventListener = listener
    }

    // Now test getAudioTracks
    var error: FlutterError?
    let result = try #require(player.getAudioTracks(&error))
    #expect(error == nil)

    // Regular audio files do not have media selection groups.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    #expect(result.count == 0)

    player.disposeWithError(&error)
  }

  // Tests that getAudioTracks works correctly through the plugin API with a real video.
  // Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
  @Test func getAudioTracksViaPluginWithRealVideo() async throws {
    // TODO(stuartmorgan): Add more use of protocols in FVPVideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = FVPDefaultAVFactory()
    let testURL = URL(string: mp4TestURI)!
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    // Wait for player to become ready
    let listener = StubEventListener()
    await withCheckedContinuation { initialized in
      listener.initializationContinuation = initialized
      player.eventListener = listener
    }

    // Now test getAudioTracks
    var error: FlutterError?
    let result = try #require(player.getAudioTracks(&error))
    #expect(error == nil)

    // Regular MP4 files do not have media selection groups.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    #expect(result.count == 0)

    player.disposeWithError(&error)
  }

  @Test func loadTracksWithMediaTypeIsCalledOnNewerOS() {
    if #available(iOS 15.0, macOS 12.0, *) {
      let mockAsset = TestAsset(duration: CMTimeMake(value: 1, timescale: 1), tracks: [])
      let item = StubPlayerItem(asset: mockAsset)

      let stubAVFactory = StubFVPAVFactory(player: nil, playerItem: item, pixelBufferSource: nil)
      let stubViewProvider = StubViewProvider()
      let _ = FVPVideoPlayer(
        playerItem: item, avFactory: stubAVFactory, viewProvider: stubViewProvider)
      #expect(mockAsset.loadedTracksAsynchronously)
    }
  }

  // MARK: - Helper Methods

  /// Creates a plugin with the given dependencies, and default stubs for any that aren't provided,
  /// then initializes it.
  private func createInitializedPlugin(
    avFactory: FVPAVFactory = StubFVPAVFactory(),
    displayLinkFactory: FVPDisplayLinkFactory = StubFVPDisplayLinkFactory(),
    binaryMessenger: FlutterBinaryMessenger = StubBinaryMessenger(),
    textureRegistry: FlutterTextureRegistry = TestTextureRegistry(),
    viewProvider: FVPViewProvider = StubViewProvider(),
    assetProvider: FVPAssetProvider = StubAssetProvider()
  ) -> FVPVideoPlayerPlugin {
    let plugin = FVPVideoPlayerPlugin(
      avFactory: avFactory,
      displayLinkFactory: displayLinkFactory,
      binaryMessenger: binaryMessenger,
      textureRegistry: textureRegistry,
      viewProvider: viewProvider,
      assetProvider: assetProvider)
    var error: FlutterError?
    plugin.initialize(&error)
    #expect(error == nil)
    return plugin
  }

  private func playerItem(with url: URL, factory: FVPAVFactory) -> FVPAVPlayerItem {
    let asset = factory.urlAsset(with: url, options: nil)
    return factory.playerItem(with: asset)
  }

  private func waitForPlayerItemStatus(_ item: AVPlayerItem, state: AVPlayerItem.Status) async {
    await withCheckedContinuation { continuation in
      // Check whether it already has the desired status.
      if item.status == state {
        continuation.resume()
        return
      }
      // If not, wait for that status.
      var observation: NSKeyValueObservation?
      observation = item.observe(\.status, options: [.initial, .new]) {
        [observation = observation] _, change in
        if change.newValue == state {
          observation?.invalidate()
          continuation.resume()
        }
      }
    }
  }

  // Temporary test adapter until the player implementation is converted to use async.
  private func asyncSeekTo(player: FVPVideoPlayer, time: Int) async {
    await withCheckedContinuation { continuation in
      player.seek(to: time) { error in
        #expect(error == nil)
        continuation.resume()
      }
    }
  }
}
