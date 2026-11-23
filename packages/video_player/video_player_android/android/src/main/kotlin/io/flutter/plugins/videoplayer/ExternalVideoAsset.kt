// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.source.MediaSource

/** An asset configured by a [VideoPlayerAndroidExternalApi.MediaConfigProvider]. */
internal class ExternalVideoAsset(
    assetUrl: String,
    private val config: VideoPlayerAndroidExternalApi.MediaConfig
) : VideoAsset(assetUrl) {
  override val mediaItem: MediaItem
    get() = config.mediaItem

  override fun getMediaSourceFactory(context: Context): MediaSource.Factory {
    return config.mediaSourceFactory
  }
}
