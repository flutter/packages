// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import static org.junit.Assert.*;
import static org.mockito.Mockito.*;

import androidx.media3.common.C;
import androidx.media3.common.Format;
import androidx.media3.common.Tracks;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.view.TextureRegistry;
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
  @Mock private Tracks mockTracks;
  @Mock private Tracks.Group mockAudioGroup1;
  @Mock private Tracks.Group mockAudioGroup2;
  @Mock private Tracks.Group mockVideoGroup;

  private VideoPlayer videoPlayer;

  @Before
  public void setUp() {
    MockitoAnnotations.openMocks(this);
    
    // Create a concrete VideoPlayer implementation for testing
    videoPlayer = new VideoPlayer(
        mockVideoPlayerCallbacks,
        mockSurfaceProducer,
        () -> mockExoPlayer
    ) {};
  }

  @Test
  public void testGetAudioTracks_withMultipleAudioTracks() {
    // Create mock formats for audio tracks
    Format audioFormat1 = new Format.Builder()
        .setId("audio_track_1")
        .setLabel("English")
        .setLanguage("en")
        .setBitrate(128000)
        .setSampleRate(48000)
        .setChannelCount(2)
        .setCodecs("mp4a.40.2")
        .build();

    Format audioFormat2 = new Format.Builder()
        .setId("audio_track_2")
        .setLabel("Español")
        .setLanguage("es")
        .setBitrate(96000)
        .setSampleRate(44100)
        .setChannelCount(2)
        .setCodecs("mp4a.40.2")
        .build();

    // Mock audio groups
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.length()).thenReturn(1);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(audioFormat1);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(true);

    when(mockAudioGroup2.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup2.length()).thenReturn(1);
    when(mockAudioGroup2.getTrackFormat(0)).thenReturn(audioFormat2);
    when(mockAudioGroup2.isTrackSelected(0)).thenReturn(false);

    // Mock video group (should be ignored)
    when(mockVideoGroup.getType()).thenReturn(C.TRACK_TYPE_VIDEO);

    // Mock tracks
    List<Tracks.Group> groups = List.of(mockAudioGroup1, mockAudioGroup2, mockVideoGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(2, result.size());

    // Verify first track
    Messages.AudioTrackMessage track1 = result.get(0);
    assertEquals("0_0", track1.getId());
    assertEquals("English", track1.getLabel());
    assertEquals("en", track1.getLanguage());
    assertTrue(track1.getIsSelected());
    assertEquals(Long.valueOf(128000), track1.getBitrate());
    assertEquals(Long.valueOf(48000), track1.getSampleRate());
    assertEquals(Long.valueOf(2), track1.getChannelCount());
    assertEquals("mp4a.40.2", track1.getCodec());

    // Verify second track
    Messages.AudioTrackMessage track2 = result.get(1);
    assertEquals("1_0", track2.getId());
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

    List<Tracks.Group> groups = List.of(mockVideoGroup);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(0, result.size());
  }

  @Test
  public void testGetAudioTracks_withNullValues() {
    // Create format with null/missing values
    Format audioFormat = new Format.Builder()
        .setId("audio_track_null")
        .setLabel(null) // Null label
        .setLanguage(null) // Null language
        .setBitrate(Format.NO_VALUE) // No bitrate
        .setSampleRate(Format.NO_VALUE) // No sample rate
        .setChannelCount(Format.NO_VALUE) // No channel count
        .setCodecs(null) // Null codec
        .build();

    // Mock audio group
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.length()).thenReturn(1);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(audioFormat);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(false);

    List<Tracks.Group> groups = List.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(1, result.size());

    Messages.AudioTrackMessage track = result.get(0);
    assertEquals("0_0", track.getId());
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
    Format audioFormat1 = new Format.Builder()
        .setId("audio_track_1")
        .setLabel("Track 1")
        .setLanguage("en")
        .setBitrate(128000)
        .build();

    Format audioFormat2 = new Format.Builder()
        .setId("audio_track_2")
        .setLabel("Track 2")
        .setLanguage("en")
        .setBitrate(192000)
        .build();

    // Mock audio group with multiple tracks
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.length()).thenReturn(2);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(audioFormat1);
    when(mockAudioGroup1.getTrackFormat(1)).thenReturn(audioFormat2);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(true);
    when(mockAudioGroup1.isTrackSelected(1)).thenReturn(false);

    List<Tracks.Group> groups = List.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(2, result.size());

    // Verify track IDs are unique
    Messages.AudioTrackMessage track1 = result.get(0);
    Messages.AudioTrackMessage track2 = result.get(1);
    assertEquals("0_0", track1.getId());
    assertEquals("0_1", track2.getId());
    assertNotEquals(track1.getId(), track2.getId());
  }

  @Test
  public void testGetAudioTracks_withDifferentCodecs() {
    // Test various codec formats
    Format aacFormat = new Format.Builder()
        .setCodecs("mp4a.40.2")
        .setLabel("AAC Track")
        .build();

    Format ac3Format = new Format.Builder()
        .setCodecs("ac-3")
        .setLabel("AC3 Track")
        .build();

    Format eac3Format = new Format.Builder()
        .setCodecs("ec-3")
        .setLabel("EAC3 Track")
        .build();

    // Mock audio groups
    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.length()).thenReturn(3);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(aacFormat);
    when(mockAudioGroup1.getTrackFormat(1)).thenReturn(ac3Format);
    when(mockAudioGroup1.getTrackFormat(2)).thenReturn(eac3Format);
    when(mockAudioGroup1.isTrackSelected(anyInt())).thenReturn(false);

    List<Tracks.Group> groups = List.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();

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
    Format highBitrateFormat = new Format.Builder()
        .setId("high_bitrate_track")
        .setLabel("High Quality")
        .setBitrate(1536000) // 1.5 Mbps
        .setSampleRate(96000) // 96 kHz
        .setChannelCount(8) // 7.1 surround
        .build();

    when(mockAudioGroup1.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
    when(mockAudioGroup1.length()).thenReturn(1);
    when(mockAudioGroup1.getTrackFormat(0)).thenReturn(highBitrateFormat);
    when(mockAudioGroup1.isTrackSelected(0)).thenReturn(true);

    List<Tracks.Group> groups = List.of(mockAudioGroup1);
    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Test the method
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();

    // Verify results
    assertNotNull(result);
    assertEquals(1, result.size());

    Messages.AudioTrackMessage track = result.get(0);
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
      Tracks.Group mockGroup = mock(Tracks.Group.class);
      when(mockGroup.getType()).thenReturn(C.TRACK_TYPE_AUDIO);
      when(mockGroup.length()).thenReturn(1);
      
      Format format = new Format.Builder()
          .setId("track_" + i)
          .setLabel("Track " + i)
          .setLanguage("en")
          .build();
      
      when(mockGroup.getTrackFormat(0)).thenReturn(format);
      when(mockGroup.isTrackSelected(0)).thenReturn(i == 0); // Only first track selected
      
      groups.add(mockGroup);
    }

    when(mockTracks.getGroups()).thenReturn(groups);
    when(mockExoPlayer.getCurrentTracks()).thenReturn(mockTracks);

    // Measure performance
    long startTime = System.currentTimeMillis();
    List<Messages.AudioTrackMessage> result = videoPlayer.getAudioTracks();
    long endTime = System.currentTimeMillis();

    // Verify results
    assertNotNull(result);
    assertEquals(numGroups, result.size());
    
    // Should complete within reasonable time (1 second for 50 tracks)
    assertTrue("getAudioTracks took too long: " + (endTime - startTime) + "ms", 
               (endTime - startTime) < 1000);
  }
}
