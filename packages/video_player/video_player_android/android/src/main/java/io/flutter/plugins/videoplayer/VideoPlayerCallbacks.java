// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Callbacks representing events invoked by {@link VideoPlayer}.
 *
 * <p>In the actual plugin, this will always be {@link VideoPlayerEventCallbacks}, which creates the
 * expected events to send back through the plugin channel. In tests methods can be overridden in
 * order to assert results.
 *
 * <p>See {@link androidx.media3.common.Player.Listener} for details.
 */
public interface VideoPlayerCallbacks {
  void onInitialized(int width, int height, long durationInMs, int rotationCorrectionInDegrees);

  void onReloadingStart();

  void onReloadingEnd(int width, int height, long durationInMs, @Nullable Long textureId);

  /**
   * The player has rendered a frame to its surface for the first time since that surface was set.
   *
   * <p>Sent again after every {@code loadAsset}, because loading gives the player a new surface.
   */
  void onRenderedFirstFrame();

  void onPlaybackStateChanged(@NonNull PlatformPlaybackState state);

  void onError(@NonNull String code, @Nullable String message, @Nullable Object details);

  void onIsPlayingStateUpdate(boolean isPlaying);

  void onAudioTrackChanged(@Nullable String selectedTrackId);
}
