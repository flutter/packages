// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import android.view.Surface;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugins.videoplayer.texture.TextureVideoPlayer;
import io.flutter.view.TextureRegistry;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Captor;
import org.mockito.InOrder;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

/**
 * Unit tests for {@link TextureVideoPlayer}.
 *
 * <p>This test suite <em>narrowly verifies</em> that {@link TextureVideoPlayer} interfaces with the
 * {@link ExoPlayer} interface <em>exactly</em> as it did when the test suite was created. That is,
 * if the behavior changes, this test will need to change. However, this suite should catch bugs
 * related to <em>"this is a safe refactor with no behavior changes"</em>.
 */
@RunWith(RobolectricTestRunner.class)
public final class TextureVideoPlayerTest {
  private static final String FAKE_ASSET_URL = "https://flutter.dev/movie.mp4";
  private FakeVideoAsset fakeVideoAsset;

  @Mock private VideoPlayerCallbacks mockEvents;
  @Mock private TextureRegistry.SurfaceProducer mockProducer;
  @Mock private ExoPlayer mockExoPlayer;
  @Captor private ArgumentCaptor<AudioAttributes> attributesCaptor;
  @Captor private ArgumentCaptor<TextureRegistry.SurfaceProducer.Callback> callbackCaptor;
  @Captor private ArgumentCaptor<Player.Listener> listenerCaptor;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  @Before
  public void setUp() {
    fakeVideoAsset = new FakeVideoAsset(FAKE_ASSET_URL);
    when(mockProducer.getSurface()).thenReturn(mock(Surface.class));
  }

  private VideoPlayer createVideoPlayer() {
    return createVideoPlayer(new VideoPlayerOptions());
  }

  private TextureVideoPlayer createVideoPlayer(VideoPlayerOptions options) {
    return new TextureVideoPlayer(
        mockEvents, mockProducer, fakeVideoAsset.getMediaItem(), options, () -> mockExoPlayer);
  }

  @Test
  public void loadsAndPreparesProvidedMediaEnablesAudioFocusByDefault() {
    VideoPlayer videoPlayer = createVideoPlayer();

    verify(mockExoPlayer).setMediaItem(fakeVideoAsset.getMediaItem());
    verify(mockExoPlayer).prepare();
    verify(mockProducer).getSurface();
    verify(mockExoPlayer).setVideoSurface(any());

    verify(mockExoPlayer).setAudioAttributes(attributesCaptor.capture(), eq(true));
    assertEquals(attributesCaptor.getValue().contentType, C.AUDIO_CONTENT_TYPE_MOVIE);

    videoPlayer.dispose();
  }

  @Test
  public void onSurfaceProducerDestroyedAndAvailableReleasesAndThenRecreatesAndResumesPlayer() {
    VideoPlayer videoPlayer = createVideoPlayer();

    verify(mockProducer).setCallback(callbackCaptor.capture());
    verify(mockExoPlayer, never()).release();

    when(mockExoPlayer.getCurrentPosition()).thenReturn(10L);
    when(mockExoPlayer.getRepeatMode()).thenReturn(Player.REPEAT_MODE_ALL);
    when(mockExoPlayer.getVolume()).thenReturn(0.5f);
    when(mockExoPlayer.getPlaybackParameters()).thenReturn(new PlaybackParameters(2.5f));

    TextureRegistry.SurfaceProducer.Callback producerLifecycle = callbackCaptor.getValue();
    simulateSurfaceDestruction(producerLifecycle);

    verify(mockExoPlayer).release();

    // Create a new mock exo player so that we get a new instance.
    mockExoPlayer = mock(ExoPlayer.class);
    producerLifecycle.onSurfaceAvailable();

    verify(mockExoPlayer).setVideoSurface(any());
    verify(mockExoPlayer).seekTo(10L);
    verify(mockExoPlayer).setRepeatMode(Player.REPEAT_MODE_ALL);
    verify(mockExoPlayer).setVolume(0.5f);
    verify(mockExoPlayer).setPlaybackParameters(new PlaybackParameters(2.5f));

    videoPlayer.dispose();
  }

  @Test
  public void onSurfaceProducerDestroyedDoesNotStopOrPauseVideo() {
    VideoPlayer videoPlayer = createVideoPlayer();

    verify(mockProducer).setCallback(callbackCaptor.capture());
    TextureRegistry.SurfaceProducer.Callback producerLifecycle = callbackCaptor.getValue();
    simulateSurfaceDestruction(producerLifecycle);

    verify(mockExoPlayer, never()).stop();
    verify(mockExoPlayer, never()).pause();
    verify(mockExoPlayer, never()).setPlayWhenReady(anyBoolean());

    videoPlayer.dispose();
  }

