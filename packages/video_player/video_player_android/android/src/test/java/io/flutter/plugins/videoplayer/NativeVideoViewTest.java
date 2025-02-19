package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.view.SurfaceView;
import androidx.media3.exoplayer.ExoPlayer;
import java.lang.reflect.Field;
import org.junit.Test;

public class NativeVideoViewTest {
  @Test
  public void createsSurfaceViewAndSetsItForExoPlayer() throws Exception {
    final Context mockContext = mock(Context.class);
    final ExoPlayer mockExoPlayer = mock(ExoPlayer.class);

    final NativeVideoView view = new NativeVideoView(mockContext, mockExoPlayer);

    final Field field = NativeVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    final SurfaceView surfaceView = (SurfaceView) field.get(view);

    assertNotNull(surfaceView);
    verify(mockExoPlayer).setVideoSurfaceView(surfaceView);
  }
}
