// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.MediaItem;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.rtsp.RtspMediaSource;
import androidx.media3.exoplayer.source.MediaSource;

final class RtspVideoAsset extends VideoAsset {
  RtspVideoAsset(@NonNull String assetUrl) {
    super(assetUrl);
  }

  @NonNull
  @Override
  MediaItem getMediaItem() {
    return new MediaItem.Builder().setUri(assetUrl).build();
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(markerClass = UnstableApi.class)
  @Override
  MediaSource.Factory getMediaSourceFactory(Context context) {
    return new RtspMediaSource.Factory();
  }
}
