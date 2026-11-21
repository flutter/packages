// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.util.LongSparseArray;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.plugins.videoplayer.platformview.PlatformVideoViewFactory;
import io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer;
import io.flutter.plugins.videoplayer.texture.TextureVideoPlayer;
import io.flutter.view.TextureRegistry;
import java.lang.reflect.Field;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class VideoPlayerPluginTest {
  @Mock private TextureRegistry mockTextureRegistry;
  @Mock private TextureRegistry.SurfaceProducer mockSurfaceProducer;
  @Mock private PlatformViewRegistry mockPlatformViewRegistry;
  private VideoPlayerPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    when(mockTextureRegistry.createSurfaceProducer()).thenReturn(mockSurfaceProducer);
  }

  private FlutterPlugin.FlutterPluginBinding createMockBinding() {
    FlutterPlugin.FlutterPluginBinding binding = mock(FlutterPlugin.FlutterPluginBinding.class);
    when(binding.getApplicationContext()).thenReturn(mock(Context.class));
    when(binding.getTextureRegistry()).thenReturn(mockTextureRegistry);
    when(binding.getBinaryMessenger())
        .thenReturn(mock(io.flutter.plugin.common.BinaryMessenger.class));
    when(binding.getPlatformViewRegistry()).thenReturn(mockPlatformViewRegistry);
    return binding;
  }

  @SuppressWarnings("unchecked")
  private LongSparseArray<VideoPlayer> getVideoPlayers() throws Exception {
    final Field field = VideoPlayerPlugin.class.getDeclaredField("videoPlayers");
    field.setAccessible(true);
    return (LongSparseArray<VideoPlayer>) field.get(plugin);
  }

  // This is only a placeholder test and doesn't actually initialize the plugin.
  @Test
  public void initPluginDoesNotThrow() {
    final VideoPlayerPlugin plugin = new VideoPlayerPlugin();
  }

  @Test
  public void registersPlatformVideoViewFactory() {
    plugin = new VideoPlayerPlugin();
    plugin.onAttachedToEngine(createMockBinding());
    verify(mockPlatformViewRegistry)
        .registerViewFactory(
            eq("plugins.flutter.dev/video_player_android"), any(PlatformVideoViewFactory.class));
  }

  @Test
  public void createsPlatformViewVideoPlayer() throws Exception {
    plugin =
        new VideoPlayerPlugin(
            (context, callbacks, asset, options) -> mock(PlatformViewVideoPlayer.class), null);
    plugin.onAttachedToEngine(createMockBinding());

    final CreationOptions options =
        new CreationOptions(
            "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
            null,
            new HashMap<>(),
            null,
            null);

    final long playerId = plugin.createForPlatformView(options);

    final LongSparseArray<VideoPlayer> videoPlayers = getVideoPlayers();
    assertTrue(videoPlayers.get(playerId) instanceof PlatformViewVideoPlayer);
  }

  @Test
  public void createsTextureVideoPlayer() throws Exception {
    plugin =
        new VideoPlayerPlugin(
            null, (context, callbacks, producer, asset, options) -> mock(TextureVideoPlayer.class));
    plugin.onAttachedToEngine(createMockBinding());

    final CreationOptions options =
        new CreationOptions(
            "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
            null,
            new HashMap<>(),
            null,
            null);

    final TexturePlayerIds ids = plugin.createForTextureView(options);

    final LongSparseArray<VideoPlayer> videoPlayers = getVideoPlayers();
    assertTrue(videoPlayers.get(ids.getPlayerId()) instanceof TextureVideoPlayer);
  }
}
