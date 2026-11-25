// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.annotation.OptIn
import androidx.annotation.VisibleForTesting
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.UnstableApi
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.source.MediaSource

internal class HttpVideoAsset(
    assetUrl: String?,
    private val streamingFormat: StreamingFormat,
    private val httpHeaders: Map<String, String>,
    private val userAgent: String?
) : VideoAsset(assetUrl) {
  override val mediaItem: MediaItem
    get() {
      val builder = MediaItem.Builder().setUri(assetUrl)
      val mimeType: String? =
          when (streamingFormat) {
            StreamingFormat.SMOOTH -> MimeTypes.APPLICATION_SS
            StreamingFormat.DYNAMIC_ADAPTIVE -> MimeTypes.APPLICATION_MPD
            StreamingFormat.HTTP_LIVE -> MimeTypes.APPLICATION_M3U8
            else -> null
          }
      if (mimeType != null) {
        builder.setMimeType(mimeType)
      }
      return builder.build()
    }

  override fun getMediaSourceFactory(context: Context): MediaSource.Factory {
    return getMediaSourceFactory(context, DefaultHttpDataSource.Factory())
  }

  /**
   * Returns a configured media source factory, starting at the provided factory.
   *
   * This method is provided for ease of testing without making real HTTP calls.
   *
   * @param context application context.
   * @param initialFactory initial factory, to be configured.
   * @return configured factory, or `null` if not needed for this asset type.
   */
  @VisibleForTesting
  fun getMediaSourceFactory(
      context: Context,
      initialFactory: DefaultHttpDataSource.Factory
  ): MediaSource.Factory {
    unstableUpdateDataSourceFactory(initialFactory, httpHeaders, userAgent)
    val dataSourceFactory: DataSource.Factory = DefaultDataSource.Factory(context, initialFactory)
    return DefaultMediaSourceFactory(context).setDataSourceFactory(dataSourceFactory)
  }

  private companion object {
    // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
    @OptIn(UnstableApi::class)
    fun unstableUpdateDataSourceFactory(
        factory: DefaultHttpDataSource.Factory,
        httpHeaders: Map<String, String>,
        userAgent: String?
    ) {
      factory.setUserAgent(userAgent).setAllowCrossProtocolRedirects(true)
      if (httpHeaders.isNotEmpty()) {
        factory.setDefaultRequestProperties(httpHeaders)
      }
    }
  }
}
