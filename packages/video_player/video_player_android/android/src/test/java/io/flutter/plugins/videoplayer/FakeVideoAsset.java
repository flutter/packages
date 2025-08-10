// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.test.utils.FakeMediaSourceFactory;

/** A fake implementation of the {@link VideoAsset} class. */
final class FakeVideoAsset extends VideoAsset {
  @NonNull private final MediaSource.Factory mediaSourceFactory;

  FakeVideoAsset(String assetUrl) {
    this(assetUrl, new FakeMediaSourceFactory());
  }

  FakeVideoAsset(String assetUrl, @NonNull MediaSource.Factory mediaSourceFactory) {
    super(assetUrl);
    this.mediaSourceFactory = mediaSourceFactory;
  }

  @NonNull
  @Override
  public MediaItem getMediaItem() {
    return new MediaItem.Builder().setUri(assetUrl).build();
  }

  @NonNull
  @Override
  public MediaSource.Factory getMediaSourceFactory(@NonNull Context context) {
    return mediaSourceFactory;
  }
}
