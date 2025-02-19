package io.flutter.plugins.videoplayer;

import static org.mockito.Mockito.*;

import android.content.Context;
import androidx.media3.exoplayer.ExoPlayer;
import org.junit.Test;
import java.lang.reflect.Field;

public class NativeVideoViewTest {
  @Test
  public void createsSurfaceView() throws Exception {
    final Context mockContext = mock(Context.class);
    final ExoPlayer mockExoPlayer = mock(ExoPlayer.class);

    final NativeVideoView view = new NativeVideoView(mockContext, mockExoPlayer);

    Field field = NativeVideoView.class.getDeclaredField("surfaceView");
    field.setAccessible(true);
    assert (field.get(view) != null);
  }

  @Test
  public void setsVideoSurfaceViewForExoPlayer() throws Exception {
    final Context mockContext = mock(Context.class);
    final ExoPlayer mockExoPlayer = mock(ExoPlayer.class);

    final NativeVideoView view = new NativeVideoView(mockContext, mockExoPlayer);

    verify(mockExoPlayer).setVideoSurfaceView(any());
  }
}
