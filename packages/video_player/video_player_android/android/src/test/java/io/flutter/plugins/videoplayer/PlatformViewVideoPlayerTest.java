// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertTrue;

import android.content.Context;
import androidx.annotation.OptIn;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer;
import java.lang.reflect.Field;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

/** Unit tests for {@link PlatformViewVideoPlayer}. */
@RunWith(RobolectricTestRunner.class)
public final class PlatformViewVideoPlayerTest {
  private static final String FAKE_ASSET_URL = "https://flutter.dev/movie.mp4";
  private FakeVideoAsset fakeVideoAsset;

  @Before
  public void setUp() {
    fakeVideoAsset = new FakeVideoAsset(FAKE_ASSET_URL);
  }

  private boolean getEnableDecoderFallback(DefaultRenderersFactory renderersFactory)
      throws Exception {
    final Field field = DefaultRenderersFactory.class.getDeclaredField("enableDecoderFallback");
    field.setAccessible(true);
    return field.getBoolean(renderersFactory);
  }

  @OptIn(markerClass = UnstableApi.class)
  @Test
  public void createExoPlayerEnablesDecoderFallbackWhenSet() throws Exception {
    final Context context = ApplicationProvider.getApplicationContext();
    final DefaultRenderersFactory renderersFactory = new DefaultRenderersFactory(context);
    final VideoPlayerOptions options = new VideoPlayerOptions();
    options.enableDecoderFallback = true;

    final ExoPlayer exoPlayer =
        PlatformViewVideoPlayer.createExoPlayer(context, fakeVideoAsset, options, renderersFactory);

    assertTrue(getEnableDecoderFallback(renderersFactory));

    exoPlayer.release();
  }
}
