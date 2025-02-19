package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.*;

import android.content.Context;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;
import org.junit.Test;

public class NativeVideoViewFactoryTest {
  @Test
  public void createsNativeVideoViewBasedOnSuppliedArguments() throws Exception {
    final VideoPlayerProvider videoPlayerProvider = mock(VideoPlayerProvider.class);
    final VideoPlayer videoPlayer = mock(VideoPlayer.class);
    final ExoPlayer exoPlayer = mock(ExoPlayer.class);
    final Context context = mock(Context.class);
    final long playerId = 1L;

    when(videoPlayerProvider.getVideoPlayer(playerId)).thenReturn(videoPlayer);
    when(videoPlayer.getExoPlayer()).thenReturn(exoPlayer);

    final NativeVideoViewFactory factory = new NativeVideoViewFactory(videoPlayerProvider);
    final Messages.PlatformVideoViewCreationParams args =
        new Messages.PlatformVideoViewCreationParams.Builder().setPlayerId(playerId).build();

    final PlatformView view = factory.create(context, 0, args);

    assertTrue(view instanceof NativeVideoView);
    verify(videoPlayerProvider).getVideoPlayer(playerId);
    verify(videoPlayer).getExoPlayer();
  }
}
