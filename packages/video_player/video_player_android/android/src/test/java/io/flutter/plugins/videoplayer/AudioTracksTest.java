// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;
import com.google.common.collect.ImmutableList;
import io.flutter.view.TextureRegistry;
import java.lang.reflect.Field;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class AudioTracksTest {

  @Mock private ExoPlayer mockExoPlayer;
  @Mock private VideoPlayerCallbacks mockVideoPlayerCallbacks;
  @Mock private TextureRegistry.SurfaceProducer mockSurfaceProducer;
  @Mock private MediaItem mockMediaItem;
  @Mock private VideoPlayerOptions mockVideoPlayerOptions;
  @Mock private Tracks mockTracks;
  @Mock private Tracks.Group mockAudioGroup1;
  @Mock private Tracks.Group mockAudioGroup2;
  @Mock private Tracks.Group mockVideoGroup;

  private VideoPlayer videoPlayer;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);

    // Create a concrete VideoPlayer implementation for testing
    videoPlayer =
        new VideoPlayer(
            mockVideoPlayerCallbacks,
            mockMediaItem,
            mockVideoPlayerOptions,
            mockSurfaceProducer,
            () -> mockExoPlayer) {
          @Override
          protected ExoPlayerEventListener createExoPlayerEventListener(
              ExoPlayer exoPlayer, TextureRegistry.SurfaceProducer surfaceProducer) {
            return mock(ExoPlayerEventListener.class);
          }
        };
  }

  // Helper method to set the length field on a mocked Tracks.Group
  private void setGroupLength(Tracks.Group group, int length) {
    try {
      Field lengthField = group.getClass().getDeclaredField("length");
      lengthField.setAccessible(true);
      lengthField.setInt(group, length);
    } catch (Exception e) {
      // If reflection fails, we'll handle it in the test
      throw new RuntimeException("Failed to set length field", e);
    }
  }

  @Test
  public void testGetAudioTracks_withMultipleAudioTracks() {
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

    // Test the method
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(2, result.size());

    // Verify first track
    Messages.ExoPlayerAudioTrackData track1 = result.get(0);
    assertEquals("0_0", track1.getTrackId());
    assertEquals("English", track1.getLabel());
    assertEquals("en", track1.getLanguage());
    assertTrue(track1.getIsSelected());
    assertEquals(Long.valueOf(128000), track1.getBitrate());
    assertEquals(Long.valueOf(48000), track1.getSampleRate());
    assertEquals(Long.valueOf(2), track1.getChannelCount());
    assertEquals("mp4a.40.2", track1.getCodec());

    // Verify second track
    Messages.ExoPlayerAudioTrackData track2 = result.get(1);
    assertEquals("1_0", track2.getTrackId());
    assertEquals("Español", track2.getLabel());
    assertEquals("es", track2.getLanguage());
    assertFalse(track2.getIsSelected());
    assertEquals(Long.valueOf(96000), track2.getBitrate());
    assertEquals(Long.valueOf(44100), track2.getSampleRate());
    assertEquals(Long.valueOf(2), track2.getChannelCount());
    assertEquals("mp4a.40.2", track2.getCodec());
  }

  @Test
  public void testGetAudioTracks_withNoAudioTracks() {
    // Mock video group only (no audio tracks)
    when(mockVideoGroup.getType()).thenReturn(C.TRACK_TYPE_VIDEO);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockVideoGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(0, result.size());
  }

  @Test
  public void testGetAudioTracks_withNullValues() {
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

    // Test the method
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(1, result.size());

    Messages.ExoPlayerAudioTrackData track = result.get(0);
    assertEquals("0_0", track.getTrackId());
    assertEquals("Audio Track 1", track.getLabel()); // Fallback label
    assertEquals("und", track.getLanguage()); // Fallback language
    assertFalse(track.getIsSelected());
    assertNull(track.getBitrate());
    assertNull(track.getSampleRate());
    assertNull(track.getChannelCount());
    assertNull(track.getCodec());
  }

  @Test
  public void testGetAudioTracks_withMultipleTracksInSameGroup() {
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

    // Test the method
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(2, result.size());

    // Verify track IDs are unique
    Messages.ExoPlayerAudioTrackData track1 = result.get(0);
    Messages.ExoPlayerAudioTrackData track2 = result.get(1);
    assertEquals("0_0", track1.getTrackId());
    assertEquals("0_1", track2.getTrackId());
    assertNotEquals(track1.getTrackId(), track2.getTrackId());
  }

  @Test
  public void testGetAudioTracks_withDifferentCodecs() {
    // Test various codec formats
    Format aacFormat = new Format.Builder().setCodecs("mp4a.40.2").setLabel("AAC Track").build();

    Format ac3Format = new Format.Builder().setCodecs("ac-3").setLabel("AC3 Track").build();

    Format eac3Format = new Format.Builder().setCodecs("ec-3").setLabel("EAC3 Track").build();

    // Mock audio group with different codecs
    setGroupLength(mockAudioGroup1, 3);
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(aacFormat);
    when(mockAudioGroup1.getTrackFormat(1)).thenReturn(ac3Format);
    when(mockAudioGroup1.getTrackFormat(2)).thenReturn(eac3Format);
    when(mockAudioGroup1.isTrackSelected(anyInt())).thenReturn(false);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(3, result.size());

    assertEquals("mp4a.40.2", result.get(0).getCodec());
    assertEquals("ac-3", result.get(1).getCodec());
    assertEquals("ec-3", result.get(2).getCodec());
  }

  @Test
  public void testGetAudioTracks_withHighBitrateValues() {
    // Test with high bitrate values
    Format highBitrateFormat =
        new Format.Builder()
            .setId("high_bitrate_track")
            .setLabel("High Quality")
            .setAverageBitrate(1536000) // 1.5 Mbps
            .setSampleRate(96000) // 96 kHz
            .setChannelCount(8) // 7.1 surround
            .build();

    // Mock audio group with high bitrate format
    setGroupLength(mockAudioGroup1, 1);
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(highBitrateFormat);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(true);

    ImmutableList<Tracks.Group> groups = ImmutableList.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(1, result.size());

    Messages.ExoPlayerAudioTrackData track = result.get(0);
    assertEquals(Long.valueOf(1536000), track.getBitrate());
    assertEquals(Long.valueOf(96000), track.getSampleRate());
    assertEquals(Long.valueOf(8), track.getChannelCount());
  }

  @Test
  public void testGetAudioTracks_performanceWithManyTracks() {
    // Test performance with many audio tracks
    int numGroups = 50;
    List<Tracks.Group> groups = new java.util.ArrayList<>();

    for (int i = 0; i < numGroups; i++) {
      Format format =
          new Format.Builder().setId("track_" + i).setLabel("Track " + i).setLanguage("en").build();

      Tracks.Group mockGroup = mock(Tracks.Group.class);
      setGroupLength(mockGroup, 1);
      when(mockGroup.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
      when(mockGroup.getTrackFormat(0)).thenReturn(format);
      when(mockGroup.isTrackSelected(0)).thenReturn(i == 0); // Only first track selected
      groups.add(mockGroup);
    }

    when(mockTracks.getGroups()).thenReturn(ImmutableList.copyOf(groups));
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Measure performance
    long startTime = System.currentTimeMillis();
    Messages.NativeAudioTrackData nativeData = videoPlayer.getAudioTracks();
    List<Messages.ExoPlayerAudioTrackData> result = nativeData.getExoPlayerTracks();
    long endTime = System.currentTimeMillis();

    // Verify results
    assertNotNull(result);
    assertEquals(numGroups, result.size());

    // Should complete within reasonable time (1 second for 50 tracks)
    assertTrue(
        "getAudioTracks took too long: " + (endTime - startTime) + "ms",
        (endTime - startTime) < 1000);
  }
}
