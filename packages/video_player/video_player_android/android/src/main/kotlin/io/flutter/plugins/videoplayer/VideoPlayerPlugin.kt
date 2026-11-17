// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import android.util.LongSparseArray
import androidx.annotation.VisibleForTesting
import androidx.core.util.forEach
import androidx.core.util.isEmpty
import io.flutter.FlutterInjector
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.videoplayer.AndroidVideoPlayerApi.Companion.setUp
import io.flutter.plugins.videoplayer.VideoPlayerInstanceApi.Companion.setUp
import io.flutter.plugins.videoplayer.platformview.PlatformVideoViewFactory
import io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer
import io.flutter.plugins.videoplayer.texture.TextureVideoPlayer
import io.flutter.view.TextureRegistry
import io.flutter.view.TextureRegistry.SurfaceProducer

internal typealias PlatformViewPlayerConstructor =
    (
        context: Context,
        events: VideoPlayerCallbacks,
        asset: VideoAsset,
        options: VideoPlayerOptions) -> PlatformViewVideoPlayer

internal typealias TexturePlayerConstructor =
    (
        context: Context,
        events: VideoPlayerCallbacks,
        surfaceProducer: SurfaceProducer,
        asset: VideoAsset,
        options: VideoPlayerOptions) -> TextureVideoPlayer

