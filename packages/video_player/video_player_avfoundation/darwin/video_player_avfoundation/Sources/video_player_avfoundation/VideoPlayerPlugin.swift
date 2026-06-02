// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

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

// Protocol for an display link factory. Used for injecting display links in tests.
protocol DisplayLinkFactory {
  func displayLink(
    with viewProvider: FVPViewProvider,
    callback: @escaping () -> Void
  ) -> FVPDisplayLink
}

/// Non-test implementation of the display link factory.
final class DefaultDisplayLinkFactory: DisplayLinkFactory {
  func displayLink(
    with viewProvider: FVPViewProvider,
    callback: @escaping () -> Void
  ) -> FVPDisplayLink {
    #if os(iOS)
      return FVPCADisplayLink(viewProvider: viewProvider, callback: callback)
    #elseif os(macOS)
      if #available(macOS 14.0, *) {
        return FVPCADisplayLink(viewProvider: viewProvider, callback: callback)
      }
      return FVPCoreVideoDisplayLink(viewProvider: viewProvider, callback: callback)
    #endif
  }
}

/// Non-test implementation of FVPAssetProvider, wrapping a Flutter plugin
/// registrar.
final class DefaultAssetProvider: NSObject, FVPAssetProvider {
  private weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()
  }

  func lookupKey(forAsset asset: String) -> String? {
    return registrar?.lookupKey(forAsset: asset)
  }

  func lookupKey(forAsset asset: String, fromPackage package: String) -> String? {
    return registrar?.lookupKey(forAsset: asset, fromPackage: package)
  }
}

public final class VideoPlayerPlugin: NSObject, FlutterPlugin, AVFoundationVideoPlayerApi {
  private let binaryMessenger: FlutterBinaryMessenger
  private let textureRegistry: FlutterTextureRegistry
  private let displayLinkFactory: DisplayLinkFactory
  private let avFactory: FVPAVFactory
  private let viewProvider: FVPViewProvider
  private let assetProvider: FVPAssetProvider
  private var nextPlayerIdentifier: Int64 = 1
  var playersByIdentifier: [Int64: FVPVideoPlayer] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = VideoPlayerPlugin(registrar: registrar)
    // Publish the instance so that it receives detachFromEngine.
    registrar.publish(instance)

    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    let factory = NativeVideoViewFactory(
      messenger: messenger,
      playerByIdentifierProvider: {
        [weak instance] (playerIdentifier: Int64) -> FVPVideoPlayer? in
        return instance?.playersByIdentifier[playerIdentifier]
      }
    )
    registrar.register(factory, withId: "plugins.flutter.dev/video_player_ios")

