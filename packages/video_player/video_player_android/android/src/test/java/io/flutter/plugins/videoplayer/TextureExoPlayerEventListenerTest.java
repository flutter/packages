// Copyright 2013 The Flutter Authors
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
  public void
      onPlaybackStateChangedReadySendInitialized_whenSurfaceProducerHandlesCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  public void
      onPlaybackStateChangedReadySendInitializedWithRotationCorrectionAndWidthAndHeightSwap_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, rotationCorrection);
  }

  @Test
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerHandlesCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 0);

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesSwapWidthAndHeight_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 90);
  }

  @Test
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerHandlesCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0);
    int rotationCorrection = 270;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 270);
  }

  @Test
  public void onPlaybackStateChangedReadyScalesWidthByPixelAspectRatio_whenContentIsAnamorphic() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    // Anamorphic content: 1080x720 coded pixels with a 3:8 pixel aspect ratio displays as 405x720.
    VideoSize size = new VideoSize(1080, 720, 0.375f);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(405, 720, 10L, 0);
  }

  @Test
  public void onPlaybackStateChangedReadyDoesNotScaleWidth_whenPixelAspectRatioIsSquare() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 1f);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  public void
      onPlaybackStateChangedReadyScalesWidthByPixelAspectRatio_whenAnamorphicAndRotationCorrected() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    // ExoPlayer reports a pixel aspect ratio that already accounts for the applied rotation,
    // so the width is scaled the same way regardless of the rotation correction.
    VideoSize size = new VideoSize(1080, 720, 0.375f);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(405, 720, 10L, rotationCorrection);
  }

  @Test
  public void onPlaybackStateChangedReadyReportsAtLeastOnePixel_whenPixelAspectRatioIsDegenerate() {
    TextureExoPlayerEventListener eventListener =
        new TextureExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    // A malformed ratio would otherwise round the width down to zero.
    VideoSize size = new VideoSize(800, 400, 0.0001f);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(1, 400, 10L, 0);
  }
}
