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

#if canImport(video_player_avfoundation_objc)
  import video_player_avfoundation_objc
#endif

/// A factory class responsible for creating native video views that can be embedded in a
/// Flutter app.
final class NativeVideoViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger
  private let playerByIdentifierProvider: (Int64) -> FVPVideoPlayer?

  /// Initializes a new instance of NativeVideoViewFactory with the given messenger and
  /// a block that provides video players associated with their identifiers.
  init(
    messenger: FlutterBinaryMessenger,
    playerByIdentifierProvider: @escaping (Int64) -> FVPVideoPlayer?
  ) {
    self.messenger = messenger
    self.playerByIdentifierProvider = playerByIdentifierProvider
    super.init()
  }

  #if os(macOS)
    func create(
      withViewIdentifier viewIdentifier: Int64,
      arguments: Any?
    ) -> NSView {
      return createNativeVideoView(arguments: arguments as! PlatformVideoViewCreationParams)
    }
  #elseif os(iOS)
    func create(
      withFrame frame: CGRect,
      viewIdentifier: Int64,
      arguments: Any?
    ) -> FlutterPlatformView {
      return createNativeVideoView(arguments: arguments as! PlatformVideoViewCreationParams)
    }
  #endif

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return VideoPlayerPluginMessagesPigeonCodec.shared
  }

  /// Creates a native video view for the given arguments.
  private func createNativeVideoView(
    arguments args: PlatformVideoViewCreationParams
  ) -> FVPNativeVideoView {
    // The Dart code should never attempt to create a platform view for a player that doesn't exist,
    // and there's no mechanism to report an error, so just force-unwrap.
    let player = playerByIdentifierProvider(args.playerId)!
    return FVPNativeVideoView(player: player.player)
  }
}