    AVFoundationVideoPlayerApiSetup.setUp(binaryMessenger: messenger, api: instance)
  }

  convenience init(registrar: FlutterPluginRegistrar) {
    #if os(iOS)
      let messenger = registrar.messenger()
      let textures = registrar.textures()
    #else
      let messenger = registrar.messenger
      let textures = registrar.textures
    #endif
    self.init(
      avFactory: FVPDefaultAVFactory(),
      displayLinkFactory: DefaultDisplayLinkFactory(),
      binaryMessenger: messenger,
      textureRegistry: textures,
      viewProvider: FVPDefaultViewProvider(registrar: registrar),
      assetProvider: DefaultAssetProvider(registrar: registrar)
    )
  }

  init(
    avFactory: FVPAVFactory,
    displayLinkFactory: DisplayLinkFactory,
    binaryMessenger: FlutterBinaryMessenger,
    textureRegistry: FlutterTextureRegistry,
    viewProvider: FVPViewProvider,
    assetProvider: FVPAssetProvider
  ) {
    self.binaryMessenger = binaryMessenger
    self.textureRegistry = textureRegistry
    self.assetProvider = assetProvider
    self.viewProvider = viewProvider
    self.displayLinkFactory = displayLinkFactory
    self.avFactory = avFactory
    super.init()
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    for player in playersByIdentifier.values {
      // Remove the channel and texture cleanup, and the event listener, to ensure that the player
      // doesn't message the engine that is no longer connected.
      player.onDisposed = nil
      player.eventListener = nil
      var error: FlutterError?
      player.disposeWithError(&error)
    }
    playersByIdentifier.removeAll()
    #if os(iOS)
      let messenger = registrar.messenger()
    #else
      let messenger = registrar.messenger
    #endif
    AVFoundationVideoPlayerApiSetup.setUp(binaryMessenger: messenger, api: nil)
  }

  func initialize() throws {
    #if os(iOS)
      // Allow audio playback when the Ring/Silent switch is set to silent
      upgradeAudioSessionCategory(
        session: avFactory.sharedAudioSession(),
        requestedCategory: .playback,
        options: [],
        clearOptions: []
      )
    #endif

    for player in playersByIdentifier.values {
      var error: FlutterError?
      player.disposeWithError(&error)
    }
    playersByIdentifier.removeAll()
  }

  func createPlatformViewPlayer(options params: CreationOptions) throws -> Int64 {
    let item = try playerItem(with: params)
    let player = FVPVideoPlayer(playerItem: item, avFactory: avFactory, viewProvider: viewProvider)
    return configurePlayer(player, extraDisposeHandler: nil)
  }

  func createTexturePlayer(options creationOptions: CreationOptions) throws -> TexturePlayerIds {
    let item = try playerItem(with: creationOptions)
    let frameUpdater = FVPFrameUpdater(registry: textureRegistry)
    let displayLink = displayLinkFactory.displayLink(with: viewProvider) {
      frameUpdater.displayLinkFired()
    }

    let player = FVPTextureBasedVideoPlayer(
      playerItem: item,
      frameUpdater: frameUpdater,
      displayLink: displayLink,
      avFactory: avFactory,
      viewProvider: viewProvider
    )

    let textureId = textureRegistry.register(player)
    player.setTextureIdentifier(textureId)

    let playerId = configurePlayer(player) { [weak self] in
      self?.textureRegistry.unregisterTexture(textureId)
    }

    return TexturePlayerIds(playerId: playerId, textureId: textureId)
  }

  func setMixWithOthers(_ mixWithOthers: Bool) throws {
    #if os(iOS)
      let session = avFactory.sharedAudioSession()
      if mixWithOthers {
        upgradeAudioSessionCategory(
          session: session,
          requestedCategory: session.category,
          options: .mixWithOthers,
          clearOptions: []
        )
      } else {
        upgradeAudioSessionCategory(
          session: session,
          requestedCategory: session.category,
          options: [],
          clearOptions: .mixWithOthers
        )
      }
    #endif
    // AVAudioSession doesn't exist on macOS, and audio always mixes, so just no-op.
  }

  func fileURLForAsset(name asset: String, package: String?) throws -> String? {
    let resource =
      if let package = package {
        assetProvider.lookupKey(forAsset: asset, fromPackage: package)
      } else {
        assetProvider.lookupKey(forAsset: asset)
      }

    var path = Bundle.main.path(forResource: resource, ofType: nil)
    #if os(macOS)
      // See https://github.com/flutter/flutter/issues/135302
      // TODO(stuartmorgan): Remove this if the asset APIs are adjusted to work better for macOS.
      if path == nil, let resource = resource {
        path = URL(string: resource, relativeTo: Bundle.main.bundleURL)?.path
      }
    #endif

    guard let validPath = path else {
      return nil
    }
    return URL(fileURLWithPath: validPath).absoluteString
  }

  // MARK: - Private

  private func configurePlayer(
    _ player: FVPVideoPlayer,
    extraDisposeHandler: (() -> Void)?
  ) -> Int64 {
    let playerId = nextPlayerIdentifier
    nextPlayerIdentifier += 1
    playersByIdentifier[playerId] = player

    let channelSuffix = "\(playerId)"
    // Set up the player-specific API handler, and its onDispose unregistration.
    SetUpFVPVideoPlayerInstanceApiWithSuffix(binaryMessenger, player, channelSuffix)

    player.onDisposed = { [weak self] in
      guard let strongSelf = self else { return }
      SetUpFVPVideoPlayerInstanceApiWithSuffix(strongSelf.binaryMessenger, nil, channelSuffix)
      extraDisposeHandler?()
      strongSelf.playersByIdentifier.removeValue(forKey: playerId)
    }

    // Set up the event channel.
    let eventBridge = FVPEventBridge(
      messenger: binaryMessenger,
      channelName: "flutter.dev/videoPlayer/videoEvents\(channelSuffix)"
    )
    player.eventListener = eventBridge

    return playerId
  }

  private func playerItem(with options: CreationOptions) throws -> FVPAVPlayerItem {
    let headers = options.httpHeaders
    let itemOptions = headers.isEmpty ? nil : ["AVURLAssetHTTPHeaderFieldsKey": headers]
    guard let url = URL(string: options.uri) else {
      throw PigeonError(code: "video_player", message: "Invalid URI", details: nil)
    }
    let asset = avFactory.urlAsset(with: url, options: itemOptions)
    return avFactory.playerItem(with: asset)
  }
}

#if os(iOS)
  // This function, although slightly modified, is also in camera_avfoundation.
  // Both need to do the same thing and run on the same thread (for example main thread).
  // Do not overwrite PlayAndRecord with Playback which causes inability to record
  // audio, do not overwrite all options.
  // Only change category if it is considered an upgrade which means it can only enable
  // ability to play in silent mode or ability to record audio but never disables it,
  // that could affect other plugins which depend on this global state. Only change
  // category or options if there is change to prevent unnecessary lags and silence.
  private func upgradeAudioSessionCategory(
    session: FVPAVAudioSession,
    requestedCategory: AVAudioSession.Category,
    options: AVAudioSession.CategoryOptions,
    clearOptions: AVAudioSession.CategoryOptions
  ) {
    let playCategories: Set<AVAudioSession.Category> = [.playback, .playAndRecord]
    let recordCategories: Set<AVAudioSession.Category> = [.record, .playAndRecord]
    let requiredCategories: Set<AVAudioSession.Category> = [requestedCategory, session.category]

    let requiresPlay = !requiredCategories.isDisjoint(with: playCategories)
    let requiresRecord = !requiredCategories.isDisjoint(with: recordCategories)

    var finalCategory = requestedCategory
    if requiresPlay && requiresRecord {
      finalCategory = .playAndRecord
    } else if requiresPlay {
      finalCategory = .playback
    } else if requiresRecord {
      finalCategory = .record
    }

    let newOptions = session.categoryOptions.subtracting(clearOptions).union(options)

    if finalCategory == session.category && newOptions == session.categoryOptions {
      return
    }

    try? session.setCategory(finalCategory, with: newOptions)
  }
#endif
