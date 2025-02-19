// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import android.content.Context;
import android.util.LongSparseArray;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.plugins.videoplayer.Messages.PlatformVideoViewType;
import io.flutter.plugins.videoplayer.Messages.CreateMessage;
import io.flutter.view.TextureRegistry;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import java.lang.reflect.Field;
import java.util.HashMap;

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

    FlutterPlugin.FlutterPluginBinding binding = mock(FlutterPlugin.FlutterPluginBinding.class);
    when(binding.getApplicationContext()).thenReturn(mock(Context.class));
    when(binding.getTextureRegistry()).thenReturn(mockTextureRegistry);
    when(binding.getBinaryMessenger())
        .thenReturn(mock(io.flutter.plugin.common.BinaryMessenger.class));
    when(binding.getPlatformViewRegistry()).thenReturn(mockPlatformViewRegistry);

    plugin = new VideoPlayerPlugin();
    plugin.onAttachedToEngine(binding);
  }

  @SuppressWarnings("unchecked")
  private LongSparseArray<VideoPlayer> getVideoPlayers() throws Exception {
    Field field = VideoPlayerPlugin.class.getDeclaredField("videoPlayers");
    field.setAccessible(true);
    return (LongSparseArray<VideoPlayer>) field.get(plugin);
  }

  // This is only a placeholder test and doesn't actually initialize the plugin.
  @Test
  public void initPluginDoesNotThrow() {
    final VideoPlayerPlugin plugin = new VideoPlayerPlugin();
  }

  @Test
  public void registersNativeVideoViewFactory() throws Exception {
    verify(mockPlatformViewRegistry)
        .registerViewFactory(
            eq("plugins.flutter.dev/video_player_android"), any(NativeVideoViewFactory.class));
  }

  @Test
  public void createsVideoPlayerWithPlatformViewType() throws Exception {
    MockedStatic<VideoPlayer> mockedVideoPlayerStatic = mockStatic(VideoPlayer.class);
    mockedVideoPlayerStatic
        .when(() -> VideoPlayer.create(any(), any(), any(), any()))
        .thenReturn(mock(VideoPlayer.class));

    CreateMessage createMessage =
        new CreateMessage.Builder()
            .setViewType(PlatformVideoViewType.PLATFORM_VIEW)
            .setHttpHeaders(new HashMap<>())
            .setUri("https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")
            .build();

    long playerId = plugin.create(createMessage);

    LongSparseArray<VideoPlayer> videoPlayers = getVideoPlayers();
    assertNotNull(videoPlayers.get(playerId));
  }

  @Test
  public void createsVideoPlayerWithTextureViewType() throws Exception {
    MockedStatic<TextureBasedVideoPlayer> mockedTextureBasedVideoPlayerStatic =
        mockStatic(TextureBasedVideoPlayer.class);
    mockedTextureBasedVideoPlayerStatic
        .when(() -> TextureBasedVideoPlayer.create(any(), any(), any(), any(), any()))
        .thenReturn(mock(TextureBasedVideoPlayer.class));

    CreateMessage createMessage =
        new CreateMessage.Builder()
            .setViewType(PlatformVideoViewType.TEXTURE_VIEW)
            .setHttpHeaders(new HashMap<>())
            .setUri("https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4")
            .build();
    long playerId = plugin.create(createMessage);

    LongSparseArray<VideoPlayer> videoPlayers = getVideoPlayers();
    final VideoPlayer player = videoPlayers.get(playerId);
    assertTrue(videoPlayers.get(playerId) instanceof TextureBasedVideoPlayer);
  }
}
