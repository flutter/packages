// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.media3.common.MediaItem
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.exoplayer.source.MediaSource

internal class LocalVideoAsset(assetUrl: String) : VideoAsset(assetUrl) {
  override val mediaItem: MediaItem
    get() = MediaItem.Builder().setUri(assetUrl).build()

  override fun getMediaSourceFactory(context: Context): MediaSource.Factory {
    return DefaultMediaSourceFactory(context)
  }
}
