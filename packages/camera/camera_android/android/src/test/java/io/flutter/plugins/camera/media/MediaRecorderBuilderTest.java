// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.*;

import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.MediaCodecInfo;
import android.media.MediaFormat;
import android.media.MediaRecorder;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.util.List;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InOrder;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;
import org.robolectric.shadows.MediaCodecInfoBuilder;
import org.robolectric.shadows.ShadowMediaCodecList;

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

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void build_shouldSetRequestedVideoEncoderWhenSupportedLegacy() throws IOException {
    addVideoEncoder(MediaFormat.MIMETYPE_VIDEO_HEVC, 1920, 1080);

    MediaRecorder recorder =
        buildWithVideoEncoderLegacy(
            getCamcorderProfile(MediaRecorder.VideoEncoder.H264, 1280, 720),
            MediaRecorder.VideoEncoder.HEVC);

    verify(recorder).setVideoEncoder(MediaRecorder.VideoEncoder.HEVC);
  }

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void build_shouldKeepProfileVideoEncoderWhenRequestedIsUnsupportedLegacy()
      throws IOException {
    addVideoEncoder(MediaFormat.MIMETYPE_VIDEO_AVC, 1920, 1080);

    MediaRecorder recorder =
        buildWithVideoEncoderLegacy(
            getCamcorderProfile(MediaRecorder.VideoEncoder.H264, 1280, 720),
            MediaRecorder.VideoEncoder.HEVC);

    verify(recorder).setVideoEncoder(MediaRecorder.VideoEncoder.H264);
  }

  @Config(maxSdk = 30)
  @SuppressWarnings("deprecation")
  @Test
  public void build_shouldKeepProfileVideoEncoderWhenRequestedEncoderIsTooSmallLegacy()
      throws IOException {
    addVideoEncoder(MediaFormat.MIMETYPE_VIDEO_HEVC, 512, 512);

    MediaRecorder recorder =
        buildWithVideoEncoderLegacy(
            getCamcorderProfile(MediaRecorder.VideoEncoder.H264, 1280, 720),
            MediaRecorder.VideoEncoder.HEVC);

    verify(recorder).setVideoEncoder(MediaRecorder.VideoEncoder.H264);
  }

  @Config(minSdk = 31)
  @Test
  public void build_shouldSetRequestedVideoEncoderWhenSupported() throws IOException {
    addVideoEncoder(MediaFormat.MIMETYPE_VIDEO_HEVC, 1920, 1080);

    MediaRecorder recorder =
        buildWithVideoEncoder(
            getEncoderProfilesVideoProfile(MediaRecorder.VideoEncoder.H264, 1280, 720),
            MediaRecorder.VideoEncoder.HEVC);

    verify(recorder).setVideoEncoder(MediaRecorder.VideoEncoder.HEVC);
  }

  @Config(minSdk = 31)
  @Test
  public void build_shouldKeepProfileVideoEncoderWhenRequestedIsUnsupported() throws IOException {
    addVideoEncoder(MediaFormat.MIMETYPE_VIDEO_AVC, 1920, 1080);

    MediaRecorder recorder =
        buildWithVideoEncoder(
            getEncoderProfilesVideoProfile(MediaRecorder.VideoEncoder.H264, 1280, 720),
            MediaRecorder.VideoEncoder.HEVC);

    verify(recorder).setVideoEncoder(MediaRecorder.VideoEncoder.H264);
  }

  @Config(minSdk = 31)
  @Test
  public void build_shouldKeepProfileVideoEncoderWhenRequestedEncoderIsTooSmall()
      throws IOException {
    addVideoEncoder(MediaFormat.MIMETYPE_VIDEO_HEVC, 512, 512);

    MediaRecorder recorder =
        buildWithVideoEncoder(
            getEncoderProfilesVideoProfile(MediaRecorder.VideoEncoder.H264, 1280, 720),
            MediaRecorder.VideoEncoder.HEVC);

    verify(recorder).setVideoEncoder(MediaRecorder.VideoEncoder.H264);
  }

  private MediaRecorder buildWithVideoEncoder(
      EncoderProfiles.VideoProfile videoProfile, int videoEncoder) throws IOException {
    EncoderProfiles recorderProfile = mock(EncoderProfiles.class);
    when(recorderProfile.getVideoProfiles()).thenReturn(List.of(videoProfile));
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    when(mockFactory.makeMediaRecorder()).thenReturn(mock(MediaRecorder.class));

    return new MediaRecorderBuilder(
            recorderProfile,
            mockFactory,
            new MediaRecorderBuilder.RecordingParameters(
                "mock_video_file_path", null, null, null, videoEncoder))
        .build();
  }

  @SuppressWarnings("deprecation")
  private MediaRecorder buildWithVideoEncoderLegacy(
      CamcorderProfile recorderProfile, int videoEncoder) throws IOException {
    MediaRecorderBuilder.MediaRecorderFactory mockFactory =
        mock(MediaRecorderBuilder.MediaRecorderFactory.class);
    when(mockFactory.makeMediaRecorder()).thenReturn(mock(MediaRecorder.class));

    return new MediaRecorderBuilder(
            recorderProfile,
            mockFactory,
            new MediaRecorderBuilder.RecordingParameters(
                "mock_video_file_path", null, null, null, videoEncoder))
        .build();
  }

  @SuppressWarnings("deprecation")
  private CamcorderProfile getCamcorderProfile(int videoCodec, int width, int height) {
    try {
      Constructor<CamcorderProfile> constructor =
          CamcorderProfile.class.getDeclaredConstructor(
              int.class, int.class, int.class, int.class, int.class, int.class, int.class,
              int.class, int.class, int.class, int.class, int.class);

      constructor.setAccessible(true);
      return constructor.newInstance(0, 0, 0, videoCodec, 0, 0, width, height, 0, 0, 0, 0);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  private EncoderProfiles.VideoProfile getEncoderProfilesVideoProfile(
      int codec, int width, int height) {
    try {
      Constructor<EncoderProfiles.VideoProfile> constructor =
          EncoderProfiles.VideoProfile.class.getDeclaredConstructor(
              int.class, int.class, int.class, int.class, int.class, int.class);

      constructor.setAccessible(true);
      return constructor.newInstance(codec, width, height, 0, 0, 0);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  /**
   * Adds an encoder for {@code mimeType} that supports videos up to {@code maxWidth} x {@code
   * maxHeight}.
   */
  private static void addVideoEncoder(String mimeType, int maxWidth, int maxHeight) {
    // The level sets the encoder's block limits; it is high enough for 1080p.
    MediaCodecInfo.CodecProfileLevel profileLevel = new MediaCodecInfo.CodecProfileLevel();
    if (mimeType.equals(MediaFormat.MIMETYPE_VIDEO_HEVC)) {
      profileLevel.profile = MediaCodecInfo.CodecProfileLevel.HEVCProfileMain;
      profileLevel.level = MediaCodecInfo.CodecProfileLevel.HEVCMainTierLevel51;
    } else {
      profileLevel.profile = MediaCodecInfo.CodecProfileLevel.AVCProfileHigh;
      profileLevel.level = MediaCodecInfo.CodecProfileLevel.AVCLevel51;
    }
    MediaFormat format = MediaFormat.createVideoFormat(mimeType, maxWidth, maxHeight);
    // Older SDKs rebuild the capabilities from this key, so the size limit must be set here too.
    format.setString("size-range", "2x2-" + maxWidth + "x" + maxHeight);
    ShadowMediaCodecList.addCodec(
        MediaCodecInfoBuilder.newBuilder()
            .setName("fake.encoder." + mimeType)
            .setIsEncoder(true)
            .setCapabilities(
                MediaCodecInfoBuilder.CodecCapabilitiesBuilder.newBuilder()
                    .setMediaFormat(format)
                    .setIsEncoder(true)
                    .setProfileLevels(new MediaCodecInfo.CodecProfileLevel[] {profileLevel})
                    .setColorFormats(
                        new int[] {MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface})
                    .build())
            .build());
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
