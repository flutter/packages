// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import Flutter
import XCTest
@preconcurrency import video_player_avfoundation

@MainActor class VideoPlayerTests: XCTestCase {

  let mp4TestURL = URL(
    string: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")!
  let hlsTestURL = URL(
    string: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8")!

  func testBlankVideoBugWithEncryptedVideoStreamAndInvertedAspectRatioBugForSomeVideoStream() {
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
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(),
      displayLinkFactory: StubFVPDisplayLinkFactory(),
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: viewProvider,
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    XCTAssertNotNil(identifiers)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer

    XCTAssertNotNil(player.playerLayer, "AVPlayerLayer should be present.")
    XCTAssertEqual(
      player.playerLayer.superlayer, view.layer, "AVPlayerLayer should be added on screen.")
  }

  func testPlayerForPlatformViewDoesNotRegisterTexture() {
    let textureRegistry = TestTextureRegistry()
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(),
      displayLinkFactory: stubDisplayLinkFactory,
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: textureRegistry,
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8",
      httpHeaders: [:])
    videoPlayerPlugin.createPlatformViewPlayer(with: create, error: &error)
    XCTAssertNil(error)

    XCTAssertFalse(textureRegistry.registeredTexture)
  }

  func testSeekToWhilePausedStartsDisplayLinkTemporarily() {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
    // the player via the plugin instead of directly to include that logic in the test.
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory,
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    XCTAssertNotNil(identifiers)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer

    // Ensure that the video playback is paused before seeking.
    player.pauseWithError(&error)
    XCTAssertNil(error)

    let seekExpectation = expectation(description: "seekTo completes")
    player.seek(to: 1234) { error in
      seekExpectation.fulfill()
    }
    waitForExpectations(timeout: 30.0)

    // Seeking to a new position should start the display link temporarily.
    XCTAssertTrue(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    stubDisplayLinkFactory.fireDisplayLink?()
    player.copyPixelBuffer()
    // Since a frame was found, and the video is paused, the display link should be paused again.
    XCTAssertFalse(stubDisplayLinkFactory.displayLink.running)
  }

  func testInitStartsDisplayLinkTemporarily() {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory,
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)

    // Init should start the display link temporarily.
    XCTAssertTrue(stubDisplayLinkFactory.displayLink.running)

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
    XCTAssertFalse(stubDisplayLinkFactory.displayLink.running)
  }

  func testSeekToWhilePlayingDoesNotStopDisplayLink() {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory,
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer

    // Ensure that the video is playing before seeking.
    player.playWithError(&error)
    XCTAssertNil(error)

    let seekExpectation = expectation(description: "seekTo completes")
    player.seek(to: 1234) { error in
      seekExpectation.fulfill()
    }
    waitForExpectations(timeout: 30.0)
    XCTAssertTrue(stubDisplayLinkFactory.displayLink.running)

    // Simulate a buffer being available.
    var bufferRef: CVPixelBuffer?
    CVPixelBufferCreate(nil, 1, 1, kCVPixelFormatType_32BGRA, nil, &bufferRef)
    mockVideoOutput.pixelBuffer = bufferRef
    // Simulate a callback from the engine to request a new frame.
    stubDisplayLinkFactory.fireDisplayLink?()
    // Since the video was playing, the display link should not be paused after getting a buffer.
    XCTAssertTrue(stubDisplayLinkFactory.displayLink.running)
  }

  func testPauseWhileWaitingForFrameDoesNotStopDisplayLink() {
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    // Display link and frame updater wire-up is currently done in FVPVideoPlayerPlugin, so create
    // the player via the plugin instead of directly to include that logic in the test.
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(),
      displayLinkFactory: stubDisplayLinkFactory,
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    let player =
      videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer

    // Run a play/pause cycle to force the pause codepath to run completely.
    player.playWithError(&error)
    XCTAssertNil(error)
    player.pauseWithError(&error)
    XCTAssertNil(error)

    // Since a buffer hasn't been available yet, the pause should not have stopped the display link.
    XCTAssertTrue(stubDisplayLinkFactory.displayLink.running)
  }

  func testDeregistersFromPlayer() {
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(),
      displayLinkFactory: StubFVPDisplayLinkFactory(),
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    XCTAssertNotNil(identifiers)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPVideoPlayer
    XCTAssertNotNil(player)

    player.disposeWithError(&error)
    XCTAssertNil(error)
    XCTAssertEqual(videoPlayerPlugin.playersByIdentifier.count, 0)
  }

  func testBufferingStateFromPlayer() {
    let realObjectFactory = FVPDefaultAVFactory()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: realObjectFactory,
      displayLinkFactory: StubFVPDisplayLinkFactory(),
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    XCTAssertNotNil(identifiers)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPVideoPlayer
    XCTAssertNotNil(player)
    let avPlayer = player.player
    avPlayer.play()

    let bufferingStateExpectation = expectation(description: "bufferingState")
    let eventSink: FlutterEventSink = { event in
      guard let event = event as? [String: Any], let eventType = event["event"] as? String else {
        return
      }
      if eventType == "bufferingEnd" {
        XCTAssertTrue(avPlayer.currentItem!.isPlaybackLikelyToKeepUp)
      }
      if eventType == "bufferingStart" {
        XCTAssertFalse(avPlayer.currentItem!.isPlaybackLikelyToKeepUp)
      }
    }
    (player.eventListener as? FlutterStreamHandler)?.onListen(
      withArguments: nil, eventSink: eventSink)

    let timeout: TimeInterval = 10
    DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
      bufferingStateExpectation.fulfill()
    }
    waitForExpectations(timeout: timeout + 1)
  }

