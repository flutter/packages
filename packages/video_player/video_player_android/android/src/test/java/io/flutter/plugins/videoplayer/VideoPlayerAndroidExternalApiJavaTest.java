// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.media3.common.MediaItem;
import androidx.media3.test.utils.FakeMediaSourceFactory;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformViewRegistry;
import io.flutter.plugins.videoplayer.texture.TextureVideoPlayer;
import io.flutter.view.TextureRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.After;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

/**
 * Exercises {@link VideoPlayerAndroidExternalApi} the way a Java plugin uses it.
 *
 * <p>Behavior is covered by VideoPlayerAndroidExternalApiTest; this test is in Java because the API
 * is public to Java callers, and what they see (static methods, getters, constructors) can only be
 * checked from Java.
 */
@RunWith(RobolectricTestRunner.class)
public class VideoPlayerAndroidExternalApiJavaTest {
  private static final String URL =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  private final FlutterPlugin.FlutterPluginBinding binding = createMockBinding();

  @After
  public void tearDown() {
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(binding, null);
  }

  private static FlutterPlugin.FlutterPluginBinding createMockBinding() {
    final TextureRegistry textureRegistry = mock(TextureRegistry.class);
    when(textureRegistry.createSurfaceProducer())
        .thenReturn(mock(TextureRegistry.SurfaceProducer.class));
    final FlutterPlugin.FlutterPluginBinding binding =
        mock(FlutterPlugin.FlutterPluginBinding.class);
    when(binding.getApplicationContext()).thenReturn(mock(Context.class));
    when(binding.getTextureRegistry()).thenReturn(textureRegistry);
    when(binding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(binding.getPlatformViewRegistry()).thenReturn(mock(PlatformViewRegistry.class));
    return binding;
  }

  @Test
  public void javaProviderConfiguresPlayer() {
    final List<VideoAsset> createdAssets = new ArrayList<>();
    final VideoPlayerPlugin plugin =
        new VideoPlayerPlugin(
            null,
            (context, callbacks, producer, asset, options) -> {
              createdAssets.add(asset);
              return mock(TextureVideoPlayer.class);
            });
    plugin.onAttachedToEngine(binding);
    final MediaItem mediaItem = MediaItem.fromUri(URL);
    final List<VideoPlayerAndroidExternalApi.MediaConfigRequest> requests = new ArrayList<>();
    VideoPlayerAndroidExternalApi.setMediaConfigProvider(
        binding,
        request -> {
          requests.add(request);
          return new VideoPlayerAndroidExternalApi.MediaConfig(
              mediaItem, new FakeMediaSourceFactory());
        });
    final Map<String, String> httpHeaders = new HashMap<>();
    httpHeaders.put("Authorization", "Bearer token");

    plugin.createForTextureView(new CreationOptions(URL, null, httpHeaders, "agent", null));

    final VideoPlayerAndroidExternalApi.MediaConfigRequest request = requests.get(0);
    assertEquals(URL, request.getUri());
    assertEquals(httpHeaders, request.getHttpHeaders());
    assertEquals("agent", request.getUserAgent());
    assertThrows(UnsupportedOperationException.class, () -> request.getHttpHeaders().put("X", "Y"));
    assertSame(mediaItem, createdAssets.get(0).getMediaItem());
  }
}
