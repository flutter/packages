// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.mockito.ArgumentMatchers.contains;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import androidx.media3.common.Format;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

/**
 * Unit tests for {@link ExoPlayerEventListener}.
 *
 * <p>This test suite <em>narrowly verifies</em> that the events emitted by the underlying {@link
 * androidx.media3.exoplayer.ExoPlayer} instance are translated to the callback interface we expect
 * ({@link VideoPlayerCallbacks} and/or interface with the player instance as expected.
 */
@RunWith(RobolectricTestRunner.class)
public final class ExoPlayerEventListenerTest {
  @Mock private ExoPlayer mockExoPlayer;
  @Mock private VideoPlayerCallbacks mockCallbacks;
  private ExoPlayerEventListener eventListener;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Test
  @Config(maxSdk = 21)
  public void onPlaybackStateChangedReadySendInitialized_belowAndroid21() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void onPlaybackStateChangedReadySendInitialized_whenSurfaceProducerHandlesCropAndRotation() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
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
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, rotationCorrection);
  }

  @Test
  @Config(maxSdk = 21)
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesSwapWidthAndHeight_belowAndroid21() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 90, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode90DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerHandlesCropAndRotation() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
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
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    int rotationCorrection = 90;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, 90);
  }

  @Test
  @Config(maxSdk = 21)
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesSwapWidthAndHeight_belowAndroid21() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 270, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesDoesNotSwapWidthAndHeight_whenSurfaceProducerHandlesCropAndRotation() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 270, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 0);
  }

  @Test
  @Config(minSdk = 22)
  public void
      onPlaybackStateChangedReadyInPortraitMode270DegreesSwapWidthAndHeight_whenSurfaceProducerDoesNotHandleCropAndRotation() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, false);
    VideoSize size = new VideoSize(800, 400, 0, 0);
    int rotationCorrection = 270;
    Format videoFormat = new Format.Builder().setRotationDegrees(rotationCorrection).build();

    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);
    when(mockExoPlayer.getVideoFormat()).thenReturn(videoFormat);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(400, 800, 10L, 270);
  }

  @Test
  @Config(maxSdk = 21)
  public void onPlaybackStateChangedReadyFlipped180DegreesInformEventHandler_belowAndroid21() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    VideoSize size = new VideoSize(800, 400, 180, 0);
    when(mockExoPlayer.getVideoSize()).thenReturn(size);
    when(mockExoPlayer.getDuration()).thenReturn(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onInitialized(800, 400, 10L, 180);
  }

  @Test
  public void onPlaybackStateChangedBufferingSendsBufferingStartAndUpdates() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    when(mockExoPlayer.getBufferedPosition()).thenReturn(10L);
    eventListener.onPlaybackStateChanged(Player.STATE_BUFFERING);

    verify(mockCallbacks).onBufferingStart();
    verify(mockCallbacks).onBufferingUpdate(10L);
    verifyNoMoreInteractions(mockCallbacks);

    // If it's invoked again, only the update event is called.
    verify(mockCallbacks).onBufferingUpdate(10L);
    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedEndedSendsOnCompleted() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    eventListener.onPlaybackStateChanged(Player.STATE_ENDED);

    verify(mockCallbacks).onCompleted();
    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedEndedAfterBufferingSendsBufferingEndAndOnCompleted() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    when(mockExoPlayer.getBufferedPosition()).thenReturn(10L);
    eventListener.onPlaybackStateChanged(Player.STATE_BUFFERING);
    verify(mockCallbacks).onBufferingStart();
    verify(mockCallbacks).onBufferingUpdate(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_ENDED);
    verify(mockCallbacks).onCompleted();
    verify(mockCallbacks).onBufferingEnd();

    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedIdleDoNothing() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    eventListener.onPlaybackStateChanged(Player.STATE_IDLE);

    verifyNoInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedIdleAfterBufferingSendsBufferingEnd() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    when(mockExoPlayer.getBufferedPosition()).thenReturn(10L);
    eventListener.onPlaybackStateChanged(Player.STATE_BUFFERING);
    verify(mockCallbacks).onBufferingStart();
    verify(mockCallbacks).onBufferingUpdate(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_IDLE);
    verify(mockCallbacks).onBufferingEnd();

    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onErrorVideoErrorWhenBufferingInProgressAlsoEndBuffering() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    when(mockExoPlayer.getBufferedPosition()).thenReturn(10L);
    eventListener.onPlaybackStateChanged(Player.STATE_BUFFERING);
    verify(mockCallbacks).onBufferingStart();
    verify(mockCallbacks).onBufferingUpdate(10L);

    eventListener.onPlayerError(
        new PlaybackException("BAD", null, PlaybackException.ERROR_CODE_AUDIO_TRACK_INIT_FAILED));
    verify(mockCallbacks).onBufferingEnd();
    verify(mockCallbacks).onError(eq("VideoError"), contains("BAD"), isNull());
  }

  @Test
  public void onErrorBehindLiveWindowSeekToDefaultAndPrepare() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    eventListener.onPlayerError(
        new PlaybackException("SORT_OF_OK", null, PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW));

    verify(mockExoPlayer).seekToDefaultPosition();
    verify(mockExoPlayer).prepare();
    verifyNoInteractions(mockCallbacks);
  }

  @Test
  public void onIsPlayingChangedToggled() {
    ExoPlayerEventListener eventListener = new ExoPlayerEventListener(mockExoPlayer, mockCallbacks, true);
    eventListener.onIsPlayingChanged(true);
    verify(mockCallbacks).onIsPlayingStateUpdate(true);

    eventListener.onIsPlayingChanged(false);
    verify(mockCallbacks).onIsPlayingStateUpdate(false);
  }
}
