// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.exoplayer.ExoPlayer;

/**
 * Internal state representing an {@link ExoPlayer} instance at a snapshot in time.
 *
 * <p>During the Android application lifecycle, the underlying {@link android.view.Surface} being
 * rendered to by the player can be destroyed when the application is in the background and memory
 * is reclaimed. Upon <em>resume</em>, the player will need to be recreated, but start again at the
 * previous point (and settings).
 */
public final class ExoPlayerState {
  /**
   * Saves a representation of the current state of the player at the current point in time.
   *
   * <p>The inverse of this operation is {@link #restore(ExoPlayer)}.
   *
   * @param exoPlayer the active player instance.
   * @return an opaque object representing the state.
   */
  @NonNull
  public static ExoPlayerState save(@NonNull ExoPlayer exoPlayer) {
    return new ExoPlayerState(
        /* position= */ exoPlayer.getCurrentPosition(),
        /* repeatMode= */ exoPlayer.getRepeatMode(),
        /* volume= */ exoPlayer.getVolume(),
        /* playbackParameters= */ exoPlayer.getPlaybackParameters());
  }

  private ExoPlayerState(
      long position, int repeatMode, float volume, PlaybackParameters playbackParameters) {
    this.position = position;
    this.repeatMode = repeatMode;
    this.volume = volume;
    this.playbackParameters = playbackParameters;
  }

  /** Previous value of {@link ExoPlayer#getCurrentPosition()}. */
  private final long position;

  /** Previous value of {@link ExoPlayer#getRepeatMode()}. */
  private final int repeatMode;

  /** Previous value of {@link ExoPlayer#getVolume()}. */
  private final float volume;

  /** Previous value of {@link ExoPlayer#getPlaybackParameters()}. */
  private final PlaybackParameters playbackParameters;

  /**
   * Restores the captured state onto the provided player.
   *
   * <p>This will typically be done after creating a new player, setting up a media source, and
   * listening to events.
   *
   * @param exoPlayer the new player instance to reflect the state back to.
   */
  public void restore(@NonNull ExoPlayer exoPlayer) {
    exoPlayer.seekTo(position);
    exoPlayer.setRepeatMode(repeatMode);
    exoPlayer.setVolume(volume);
    exoPlayer.setPlaybackParameters(playbackParameters);
  }
}
