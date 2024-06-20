// Copyright 2013 The Flutter Authors. All rights reserved.
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
interface VideoPlayerCallbacks {
  void onInitialized(int width, int height, long durationInMs, int rotationCorrectionInDegrees);

  void onBufferingStart();

  void onBufferingUpdate(long bufferedPosition);

  void onBufferingEnd();

  void onCompleted();

  void onError(@NonNull String code, @Nullable String message, @Nullable Object details);

  void onIsPlayingStateUpdate(boolean isPlaying);
}
