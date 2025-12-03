// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.verifyNoMoreInteractions;

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
  private TestExoPlayerEventListener eventListener;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  /**
   * A test subclass of {@link ExoPlayerEventListener} that exposes the abstract class for testing.
   */
  private static final class TestExoPlayerEventListener extends ExoPlayerEventListener {
    private boolean calledSendInitialized = false;

    public TestExoPlayerEventListener(ExoPlayer exoPlayer, VideoPlayerCallbacks callbacks) {
      super(exoPlayer, callbacks);
    }

    @Override
    protected void sendInitialized() {
      calledSendInitialized = true;
    }

    boolean calledSendInitialized() {
      return calledSendInitialized;
    }
  }

  @Before
  public void setUp() {
    eventListener = new TestExoPlayerEventListener(mockExoPlayer, mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedBufferingSendsBuffering() {
    eventListener.onPlaybackStateChanged(Player.STATE_BUFFERING);

    verify(mockCallbacks).onPlaybackStateChanged(PlatformPlaybackState.BUFFERING);
    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedEndedSendsEnded() {
    eventListener.onPlaybackStateChanged(Player.STATE_ENDED);

    verify(mockCallbacks).onPlaybackStateChanged(PlatformPlaybackState.ENDED);
    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedIdleSendsIdle() {
    eventListener.onPlaybackStateChanged(Player.STATE_IDLE);

    verify(mockCallbacks).onPlaybackStateChanged(PlatformPlaybackState.IDLE);
    verifyNoMoreInteractions(mockCallbacks);
  }

  @Test
  public void onPlaybackStateChangedReadySendsInitializedAndReady() {
    eventListener.onPlaybackStateChanged(Player.STATE_READY);

    verify(mockCallbacks).onPlaybackStateChanged(PlatformPlaybackState.READY);
    verifyNoMoreInteractions(mockCallbacks);
    assertTrue(eventListener.calledSendInitialized());
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