  func testVideoControls() {
    let eventListener = sanityTestURI(
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")
    XCTAssertEqual(eventListener.initializationSize.height, 720)
    XCTAssertEqual(eventListener.initializationSize.width, 1280)
    XCTAssertEqual(Double(eventListener.initializationDuration), 4000, accuracy: 200)
  }

  func testAudioControls() {
    let eventListener = sanityTestURI(
      "https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3")
    XCTAssertEqual(eventListener.initializationSize.height, 0)
    XCTAssertEqual(eventListener.initializationSize.width, 0)
    XCTAssertEqual(Double(eventListener.initializationDuration), 5400, accuracy: 200)
  }

  func testHLSControls() {
    let eventListener = sanityTestURI(
      "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8")
    XCTAssertEqual(eventListener.initializationSize.height, 720)
    XCTAssertEqual(eventListener.initializationSize.width, 1280)
    XCTAssertEqual(Double(eventListener.initializationDuration), 4000, accuracy: 200)
  }

  func testAudioOnlyHLSControls() throws {
    throw XCTSkip("Flaky; see https://github.com/flutter/flutter/issues/164381")

    let eventListener = sanityTestURI(
      "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee_audio_only.m3u8")
    XCTAssertEqual(eventListener.initializationSize.height, 0)
    XCTAssertEqual(eventListener.initializationSize.width, 0)
    XCTAssertEqual(Double(eventListener.initializationDuration), 4000, accuracy: 200)
  }

  #if os(iOS)
    func testTransformFixOrientationUp() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform.identity
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, 0)
      XCTAssertEqual(t.ty, 0)
    }

    func testTransformFixOrientationDown() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, size.width)
      XCTAssertEqual(t.ty, size.height)
    }

    func testTransformFixOrientationLeft() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: -1, c: 1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, 0)
      XCTAssertEqual(t.ty, size.width)
    }

    func testTransformFixOrientationRight() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, size.height)
      XCTAssertEqual(t.ty, 0)
    }

    func testTransformFixOrientationUpMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, size.width)
      XCTAssertEqual(t.ty, 0)
    }

    func testTransformFixOrientationDownMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, 0)
      XCTAssertEqual(t.ty, size.height)
    }

    func testTransformFixOrientationLeftMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: -1, c: -1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, size.height)
      XCTAssertEqual(t.ty, size.width)
    }

    func testTransformFixOrientationRightMirrored() {
      let size = CGSize(width: 800, height: 600)
      let naturalTransform = CGAffineTransform(a: 0, b: 1, c: 1, d: 0, tx: 0, ty: 0)
      let t = FVPGetStandardizedTrackTransform(naturalTransform, size)
      XCTAssertEqual(t.tx, 0)
      XCTAssertEqual(t.ty, 0)
    }
  #endif

  func testSeekToleranceWhenNotSeekingToEnd() {
    let inspectableAVPlayer = InspectableAVPlayer()
    let stubAVFactory = StubFVPAVFactory(player: inspectableAVPlayer)
    let player = FVPVideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    player.eventListener = listener

    let seekExpectation = expectation(
      description: "seekTo has zero tolerance when seeking not to end")
    player.seek(to: 1234) { error in
      seekExpectation.fulfill()
    }

    waitForExpectations(timeout: 30.0)
    XCTAssertEqual(inspectableAVPlayer.beforeTolerance?.intValue, 0)
    XCTAssertEqual(inspectableAVPlayer.afterTolerance?.intValue, 0)
  }

  func testSeekToleranceWhenSeekingToEnd() {
    let inspectableAVPlayer = InspectableAVPlayer()
    let stubAVFactory = StubFVPAVFactory(player: inspectableAVPlayer)
    let player = FVPVideoPlayer(
      playerItem: StubPlayerItem(),
      avFactory: stubAVFactory,
      viewProvider: StubViewProvider())
    let listener = StubEventListener()
    player.eventListener = listener

    let seekExpectation = expectation(
      description: "seekTo has non-zero tolerance when seeking to end")
    // The duration of this video is "0" due to the non standard initiliatazion process.
    player.seek(to: 0) { error in
      seekExpectation.fulfill()
    }
    waitForExpectations(timeout: 30.0)
    XCTAssertGreaterThan(inspectableAVPlayer.beforeTolerance?.intValue ?? 0, 0)
    XCTAssertGreaterThan(inspectableAVPlayer.afterTolerance?.intValue ?? 0, 0)
  }

  /// Sanity checks a video player playing the given URL with the actual AVPlayer. This is essentially
  /// a mini integration test of the player component.
  ///
  /// Returns the stub event listener to allow tests to inspect the call state.
  func sanityTestURI(_ testURI: String) -> StubEventListener {
    let realObjectFactory = FVPDefaultAVFactory()
    guard let testURL = URL(string: testURI) else {
      XCTFail("Failed to create URL")
      return StubEventListener()
    }
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())
    XCTAssertNotNil(player)

    let initializedExpectation = expectation(description: "initialized")
    let listener = StubEventListener(initializationExpectation: initializedExpectation)
    player.eventListener = listener
    waitForExpectations(timeout: 30.0)

    // Starts paused.
    let avPlayer = player.player
    XCTAssertEqual(avPlayer.rate, 0)
    XCTAssertEqual(avPlayer.volume, 1)
    XCTAssertEqual(avPlayer.timeControlStatus, .paused)

    // Change playback speed.
    var error: FlutterError?
    player.setPlaybackSpeed(2, error: &error)
    XCTAssertNil(error)
    player.playWithError(&error)
    XCTAssertNil(error)
    XCTAssertEqual(avPlayer.rate, 2)
    XCTAssertEqual(avPlayer.timeControlStatus, .waitingToPlayAtSpecifiedRate)

    // Volume
    player.setVolume(0.1, error: &error)
    XCTAssertNil(error)
    XCTAssertEqual(avPlayer.volume, 0.1)

    return listener
  }

  // Checks whether [AVPlayer rate] KVO observations are correctly detached.
  // - https://github.com/flutter/flutter/issues/124937
  //
  // Failing to de-register results in a crash in [AVPlayer willChangeValueForKey:].
  func testDoesNotCrashOnRateObservationAfterDisposal() {
    let realObjectFactory = FVPDefaultAVFactory()

    var avPlayer: AVPlayer? = nil
    weak var weakPlayer: FVPVideoPlayer? = nil

    // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
    autoreleasepool {
      let videoPlayerPlugin = FVPVideoPlayerPlugin(
        avFactory: realObjectFactory,
        displayLinkFactory: StubFVPDisplayLinkFactory(),
        binaryMessenger: StubBinaryMessenger(),
        textureRegistry: TestTextureRegistry(),
        viewProvider: StubViewProvider(),
        assetProvider: StubAssetProvider())

      var error: FlutterError?
      videoPlayerPlugin.initialize(&error)
      XCTAssertNil(error)

      let create = FVPCreationOptions.make(
        withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        httpHeaders: [:])
      let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
      XCTAssertNil(error)
      XCTAssertNotNil(identifiers)

      let player = videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPVideoPlayer
      XCTAssertNotNil(player)
      weakPlayer = player
      avPlayer = player.player

      player.disposeWithError(&error)
      XCTAssertNil(error)
    }

    let expectation = XCTestExpectation(description: "Object deallocated")
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak weakPlayer] timer in
      if weakPlayer == nil {
        timer.invalidate()
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: 10.0)

    avPlayer?.willChangeValue(forKey: "rate")  // No assertions needed. Lack of crash is a success.
    avPlayer?.didChangeValue(forKey: "rate")
  }

  // During the hot reload:
  //  1. `[FVPVideoPlayer onTextureUnregistered:]` gets called.
  //  2. `[FVPVideoPlayerPlugin initialize:]` gets called.
  //
  // Both of these methods dispatch [FVPVideoPlayer dispose] on the main thread
  // leading to a possible crash when de-registering observers twice.
  func testHotReloadDoesNotCrash() {
    weak var weakPlayer: FVPVideoPlayer? = nil

    // Autoreleasepool is needed to simulate conditions of FVPVideoPlayer deallocation.
    autoreleasepool {
      let videoPlayerPlugin = FVPVideoPlayerPlugin(
        avFactory: StubFVPAVFactory(),
        displayLinkFactory: StubFVPDisplayLinkFactory(),
        binaryMessenger: StubBinaryMessenger(),
        textureRegistry: TestTextureRegistry(),
        viewProvider: StubViewProvider(),
        assetProvider: StubAssetProvider())

      var error: FlutterError?
      videoPlayerPlugin.initialize(&error)
      XCTAssertNil(error)

      let create = FVPCreationOptions.make(
        withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
        httpHeaders: [:])
      let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
      XCTAssertNil(error)
      XCTAssertNotNil(identifiers)

      let player =
        videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPTextureBasedVideoPlayer
      weakPlayer = player

      player.onTextureUnregistered(StubTexture())

      videoPlayerPlugin.initialize(&error)
      XCTAssertNil(error)
    }

    let expectation = XCTestExpectation(description: "Object deallocated")
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak weakPlayer] timer in
      if weakPlayer == nil {
        timer.invalidate()
        expectation.fulfill()
      }
    }
    wait(for: [expectation], timeout: 10.0)  // No assertions needed. Lack of crash is a success.
  }

  func testFailedToLoadVideoEventShouldBeAlwaysSent() {
    // Use real objects to test a real failure flow.
    let realObjectFactory = FVPDefaultAVFactory()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: realObjectFactory,
      displayLinkFactory: StubFVPDisplayLinkFactory(),
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(withUri: "", httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPVideoPlayer
    XCTAssertNotNil(player)

    let item = player.player.currentItem!
    keyValueObservingExpectation(for: item, keyPath: "status") { _, change in
      return item.status == .failed
    }
    waitForExpectations(timeout: 10.0)

    let failedExpectation = expectation(description: "failed")
    // TODO(stuartmorgan): Update this test to instead use a mock listener, and add separate unit
    // tests of FVPEventBridge.
    let eventSink: FlutterEventSink = { event in
      if event is FlutterError {
        failedExpectation.fulfill()
      }
    }
    (player.eventListener as? FlutterStreamHandler)?.onListen(
      withArguments: nil, eventSink: eventSink)
    waitForExpectations(timeout: 10.0)
  }

  func testUpdatePlayingStateShouldNotResetRate() {
    let realObjectFactory = FVPDefaultAVFactory()
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: mp4TestURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    let initializedExpectation = expectation(description: "initialized")
    let listener = StubEventListener(initializationExpectation: initializedExpectation)
    player.eventListener = listener
    waitForExpectations(timeout: 10)

    var error: FlutterError?
    player.setPlaybackSpeed(2, error: &error)
    XCTAssertNil(error)
    player.playWithError(&error)
    XCTAssertNil(error)
    XCTAssertEqual(player.player.rate, 2)
  }

  func testPlayerShouldNotDropEverySecondFrame() {
    let textureRegistry = TestTextureRegistry()
    let stubDisplayLinkFactory = StubFVPDisplayLinkFactory()
    let mockVideoOutput = TestPixelBufferSource()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: StubFVPAVFactory(pixelBufferSource: mockVideoOutput),
      displayLinkFactory: stubDisplayLinkFactory,
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: textureRegistry,
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())

    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      httpHeaders: [:])
    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
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
    XCTAssertEqual(textureRegistry.textureFrameAvailableCount, 1)

    addFrame()
    stubDisplayLinkFactory.fireDisplayLink?()
    player.copyPixelBuffer()
    XCTAssertEqual(textureRegistry.textureFrameAvailableCount, 2)
  }

  func testVideoOutputIsAddedWhenAVPlayerItemBecomesReady() {
    let realObjectFactory = FVPDefaultAVFactory()
    let videoPlayerPlugin = FVPVideoPlayerPlugin(
      avFactory: realObjectFactory,
      displayLinkFactory: StubFVPDisplayLinkFactory(),
      binaryMessenger: StubBinaryMessenger(),
      textureRegistry: TestTextureRegistry(),
      viewProvider: StubViewProvider(),
      assetProvider: StubAssetProvider())
    var error: FlutterError?
    videoPlayerPlugin.initialize(&error)
    XCTAssertNil(error)

    let create = FVPCreationOptions.make(
      withUri: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      httpHeaders: [:])

    let identifiers = videoPlayerPlugin.createTexturePlayer(with: create, error: &error)
    XCTAssertNil(error)
    XCTAssertNotNil(identifiers)
    let player = videoPlayerPlugin.playersByIdentifier[identifiers!.playerId] as! FVPVideoPlayer
    XCTAssertNotNil(player)

    let item = player.player.currentItem!
    keyValueObservingExpectation(for: item, keyPath: "status") { _, change in
      return item.status == .readyToPlay
    }
    waitForExpectations(timeout: 10.0)
    // Video output is added as soon as the status becomes ready to play.
    XCTAssertEqual(item.outputs.count, 1)
  }

  #if os(iOS)
    func testVideoPlayerShouldNotOverwritePlayAndRecordNorDefaultToSpeaker() {
      let stubFactory = StubFVPAVFactory()
      let audioSession = TestAudioSession()
      stubFactory.audioSession = audioSession
      let videoPlayerPlugin = FVPVideoPlayerPlugin(
        avFactory: stubFactory,
        displayLinkFactory: StubFVPDisplayLinkFactory(),
        binaryMessenger: StubBinaryMessenger(),
        textureRegistry: TestTextureRegistry(),
        viewProvider: StubViewProvider(),
        assetProvider: StubAssetProvider())

      audioSession.category = .playAndRecord
      audioSession.categoryOptions = .defaultToSpeaker

      var error: FlutterError?
      videoPlayerPlugin.initialize(&error)
      XCTAssertNil(error)
      videoPlayerPlugin.setMixWithOthers(true, error: &error)
      XCTAssertNil(error)
      XCTAssertEqual(audioSession.category, .playAndRecord, "Category should be PlayAndRecord.")
      XCTAssertTrue(
        audioSession.categoryOptions.contains(.defaultToSpeaker),
        "Flag DefaultToSpeaker was removed.")
      XCTAssertTrue(
        audioSession.categoryOptions.contains(.mixWithOthers), "Flag MixWithOthers should be set.")
    }

    func testSetMixWithOthersShouldNoOpWhenNoChangesAreRequired() {
      let stubFactory = StubFVPAVFactory()
      let audioSession = TestAudioSession()
      stubFactory.audioSession = audioSession
      let videoPlayerPlugin = FVPVideoPlayerPlugin(
        avFactory: stubFactory,
        displayLinkFactory: StubFVPDisplayLinkFactory(),
        binaryMessenger: StubBinaryMessenger(),
        textureRegistry: TestTextureRegistry(),
        viewProvider: StubViewProvider(),
        assetProvider: StubAssetProvider())

      audioSession.category = .playAndRecord
      audioSession.categoryOptions = [.mixWithOthers, .defaultToSpeaker]

      var error: FlutterError?
      videoPlayerPlugin.initialize(&error)
      XCTAssertNil(error)
      videoPlayerPlugin.setMixWithOthers(true, error: &error)
      XCTAssertNil(error)
      XCTAssertFalse(audioSession.setCategoryCalled)
    }
  #endif

  // MARK: - Audio Track Tests

  // Tests getAudioTracks with a regular MP4 video file using real AVFoundation.
  // Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
  func testGetAudioTracksWithRealMP4Video() {
    let realObjectFactory = FVPDefaultAVFactory()
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: mp4TestURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())
    XCTAssertNotNil(player)

    let initializedExpectation = expectation(description: "initialized")
    let listener = StubEventListener(initializationExpectation: initializedExpectation)
    player.eventListener = listener
    waitForExpectations(timeout: 30.0)

    // Now test getAudioTracks
    var error: FlutterError?
    let result = player.getAudioTracks(&error)

    XCTAssertNil(error)
    XCTAssertNotNil(result)

    // Regular MP4 files do not have media selection groups for audio.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    XCTAssertEqual(result?.count, 0)

    player.disposeWithError(&error)
  }

  // Tests getAudioTracks with an HLS stream using real AVFoundation.
  // HLS streams use media selection groups for audio track selection.
  func testGetAudioTracksWithRealHLSStream() {
    let realObjectFactory = FVPDefaultAVFactory()
    let hlsURL = URL(
      string: "https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8")!

    let player = FVPVideoPlayer(
      playerItem: playerItem(with: hlsURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())
    XCTAssertNotNil(player)

    let initializedExpectation = expectation(description: "initialized")
    let listener = StubEventListener(initializationExpectation: initializedExpectation)
    player.eventListener = listener
    waitForExpectations(timeout: 30.0)

    // Now test getAudioTracks
    var error: FlutterError?
    let result = player.getAudioTracks(&error)

    XCTAssertNil(error)
    XCTAssertNotNil(result)

    // For HLS streams with multiple audio options, we get media selection tracks.
    // The bee.m3u8 stream may or may not have multiple audio tracks.
    // We verify the method returns valid data without crashing.
    for track in result ?? [] {
      XCTAssertNotNil(track.displayName)
      XCTAssertGreaterThanOrEqual(track.index, 0)
    }

    player.disposeWithError(&error)
  }

  // Tests that getAudioTracks returns valid data for audio-only files.
  // Regular audio files do not have media selection groups, so getAudioTracks returns an empty array.
  func testGetAudioTracksWithRealAudioFile() {
    // TODO(stuartmorgan): Add more use of protocols in FVPVideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = FVPDefaultAVFactory()
    let audioURL = URL(
      string: "https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3")!

    let player = FVPVideoPlayer(
      playerItem: playerItem(with: audioURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())
    XCTAssertNotNil(player)

    let initializedExpectation = expectation(description: "initialized")
    let listener = StubEventListener(initializationExpectation: initializedExpectation)
    player.eventListener = listener
    waitForExpectations(timeout: 30.0)

    // Now test getAudioTracks
    var error: FlutterError?
    let result = player.getAudioTracks(&error)

    XCTAssertNil(error)
    XCTAssertNotNil(result)

    // Regular audio files do not have media selection groups.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    XCTAssertEqual(result?.count, 0)

    player.disposeWithError(&error)
  }

  // Tests that getAudioTracks works correctly through the plugin API with a real video.
  // Regular MP4 files do not have media selection groups, so getAudioTracks returns an empty array.
  func testGetAudioTracksViaPluginWithRealVideo() {
    // TODO(stuartmorgan): Add more use of protocols in FVPVideoPlayer so that this test
    // can use a fake item/asset instead of loading an actual remote asset.
    let realObjectFactory = FVPDefaultAVFactory()
    let testURL = URL(
      string: "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")!
    let player = FVPVideoPlayer(
      playerItem: playerItem(with: testURL, factory: realObjectFactory),
      avFactory: realObjectFactory,
      viewProvider: StubViewProvider())

    // Wait for player item to become ready
    let item = player.player.currentItem!
    keyValueObservingExpectation(for: item, keyPath: "status") { _, _ in
      return item.status == .readyToPlay
    }
    waitForExpectations(timeout: 30.0)

    // Now test getAudioTracks
    var error: FlutterError?
    let result = player.getAudioTracks(&error)

    XCTAssertNil(error)
    XCTAssertNotNil(result)

    // Regular MP4 files do not have media selection groups.
    // getAudioTracks only returns selectable audio tracks from HLS streams.
    XCTAssertEqual(result?.count, 0)

    player.disposeWithError(&error)
  }

  func testLoadTracksWithMediaTypeIsCalledOnNewerOS() {
    if #available(iOS 15.0, macOS 12.0, *) {
      let mockAsset = TestAsset(duration: CMTimeMake(value: 1, timescale: 1), tracks: [])
      let item = StubPlayerItem(asset: mockAsset)

      let stubAVFactory = StubFVPAVFactory(player: nil, playerItem: item, pixelBufferSource: nil)
      let stubViewProvider = StubViewProvider()
      let player = FVPVideoPlayer(
        playerItem: item, avFactory: stubAVFactory, viewProvider: stubViewProvider)
      XCTAssertNotNil(player)
      XCTAssertTrue(mockAsset.loadedTracksAsynchronously)
    }
  }
  // MARK: - Helper Methods

  private func playerItem(with url: URL, factory: FVPAVFactory) -> FVPAVPlayerItem {
    let asset = factory.urlAsset(with: url, options: nil)
    return factory.playerItem(with: asset)
  }
}
