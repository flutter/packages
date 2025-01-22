// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.MediaRecorder;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class MediaRecorderBuilderTest {

  private static final int testVideoBitrate = 200000;
  private static final int testFps = 15;
  private static final int testAudioBitrate = 32000;

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void ctor_testLegacy() {
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
            CamcorderProfile.get(CamcorderProfile.QUALITY_1080P),
            new MediaRecorderBuilder.RecordingParameters(""));

    assertNotNull(builder);
  }

  @Config(minSdk = 31)
  @Test
  public void ctor_test() {
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
            CamcorderProfile.getAll("0", CamcorderProfile.QUALITY_1080P),
            new MediaRecorderBuilder.RecordingParameters(""));

    assertNotNull(builder);
  }

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void ctor_testDefaultsLegacy() {
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
            CamcorderProfile.get(CamcorderProfile.QUALITY_1080P),
            new MediaRecorderBuilder.RecordingParameters(""));

    assertNotNull(builder);
  }

  @Config(minSdk = 31)
  @Test
  public void ctor_testDefaults() {
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
            CamcorderProfile.getAll("0", CamcorderProfile.QUALITY_1080P),
            new MediaRecorderBuilder.RecordingParameters(""));

    assertNotNull(builder);
  }

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsDisabledLegacy() throws IOException {
    CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
                recorderProfile,
                mockFactory,
                new MediaRecorderBuilder.RecordingParameters(
                    outputFilePath, testFps, testVideoBitrate, null))
            .setEnableAudio(false)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);

    MediaRecorder recorder = builder.build();

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.fileFormat);
    inOrder.verify(recorder).setVideoEncoder(recorderProfile.videoCodec);
    inOrder.verify(recorder).setVideoEncodingBitRate(testVideoBitrate);
    inOrder.verify(recorder).setVideoFrameRate(testFps);
    inOrder
        .verify(recorder)
        .setVideoSize(recorderProfile.videoFrameWidth, recorderProfile.videoFrameHeight);
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  @Config(minSdk = 31)
  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsDisabled() throws IOException {
    EncoderProfiles recorderProfile = mock(EncoderProfiles.class);
    List<EncoderProfiles.VideoProfile> mockVideoProfiles =
        List.of(getEmptyEncoderProfilesVideoProfile());
    List<EncoderProfiles.AudioProfile> mockAudioProfiles =
        List.of(getEmptyEncoderProfilesAudioProfile());
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
                recorderProfile,
                mockFactory,
                new MediaRecorderBuilder.RecordingParameters(
                    outputFilePath, testFps, testVideoBitrate, null))
            .setEnableAudio(false)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);
    when(recorderProfile.getVideoProfiles()).thenReturn(mockVideoProfiles);
    when(recorderProfile.getAudioProfiles()).thenReturn(mockAudioProfiles);

    MediaRecorder recorder = builder.build();

    EncoderProfiles.VideoProfile videoProfile = mockVideoProfiles.get(0);

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.getRecommendedFileFormat());
    inOrder.verify(recorder).setVideoEncoder(videoProfile.getCodec());
    inOrder.verify(recorder).setVideoEncodingBitRate(testVideoBitrate);
    inOrder.verify(recorder).setVideoFrameRate(testFps);
    inOrder.verify(recorder).setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  @Config(minSdk = 31)
  @Test(expected = IndexOutOfBoundsException.class)
  public void build_shouldThrowExceptionWithoutVideoOrAudioProfiles() throws IOException {
    EncoderProfiles recorderProfile = mock(EncoderProfiles.class);
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
                recorderProfile,
                mockFactory,
                new MediaRecorderBuilder.RecordingParameters(outputFilePath))
            .setEnableAudio(false)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);

    MediaRecorder recorder = builder.build();
  }

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsEnabledLegacy() throws IOException {
    CamcorderProfile recorderProfile = getEmptyCamcorderProfile();
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
                recorderProfile,
                mockFactory,
                new MediaRecorderBuilder.RecordingParameters(
                    outputFilePath, testFps, testVideoBitrate, testAudioBitrate))
            .setEnableAudio(true)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);

    MediaRecorder recorder = builder.build();

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setAudioSource(MediaRecorder.AudioSource.MIC);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.fileFormat);
    inOrder.verify(recorder).setAudioEncoder(recorderProfile.audioCodec);
    inOrder.verify(recorder).setAudioEncodingBitRate(testAudioBitrate);
    inOrder.verify(recorder).setAudioSamplingRate(recorderProfile.audioSampleRate);
    inOrder.verify(recorder).setVideoEncoder(recorderProfile.videoCodec);
    inOrder.verify(recorder).setVideoEncodingBitRate(testVideoBitrate);
    inOrder.verify(recorder).setVideoFrameRate(testFps);
    inOrder
        .verify(recorder)
        .setVideoSize(recorderProfile.videoFrameWidth, recorderProfile.videoFrameHeight);
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  @Config(minSdk = 31)
  @Test
  public void build_shouldSetValuesInCorrectOrderWhenAudioIsEnabled() throws IOException {
    EncoderProfiles recorderProfile = mock(EncoderProfiles.class);
    List<EncoderProfiles.VideoProfile> mockVideoProfiles =
        List.of(getEmptyEncoderProfilesVideoProfile());
    List<EncoderProfiles.AudioProfile> mockAudioProfiles =
        List.of(getEmptyEncoderProfilesAudioProfile());
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    MediaRecorder mockMediaRecorder = mock(MediaRecorder.class);
    String outputFilePath = "mock_video_file_path";
    int mediaOrientation = 1;
    MediaRecorderBuilder builder =
        new MediaRecorderBuilder(
                recorderProfile,
                mockFactory,
                new MediaRecorderBuilder.RecordingParameters(
                    outputFilePath, testFps, testVideoBitrate, testAudioBitrate))
            .setEnableAudio(true)
            .setMediaOrientation(mediaOrientation);

    when(mockFactory.makeMediaRecorder()).thenReturn(mockMediaRecorder);
    when(recorderProfile.getVideoProfiles()).thenReturn(mockVideoProfiles);
    when(recorderProfile.getAudioProfiles()).thenReturn(mockAudioProfiles);

    MediaRecorder recorder = builder.build();

    EncoderProfiles.VideoProfile videoProfile = mockVideoProfiles.get(0);
    EncoderProfiles.AudioProfile audioProfile = mockAudioProfiles.get(0);

    InOrder inOrder = inOrder(recorder);
    inOrder.verify(recorder).setAudioSource(MediaRecorder.AudioSource.MIC);
    inOrder.verify(recorder).setVideoSource(MediaRecorder.VideoSource.SURFACE);
    inOrder.verify(recorder).setOutputFormat(recorderProfile.getRecommendedFileFormat());
    inOrder.verify(recorder).setAudioEncoder(audioProfile.getCodec());
    inOrder.verify(recorder).setAudioEncodingBitRate(testAudioBitrate);
    inOrder.verify(recorder).setAudioSamplingRate(audioProfile.getSampleRate());
    inOrder.verify(recorder).setVideoEncoder(videoProfile.getCodec());
    inOrder.verify(recorder).setVideoEncodingBitRate(testVideoBitrate);
    inOrder.verify(recorder).setVideoFrameRate(testFps);
    inOrder.verify(recorder).setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
    inOrder.verify(recorder).setOutputFile(outputFilePath);
    inOrder.verify(recorder).setOrientationHint(mediaOrientation);
    inOrder.verify(recorder).prepare();
  }

  private CamcorderProfile getEmptyCamcorderProfile() {
    try {
      Constructor<CamcorderProfile> constructor =
          CamcorderProfile.class.getDeclaredConstructor(
              int.class, int.class, int.class, int.class, int.class, int.class, int.class,
              int.class, int.class, int.class, int.class, int.class);

      constructor.setAccessible(true);
      return constructor.newInstance(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    } catch (Exception ignored) {
    }

    return null;
  }

  private EncoderProfiles.VideoProfile getEmptyEncoderProfilesVideoProfile() {
    try {
      Constructor<EncoderProfiles.VideoProfile> constructor =
          EncoderProfiles.VideoProfile.class.getDeclaredConstructor(
              int.class, int.class, int.class, int.class, int.class, int.class);

      constructor.setAccessible(true);
      return constructor.newInstance(0, 0, 0, 0, 0, 0);
    } catch (Exception ignored) {
    }

    return null;
  }

  private EncoderProfiles.AudioProfile getEmptyEncoderProfilesAudioProfile() {
    try {
      Constructor<EncoderProfiles.AudioProfile> constructor =
          EncoderProfiles.AudioProfile.class.getDeclaredConstructor(
              int.class, int.class, int.class, int.class, int.class);

      constructor.setAccessible(true);
      return constructor.newInstance(0, 0, 0, 0, 0);
    } catch (Exception ignored) {
    }

    return null;
  }
}
