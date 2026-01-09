// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.*;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackParameters;
import androidx.media3.common.Player;
import androidx.media3.common.TrackGroup;
import androidx.media3.common.TrackSelectionOverride;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.trackselection.DefaultTrackSelector;
import com.google.common.collect.ImmutableList;
import io.flutter.plugins.videoplayer.platformview.PlatformViewExoPlayerEventListener;
import io.flutter.view.TextureRegistry.SurfaceProducer;
import java.lang.reflect.Field;
import java.util.List;
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
 * Unit tests for {@link VideoPlayer}.
 *
 * <p>This test suite <em>narrowly verifies</em> that {@link VideoPlayer} interfaces with the {@link
 * ExoPlayer} interface <em>exactly</em> as it did when the test suite was created. That is, if the
 * behavior changes, this test will need to change. However, this suite should catch bugs related to
 * <em>"this is a safe refactor with no behavior changes"</em>.
 *
 * <p>It's hypothetically possible to write better tests using {@link
 * androidx.media3.test.utils.FakeMediaSource}, but you really need a PhD in the Android media APIs
 * in order to figure out how to set everything up so the player "works".
 */
@RunWith(RobolectricTestRunner.class)
public final class VideoPlayerTest {
  private static final String FAKE_ASSET_URL = "https://flutter.dev/movie.mp4";
  private FakeVideoAsset fakeVideoAsset;

  @Mock private VideoPlayerCallbacks mockEvents;
  @Mock private ExoPlayer mockExoPlayer;
  @Captor private ArgumentCaptor<AudioAttributes> attributesCaptor;
  @Captor private ArgumentCaptor<Player.Listener> listenerCaptor;

  @Rule public MockitoRule initRule = MockitoJUnit.rule();

  /** A test subclass of {@link VideoPlayer} that exposes the abstract class for testing. */
  private final class TestVideoPlayer extends VideoPlayer {
    private TestVideoPlayer(
        @NonNull VideoPlayerCallbacks events,
        @NonNull MediaItem mediaItem,
        @NonNull VideoPlayerOptions options,
        @Nullable SurfaceProducer surfaceProducer,
        @NonNull ExoPlayerProvider exoPlayerProvider) {
      super(events, mediaItem, options, surfaceProducer, exoPlayerProvider);
    }

    @NonNull
    @Override
    protected ExoPlayerEventListener createExoPlayerEventListener(
        @NonNull ExoPlayer exoPlayer, @Nullable SurfaceProducer surfaceProducer) {
      // Use platform view implementation for testing.
      return new PlatformViewExoPlayerEventListener(exoPlayer, mockEvents);
    }
  }

  @Before
  public void setUp() {
    fakeVideoAsset = new FakeVideoAsset(FAKE_ASSET_URL);
  }

  private VideoPlayer createVideoPlayer() {
    return createVideoPlayer(new VideoPlayerOptions());
  }

  private VideoPlayer createVideoPlayer(VideoPlayerOptions options) {
    return new TestVideoPlayer(
        mockEvents, fakeVideoAsset.getMediaItem(), options, null, () -> mockExoPlayer);
  }

  @Test
  public void loadsAndPreparesProvidedMediaEnablesAudioFocusByDefault() {
    VideoPlayer videoPlayer = createVideoPlayer();

    verify(mockExoPlayer).setMediaItem(fakeVideoAsset.getMediaItem());
    verify(mockExoPlayer).prepare();

    verify(mockExoPlayer).setAudioAttributes(attributesCaptor.capture(), eq(true));
    assertEquals(C.AUDIO_CONTENT_TYPE_MOVIE, attributesCaptor.getValue().contentType);

    videoPlayer.dispose();
  }

  @Test
  public void loadsAndPreparesProvidedMediaDisablesAudioFocusWhenMixModeSet() {
    VideoPlayerOptions options = new VideoPlayerOptions();
    options.mixWithOthers = true;

    VideoPlayer videoPlayer = createVideoPlayer(options);

    verify(mockExoPlayer).setAudioAttributes(attributesCaptor.capture(), eq(false));
    assertEquals(C.AUDIO_CONTENT_TYPE_MOVIE, attributesCaptor.getValue().contentType);

    videoPlayer.dispose();
  }

  @Test
  public void playsAndPausesProvidedMedia() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.play();
    verify(mockExoPlayer).play();

    videoPlayer.pause();
    verify(mockExoPlayer).pause();

