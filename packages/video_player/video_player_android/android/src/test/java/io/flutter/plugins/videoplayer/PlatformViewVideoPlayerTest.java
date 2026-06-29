// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockConstruction;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import androidx.annotation.OptIn;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.platformview.PlatformViewVideoPlayer;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockedConstruction;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public final class PlatformViewVideoPlayerTest {
  private static final String FAKE_ASSET_URL = "https://flutter.dev/movie.mp4";
  private FakeVideoAsset fakeVideoAsset;

  @Mock private VideoPlayerCallbacks mockEvents;
  @Mock private ExoPlayer mockExoPlayer;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Before
  public void setUp() {
    fakeVideoAsset = new FakeVideoAsset(FAKE_ASSET_URL);
  }

  @OptIn(markerClass = UnstableApi.class)
  @Test
  public void create_withBackBufferDuration_setsLoadControl() {
    Context mockContext = mock(Context.class);
    VideoPlayerOptions options = new VideoPlayerOptions();
    options.backBufferDurationMs = 20000L;

    try (MockedConstruction<ExoPlayer.Builder> mockedBuilder =
        mockConstruction(
            ExoPlayer.Builder.class,
            (mock, context) -> {
              when(mock.setLoadControl(any())).thenReturn(mock);
              when(mock.setTrackSelector(any())).thenReturn(mock);
              when(mock.setMediaSourceFactory(any())).thenReturn(mock);
              when(mock.build()).thenReturn(mockExoPlayer);
            })) {

      PlatformViewVideoPlayer player =
          PlatformViewVideoPlayer.create(mockContext, mockEvents, fakeVideoAsset, options);

      assertEquals(1, mockedBuilder.constructed().size());
      ExoPlayer.Builder builderMock = mockedBuilder.constructed().get(0);
      verify(builderMock).setLoadControl(any());
      player.dispose();
    }
  }
}
