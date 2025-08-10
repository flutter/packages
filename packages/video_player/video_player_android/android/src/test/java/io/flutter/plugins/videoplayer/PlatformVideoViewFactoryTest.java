// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.*;

import android.content.Context;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugins.videoplayer.platformview.PlatformVideoView;
import io.flutter.plugins.videoplayer.platformview.PlatformVideoViewFactory;
import org.junit.Test;

public class PlatformVideoViewFactoryTest {
  @Test
  public void createsPlatformVideoViewBasedOnSuppliedArguments() {
    final PlatformVideoViewFactory.VideoPlayerProvider videoPlayerProvider =
        mock(PlatformVideoViewFactory.VideoPlayerProvider.class);
    final VideoPlayer videoPlayer = mock(VideoPlayer.class);
    final ExoPlayer exoPlayer = mock(ExoPlayer.class);
    final Context context = mock(Context.class);
    final long playerId = 1L;

    when(videoPlayerProvider.getVideoPlayer(playerId)).thenReturn(videoPlayer);
    when(videoPlayer.getExoPlayer()).thenReturn(exoPlayer);

    final PlatformVideoViewFactory factory = new PlatformVideoViewFactory(videoPlayerProvider);
    final Messages.PlatformVideoViewCreationParams args =
        new Messages.PlatformVideoViewCreationParams.Builder().setPlayerId(playerId).build();

    final PlatformView view = factory.create(context, 0, args);

    assertTrue(view instanceof PlatformVideoView);
    verify(videoPlayerProvider).getVideoPlayer(playerId);
    verify(videoPlayer).getExoPlayer();
  }
}
