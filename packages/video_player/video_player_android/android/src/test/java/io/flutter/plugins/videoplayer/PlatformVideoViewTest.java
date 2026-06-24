// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.os.Build;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugins.videoplayer.platformview.PlatformVideoView;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Objects;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.Shadows;
import org.robolectric.annotation.Config;
import org.robolectric.shadows.ShadowSurfaceView;

/** Unit tests for {@link PlatformVideoView}. */
@RunWith(RobolectricTestRunner.class)
public class PlatformVideoViewTest {

  @Test
  @Config(sdk = 34)
  public void surfaceCreatedBindsSurfaceWithoutSeekOutsideAndroid9() throws Exception {
    final Context context = ApplicationProvider.getApplicationContext();
    final ExoPlayer exoPlayer = mock(ExoPlayer.class);

    final PlatformVideoView view = new PlatformVideoView(context, exoPlayer);

    // Get the internal SurfaceView via reflection for testing.
    final Field field = PlatformVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    final SurfaceView surfaceView = (SurfaceView) field.get(view);

    // Bypass FakeSurfaceHolder to get the callback registered by PlatformVideoView
    ShadowSurfaceView shadowView = Shadows.shadowOf(surfaceView);
    Iterable<SurfaceHolder.Callback> callbacks = shadowView.getFakeSurfaceHolder().getCallbacks();
    assertNotNull("SurfaceCallbacks should not be null", callbacks);

    SurfaceHolder.Callback callback = callbacks.iterator().next();
    assertNotNull("Callback must exist", callback);

    Surface mockSurface = mock(Surface.class);
    when(mockSurface.isValid()).thenReturn(true);
    SurfaceHolder mockHolder = mock(SurfaceHolder.class);
    when(mockHolder.getSurface()).thenReturn(mockSurface);

    // Trigger manually
    callback.surfaceCreated(mockHolder);

    // Verify it used the manual surface mechanism instead of setVideoSurfaceView()
    verify(exoPlayer).setVideoSurface(mockSurface);
    verify(exoPlayer, never()).seekTo(anyLong());
  }

  @Test
  @Config(sdk = Build.VERSION_CODES.P)
  public void surfaceCreatedSeeksOnAndroid9() throws Exception {
    final Context context = ApplicationProvider.getApplicationContext();
    final ExoPlayer exoPlayer = mock(ExoPlayer.class);
    final PlatformVideoView view = new PlatformVideoView(context, exoPlayer);

    final Field field = PlatformVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    final SurfaceView surfaceView = (SurfaceView) field.get(view);

    ShadowSurfaceView shadowView = Shadows.shadowOf(surfaceView);
    Iterable<SurfaceHolder.Callback> callbacks = shadowView.getFakeSurfaceHolder().getCallbacks();
    assertNotNull("SurfaceCallbacks should not be null", callbacks);

    SurfaceHolder.Callback callback = callbacks.iterator().next();
    assertNotNull("Callback must exist", callback);

    Surface mockSurface = mock(Surface.class);
    when(mockSurface.isValid()).thenReturn(true);
    SurfaceHolder mockHolder = mock(SurfaceHolder.class);
    when(mockHolder.getSurface()).thenReturn(mockSurface);
    when(exoPlayer.getPlayWhenReady()).thenReturn(false);
    when(exoPlayer.getCurrentPosition()).thenReturn(0L);

    callback.surfaceCreated(mockHolder);

    verify(exoPlayer).setVideoSurface(mockSurface);
    verify(exoPlayer).seekTo(1);
  }

  @Test
  @Config(sdk = 34)
  public void rebindsSurfaceWhenVisibilityChangesToVisible() throws Exception {
    final Context context = ApplicationProvider.getApplicationContext();
    final ExoPlayer exoPlayer = mock(ExoPlayer.class);
    final PlatformVideoView view = new PlatformVideoView(context, exoPlayer);

    final Field field = PlatformVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    final SurfaceView surfaceView = spy((SurfaceView) Objects.requireNonNull(field.get(view)));
    when(surfaceView.isShown()).thenReturn(true);
    field.set(view, surfaceView); // Inject the spy back

    Surface mockSurface = mock(Surface.class);
    when(mockSurface.isValid()).thenReturn(true);
    SurfaceHolder mockHolder = mock(SurfaceHolder.class);
    when(mockHolder.getSurface()).thenReturn(mockSurface);
    when(surfaceView.getHolder()).thenReturn(mockHolder);

    // Trigger visibility changed
    Method method = View.class.getDeclaredMethod("onVisibilityChanged", View.class, int.class);
    method.setAccessible(true);
    method.invoke(surfaceView, surfaceView, View.VISIBLE);

    verify(exoPlayer).setVideoSurface(mockSurface);
    verify(exoPlayer, never()).seekTo(anyLong());
  }
}
