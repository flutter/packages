// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.media3.common.Format;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.texture.TextureExoPlayerEventListener;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

/**
 * Unit tests for {@link TextureExoPlayerEventListener}.
 *
 * <p>This test suite <em>narrowly verifies</em> that the events emitted by the underlying {@link
 * androidx.media3.exoplayer.ExoPlayer} instance are translated to the callback interface we expect
 * ({@link VideoPlayerCallbacks} and/or interface with the player instance as expected).
 */
@RunWith(RobolectricTestRunner.class)
public class TextureExoPlayerEventListenerTest {
  @Mock private ExoPlayer mockExoPlayer;
  @Mock private VideoPlayerCallbacks mockCallbacks;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Test
  @Config(maxSdk = 21)
  public void onPlaybackStateChangedReadySendInitialized_belowAndroid21() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadySendInitialized_whenSurfaceProducerHandlesCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadySendInitializedWithRotationCorrectionAndWidthAndHeightSwap_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, rotationCorrection);
  }

  @Test
  @Config(maxSdk = 21)
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesSwapWidthAndHeight_belowAndroid21() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 90, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerHandlesCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 90, 0);

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesSwapWidthAndHeight_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 90);
  }

  @Test
  @Config(maxSdk = 21)
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesSwapWidthAndHeight_belowAndroid21() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 270, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerHandlesCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 270, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    int rotationCorrection = 270;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 270);
  }

  @Test
  @Config(maxSdk = 21)
  public void onPlaybackStateChangedReadyFlipped180DegreesInformEventHandler_belowAndroid21() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 180, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 180);
  }
}