/** Android platform implementation of the VideoPlayerPlugin. */
class VideoPlayerPlugin
/** Register this with the v2 embedding for the plugin to respond to lifecycle callbacks. */
: FlutterPlugin, AndroidVideoPlayerApi {
  private val videoPlayers = LongSparseArray<VideoPlayer>()
  private var flutterState: FlutterState? = null
  private val sharedOptions = VideoPlayerOptions()
  private var nextPlayerIdentifier: Long = 1

  private val createPlatformViewPlayer: PlatformViewPlayerConstructor
  private val createTexturePlayer: TexturePlayerConstructor

  constructor() : this(null, null)

  @VisibleForTesting
  internal constructor(
      createPlatformViewPlayer: PlatformViewPlayerConstructor?,
      createTexturePlayer: TexturePlayerConstructor?
  ) {
    this.createPlatformViewPlayer = createPlatformViewPlayer ?: PlatformViewVideoPlayer::create
    this.createTexturePlayer = createTexturePlayer ?: TextureVideoPlayer::create
  }

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    val injector = FlutterInjector.instance()
    val flutterState =
        FlutterState(
            binding.applicationContext,
            binding.binaryMessenger,
            { asset: String -> injector.flutterLoader().getLookupKeyForAsset(asset) },
            { asset: String, packageName: String ->
              injector.flutterLoader().getLookupKeyForAsset(asset, packageName)
            },
            binding.textureRegistry)
    this.flutterState = flutterState
    flutterState.startListening(this, binding.binaryMessenger)

    binding.platformViewRegistry.registerViewFactory(
        "plugins.flutter.dev/video_player_android", PlatformVideoViewFactory(videoPlayers::get))
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    if (flutterState == null) {
      Log.wtf(TAG, "Detached from the engine before registering to it.")
    }
    flutterState?.stopListening(binding.binaryMessenger)
    flutterState = null
    onDestroy()
  }

  private fun disposeAllPlayers() {
    videoPlayers.forEach { _, value -> value.dispose() }
    videoPlayers.clear()
  }

  // TODO(stuartmorgan): Fix the fact that this is called directly from an integration test, and
  //   make it private.
  @VisibleForTesting
  fun onDestroy() {
    // The whole FlutterView is being destroyed. Here we release resources acquired for all
    // instances
    // of VideoPlayer. Once https://github.com/flutter/flutter/issues/19358 is resolved this may
    // be replaced with just asserting that videoPlayers.isEmpty().
    // https://github.com/flutter/flutter/issues/20989 tracks this.
    disposeAllPlayers()
  }

  override fun initialize() {
    disposeAllPlayers()
  }

  override fun createForPlatformView(options: CreationOptions): Long {
    val flutterState =
        this.flutterState
            ?: throw IllegalStateException("Cannot create a player when no engine is attached")
    val videoAsset = videoAssetWithOptions(options)

    val id = nextPlayerIdentifier++
    val streamInstance = id.toString()
    val playerOptions = VideoPlayerOptions(sharedOptions)
    playerOptions.backBufferDurationMs = options.backBufferDurationMs

    val videoPlayer: VideoPlayer =
        createPlatformViewPlayer(
            flutterState.applicationContext,
            VideoPlayerEventCallbacks.bindTo(flutterState.binaryMessenger, streamInstance),
            videoAsset,
            playerOptions)

    registerPlayerInstance(videoPlayer, id, flutterState.binaryMessenger)
    return id
  }

  override fun createForTextureView(options: CreationOptions): TexturePlayerIds {
    val flutterState =
        this.flutterState
            ?: throw IllegalStateException("Cannot create a player when no engine is attached")
    val videoAsset = videoAssetWithOptions(options)

    val id = nextPlayerIdentifier++
    val streamInstance = id.toString()
    val handle = flutterState.textureRegistry.createSurfaceProducer()
    val playerOptions = VideoPlayerOptions(sharedOptions)
    playerOptions.backBufferDurationMs = options.backBufferDurationMs

    val videoPlayer: VideoPlayer =
        createTexturePlayer(
            flutterState.applicationContext,
            VideoPlayerEventCallbacks.bindTo(flutterState.binaryMessenger, streamInstance),
            handle,
            videoAsset,
            playerOptions)

    registerPlayerInstance(videoPlayer, id, flutterState.binaryMessenger)
    return TexturePlayerIds(id, handle.id())
  }

  private fun videoAssetWithOptions(options: CreationOptions): VideoAsset {
    val uri = options.uri
    if (uri.startsWith("asset:")) {
      return VideoAsset.fromAssetUrl(uri)
    } else if (uri.startsWith("rtsp:")) {
      return VideoAsset.fromRtspUrl(uri)
    } else {
      val streamingFormat =
          when (options.formatHint) {
            PlatformVideoFormat.SS -> VideoAsset.StreamingFormat.SMOOTH
            PlatformVideoFormat.DASH -> VideoAsset.StreamingFormat.DYNAMIC_ADAPTIVE
            PlatformVideoFormat.HLS -> VideoAsset.StreamingFormat.HTTP_LIVE
            null -> VideoAsset.StreamingFormat.UNKNOWN
          }
      return VideoAsset.fromRemoteUrl(uri, streamingFormat, options.httpHeaders, options.userAgent)
    }
  }

  private fun registerPlayerInstance(player: VideoPlayer, id: Long, messenger: BinaryMessenger) {
    // Set up the instance-specific API handler, and make sure it is removed when the player is
    // disposed.
    val channelSuffix = id.toString()
    setUp(messenger, player, channelSuffix)
    player.setDisposeHandler { VideoPlayerInstanceApi.setUp(messenger, null, channelSuffix) }

    videoPlayers.put(id, player)
  }

  private fun getPlayer(playerId: Long): VideoPlayer {
    val player = videoPlayers.get(playerId)

    // Avoid a very ugly un-debuggable NPE that results in returning a null player.
    if (player == null) {
      var message = "No player found with playerId <$playerId>"
      if (videoPlayers.isEmpty()) {
        message += " and no active players created by the plugin."
      }
      throw IllegalStateException(message)
    }

    return player
  }

  override fun dispose(playerId: Long) {
    val player = getPlayer(playerId)
    player.dispose()
    videoPlayers.remove(playerId)
  }

  override fun setMixWithOthers(mixWithOthers: Boolean) {
    sharedOptions.mixWithOthers = mixWithOthers
  }

  override fun getLookupKeyForAsset(asset: String, packageName: String?): String {
    flutterState?.let {
      return (if (packageName == null) it.keyForAsset(asset)
      else it.keyForAssetAndPackageName(asset, packageName))
    }
    Log.wtf(TAG, "Called lookupKeyForAsset without an engine attached.")
    return ""
  }

  private class FlutterState(
      val applicationContext: Context,
      val binaryMessenger: BinaryMessenger,
      val keyForAsset: (String) -> String,
      val keyForAssetAndPackageName: (asset: String, packageName: String) -> String,
      val textureRegistry: TextureRegistry
  ) {
    fun startListening(methodCallHandler: VideoPlayerPlugin?, messenger: BinaryMessenger) {
      setUp(messenger, methodCallHandler)
    }

    fun stopListening(messenger: BinaryMessenger) {
      AndroidVideoPlayerApi.setUp(messenger, null)
    }
  }

  companion object {
    private const val TAG = "VideoPlayerPlugin"
  }
}
