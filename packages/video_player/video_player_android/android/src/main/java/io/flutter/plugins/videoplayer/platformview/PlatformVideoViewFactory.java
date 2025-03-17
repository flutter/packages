// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugins.videoplayer.Messages;
import io.flutter.plugins.videoplayer.VideoPlayer;
import java.util.Objects;

/**
 * A factory class responsible for creating platform video views that can be embedded in a Flutter
 * app.
 */
public class PlatformVideoViewFactory extends PlatformViewFactory {
  private final VideoPlayerProvider videoPlayerProvider;

  /** Functional interface for providing a VideoPlayer instance based on the player ID. */
  @FunctionalInterface
  public interface VideoPlayerProvider {
    /**
     * Retrieves a VideoPlayer instance based on the provided player ID.
     *
     * @param playerId The unique identifier for the video player.
     * @return A VideoPlayer instance associated with the given player ID.
     */
    @NonNull
    VideoPlayer getVideoPlayer(@NonNull Long playerId);
  }

  /**
   * Constructs a new PlatformVideoViewFactory.
   *
   * @param videoPlayerProvider The provider used to retrieve the video player associated with the
   *     view.
   */
  public PlatformVideoViewFactory(@NonNull VideoPlayerProvider videoPlayerProvider) {
    super(Messages.AndroidVideoPlayerApi.getCodec());
    this.videoPlayerProvider = videoPlayerProvider;
  }

  /**
   * Creates a new instance of platform view.
   *
   * @param context The context in which the view is running.
   * @param id The unique identifier for the view.
   * @param args The arguments for creating the view.
   * @return A new instance of PlatformVideoView.
   */
  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
    final Messages.PlatformVideoViewCreationParams params =
        Objects.requireNonNull((Messages.PlatformVideoViewCreationParams) args);
    final Long playerId = params.getPlayerId();

    final VideoPlayer player = videoPlayerProvider.getVideoPlayer(playerId);
    final ExoPlayer exoPlayer = player.getExoPlayer();

    return new PlatformVideoView(context, exoPlayer);
  }
}
