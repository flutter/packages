// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.Mockito.*;
import static org.mockito.Mockito.doAnswer;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;

import android.graphics.SurfaceTexture;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.Format;
import com.google.android.exoplayer2.PlaybackException;
import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
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
  private EventChannel fakeEventChannel;
  private TextureRegistry.SurfaceTextureEntry fakeSurfaceTextureEntry;
  private SurfaceTexture fakeSurfaceTexture;
  private VideoPlayerOptions fakeVideoPlayerOptions;
  private QueuingEventSink fakeEventSink;
  private DefaultHttpDataSource.Factory httpDataSourceFactorySpy;

  @Captor private ArgumentCaptor<HashMap<String, Object>> eventCaptor;

  @Before
  public void before() {
    MockitoAnnotations.openMocks(this);

    fakeExoPlayer = mock(ExoPlayer.class);
    fakeEventChannel = mock(EventChannel.class);
    fakeSurfaceTextureEntry = mock(TextureRegistry.SurfaceTextureEntry.class);
    fakeSurfaceTexture = mock(SurfaceTexture.class);
    when(fakeSurfaceTextureEntry.surfaceTexture()).thenReturn(fakeSurfaceTexture);
    fakeVideoPlayerOptions = mock(VideoPlayerOptions.class);
    fakeEventSink = mock(QueuingEventSink.class);
    httpDataSourceFactorySpy = spy(new DefaultHttpDataSource.Factory());
  }

  @Test
  public void videoPlayer_buildsHttpDataSourceFactoryProperlyWhenHttpHeadersNull() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);

    videoPlayer.buildHttpDataSourceFactory(new HashMap<>());

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
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);
    Map<String, String> httpHeaders =
        new HashMap<String, String>() {
          {
            put("header", "value");
            put("User-Agent", "userAgent");
          }
        };

    videoPlayer.buildHttpDataSourceFactory(httpHeaders);

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
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);
    Map<String, String> httpHeaders =
        new HashMap<String, String>() {
          {
            put("header", "value");
          }
        };

    videoPlayer.buildHttpDataSourceFactory(httpHeaders);

    verify(httpDataSourceFactorySpy).setUserAgent("ExoPlayer");
    verify(httpDataSourceFactorySpy).setAllowCrossProtocolRedirects(true);
    verify(httpDataSourceFactorySpy).setDefaultRequestProperties(httpHeaders);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_90RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(90).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 200);
    assertEquals(event.get("height"), 100);
    assertEquals(event.get("rotationCorrection"), null);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_270RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(270).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 200);
    assertEquals(event.get("height"), 100);
    assertEquals(event.get("rotationCorrection"), null);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_0RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(0).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 100);
    assertEquals(event.get("height"), 200);
    assertEquals(event.get("rotationCorrection"), null);
  }

  @Test
  public void sendInitializedSendsExpectedEvent_180RotationDegrees() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);
    Format testFormat =
        new Format.Builder().setWidth(100).setHeight(200).setRotationDegrees(180).build();

    when(fakeExoPlayer.getVideoFormat()).thenReturn(testFormat);
    when(fakeExoPlayer.getDuration()).thenReturn(10L);

    videoPlayer.isInitialized = true;
    videoPlayer.sendInitialized();

    verify(fakeEventSink).success(eventCaptor.capture());
    HashMap<String, Object> event = eventCaptor.getValue();

    assertEquals(event.get("event"), "initialized");
    assertEquals(event.get("duration"), 10L);
    assertEquals(event.get("width"), 100);
    assertEquals(event.get("height"), 200);
    assertEquals(event.get("rotationCorrection"), 180);
  }

  @Test
  public void onIsPlayingChangedSendsExpectedEvent() {
    VideoPlayer videoPlayer =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);

    doAnswer(
            (Answer<Void>)
                invocation -> {
                  Map<String, Object> event = new HashMap<>();
                  event.put("event", "isPlayingStateUpdate");
                  event.put("isPlaying", (Boolean) invocation.getArguments()[0]);
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

    VideoPlayer unused =
        new VideoPlayer(
            fakeExoPlayer,
            fakeEventChannel,
            fakeSurfaceTextureEntry,
            fakeVideoPlayerOptions,
            fakeEventSink,
            httpDataSourceFactorySpy);

    PlaybackException exception =
        new PlaybackException(null, null, PlaybackException.ERROR_CODE_BEHIND_LIVE_WINDOW);
    listeners.forEach(listener -> listener.onPlayerError(exception));

    verify(fakeExoPlayer).seekToDefaultPosition();
    verify(fakeExoPlayer).prepare();
  }
}
