// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import android.util.LongSparseArray;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Objects;

class NativeViewFactory extends PlatformViewFactory {
  private final LongSparseArray<VideoPlayer> videoPlayers;

  NativeViewFactory(LongSparseArray<VideoPlayer> videoPlayers) {
    super(Messages.AndroidVideoPlayerApi.getCodec());
    this.videoPlayers = videoPlayers;
  }

  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
    final Messages.PlatformVideoViewCreationParams params =
        Objects.requireNonNull((Messages.PlatformVideoViewCreationParams) args);
    final Long playerId = params.getPlayerId();

    final VideoPlayer player = videoPlayers.get(playerId);
    final ExoPlayer exoPlayer = player.getExoPlayer();

    return new NativeView(context, exoPlayer);
  }
}
