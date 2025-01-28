// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Objects;

/**
 * A factory class responsible for creating native video views that can be embedded in a Flutter
 * app.
 */
class NativeVideoViewFactory extends PlatformViewFactory {
  private final VideoPlayerProvider videoPlayerProvider;

  /**
   * Constructs a new NativeVideoViewFactory.
   *
   * @param videoPlayerProvider The provider used to retrieve the video player associated with the
   *     view.
   */
  public NativeVideoViewFactory(@NonNull VideoPlayerProvider videoPlayerProvider) {
    super(Messages.AndroidVideoPlayerApi.getCodec());
    this.videoPlayerProvider = videoPlayerProvider;
  }

  /**
   * Creates a new instance of platform view.
   *
   * @param context The context in which the view is running.
   * @param id The unique identifier for the view.
   * @param args The arguments for creating the view.
   * @return A new instance of NativeVideoView.
   */
  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
    final Messages.PlatformVideoViewCreationParams params =
        Objects.requireNonNull((Messages.PlatformVideoViewCreationParams) args);
    final Long playerId = params.getPlayerId();

    final VideoPlayer player = videoPlayerProvider.getVideoPlayer(playerId);
    final ExoPlayer exoPlayer = player.getExoPlayer();

    return new NativeVideoView(context, exoPlayer);
  }
}
