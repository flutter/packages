// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import java.util.Map;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

/**
 * Unit tests {@link VideoPlayerEventCallbacks}.
 *
 * <p>This test suite <em>narrowly verifies</em> that calling the provided event callbacks, such as
 * {@link VideoPlayerEventCallbacks#onPlaybackStateChanged(PlatformPlaybackState)}, produces the
 * expected data as an encoded {@link Map}.
 *
 * <p>In other words, this tests that "the Java-side of the event channel works as expected".
 */
@RunWith(RobolectricTestRunner.class)
public final class VideoPlayerEventCallbacksTest {
  private VideoPlayerEventCallbacks eventCallbacks;

  @Mock private QueuingEventSink mockEventSink;

  @Captor private ArgumentCaptor<PlatformVideoEvent> eventCaptor;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Before
  public void setUp() {
    eventCallbacks = VideoPlayerEventCallbacks.withSink(mockEventSink);
  }

  @Test
  public void onInitializedSendsExpectedArguments() {
    final int width = 800;
    final int height = 600;
    final long duration = 10L;
    final int rotation = 180;
    eventCallbacks.onInitialized(width, height, duration, rotation);

    verify(mockEventSink).success(eventCaptor.capture());

    PlatformVideoEvent actual = eventCaptor.getValue();
    InitializationEvent expected = new InitializationEvent(duration, width, height, rotation);
    assertEquals(expected, actual);
  }

  @Test
  public void onPlaybackStateChanged() {
    PlatformPlaybackState state = PlatformPlaybackState.READY;
    eventCallbacks.onPlaybackStateChanged(state);

    verify(mockEventSink).success(eventCaptor.capture());

    PlatformVideoEvent actual = eventCaptor.getValue();
    PlaybackStateChangeEvent expected = new PlaybackStateChangeEvent(state);
    assertEquals(expected, actual);
  }

  @Test
  public void onError() {
    eventCallbacks.onError("code", "message", "details");

    verify(mockEventSink).error(eq("code"), eq("message"), eq("details"));
  }

  @Test
  public void onIsPlayingStateUpdate() {
    eventCallbacks.onIsPlayingStateUpdate(true);

    verify(mockEventSink).success(eventCaptor.capture());

    PlatformVideoEvent actual = eventCaptor.getValue();
    IsPlayingStateEvent expected = new IsPlayingStateEvent(true);
    assertEquals(expected, actual);
  }
}
