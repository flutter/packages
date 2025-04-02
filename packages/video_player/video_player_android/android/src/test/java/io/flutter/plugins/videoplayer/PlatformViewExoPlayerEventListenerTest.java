// Copyright 2013 The Flutter Authors. All rights reserved.
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
}
