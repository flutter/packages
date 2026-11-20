// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

import android.content.Context
import androidx.annotation.OptIn
import androidx.media3.common.MediaItem
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.rtsp.RtspMediaSource
import androidx.media3.exoplayer.source.MediaSource

internal class RtspVideoAsset(assetUrl: String) : VideoAsset(assetUrl) {
  override val mediaItem: MediaItem
    get() = MediaItem.Builder().setUri(assetUrl).build()

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(UnstableApi::class)
  override fun getMediaSourceFactory(context: Context): MediaSource.Factory {
    return RtspMediaSource.Factory()
  }
}
