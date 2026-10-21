// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.media3.common.Format;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.platformview.PlatformViewExoPlayerEventListener;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

/**
 * Unit tests for {@link PlatformViewExoPlayerEventListener}.
 *
 * <p>This test suite <em>narrowly verifies</em> that the events emitted by the underlying {@link
 * androidx.media3.exoplayer.ExoPlayer} instance are translated to the callback interface we expect
 * ({@link VideoPlayerCallbacks} and/or interface with the player instance as expected).
 */
@RunWith(RobolectricTestRunner.class)
public final class PlatformViewExoPlayerEventListenerTest {
  @Mock private ExoPlayer mockExoPlayer;
  @Mock private VideoPlayerCallbacks mockCallbacks;
  private ExoPlayerEventListener eventListener;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Before
  public void setUp() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedReadySendInitialized() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    Format format = new Format.Builder().setWidth(800).setHeight(400).build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyInPortraitMode90DegreesSwapsWidthAndHeight() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    Format format =
        new Format.Builder().setWidth(800).setHeight(400).setRotationDegrees(90).build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyInPortraitMode270DegreesSwapsWidthAndHeight() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    Format format =
        new Format.Builder().setWidth(800).setHeight(400).setRotationDegrees(270).build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyScalesWidthByPixelAspectRatio_whenContentIsAnamorphic() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    // Anamorphic content: 1080x720 coded pixels with a 3:8 pixel aspect ratio displays as 405x720.
    Format format =
        new Format.Builder().setWidth(1080).setHeight(720).setPixelWidthHeightRatio(0.375f).build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(405, 720, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyScalesThenSwaps_whenAnamorphicAndRotated90Degrees() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    // The display size of the unrotated frame is 405x720, so rotating it yields 720x405.
    Format format =
        new Format.Builder()
            .setWidth(1080)
            .setHeight(720)
            .setPixelWidthHeightRatio(0.375f)
            .setRotationDegrees(90)
            .build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(720, 405, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyReportsAtLeastOnePixel_whenPixelAspectRatioIsDegenerate() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    // A malformed ratio would otherwise round the width down to zero.
    Format format =
        new Format.Builder().setWidth(800).setHeight(400).setPixelWidthHeightRatio(0.0001f).build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(1, 400, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyLeavesUnknownWidthUnscaled() {
    eventListener = new PlatformViewExoPlayerEventListener(mockExoPlayer, mockCallbacks);

    // Format.NO_VALUE must not be turned into a bogus scaled width.
    Format format = new Format.Builder().setHeight(400).setPixelWidthHeightRatio(0.375f).build();
    when(mockExoPlayer.getVideoFormat()).thenReturn(format);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(Format.NO_VALUE, 400, 10L, 0);
  }
}
