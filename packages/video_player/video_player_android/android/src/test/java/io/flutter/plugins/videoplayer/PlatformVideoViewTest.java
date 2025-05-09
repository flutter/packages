// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.view.SurfaceView;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.platformview.PlatformVideoView;
import java.lang.reflect.Field;
import org.junit.Test;

/** Unit tests for {@link PlatformVideoViewTest}. */
public class PlatformVideoViewTest {
  @Test
  public void createsSurfaceViewAndSetsItForExoPlayer() throws Exception {
    final Context mockContext = mock(Context.class);
    final ExoPlayer mockExoPlayer = mock(ExoPlayer.class);

    final PlatformVideoView view = new PlatformVideoView(mockContext, mockExoPlayer);

    final Field field = PlatformVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    final SurfaceView surfaceView = (SurfaceView) field.get(view);

    assertNotNull(surfaceView);
    verify(mockExoPlayer).setVideoSurfaceView(surfaceView);
  }
}
