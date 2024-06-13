// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;

import android.graphics.SurfaceTexture;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.view.TextureRegistry;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.MockitoAnnotations;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class VideoPlayerTest {
  private ExoPlayer fakeExoPlayer;
  private TextureRegistry.SurfaceTextureEntry fakeSurfaceTextureEntry;
  private VideoPlayerOptions fakeVideoPlayerOptions;
  private QueuingEventSink fakeEventSink;
  private DefaultHttpDataSource.Factory httpDataSourceFactorySpy;

  @Captor private ArgumentCaptor<HashMap<String, Object>> eventCaptor;

  private AutoCloseable mocks;

  @Before
  public void before() {
    mocks = MockitoAnnotations.openMocks(this);

    fakeExoPlayer = mock(ExoPlayer.class);
    fakeSurfaceTextureEntry = mock(TextureRegistry.SurfaceTextureEntry.class);
    SurfaceTexture fakeSurfaceTexture = mock(SurfaceTexture.class);
    when(fakeSurfaceTextureEntry.surfaceTexture()).thenReturn(fakeSurfaceTexture);
    fakeVideoPlayerOptions = mock(VideoPlayerOptions.class);
    fakeEventSink = mock(QueuingEventSink.class);
    httpDataSourceFactorySpy = spy(new DefaultHttpDataSource.Factory());
  }

  @After
  public void after() throws Exception {
    mocks.close();
  }

  @Test
  public void videoPlayer_buildsHttpDataSourceFactoryProperlyWhenHttpHeadersNull() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            VideoPlayerEventCallbacks.withSink(fakeEventSink),
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            httpDataSourceFactorySpy);

    videoPlayer.configureHttpDataSourceFactory(new HashMap<>());

    verify(httpDataSourceFactorySpy).setUserAgent("ExoPlayer");
    verify(httpDataSourceFactorySpy).setAllowCrossProtocolRedirects(true);
    verify(httpDataSourceFactorySpy, never()).setDefaultRequestProperties(any());
  }

  @Test
  public void
      videoPlayer_buildsHttpDataSourceFactoryProperlyWhenHttpHeadersNonNullAndUserAgentSpecified() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            VideoPlayerEventCallbacks.withSink(fakeEventSink),
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            httpDataSourceFactorySpy);
    Map<String, String> httpHeaders =
        new HashMap<String, String>() {
          {
            put("header", "value");
            put("User-Agent", "userAgent");
          }
        };

    videoPlayer.configureHttpDataSourceFactory(httpHeaders);

    verify(httpDataSourceFactorySpy).setUserAgent("userAgent");
    verify(httpDataSourceFactorySpy).setAllowCrossProtocolRedirects(true);
    verify(httpDataSourceFactorySpy).setDefaultRequestProperties(httpHeaders);
  }

  @Test
  public void
      videoPlayer_buildsHttpDataSourceFactoryProperlyWhenHttpHeadersNonNullAndUserAgentNotSpecified() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            VideoPlayerEventCallbacks.withSink(fakeEventSink),
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            httpDataSourceFactorySpy);
    Map<String, String> httpHeaders =
        new HashMap<String, String>() {
          {
            put("header", "value");
          }
        };

    videoPlayer.configureHttpDataSourceFactory(httpHeaders);

    verify(httpDataSourceFactorySpy).setUserAgent("ExoPlayer");
    verify(httpDataSourceFactorySpy).setAllowCrossProtocolRedirects(true);
    verify(httpDataSourceFactorySpy).setDefaultRequestProperties(httpHeaders);
  }

  private Player.Listener initVideoPlayerAndGetListener() {
    ArgumentCaptor<Player.Listener> listenerCaptor = ArgumentCaptor.forClass(Player.Listener.class);
    doNothing().when(fakeExoPlayer).addListener(listenerCaptor.capture());

    // Create a video player that will invoke fakeEventSink as a result of Player.Listener calls.
    new VideoPlayer(
        fakeExoPlayer,
        VideoPlayerEventCallbacks.withSink(fakeEventSink),
        fakeSurfaceTextureEntry,
        fakeVideoPlayerOptions,
        httpDataSourceFactorySpy);

    return Objects.requireNonNull(listenerCaptor.getValue());
  }

  @Test
  public void onPlaybackStateBufferingSendBufferedPositionUpdate() {
    Player.Listener listener = initVideoPlayerAndGetListener();
    when(fakeExoPlayer.getBufferedPosition()).thenReturn(10L);

    // Send Player.STATE_BUFFERING to trigger the "bufferingUpdate" event.
    listener.onPlaybackStateChanged(Player.STATE_BUFFERING);

    verify(fakeEventSink, atLeast(1)).success(eventCaptor.capture());
    List<HashMap<String, Object>> events = eventCaptor.getAllValues();

    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "bufferingUpdate");

    List<? extends Number> range = Arrays.asList(0, 10L);
    expected.put("values", Collections.singletonList(range));

    // We received potentially multiple events, find the one that is a "bufferingUpdate".
    for (Map<String, Object> event : events) {
      if (event.get("event") == "bufferingUpdate") {
        assertEquals(expected, event);
        return;
      }
    }

    fail("No 'bufferingUpdate' event found: " + events);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_90RotationDegrees() {
    Player.Listener listener = initVideoPlayerAndGetListener();
    VideoSize testVideoSize = new VideoSize(100, 200, 90, 1f);

    when(fakeExoPlayer.getVideoSize()).thenReturn(testVideoSize);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    // Send Player.STATE_READY to trigger the "initialized" event.
    listener.onPlaybackStateChanged(Player.STATE_READY);

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> actual = eventCaptor.getValue();

    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "initialized");
    expected.put("duration", 10L);
    expected.put("width", 200);
    expected.put("height", 100);

    assertEquals(expected, actual);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_270RotationDegrees() {
    Player.Listener listener = initVideoPlayerAndGetListener();
    VideoSize testVideoSize = new VideoSize(100, 200, 270, 1f);

    when(fakeExoPlayer.getVideoSize()).thenReturn(testVideoSize);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    // Send Player.STATE_READY to trigger the "initialized" event.
    listener.onPlaybackStateChanged(Player.STATE_READY);

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> actual = eventCaptor.getValue();

    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "initialized");
    expected.put("duration", 10L);
    expected.put("width", 200);
    expected.put("height", 100);

    assertEquals(expected, actual);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_0RotationDegrees() {
    Player.Listener listener = initVideoPlayerAndGetListener();
    VideoSize testVideoSize = new VideoSize(100, 200, 0, 1f);

    when(fakeExoPlayer.getVideoSize()).thenReturn(testVideoSize);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    // Send Player.STATE_READY to trigger the "initialized" event.
    listener.onPlaybackStateChanged(Player.STATE_READY);

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> actual = eventCaptor.getValue();

    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "initialized");
    expected.put("duration", 10L);
    expected.put("width", 100);
    expected.put("height", 200);

    assertEquals(expected, actual);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_180RotationDegrees() {
    Player.Listener listener = initVideoPlayerAndGetListener();
    VideoSize testVideoSize = new VideoSize(100, 200, 180, 1f);

    when(fakeExoPlayer.getVideoSize()).thenReturn(testVideoSize);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    // Send Player.STATE_READY to trigger the "initialized" event.
    listener.onPlaybackStateChanged(Player.STATE_READY);

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> actual = eventCaptor.getValue();

    Map<String, Object> expected = new HashMap<>();
    expected.put("event", "initialized");
    expected.put("duration", 10L);
    expected.put("width", 100);
    expected.put("height", 200);
    expected.put("rotationCorrection", 180);

    assertEquals(expected, actual);
  }

  @Test
  public void onIsPlayingChangedSendsExpectedEvent() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            VideoPlayerEventCallbacks.withSink(fakeEventSink),
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            httpDataSourceFactorySpy);

    doAnswer(
            (Answer<Void>)
                invocation -> {
                  Map<String, Object> event = new HashMap<>();
                  event.put("event", "isPlayingStateUpdate");
                  event.put("isPlaying", invocation.getArguments()[0]);
                  fakeEventSink.success(event);
                  return null;
                })
        .when(fakeExoPlayer)
        .setPlayWhenReady(anyBoolean());

    videoPlayer.play();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event1 = eventCaptor.getValue();

    assertEquals(event1.get("event"), "isPlayingStateUpdate");
    assertEquals(event1.get("isPlaying"), true);

    videoPlayer.pause();

    verify(fakeEventSink, times(2)).success(eventCaptor.capture());
    HashMap<String, Object> event2 = eventCaptor.getValue();

    assertEquals(event2.get("event"), "isPlayingStateUpdate");
    assertEquals(event2.get("isPlaying"), false);
  }

  @Test
  public void behindLiveWindowErrorResetsPlayerToDefaultPosition() {
    List<Player.Listener> listeners = new LinkedList<>();
    doAnswer(invocation -> listeners.add(invocation.getArgument(0)))
        .when(fakeExoPlayer)
        .addListener(any());

    @SuppressWarnings("unused")
    VideoPlayer unused =
        new VideoPlayer(
            fakeExoPlayer,
            VideoPlayerEventCallbacks.withSink(fakeEventSink),
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            httpDataSourceFactorySpy);

    PlaybackException exception =
        new PlaybackException(null, null, PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW);
    listeners.forEach(listener -> listener.onPlayerError(exception));

    verify(fakeExoPlayer).seekToDefaultPosition();
    verify(fakeExoPlayer).prepare();
  }

  @Test
  public void otherErrorsReportVideoErrorWithErrorString() {
    List<Player.Listener> listeners = new LinkedList<>();
    doAnswer(invocation -> listeners.add(invocation.getArgument(0)))
        .when(fakeExoPlayer)
        .addListener(any());

    @SuppressWarnings("unused")
    VideoPlayer unused =
        new VideoPlayer(
            fakeExoPlayer,
            VideoPlayerEventCallbacks.withSink(fakeEventSink),
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            httpDataSourceFactorySpy);

    PlaybackException exception =
        new PlaybackException(
            "You did bad kid", null, PlaybackException.ERROR_CODE_DECODING_FAILED);
    listeners.forEach(listener -> listener.onPlayerError(exception));

    verify(fakeEventSink).error(eq("VideoError"), contains("You did bad kid"), any());
  }
}