    videoPlayer.dispose();
  }

  @Test
  public void togglesLoopingEnablesAndDisablesRepeatMode() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.setLooping(true);
    verify(mockExoPlayer).setRepeatMode(Player.REPEAT_MODE_ALL);

    videoPlayer.setLooping(false);
    verify(mockExoPlayer).setRepeatMode(Player.REPEAT_MODE_OFF);

    videoPlayer.dispose();
  }

  @Test
  public void setVolumeIsClampedBetween0and1() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.setVolume(-1.0);
    verify(mockExoPlayer).setVolume(0f);

    videoPlayer.setVolume(2.0);
    verify(mockExoPlayer).setVolume(1f);

    videoPlayer.setVolume(0.5);
    verify(mockExoPlayer).setVolume(0.5f);

    videoPlayer.dispose();
  }

  @Test
  public void setPlaybackSpeedSetsPlaybackParametersWithValue() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.setPlaybackSpeed(2.5);
    verify(mockExoPlayer).setPlaybackParameters(new PlaybackParameters(2.5f));

    videoPlayer.dispose();
  }

  @Test
  public void seekTo() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.seekTo(10L);
    verify(mockExoPlayer).seekTo(10);

    videoPlayer.dispose();
  }

  @Test
  public void getCurrentPosition() {
    VideoPlayer videoPlayer = createVideoPlayer();

    final long playbackPosition = 20L;
    when(mockExoPlayer.getCurrentPosition()).thenReturn(playbackPosition);

    final Long position = videoPlayer.getCurrentPosition();
    assertEquals(playbackPosition, position.longValue());

    videoPlayer.dispose();
  }

  @Test
  public void getBufferedPosition() {
    VideoPlayer videoPlayer = createVideoPlayer();

    final long bufferedPosition = 10L;
    when(mockExoPlayer.getBufferedPosition()).thenReturn(bufferedPosition);

    final Long position = videoPlayer.getBufferedPosition();
    assertEquals(bufferedPosition, position.longValue());

    videoPlayer.dispose();
  }

  @Test
  public void onInitializedCalledWhenVideoPlayerInitiallyAvailable() {
    VideoPlayer videoPlayer = createVideoPlayer();

    // Pretend we have a video, and capture the registered event listener.
    when(mockExoPlayer.getVideoFormat())
        .thenReturn(
            new Format.Builder().setWidth(300).setHeight(200).setRotationDegrees(0).build());
    verify(mockExoPlayer).addListener(listenerCaptor.capture());
    Player.Listener listener = listenerCaptor.getValue();

    // Trigger an event that would trigger onInitialized.
    listener.onPlaybackStateChanged(Player.STATE_READY);
    verify(mockEvents).onInitialized(anyInt(), anyInt(), anyLong(), anyInt());

    videoPlayer.dispose();
  }

  @Test
  public void disposeReleasesExoPlayer() {
    VideoPlayer videoPlayer = createVideoPlayer();

    videoPlayer.dispose();

    verify(mockExoPlayer).release();
  }

  // Helper method to set the length field on a mocked Tracks.Group
  private void setGroupLength(Tracks.Group group, int length) {
    try {
      Field lengthField = group.getClass().getDeclaredField("length");
      lengthField.setAccessible(true);
      lengthField.setInt(group, length);
    } catch (Exception e) {
      throw new RuntimeException("Failed to set length field", e);
    }
  }

  @Test
  public void testGetAudioTracks_withMultipleAudioTracks() {
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup1 = mock(Tracks.Group.class);
    Tracks.Group mockAudioGroup2 = mock(Tracks.Group.class);
    Tracks.Group mockVideoGroup = mock(Tracks.Group.class);

    // Create mock formats for audio tracks
    Format audioFormat1 =
        new Format.Builder()
            .setId("audio_track_1")
            .setLabel("English")
            .setLanguage("en")
            .setAverageBitrate(128000)
            .setSampleRate(48000)
            .setChannelCount(2)
            .setCodecs("mp4a.40.2")
            .build();

    Format audioFormat2 =
        new Format.Builder()
            .setId("audio_track_2")
            .setLabel("Español")
            .setLanguage("es")
            .setAverageBitrate(96000)
            .setSampleRate(44100)
            .setChannelCount(2)
            .setCodecs("mp4a.40.2")
            .build();

    // Mock audio groups and set length field
    setGroupLength(mockAudioGroup1, 1);
    setGroupLength(mockAudioGroup2, 1);

    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(audioFormat1);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(true);

    when(mockAudioGroup2.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup2.getTrackFormat(0)).thenReturn(audioFormat2);
    when(mockAudioGroup2.isTrackSelected(0)).thenReturn(false);

    when(mockVideoGroup.getType()).thenReturn(C.TRACK_TYPE_VIDEO);

    // Mock tracks
    ImmutableList<Tracks.Group> groups =
        ImmutableList.of(mockAudioGroup1, mockAudioGroup2, mockVideoGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test the method
    NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(2, result.size());

    // Verify first track
    ExoPlayerAudioTrackData track1 = result.get(0);
    assertEquals(0L, track1.getGroupIndex());
    assertEquals(0L, track1.getTrackIndex());
    assertEquals("English", track1.getLabel());
    assertEquals("en", track1.getLanguage());
    assertTrue(track1.isSelected());
    assertEquals(Long.valueOf(128000), track1.getBitrate());
    assertEquals(Long.valueOf(48000), track1.getSampleRate());
    assertEquals(Long.valueOf(2), track1.getChannelCount());
    assertEquals("mp4a.40.2", track1.getCodec());

    // Verify second track
    ExoPlayerAudioTrackData track2 = result.get(1);
    assertEquals(1L, track2.getGroupIndex());
    assertEquals(0L, track2.getTrackIndex());
    assertEquals("Español", track2.getLabel());
    assertEquals("es", track2.getLanguage());
    assertFalse(track2.isSelected());
    assertEquals(Long.valueOf(96000), track2.getBitrate());
    assertEquals(Long.valueOf(44100), track2.getSampleRate());
    assertEquals(Long.valueOf(2), track2.getChannelCount());
    assertEquals("mp4a.40.2", track2.getCodec());

    videoPlayer.dispose();
  }

  @Test
  public void testGetAudioTracks_withNoAudioTracks() {
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockVideoGroup = mock(Tracks.Group.class);

    // Mock video group only (no audio tracks)
    when(mockVideoGroup.getType()).thenReturn(C.TRACK_TYPE_VIDEO);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockVideoGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test the method
    NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(0, result.size());

    videoPlayer.dispose();
  }

  @Test
  public void testGetAudioTracks_withNullValues() {
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup1 = mock(Tracks.Group.class);

    // Create format with null/missing values
    Format audioFormat =
        new Format.Builder()
            .setId("audio_track_null")
            .setLabel(null) // Null label
            .setLanguage(null) // Null language
            .setAverageBitrate(Format.NO_VALUE) // No bitrate
            .setSampleRate(Format.NO_VALUE) // No sample rate
            .setChannelCount(Format.NO_VALUE) // No channel count
            .setCodecs(null) // Null codec
            .build();

    // Mock audio group and set length field
    setGroupLength(mockAudioGroup1, 1);
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(audioFormat);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(false);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test the method
    NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(1, result.size());

    ExoPlayerAudioTrackData track = result.get(0);
    assertEquals(0L, track.getGroupIndex());
    assertEquals(0L, track.getTrackIndex());
    assertNull(track.getLabel()); // Null values should be preserved
    assertNull(track.getLanguage()); // Null values should be preserved
    assertFalse(track.isSelected());
    assertNull(track.getBitrate());
    assertNull(track.getSampleRate());
    assertNull(track.getChannelCount());
    assertNull(track.getCodec());

    videoPlayer.dispose();
  }

  @Test
  public void testGetAudioTracks_withMultipleTracksInSameGroup() {
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup1 = mock(Tracks.Group.class);

    // Create format for group with multiple tracks
    Format audioFormat1 =
        new Format.Builder()
            .setId("audio_track_1")
            .setLabel("Track 1")
            .setLanguage("en")
            .setAverageBitrate(128000)
            .build();

    Format audioFormat2 =
        new Format.Builder()
            .setId("audio_track_2")
            .setLabel("Track 2")
            .setLanguage("en")
            .setAverageBitrate(192000)
            .build();

    // Mock audio group with multiple tracks
    setGroupLength(mockAudioGroup1, 2);
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(audioFormat1);
    when(mockAudioGroup1.getTrackFormat(1)).thenReturn(audioFormat2);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(true);
    when(mockAudioGroup1.isTrackSelected(1)).thenReturn(false);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test the method
    NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(2, result.size());

    // Verify track indices are correct
    ExoPlayerAudioTrackData track1 = result.get(0);
    ExoPlayerAudioTrackData track2 = result.get(1);
    assertEquals(0L, track1.getGroupIndex());
    assertEquals(0L, track1.getTrackIndex());
    assertEquals(0L, track2.getGroupIndex());
    assertEquals(1L, track2.getTrackIndex());
    // Tracks have same group but different track indices
    assertEquals(track1.getGroupIndex(), track2.getGroupIndex());
    assertNotEquals(track1.getTrackIndex(), track2.getTrackIndex());

    videoPlayer.dispose();
  }

  @Test
  public void testSelectAudioTrack_validIndices() {
    DefaultTrackSelector mockTrackSelector = mock(DefaultTrackSelector.class);
    DefaultTrackSelector.Parameters mockParameters = mock(DefaultTrackSelector.Parameters.class);
    DefaultTrackSelector.Parameters.Builder mockBuilder =
        mock(DefaultTrackSelector.Parameters.Builder.class);

    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup = mock(Tracks.Group.class);

    Format audioFormat =
        new Format.Builder().setId("audio_track_1").setLabel("English").setLanguage("en").build();

    // Create a real TrackGroup with the format
    TrackGroup trackGroup = new TrackGroup(audioFormat);

    // Mock audio group with 2 tracks
    setGroupLength(mockAudioGroup, 2);
    when(mockAudioGroup.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup.getMediaTrackGroup()).thenReturn(trackGroup);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup);
    when(mockTracks.getGroups()).thenReturn(groups);

    // Set up track selector BEFORE creating VideoPlayer
    when(mockExoPlayer.getTrackSelector()).thenReturn(mockTrackSelector);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);
    when(mockTrackSelector.buildUponParameters()).thenReturn(mockBuilder);
    when(mockBuilder.setOverrideForType(any(TrackSelectionOverride.class))).thenReturn(mockBuilder);
    when(mockBuilder.build()).thenReturn(mockParameters);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test selecting a valid audio track
    videoPlayer.selectAudioTrack(0, 0);

    // Verify track selector was called
    verify(mockTrackSelector).buildUponParameters();
    verify(mockBuilder).setOverrideForType(any(TrackSelectionOverride.class));
    verify(mockBuilder).build();
    verify(mockTrackSelector).setParameters(mockParameters);

    videoPlayer.dispose();
  }

  @Test
  public void testSelectAudioTrack_nullTrackSelector() {
    // Track selector is null by default in mock
    VideoPlayer videoPlayer = createVideoPlayer();

    assertThrows(IllegalStateException.class, () -> videoPlayer.selectAudioTrack(0, 0));

    videoPlayer.dispose();
  }

  @Test
  public void testSelectAudioTrack_invalidGroupIndex() {
    DefaultTrackSelector mockTrackSelector = mock(DefaultTrackSelector.class);
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup = mock(Tracks.Group.class);

    Format audioFormat =
        new Format.Builder().setId("audio_track_1").setLabel("English").setLanguage("en").build();

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);
    when(mockExoPlayer.getTrackSelector()).thenReturn(mockTrackSelector);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test with invalid group index (only 1 group exists at index 0)
    assertThrows(IllegalArgumentException.class, () -> videoPlayer.selectAudioTrack(5, 0));

    videoPlayer.dispose();
  }

  @Test
  public void testSelectAudioTrack_invalidTrackIndex() {
    DefaultTrackSelector mockTrackSelector = mock(DefaultTrackSelector.class);
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup = mock(Tracks.Group.class);

    Format audioFormat =
        new Format.Builder().setId("audio_track_1").setLabel("English").setLanguage("en").build();

    // Mock audio group with only 1 track
    setGroupLength(mockAudioGroup, 1);
    when(mockAudioGroup.getType()).thenReturn(C.TRACK_TYPE_AUDIO);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);
    when(mockExoPlayer.getTrackSelector()).thenReturn(mockTrackSelector);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test with invalid track index (only 1 track exists at index 0)
    assertThrows(IllegalArgumentException.class, () -> videoPlayer.selectAudioTrack(0, 5));

    videoPlayer.dispose();
  }

  @Test
  public void testSelectAudioTrack_nonAudioGroup() {
    DefaultTrackSelector mockTrackSelector = mock(DefaultTrackSelector.class);
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockVideoGroup = mock(Tracks.Group.class);

    // Mock video group (not audio)
    setGroupLength(mockVideoGroup, 1);
    when(mockVideoGroup.getType()).thenReturn(C.TRACK_TYPE_VIDEO);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockVideoGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);
    when(mockExoPlayer.getTrackSelector()).thenReturn(mockTrackSelector);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test selecting from a non-audio group
    assertThrows(IllegalArgumentException.class, () -> videoPlayer.selectAudioTrack(0, 0));

    videoPlayer.dispose();
  }

  @Test
  public void testSelectAudioTrack_negativeIndices() {
    DefaultTrackSelector mockTrackSelector = mock(DefaultTrackSelector.class);
    Tracks mockTracks = mock(Tracks.class);
    Tracks.Group mockAudioGroup = mock(Tracks.Group.class);

    Format audioFormat =
        new Format.Builder().setId("audio_track_1").setLabel("English").setLanguage("en").build();

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);
    when(mockExoPlayer.getTrackSelector()).thenReturn(mockTrackSelector);

    VideoPlayer videoPlayer = createVideoPlayer();

    // Test with negative indices - should be caught by bounds checking
    assertThrows(IllegalArgumentException.class, () -> videoPlayer.selectAudioTrack(-1, 0));

    videoPlayer.dispose();
  }
}
