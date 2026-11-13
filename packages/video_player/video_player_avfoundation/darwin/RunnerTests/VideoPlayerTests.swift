// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Testing
@preconcurrency @testable import video_player_avfoundation
import video_player_avfoundation_objc

#if os(iOS)
  import Flutter
#else
  import FlutterMacOS
#endif

private let mp4TestURI =
  "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
private let hlsTestURI =
  "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"
private let mp3AudioTestURI =
  "https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3"
private let hlsAudioTestURI =
  "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee_audio_only.m3u8"

@MainActor struct VideoPlayerTests {

  @Test func blankVideoBugWithEncryptedVideoStreamAndInvertedAspectRatioBugForSomeVideoStream()
    async
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
    let videoPlayerPlugin = try createInitializedPlugin(viewProvider: viewProvider)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer

    #expect(player.playerLayer?.superlayer == view.layer)
  }

  @Test func playerForPlatformViewDoesNotRegisterTexture() async throws {
    let textureRegistry = TestTextureRegistry()
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let videoPlayerPlugin = try createInitializedPlugin(
      displayLinkFactory: stubDisplayLinkFactory,
      textureRegistry: textureRegistry)

    _ = try await videoPlayerPlugin.createPlatformViewPlayer(
      options: CreationOptions(uri: hlsTestURI, httpHeaders: [:]))

    #expect(!textureRegistry.registeredTexture)
  }

  @Test func seekToWhilePausedStartsDisplayLinkTemporarily() async throws {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let url = hlsTestURI
    // Display link and frame updater wire-up is currently done in VideoPlayerPlugin, so create
    // the player via the plugin instead of directly to include that logic in the test.
    let videoPlayerPlugin = try createInitializedPlugin(
      avFactory: StubAVFactory(pixelBufferSource: mockVideoOutput, assetURL: url),
      displayLinkFactory: stubDisplayLinkFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: url, httpHeaders: [:]))
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer

    // Ensure that the video playback is paused before seeking.
    player.pause()

    try await player.seek(to: 1234)

    // Seeking to a new position should start the display link temporarily.
    #expect(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    stubDisplayLinkFactory.fireDisplayLink?()
    _ = player.copyPixelBuffer()
    // Since a frame was found, and the video is paused, the display link should be paused again.
    #expect(!stubDisplayLinkFactory.displayLink.running)
  }

  @Test func initStartsDisplayLinkTemporarily() async throws {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let url = hlsTestURI
    let videoPlayerPlugin = try createInitializedPlugin(
      avFactory: StubAVFactory(pixelBufferSource: mockVideoOutput, assetURL: hlsTestURI),
      displayLinkFactory: stubDisplayLinkFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: url, httpHeaders: [:]))

    // Init should start the display link temporarily.
    #expect(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer
    stubDisplayLinkFactory.fireDisplayLink?()
    _ = player.copyPixelBuffer()
    // Since a frame was found, and the video is paused, the display link should be paused again.
    #expect(!stubDisplayLinkFactory.displayLink.running)
  }

  @Test func seekToWhilePlayingDoesNotStopDisplayLink() async throws {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let url = hlsTestURI
    let videoPlayerPlugin = try createInitializedPlugin(
      avFactory: StubAVFactory(pixelBufferSource: mockVideoOutput, assetURL: url),
      displayLinkFactory: stubDisplayLinkFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: url, httpHeaders: [:]))
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer

    // Ensure that the video is playing before seeking.
    player.play()

    try await player.seek(to: 1234)

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

  @Test func pauseWhileWaitingForFrameDoesNotStopDisplayLink() async throws {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    // Display link and frame updater wire-up is currently done in VideoPlayerPlugin, so create
    // the player via the plugin instead of directly to include that logic in the test.
    let videoPlayerPlugin = try createInitializedPlugin(displayLinkFactory: stubDisplayLinkFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: hlsTestURI, httpHeaders: [:]))
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer

    // Run a play/pause cycle to force the pause codepath to run completely.
    player.play()
    player.pause()

    // Since a buffer hasn't been available yet, the pause should not have stopped the display link.
    #expect(stubDisplayLinkFactory.displayLink.running)
  }

  @Test func disposeWhilePlayingStopsDisplayLink() async throws {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = try createInitializedPlugin(
      avFactory: StubAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: hlsTestURI, httpHeaders: [:]))
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer

    player.play()
    player.dispose()

    #expect(!stubDisplayLinkFactory.displayLink.running)
  }

  @Test func deregistersFromPlayer() async throws {
    let videoPlayerPlugin = try createInitializedPlugin()

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))
    let player = try #require(videoPlayerPlugin.playersByIdentifier[identifiers.playerId])

    player.dispose()
    #expect(videoPlayerPlugin.playersByIdentifier.count == 0)
  }

  @Test func bufferingStateFromPlayer() async throws {
    // TODO(stuartmorgan): Rewrite this test to use stubs, instead of running for 10
    // seconds with a real player and hoping to get buffer status updates.
    let realObjectFactory = DefaultAVFactory()
    let videoPlayerPlugin = try createInitializedPlugin(avFactory: realObjectFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))
    let player = try #require(videoPlayerPlugin.playersByIdentifier[identifiers.playerId])
    let avPlayer = player.player
    avPlayer.play()

    let eventSink: FlutterEventSink = { event in
      if event is BufferingEndEvent {
        #expect(avPlayer.currentItem!.isPlaybackLikelyToKeepUp)
      } else if event is BufferingStartEvent {
        #expect(!avPlayer.currentItem!.isPlaybackLikelyToKeepUp)
      }
    }
    (player.eventListener as? VideoEventsStreamHandler)?.onListen(
      withArguments: nil, sink: PigeonEventSink(eventSink))

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

  @Test func transformFixOrientationUp() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform.identity
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == 0)
    #expect(t.ty == 0)
  }

  @Test func transformFixOrientationDown() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == size.width)
    #expect(t.ty == size.height)
  }

  @Test func transformFixOrientationLeft() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == 0)
    #expect(t.ty == size.width)
  }

  @Test func transformFixOrientationRight() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == size.height)
    #expect(t.ty == 0)
  }

  @Test func transformFixOrientationUpMirrored() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == size.width)
    #expect(t.ty == 0)
  }

  @Test func transformFixOrientationDownMirrored() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == 0)
    #expect(t.ty == size.height)
  }

  @Test func transformFixOrientationLeftMirrored() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == size.height)
    #expect(t.ty == size.width)
  }

  @Test func transformFixOrientationRightMirrored() {
    let size = CGSize(width: 800, height: 600)
    let naturalTransform = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
    let t = standardizedTrackTransform(transform: naturalTransform, size: size)
    #expect(t.tx == 0)
    #expect(t.ty == 0)
  }

  @Test func seekToleranceWhenNotSeekingToEnd() async throws {
    let inspectableAVPlayer = InspectableAVPlayer()
    let stubAVFactory = StubAVFactory(player: inspectableAVPlayer)
    let player = VideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    await player.setEventListener(listener)

    try await player.seek(to: 1234)

    #expect(inspectableAVPlayer.beforeTolerance?.intValue == 0)
    #expect(inspectableAVPlayer.afterTolerance?.intValue == 0)
  }

  @Test func seekToleranceWhenSeekingToEnd() async throws {
    let inspectableAVPlayer = InspectableAVPlayer()
    let stubAVFactory = StubAVFactory(player: inspectableAVPlayer)
    let player = VideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    await player.setEventListener(listener)

    try await player.seek(to: 0)

    #expect((inspectableAVPlayer.beforeTolerance?.intValue ?? 0) > 0)
    #expect((inspectableAVPlayer.afterTolerance?.intValue ?? 0) > 0)
  }

  @Test func setPreventsDisplaySleepDuringVideoPlayback() async {
    let stubAVFactory = StubAVFactory(player: AVPlayer())
    let player = VideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    await player.setEventListener(listener)

    // The setter should update the underlying AVPlayer in both directions.
    player.setPreventsDisplaySleepDuringVideoPlayback(false)
    #expect(player.player.preventsDisplaySleepDuringVideoPlayback == false)

    player.setPreventsDisplaySleepDuringVideoPlayback(true)
    #expect(player.player.preventsDisplaySleepDuringVideoPlayback == true)
  }

  #if os(iOS)
    @Test func externalPlaybackIsEnabledForAirPlay() {
      let stubAVFactory = StubAVFactory(player: AVPlayer())
      let player = VideoPlayer(
        playerItem: StubPlayerItem(),
        avFactory: stubAVFactory,
        viewProvider: StubViewProvider())

      // usesExternalPlaybackWhileExternalScreenIsActive defaults to NO, which
      // keeps the video on the device whenever an external screen is active. An
      // AirPlay route then moves only the audio, and the receiver shows a
      // mirrored screen rather than playing the stream itself.
      #expect(player.player.allowsExternalPlayback == true)
      #expect(player.player.usesExternalPlaybackWhileExternalScreenIsActive == true)
    }
  #endif

  /// Sanity checks a video player playing the given URL with the actual AVPlayer. This is essentially
  /// a mini integration test of the player component.
  ///
  /// Returns the stub event listener to allow tests to inspect the call state.
  func sanityTestURI(_ testURI: String) async throws -> StubEventListener {
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: testURI))
    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    let listener = StubEventListener()
    await withCheckedContinuation { continuation in
      listener.onInitialized = { continuation.resume() }
      Task { @MainActor in await player.setEventListener(listener) }
    }

    // Starts paused.
    let avPlayer = player.player
    #expect(avPlayer.rate == 0)
    #expect(avPlayer.volume == 1)
    #expect(avPlayer.timeControlStatus == .paused)

    // Change playback speed.
    player.setPlaybackSpeed(2)
    player.play()
    #expect(avPlayer.rate == 2)
    #expect(avPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate)

    // Volume
    player.setVolume(0.1)
    #expect(avPlayer.volume == 0.1)

    return listener
  }

  // During the hot reload:
  //  1. `[VideoPlayer onTextureUnregistered:]` gets called.
  //  2. `[VideoPlayerPlugin initialize:]` gets called.
  //
  // Both of these methods dispatch [VideoPlayer dispose] on the main thread
  // leading to a possible crash when de-registering observers twice.
  @Test func hotReloadDoesNotCrash() async throws {
    weak var weakPlayer: VideoPlayer?

    let videoPlayerPlugin = try createInitializedPlugin(avFactory: StubAVFactory())

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))

    // Autoreleasepool is needed to simulate conditions of VideoPlayer deallocation.
    try autoreleasepool {
      let player =
        videoPlayerPlugin.playersByIdentifier[identifiers.playerId] as! TextureBasedVideoPlayer
      weakPlayer = player

      player.onTextureUnregistered(StubTexture())

      try videoPlayerPlugin.initialize()
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

  @Test func failedToLoadVideoEventShouldBeAlwaysSent() async throws {
    // Use real objects to test a real failure flow.
    let realObjectFactory = DefaultAVFactory()
    let videoPlayerPlugin = try createInitializedPlugin(avFactory: realObjectFactory)

    // Provide a URI that is a valid URI, but not a video, to trigger a failure inside AVPlayer.
    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: "https://flutter.dev", httpHeaders: [:]))
    let player = try #require(videoPlayerPlugin.playersByIdentifier[identifiers.playerId])

    await withCheckedContinuation { continuation in
      // TODO(stuartmorgan): Update this test to instead use a mock listener, and add separate unit
      // tests of EventBridge.
      let eventSink: FlutterEventSink = { event in
        if event is FlutterError {
          continuation.resume()
        }
      }
      (player.eventListener as? VideoEventsStreamHandler)?.onListen(
        withArguments: nil, sink: PigeonEventSink(eventSink))
    }
  }

  @Test func updatePlayingStateShouldNotResetRate() async throws {
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: mp4TestURI))
    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    player.setPlaybackSpeed(2)
    player.play()
    #expect(player.player.rate == 2)
  }

  @Test func playerShouldNotDropEverySecondFrame() async throws {
    let textureRegistry = TestTextureRegistry()
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = try createInitializedPlugin(
      avFactory: StubAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory,
      textureRegistry: textureRegistry)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))
    let playerIdentifier = identifiers.playerId
    let player =
      videoPlayerPlugin.playersByIdentifier[playerIdentifier] as! TextureBasedVideoPlayer

    func addFrame() {
      var bufferRef: CVPixelBuffer?
      CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
      mockVideoOutput.pixelBuffer = bufferRef
    }

    addFrame()
    stubDisplayLinkFactory.fireDisplayLink?()
    _ = player.copyPixelBuffer()
    #expect(textureRegistry.textureFrameAvailableCount == 1)

    addFrame()
    stubDisplayLinkFactory.fireDisplayLink?()
    _ = player.copyPixelBuffer()
    #expect(textureRegistry.textureFrameAvailableCount == 2)
  }

  @Test func videoOutputIsAddedWhenAVPlayerIsInitialized() async throws {
    let realObjectFactory = DefaultAVFactory()
    let videoPlayerPlugin = try createInitializedPlugin(avFactory: realObjectFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))
    let player = try #require(videoPlayerPlugin.playersByIdentifier[identifiers.playerId])

    let listener = StubEventListener()
    await withCheckedContinuation { continuation in
      listener.onInitialized = { continuation.resume() }
      Task { @MainActor in await player.setEventListener(listener) }
    }

    let item = try #require(player.player.currentItem)
    // Video output is added as soon as the status becomes ready to play.
    #expect(item.outputs.count == 1)
  }

  #if os(iOS)
    @Test func videoPlayerShouldNotOverwritePlayAndRecordNorDefaultToSpeaker() throws {
      let stubFactory = StubAVFactory()
      let audioSession = TestAudioSession()
      stubFactory.audioSession = audioSession
      audioSession.category = .playAndRecord
      audioSession.categoryOptions = .defaultToSpeaker
      let videoPlayerPlugin = try createInitializedPlugin(avFactory: stubFactory)

      try videoPlayerPlugin.setMixWithOthers(true)
      #expect(audioSession.category == .playAndRecord)
      #expect(audioSession.categoryOptions.contains(.defaultToSpeaker))
      #expect(audioSession.categoryOptions.contains(.mixWithOthers))
    }

    @Test func setMixWithOthersShouldNoOpWhenNoChangesAreRequired() throws {
      let stubFactory = StubAVFactory()
      let audioSession = TestAudioSession()
      stubFactory.audioSession = audioSession
      audioSession.category = .playAndRecord
      audioSession.categoryOptions = [.mixWithOthers, .defaultToSpeaker]
      let videoPlayerPlugin = try createInitializedPlugin(avFactory: stubFactory)

      try videoPlayerPlugin.setMixWithOthers(true)
      #expect(!audioSession.setCategoryCalled)
    }
  #endif

  // MARK: - Audio Track Tests

  // Tests getAudioTracks with a regular MP4 video file using real AVFoundation.
  // Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
  @Test func getAudioTracksWithRealMP4Video() async throws {
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: mp4TestURI))
    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    let tracks = try await player.getAudioTracks()

    // Regular MP4 files do not have media selection groups for audio.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    #expect(tracks.isEmpty)

    player.dispose()
  }

  // Tests getAudioTracks with an HLS stream using real AVFoundation.
  // HLS streams use media selection groups for audio track selection.
  @Test func getAudioTracksWithRealHLSStream() async throws {
    let realObjectFactory = DefaultAVFactory()
    let hlsURL = try #require(URL(string: hlsTestURI))

    let player = VideoPlayer(
      playerItem: playerItem(with: hlsURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    // Now test getAudioTracks
    let tracks = try await player.getAudioTracks()

    // For HLS streams with multiple audio options, we get media selection tracks.
    // The bee.m3u8 stream may or may not have multiple audio tracks.
    // We verify the method returns valid data without crashing.
    for track in tracks {
      #expect(track.displayName != nil)
      #expect(track.index >= 0)
    }

    player.dispose()
  }

  // Tests that getAudioTracks returns valid data for audio-only files.
  // Regular audio files do not have media selection groups, so getAudioTracks returns an empty array.
  @Test func getAudioTracksWithRealAudioFile() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let audioURL = try #require(URL(string: mp3AudioTestURI))

    let player = VideoPlayer(
      playerItem: playerItem(with: audioURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    let tracks = try await player.getAudioTracks()

    // Regular audio files do not have media selection groups.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    #expect(tracks.isEmpty)

    player.dispose()
  }

  // Tests that getAudioTracks works correctly through the plugin API with a real video.
  // Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
  @Test func getAudioTracksViaPluginWithRealVideo() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: mp4TestURI))
    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    // Wait for player to become ready
    let listener = StubEventListener()
    await withCheckedContinuation { continuation in
      listener.onInitialized = { continuation.resume() }
      Task { @MainActor in await player.setEventListener(listener) }
    }

    let tracks = try await player.getAudioTracks()

    // Regular MP4 files do not have media selection groups.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    #expect(tracks.isEmpty)

    player.dispose()
  }

  @Test func loadIsCalledToLoadVideoTracks() async {
    let mockAsset = TestAsset(duration: CMTime(value: 1, timescale: 1))
    let item = StubPlayerItem(asset: mockAsset)

    let stubAVFactory = StubAVFactory(player: nil, playerItem: item, pixelBufferSource: nil)
    let stubViewProvider = StubViewProvider()
    await withCheckedContinuation { continuation in
      mockAsset.continuation = continuation
      let _ = VideoPlayer(
        playerItem: item, avFactory: stubAVFactory, viewProvider: stubViewProvider)
    }
    #expect(mockAsset.loadedValue)
  }

  @Test func videoOutputIsConfiguredWithBT709ColorProperties() throws {
    let item = StubPlayerItem()
    let stubAVFactory = StubAVFactory(player: nil, playerItem: item, pixelBufferSource: nil)
    let stubViewProvider = StubViewProvider()
    let _ = VideoPlayer(
      playerItem: item, avFactory: stubAVFactory, viewProvider: stubViewProvider)

    // BT.709 color properties are required so AVFoundation tone-maps HDR sources
    // into the Flutter texture. Without them HDR samples arrive unconverted and
    // render washed out. See flutter/flutter#91241.
    let settings = try #require(stubAVFactory.lastOutputSettings)
    let colorProperties = try #require(
      settings[AVVideoColorPropertiesKey] as? [String: Any])
    #expect(
      colorProperties[AVVideoColorPrimariesKey] as? String == AVVideoColorPrimaries_ITU_R_709_2)
    #expect(
      colorProperties[AVVideoTransferFunctionKey] as? String
        == AVVideoTransferFunction_ITU_R_709_2)
    #expect(
      colorProperties[AVVideoYCbCrMatrixKey] as? String == AVVideoYCbCrMatrix_ITU_R_709_2)
  }

  // MARK: - Video Track Tests

  // Integration test for getVideoTracks with a non-HLS MP4 video over a live network request.
  // Non-HLS MP4 files don't have adaptive bitrate variants, so we expect empty media selection
  // tracks.
  @Test func getVideoTracksWithRealMP4Video() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: mp4TestURI))

    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    let tracks = try await player.getVideoTracks()

    // For regular MP4 files, media selection tracks should be empty or nil (no HLS variants)
    // The method returns empty data for non-HLS content
    #expect(tracks.mediaSelectionTracks?.isEmpty ?? true)

    player.dispose()
  }

  // Integration test for getVideoTracks with an HLS stream over a live network request.
  // HLS streams use AVAssetVariant API (iOS 15+) to enumerate available quality variants.
  @Test func getVideoTracksWithRealHLSStream() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let hlsURL = try #require(URL(string: hlsTestURI))

    let player = VideoPlayer(
      playerItem: playerItem(with: hlsURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    let tracks = try await player.getVideoTracks()

    // The bee.m3u8 stream may or may not have multiple video variants.
    // We verify the method returns valid data without crashing.
    if let mediaSelectionTracks = tracks.mediaSelectionTracks {
      // If media selection tracks exist, they should have valid structure
      for track in mediaSelectionTracks {
        #expect(track.variantIndex >= 0)
        // Bitrate should be positive if present
        if let bitrate = track.bitrate {
          #expect(bitrate > 0)
        }
      }
    }

    player.dispose()
  }

  // Tests selectVideoTrack sets preferredPeakBitRate correctly.
  @Test func selectVideoTrackSetsBitrate() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: mp4TestURI))

    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    // Set a specific bitrate
    player.selectVideoTrack(withBitrate: 5_000_000)
    #expect(player.player.currentItem?.preferredPeakBitRate == 5_000_000)

    player.dispose()
  }

  // Tests selectVideoTrack with 0 bitrate enables auto quality selection.
  @Test func selectVideoTrackAutoQuality() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let testURL = try #require(URL(string: mp4TestURI))

    let player = VideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    await withCheckedContinuation { continuation in
      let listener = StubEventListener(onInitialized: { continuation.resume() })
      Task { @MainActor in await player.setEventListener(listener) }
    }

    // First set a specific bitrate
    player.selectVideoTrack(withBitrate: 5_000_000)
    #expect(player.player.currentItem?.preferredPeakBitRate == 5_000_000)

    // Then set to auto quality (0)
    player.selectVideoTrack(withBitrate: 0)
    #expect(player.player.currentItem?.preferredPeakBitRate == 0)

    player.dispose()
  }

  // Tests that getVideoTracks works correctly through the plugin API with a real video.
  @Test func getVideoTracksViaPluginWithRealVideo() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let videoPlayerPlugin = try createInitializedPlugin(avFactory: realObjectFactory)

    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))

    let player = try #require(videoPlayerPlugin.playersByIdentifier[identifiers.playerId])

    // Wait for player item to become ready
    let item = try #require(player.player.currentItem)
    try await waitForPlayerItemStatus(item, state: .readyToPlay)

    // Just test that the call completes successfully.
    let _ = try await player.getVideoTracks()

    player.dispose()
  }

  // Tests selectVideoTrack via plugin API with HLS stream.
  @Test func selectVideoTrackViaPluginWithHLSStream() async throws {
    // TODO(stuartmorgan): Add more use of protocols in VideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = DefaultAVFactory()
    let videoPlayerPlugin = try createInitializedPlugin(avFactory: realObjectFactory)

    // Use HLS stream which supports adaptive bitrate
    let identifiers = try await videoPlayerPlugin.createTexturePlayer(
      options: CreationOptions(uri: hlsTestURI, httpHeaders: [:]))

    let player = try #require(videoPlayerPlugin.playersByIdentifier[identifiers.playerId])

    // Wait for player item to become ready
    let item = try #require(player.player.currentItem)
    try await waitForPlayerItemStatus(item, state: .readyToPlay)

    // Test setting a specific bitrate
    player.selectVideoTrack(withBitrate: 1_000_000)
    #expect(player.player.currentItem?.preferredPeakBitRate == 1_000_000)

    // Test setting auto quality
    player.selectVideoTrack(withBitrate: 0)
    #expect(player.player.currentItem?.preferredPeakBitRate == 0)

    player.dispose()
  }

  @Test func validFrameDurationWithPositiveTime() {
    let duration = CMTimeMake(value: 1, timescale: 30)
    #expect(frameDurationIsValid(duration))
  }

  @Test func validFrameDurationWithZeroTime() {
    #expect(!frameDurationIsValid(CMTime.zero))
  }

  @Test func validFrameDurationWithInvalidTime() {
    #expect(!frameDurationIsValid(CMTime.invalid))
  }

  @Test func validFrameDurationWithNegativeTime() {
    let duration = CMTimeMake(value: -1, timescale: 30)
    #expect(!frameDurationIsValid(duration))
  }

  @Test func validFrameDurationWithPositiveInfinity() {
    #expect(!frameDurationIsValid(CMTime.positiveInfinity))
  }

  @Test func validFrameDurationWithIndefinite() {
    #expect(!frameDurationIsValid(CMTime.indefinite))
  }

  @Test func apiBridgeHandlesPlayerDestruction() async throws {
    weak var weakPlayer: VideoPlayer?
    var apiBridge: VideoPlayerInstanceBridge?

    let videoPlayerPlugin = try createInitializedPlugin(avFactory: StubAVFactory())

    let identifier = try await videoPlayerPlugin.createPlatformViewPlayer(
      options: CreationOptions(uri: mp4TestURI, httpHeaders: [:]))

    // Simulation a temporary lifetime extension of the bridge, which can happen if an
    // async Pigeon closure is executing when `dispose()` is called.
    autoreleasepool {
      let player = videoPlayerPlugin.playersByIdentifier[identifier]
      weakPlayer = player
      apiBridge = player?.hostApiBridge

      player?.dispose()
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

    #expect(weakPlayer == nil)
    #expect(apiBridge != nil)
    // Calling the bridge should return a placeholder value rather than crash.
    #expect(try apiBridge?.getPosition() == 0)
  }

  // MARK: - Helper Methods

  /// Creates a plugin with the given dependencies, and default stubs for any that aren't provided,
  /// then initializes it.
  private func createInitializedPlugin(
    avFactory: WrappedAVObjectFactory = StubAVFactory(),
    displayLinkFactory: DisplayLinkFactory = StubFVPDisplayLinkFactory(),
    binaryMessenger: FlutterBinaryMessenger = StubBinaryMessenger(),
    textureRegistry: FlutterTextureRegistry = TestTextureRegistry(),
    viewProvider: FVPViewProvider = StubViewProvider(),
    assetProvider: FVPAssetProvider = StubAssetProvider()
  ) throws -> VideoPlayerPlugin {
    let plugin = VideoPlayerPlugin(
      avFactory: avFactory,
      displayLinkFactory: displayLinkFactory,
      binaryMessenger: binaryMessenger,
      textureRegistry: textureRegistry,
      viewProvider: viewProvider,
      assetProvider: assetProvider)
    try plugin.initialize()
    return plugin
  }

  private func playerItem(with url: URL, factory: WrappedAVObjectFactory) -> WrappedAVPlayerItem {
    let asset = factory.urlAsset(with: url, options: nil)
    return factory.playerItem(with: asset)
  }

  private func waitForPlayerItemStatus(_ item: AVPlayerItem, state: AVPlayerItem.Status)
    async
    throws
  {
    try await withCheckedThrowingContinuation { continuation in
      // Check whether it already has the desired status.
      if item.status == state {
        continuation.resume()
        return
      }

      if item.status == .failed {
        continuation.resume(throwing: item.error ?? NSError(domain: "VideoPlayerTests", code: 1))
        return
      }

      // If not, wait for that status. The observation token must be retained until the callback
      // fires; otherwise KVO unregisters immediately and the continuation is never resumed.
      var observation: NSKeyValueObservation?
      observation = item.observe(\.status, options: [.initial, .new]) { observedItem, _ in
        if observedItem.status == state {
          observation?.invalidate()
          observation = nil
          continuation.resume()
        } else if observedItem.status == .failed {
          observation?.invalidate()
          observation = nil
          continuation.resume(
            throwing: observedItem.error ?? NSError(domain: "VideoPlayerTests", code: 1))
        }
      }
    }
  }
}
