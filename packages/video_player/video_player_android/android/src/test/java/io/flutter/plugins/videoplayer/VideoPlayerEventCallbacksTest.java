// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
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
 * {@link VideoPlayerEventCallbacks#onBufferingUpdate(long)}, produces the expected data as an
 * encoded {@link Map}.
 *
 * <p>In other words, this tests that "the Java-side of the event channel works as expected".
 */
@RunWith(RobolectricTestRunner.class)
public final class VideoPlayerEventCallbacksTest {
  private VideoPlayerEventCallbacks eventCallbacks;

  @Mock private QueuingEventSink mockEventSink;

  @Captor private ArgumentCaptor<Map<String, Object>> eventCaptor;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Before
  public void setUp() {
    eventCallbacks = VideoPlayerEventCallbacks.withSink(mockEventSink);
  }

  @Test
  public void onInitializedSendsWidthHeightAndDuration() {
    eventCallbacks.onInitialized(800, 400, 10L, 0);

    verify(mockEventSink).success(eventCaptor.capture());

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "initialized");
    expected.put("duration", 10L);
    expected.put("width", 800);
    expected.put("height", 400);

    assertEquals(expected, actual);
  }

  @Test
  public void onInitializedIncludesRotationCorrectIfNonZero() {
    eventCallbacks.onInitialized(800, 400, 10L, 180);

    verify(mockEventSink).success(eventCaptor.capture());

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "initialized");
    expected.put("duration", 10L);
    expected.put("width", 800);
    expected.put("height", 400);
    expected.put("rotationCorrection", 180);

    assertEquals(expected, actual);
  }

  @Test
  public void onBufferingStart() {
    eventCallbacks.onBufferingStart();

    verify(mockEventSink).success(eventCaptor.capture());

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "bufferingStart");
    assertEquals(expected, actual);
  }

  @Test
  public void onBufferingUpdateProvidesAListWithASingleRange() {
    eventCallbacks.onBufferingUpdate(10L);

    verify(mockEventSink).success(eventCaptor.capture());

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "bufferingUpdate");
    expected.put("values", Collections.singletonList(Arrays.asList(0, 10L)));
    assertEquals(expected, actual);
  }

  @Test
  public void onBufferingEnd() {
    eventCallbacks.onBufferingEnd();

    verify(mockEventSink).success(eventCaptor.capture());

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "bufferingEnd");
    assertEquals(expected, actual);
  }

  @Test
  public void onCompleted() {
    eventCallbacks.onCompleted();

    verify(mockEventSink).success(eventCaptor.capture());

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "completed");
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

    Map<String, Object> actual = eventCaptor.getValue();
    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "isPlayingStateUpdate");
    expected.put("isPlaying", true);
    assertEquals(expected, actual);
  }
}