  @Test
  public void onDisposeSurfaceProducerCallbackIsDisconnected() {
    // Regression test for https://github.com/flutter/flutter/issues/156158.
    VideoPlayer videoPlayer = createVideoPlayer();
    verify(mockProducer).setCallback(any());

    videoPlayer.dispose();
    verify(mockProducer).setCallback(null);
  }

  @Test
  public void onInitializedCalledWhenVideoPlayerInitiallyCreated() {
    VideoPlayer videoPlayer = createVideoPlayer();

    // Pretend we have a video, and capture the registered event listener.
    when(mockExoPlayer.getVideoSize()).thenReturn(new VideoSize(300, 200));
    verify(mockExoPlayer).addListener(listenerCaptor.capture());
    Player.Listener listener = listenerCaptor.getValue();

    // Trigger an event that would trigger onInitialized.
    listener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockEvents).onInitialized(anyInt(), anyInt(), anyLong(), anyInt());

    videoPlayer.dispose();
  }

  @Test
  public void onSurfaceAvailableDoesNotSendInitializeEventAgain() {
    // The VideoPlayer contract assumes that the event "initialized" is sent exactly once
    // (duplicate events cause an error to be thrown at the shared Dart layer). This test verifies
    // that the onInitialized event is sent exactly once per player.
    //
    // Regression test for https://github.com/flutter/flutter/issues/154602.
    VideoPlayer videoPlayer = createVideoPlayer();
    when(mockExoPlayer.getVideoSize()).thenReturn(new VideoSize(300, 200));

    // Capture the lifecycle events so we can simulate onSurfaceAvailableDestroyed.
    verify(mockProducer).setCallback(callbackCaptor.capture());
    TextureRegistry.SurfaceProducer.Callback producerLifecycle = callbackCaptor.getValue();

    // Trigger destroyed/available.
    simulateSurfaceDestruction(producerLifecycle);
    producerLifecycle.onSurfaceAvailable();

    // Initial listener, and the new one from the resume.
    verify(mockExoPlayer, times(2)).addListener(listenerCaptor.capture());
    Player.Listener listener = listenerCaptor.getValue();

    // Now trigger that same event, which would happen in the case of a background/resume.
    listener.onPlaybackStateChanged(Player.STATE_READY);

    // Was not called because it was a result of a background/resume.
    verify(mockEvents, never()).onInitialized(anyInt(), anyInt(), anyLong(), anyInt());

    videoPlayer.dispose();
  }

  @Test
  public void onSurfaceAvailableWithoutDestroyDoesNotRecreate() {
    // Initially create the video player, which creates the initial surface.
    VideoPlayer videoPlayer = createVideoPlayer();
    verify(mockProducer).getSurface();

    // Capture the lifecycle events so we can simulate onSurfaceAvailable/Destroyed.
    verify(mockProducer).setCallback(callbackCaptor.capture());
    TextureRegistry.SurfaceProducer.Callback producerLifecycle = callbackCaptor.getValue();

    // Calling onSurfaceAvailable does not do anything, since the surface was never destroyed.
    producerLifecycle.onSurfaceAvailable();
    verifyNoMoreInteractions(mockProducer);

    videoPlayer.dispose();
  }

  @Test
  public void disposeReleasesExoPlayerBeforeTexture() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.dispose();

    // Regression test for https://github.com/flutter/flutter/issues/156158.
    // The player must be destroyed before the surface it is writing to.
    InOrder inOrder = inOrder(mockExoPlayer, mockProducer);
    inOrder.verify(mockExoPlayer).release();
    inOrder.verify(mockProducer).release();
  }

  // TODO(matanlurey): Replace with inline calls to onSurfaceAvailable once
  // available on stable; see https://github.com/flutter/flutter/issues/155131.
  // This separate method only exists to scope the suppression.
  @SuppressWarnings({"deprecation", "removal"})
  void simulateSurfaceCreation(TextureRegistry.SurfaceProducer.Callback producerLifecycle) {
    producerLifecycle.onSurfaceCreated();
  }

  // TODO(bparrishMines): Replace with inline calls to onSurfaceCleanup once available on stable;
  // see https://github.com/flutter/flutter/issues/16125. This separate method only exists to scope
  // the suppression.
  @SuppressWarnings({"deprecation", "removal"})
  void simulateSurfaceDestruction(TextureRegistry.SurfaceProducer.Callback producerLifecycle) {
    producerLifecycle.onSurfaceDestroyed();
  }
}
