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

import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

/**
 * Unit tests for {@link ExoPlayerEventListener}.
 *
 * <p>This test suite <em>narrowly verifies</em> that the events emitted by the underlying {@link
 * androidx.media3.exoplayer.ExoPlayer} instance are translated to the callback interface we expect
 * ({@link VideoPlayerCallbacks} and/or interface with the player instance as expected).
 */
@RunWith(RobolectricTestRunner.class)
public final class ExoPlayerEventListenerTest {
  @Mock private ExoPlayer mockExoPlayer;
  @Mock private VideoPlayerCallbacks mockCallbacks;
  private ExoPlayerEventListener eventListener;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  /**
   * A test subclass of {@link ExoPlayerEventListener} that exposes the abstract class for testing.
   */
  private static final class TestExoPlayerEventListener extends ExoPlayerEventListener {
    public TestExoPlayerEventListener(ExoPlayer exoPlayer, VideoPlayerCallbacks callbacks) {
      super(exoPlayer, callbacks);
    }

    @Override
    protected void sendInitialized() {
      // No implementation needed.
    }
  }

  @Before
  public void setUp() {
    eventListener = new TestExoPlayerEventListener(mockExoPlayer, mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedBufferingSendsBufferingStartAndUpdates() {
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
    eventListener.onPlaybackStateChanged(Player.STATE_ENDED);

    verify(mockCallbacks).onCompleted();
    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedEndedAfterBufferingSendsBufferingEndAndOnCompleted() {
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
  public void onPlaybackStateChangedReadyAfterBufferingSendsBufferingEnd() {
    when(mockExoPlayer.getBufferedPosition()).thenReturn(10L);
    eventListener.onPlaybackStateChanged(Player.STATE_BUFFERING);
    verify(mockCallbacks).onBufferingStart();
    verify(mockCallbacks).onBufferingUpdate(10L);

    eventListener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockCallbacks).onBufferingEnd();

    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedIdleDoNothing() {
    eventListener.onPlaybackStateChanged(Player.STATE_IDLE);

    verifyNoInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedIdleAfterBufferingSendsBufferingEnd() {
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
    eventListener.onPlayerError(
        new PlaybackException("SORT_OF_OK", null, PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW));

    verify(mockExoPlayer).seekToDefaultPosition();
    verify(mockExoPlayer).prepare();
    verifyNoInteractions(mockCallbacks);
  }

  @Test
  public void onIsPlayingChangedToggled() {
    eventListener.onIsPlayingChanged(true);
    verify(mockCallbacks).onIsPlayingStateUpdate(true);

    eventListener.onIsPlayingChanged(false);
    verify(mockCallbacks).onIsPlayingStateUpdate(false);
  }
}
