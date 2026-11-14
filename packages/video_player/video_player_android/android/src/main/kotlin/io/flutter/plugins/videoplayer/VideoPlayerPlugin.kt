// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import android.util.LongSparseArray
import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import io.flutter.FlutterInjector
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugins.videoplayer.AndroidVideoPlayerApi.Companion.setUp
import io.flutter.plugins.videoplayer.VideoPlayer.DisposeHandler
import io.flutter.plugins.videoplayer.VideoPlayerInstanceApi.Companion.setUp
import io.flutter.plugins.videoplayer.platformview.PlatformVideoViewFactory
import io.flutter.plugins.videoplayer.platformview.PlatformVideoViewFactory.VideoPlayerProvider
import io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer
import io.flutter.plugins.videoplayer.texture.TextureVideoPlayer
import io.flutter.view.TextureRegistry

/** Android platform implementation of the VideoPlayerPlugin. */
class VideoPlayerPlugin
/** Register this with the v2 embedding for the plugin to respond to lifecycle callbacks. */
: FlutterPlugin, AndroidVideoPlayerApi {
  private val videoPlayers = LongSparseArray<VideoPlayer?>()
  private var flutterState: FlutterState? = null
  private val sharedOptions = VideoPlayerOptions()
  private var nextPlayerIdentifier: Long = 1

  override fun onAttachedToEngine(binding: FlutterPluginBinding) {
    val injector = FlutterInjector.instance()
    this.flutterState =
        FlutterState(
            binding.getApplicationContext(),
            binding.getBinaryMessenger(),
            KeyForAssetFn { asset: String? ->
              injector.flutterLoader().getLookupKeyForAsset(asset!!)
            },
            KeyForAssetAndPackageName { asset: String?, packageName: String? ->
              injector.flutterLoader().getLookupKeyForAsset(asset!!, packageName!!)
            },
            binding.getTextureRegistry())
    flutterState!!.startListening(this, binding.getBinaryMessenger())

    binding
        .getPlatformViewRegistry()
        .registerViewFactory(
            "plugins.flutter.dev/video_player_android",
            PlatformVideoViewFactory(
                VideoPlayerProvider { key: Long? -> videoPlayers.get(key!!)!! }))
  }

  override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
    if (flutterState == null) {
      Log.wtf(TAG, "Detached from the engine before registering to it.")
    }
    flutterState!!.stopListening(binding.getBinaryMessenger())
    flutterState = null
    onDestroy()
  }

  private fun disposeAllPlayers() {
    for (i in 0 ..< videoPlayers.size()) {
      videoPlayers.valueAt(i)!!.dispose()
    }
    videoPlayers.clear()
  }

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

  @OptIn(markerClass = UnstableApi::class)
  override fun createForPlatformView(options: CreationOptions): Long {
    val videoAsset = videoAssetWithOptions(options)

    val id = nextPlayerIdentifier++
    val streamInstance = id.toString()
    val playerOptions = VideoPlayerOptions(sharedOptions)
    playerOptions.backBufferDurationMs = options.backBufferDurationMs

    val videoPlayer: VideoPlayer =
        PlatformViewVideoPlayer.create(
            flutterState!!.applicationContext,
            VideoPlayerEventCallbacks.bindTo(flutterState!!.binaryMessenger, streamInstance),
            videoAsset,
            playerOptions)

    registerPlayerInstance(videoPlayer, id)
    return id
  }

  @OptIn(markerClass = UnstableApi::class)
  override fun createForTextureView(options: CreationOptions): TexturePlayerIds {
    val videoAsset = videoAssetWithOptions(options)

    val id = nextPlayerIdentifier++
    val streamInstance = id.toString()
    val handle = flutterState!!.textureRegistry.createSurfaceProducer()
    val playerOptions = VideoPlayerOptions(sharedOptions)
    playerOptions.backBufferDurationMs = options.backBufferDurationMs

    val videoPlayer: VideoPlayer =
        TextureVideoPlayer.create(
            flutterState!!.applicationContext,
            VideoPlayerEventCallbacks.bindTo(flutterState!!.binaryMessenger, streamInstance),
            handle,
            videoAsset,
            playerOptions)

    registerPlayerInstance(videoPlayer, id)
    return TexturePlayerIds(id, handle.id())
  }

  private fun videoAssetWithOptions(options: CreationOptions): VideoAsset {
    val uri = options.uri
    if (uri.startsWith("asset:")) {
      return VideoAsset.fromAssetUrl(uri)
    } else if (uri.startsWith("rtsp:")) {
      return VideoAsset.fromRtspUrl(uri)
    } else {
      var streamingFormat = VideoAsset.StreamingFormat.UNKNOWN
      val formatHint = options.formatHint
      if (formatHint != null) {
        when (formatHint) {
          PlatformVideoFormat.SS -> streamingFormat = VideoAsset.StreamingFormat.SMOOTH
          PlatformVideoFormat.DASH -> streamingFormat = VideoAsset.StreamingFormat.DYNAMIC_ADAPTIVE
          PlatformVideoFormat.HLS -> streamingFormat = VideoAsset.StreamingFormat.HTTP_LIVE
        }
      }
      return VideoAsset.fromRemoteUrl(uri, streamingFormat, options.httpHeaders, options.userAgent)
    }
  }

  private fun registerPlayerInstance(player: VideoPlayer, id: Long) {
    // Set up the instance-specific API handler, and make sure it is removed when the player is
    // disposed.
    val messenger = flutterState!!.binaryMessenger
    val channelSuffix = id.toString()
    setUp(messenger, player, channelSuffix)
    player.setDisposeHandler(
        DisposeHandler { VideoPlayerInstanceApi.setUp(messenger, null, channelSuffix) })

    videoPlayers.put(id, player)
  }

  private fun getPlayer(playerId: Long): VideoPlayer {
    val player = videoPlayers.get(playerId)

    // Avoid a very ugly un-debuggable NPE that results in returning a null player.
    if (player == null) {
      var message = "No player found with playerId <" + playerId + ">"
      if (videoPlayers.size() == 0) {
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
    return (if (packageName == null) flutterState.keyForAsset.get(asset)
    else flutterState.keyForAssetAndPackageName.get(asset, packageName))!!
  }

  private interface KeyForAssetFn {
    fun get(asset: String?): String
  }

  private interface KeyForAssetAndPackageName {
    fun get(asset: String?, packageName: String?): String?
  }

  private class FlutterState(
      val applicationContext: Context,
      val binaryMessenger: BinaryMessenger,
      val keyForAsset: KeyForAssetFn,
      val keyForAssetAndPackageName: KeyForAssetAndPackageName,
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
