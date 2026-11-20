// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.source.MediaSource

/** A video to be played by [VideoPlayer]. */
internal abstract class VideoAsset
protected constructor(@JvmField protected val assetUrl: String?) {
  /**
   * Returns the configured media item to be played.
   *
   * @return media item.
   */
  abstract val mediaItem: MediaItem

  /**
   * Returns the configured media source factory, if needed for this asset type.
   *
   * @param context application context.
   * @return configured factory, or `null` if not needed for this asset type.
   */
  abstract fun getMediaSourceFactory(context: Context): MediaSource.Factory

  /** Streaming formats that can be provided to the video player as a hint. */
  internal enum class StreamingFormat {
    /** Default, if the format is either not known or not another valid format. */
    UNKNOWN,

    /** Smooth Streaming. */
    SMOOTH,

    /** MPEG-DASH (Dynamic Adaptive over HTTP). */
    DYNAMIC_ADAPTIVE,

    /** HTTP Live Streaming (HLS). */
    HTTP_LIVE
  }

  companion object {
    /**
     * Returns an asset from a local `asset:///` URL, i.e. an on-device asset.
     *
     * @param assetUrl local asset, beginning in `asset:///`.
     * @return the asset.
     */
    fun fromAssetUrl(assetUrl: String): VideoAsset {
      require(assetUrl.startsWith("asset:///")) { "assetUrl must start with 'asset:///'" }
      return LocalVideoAsset(assetUrl)
    }

    /**
     * Returns an asset from a remote URL.
     *
     * @param remoteUrl remote asset, i.e. typically beginning with `https://` or similar.
     * @param streamingFormat which streaming format, provided as a hint if able.
     * @param httpHeaders HTTP headers to set for a request.
     * @return the asset.
     */
    fun fromRemoteUrl(
        remoteUrl: String?,
        streamingFormat: StreamingFormat,
        httpHeaders: Map<String, String>,
        userAgent: String?
    ): VideoAsset {
      return HttpVideoAsset(
          remoteUrl, streamingFormat, HashMap<String, String>(httpHeaders), userAgent)
    }

    /**
     * Returns an asset from a RTSP URL.
     *
     * @param rtspUrl remote asset, beginning with `rtsp://`.
     * @return the asset.
     */
    fun fromRtspUrl(rtspUrl: String): VideoAsset {
      require(rtspUrl.startsWith("rtsp://")) { "rtspUrl must start with 'rtsp://'" }
      return RtspVideoAsset(rtspUrl)
    }
  }
}
