// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.view.SurfaceView;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugins.videoplayer.platformview.PlatformVideoView;
import java.lang.reflect.Field;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

/** Unit tests for {@link PlatformVideoView}. */
// Runs under Robolectric because instrumenting the ExoPlayer interface -- to mock it, or to build
// one -- initializes supertypes that need an Android runtime.
@RunWith(RobolectricTestRunner.class)
public class PlatformVideoViewTest {
  @Test
  public void createsSurfaceViewAndSetsItForExoPlayer() throws Exception {
    final Context context = ApplicationProvider.getApplicationContext();
    final ExoPlayer mockExoPlayer = mock(ExoPlayer.class);

    final PlatformVideoView view = new PlatformVideoView(context, mockExoPlayer);

    final Field field = PlatformVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    final SurfaceView surfaceView = (SurfaceView) field.get(view);

    assertNotNull(surfaceView);
    verify(mockExoPlayer).setVideoSurfaceView(surfaceView);
  }
}
