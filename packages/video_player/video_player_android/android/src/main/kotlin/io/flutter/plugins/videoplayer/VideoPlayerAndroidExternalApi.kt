// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.annotation.RestrictTo
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.source.MediaSource
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import java.util.WeakHashMap

/**
 * App and package facing native API provided by the `video_player_android` plugin.
 *
 * This class follows the convention of breaking changes of the Dart API, which means that any
 * changes to the class that are not backwards compatible will only be made with a major version
 * change of the plugin.
 *
 * Native code other than this external API does not follow breaking change conventions, so app or
 * plugin clients should not use any other native APIs.
 */
object VideoPlayerAndroidExternalApi {
  private const val TAG = "VideoPlayerExternalApi"

  /**
   * Providers by the binary messenger of the engine they were registered for.
   *
   * Weak keys let the entry of a destroyed engine be collected only if the provider does not itself
   * reference that engine, for example through its plugin's channels, so callers must still remove
   * their provider. Binary messengers do not override `equals`, so lookups are by identity.
   */
  private val providers = WeakHashMap<BinaryMessenger, MediaConfigProvider>()

  /**
   * Sets the [MediaConfigProvider] consulted for every player created in the engine that `binding`
   * belongs to.
   *
   * Only one provider is supported per engine. Setting a provider replaces any previously set one,
   * including one set by another package, and passing `null` removes whichever provider is current.
   *
   * This can be called from `onAttachedToEngine` regardless of whether `VideoPlayerPlugin` has been
   * attached to the engine yet, since the provider is only looked up when a player is created.
   *
   * The provider stays registered until it is replaced or removed, so callers must pass `null` from
   * their own `onDetachedFromEngine`; otherwise the provider and everything it references are kept
   * for the lifetime of the process.
   *
   * Removing a provider only affects players created afterwards. Players that already exist keep
   * using the [MediaConfig] they were given, so anything its [MediaConfig.mediaSourceFactory]
   * reads, such as a cache, must stay usable until those players are disposed.
   *
   * Can be called from any thread. A provider removed from another thread may still receive a call
   * that was already in progress.
   *
   * @param binding the binding of the calling plugin, which identifies the engine.
   * @param provider the provider, or `null` to remove the current one.
   */
  @JvmStatic
  fun setMediaConfigProvider(binding: FlutterPluginBinding, provider: MediaConfigProvider?) {
    val messenger = binding.binaryMessenger
    synchronized(providers) {
      if (provider == null) {
        providers.remove(messenger)
      } else {
        val previous = providers.put(messenger, provider)
        if (previous != null && previous !== provider) {
          Log.w(TAG, "Replacing the MediaConfigProvider previously set for this engine.")
        }
      }
    }
  }

  @JvmSynthetic
  internal fun getMediaConfigProvider(messenger: BinaryMessenger): MediaConfigProvider? {
    synchronized(providers) {
      return providers[messenger]
    }
  }

  /** Supplies the media configuration for players that the plugin should not configure itself. */
  fun interface MediaConfigProvider {
    /**
     * Returns the configuration to play `request` with, or `null` to let the plugin handle it as it
     * would without a provider.
     *
     * A returned configuration replaces all of the plugin's own loading setup for that player. That
     * includes applying [MediaConfigRequest.httpHeaders] and [MediaConfigRequest.userAgent] and
     * following cross-protocol redirects, so a provider whose media source can reach the network
     * must do those itself.
     *
     * Called on the platform thread while a player is being created, so this should not block. An
     * exception thrown here fails the creation of the player.
     */
    fun getMediaConfig(request: MediaConfigRequest): MediaConfig?
  }

  /** Describes a player that is about to be created. */
  class MediaConfigRequest
  private constructor(
      /** The application context. */
      val context: Context,
      /**
       * The URI of the video.
       *
       * For network, file, and content sources this is the URI the app supplied. For assets it is
       * `asset:///` followed by the asset's lookup key, for example
       * `asset:///flutter_assets/assets/video.mp4`.
       */
      val uri: String,
      /**
       * The MIME type implied by the app's format hint, such as
       * [androidx.media3.common.MimeTypes.APPLICATION_M3U8], or `null` if no hint was given.
       *
       * Media3 infers the format from the URI when a [MediaItem] has no MIME type, so set this on
       * the returned item to honor the hint.
       */
      val mimeType: String?,
      /** The HTTP headers the player was created with, as a read-only map. */
      val httpHeaders: Map<String, String>,
      /**
       * The user agent for HTTP requests.
       *
       * This is the `User-Agent` entry of [httpHeaders] if there is one, and otherwise the plugin's
       * default, currently `ExoPlayer`.
       */
      val userAgent: String?
  ) {
    // Requests are only created by the plugin. The factory is hidden from Java, so adding a field
    // cannot break code that constructs requests.
    @RestrictTo(RestrictTo.Scope.LIBRARY)
    internal companion object {
      @JvmSynthetic
      internal fun create(
          context: Context,
          uri: String,
          mimeType: String?,
          httpHeaders: Map<String, String>,
          userAgent: String?
      ): MediaConfigRequest = MediaConfigRequest(context, uri, mimeType, httpHeaders, userAgent)
    }
  }

  // Any field added later must have a default value and be added together with @JvmOverloads, so
  // that Java callers of this two-argument constructor keep working.
  /** The media a player should play, and how to load it. */
  class MediaConfig(
      /** The media item to play. */
      val mediaItem: MediaItem,
      /**
       * The factory used to create the media source for [mediaItem].
       *
       * Return a new factory for each request rather than sharing one between players. Media3
       * factories hold per-player state; for example, a shared factory fails DRM playback in every
       * player after the first. Data source factories and caches can be shared.
       */
      val mediaSourceFactory: MediaSource.Factory
  )
}
