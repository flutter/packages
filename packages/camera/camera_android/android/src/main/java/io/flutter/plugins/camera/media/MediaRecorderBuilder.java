// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.MediaRecorder;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugins.camera.SdkCapabilityChecker;
import java.io.IOException;

public class MediaRecorderBuilder {
  @SuppressWarnings("deprecation")
  static class MediaRecorderFactory {
    MediaRecorder makeMediaRecorder() {
      return new MediaRecorder();
    }
  }

  public static class RecordingParameters {
    @NonNull public final String outputFilePath;
    @Nullable public final Integer fps;
    @Nullable public final Integer videoBitrate;
    @Nullable public final Integer audioBitrate;

    public RecordingParameters(@NonNull String outputFilePath) {
      this(outputFilePath, null, null, null);
    }

    public RecordingParameters(
        @NonNull String outputFilePath,
        @Nullable Integer fps,
        @Nullable Integer videoBitrate,
        @Nullable Integer audioBitrate) {
      this.outputFilePath = outputFilePath;
      this.fps = fps;
      this.videoBitrate = videoBitrate;
      this.audioBitrate = audioBitrate;
    }
  }

  private final CamcorderProfile camcorderProfile;
  private final EncoderProfiles encoderProfiles;
  private final MediaRecorderFactory recorderFactory;
  @NonNull private final RecordingParameters parameters;

  private boolean enableAudio;
  private int mediaOrientation;

  public MediaRecorderBuilder(
      @NonNull CamcorderProfile camcorderProfile, @NonNull RecordingParameters parameters) {
    this(camcorderProfile, new MediaRecorderFactory(), parameters);
  }

  public MediaRecorderBuilder(
      @NonNull EncoderProfiles encoderProfiles, @NonNull RecordingParameters parameters) {
    this(encoderProfiles, new MediaRecorderFactory(), parameters);
  }

  MediaRecorderBuilder(
      @NonNull CamcorderProfile camcorderProfile,
      MediaRecorderFactory helper,
      @NonNull RecordingParameters parameters) {
    this.camcorderProfile = camcorderProfile;
    this.encoderProfiles = null;
    this.recorderFactory = helper;
    this.parameters = parameters;
  }

  MediaRecorderBuilder(
      @NonNull EncoderProfiles encoderProfiles,
      MediaRecorderFactory helper,
      @NonNull RecordingParameters parameters) {
    this.encoderProfiles = encoderProfiles;
    this.camcorderProfile = null;
    this.recorderFactory = helper;
    this.parameters = parameters;
  }

  @NonNull
  public MediaRecorderBuilder setEnableAudio(boolean enableAudio) {
    this.enableAudio = enableAudio;
    return this;
  }

  @NonNull
  public MediaRecorderBuilder setMediaOrientation(int orientation) {
    this.mediaOrientation = orientation;
    return this;
  }

  @NonNull
  public MediaRecorder build() throws IOException, NullPointerException, IndexOutOfBoundsException {
    MediaRecorder mediaRecorder = recorderFactory.makeMediaRecorder();

    // There's a fixed order that mediaRecorder expects. Only change these functions accordingly.
    // You can find the specifics here: https://developer.android.com/reference/android/media/MediaRecorder.
    if (enableAudio) mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);

    if (SdkCapabilityChecker.supportsEncoderProfiles() && encoderProfiles != null) {
      mediaRecorder.setOutputFormat(encoderProfiles.getRecommendedFileFormat());

      EncoderProfiles.VideoProfile videoProfile = encoderProfiles.getVideoProfiles().get(0);

      if (enableAudio) {
        EncoderProfiles.AudioProfile audioProfile = encoderProfiles.getAudioProfiles().get(0);

        mediaRecorder.setAudioEncoder(audioProfile.getCodec());
        mediaRecorder.setAudioEncodingBitRate(
            (parameters.audioBitrate != null && parameters.audioBitrate.intValue() > 0)
                ? parameters.audioBitrate
                : audioProfile.getBitrate());
        mediaRecorder.setAudioSamplingRate(audioProfile.getSampleRate());
      }

      mediaRecorder.setVideoEncoder(videoProfile.getCodec());

      int videoBitrate =
          (parameters.videoBitrate != null && parameters.videoBitrate.intValue() > 0)
              ? parameters.videoBitrate
              : videoProfile.getBitrate();

      mediaRecorder.setVideoEncodingBitRate(videoBitrate);

      int fps =
          (parameters.fps != null && parameters.fps.intValue() > 0)
              ? parameters.fps
              : videoProfile.getFrameRate();

      mediaRecorder.setVideoFrameRate(fps);

      mediaRecorder.setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
    } else if (camcorderProfile != null) {
      mediaRecorder.setOutputFormat(camcorderProfile.fileFormat);
      if (enableAudio) {
        mediaRecorder.setAudioEncoder(camcorderProfile.audioCodec);
        mediaRecorder.setAudioEncodingBitRate(
            (parameters.audioBitrate != null && parameters.audioBitrate.intValue() > 0)
                ? parameters.audioBitrate
                : camcorderProfile.audioBitRate);
        mediaRecorder.setAudioSamplingRate(camcorderProfile.audioSampleRate);
      }
      mediaRecorder.setVideoEncoder(camcorderProfile.videoCodec);
      mediaRecorder.setVideoEncodingBitRate(
          (parameters.videoBitrate != null && parameters.videoBitrate.intValue() > 0)
              ? parameters.videoBitrate
              : camcorderProfile.videoBitRate);
      mediaRecorder.setVideoFrameRate(
          (parameters.fps != null && parameters.fps.intValue() > 0)
              ? parameters.fps
              : camcorderProfile.videoFrameRate);
      mediaRecorder.setVideoSize(
          camcorderProfile.videoFrameWidth, camcorderProfile.videoFrameHeight);
    }

    mediaRecorder.setOutputFile(parameters.outputFilePath);
    mediaRecorder.setOrientationHint(this.mediaOrientation);

    mediaRecorder.prepare();

    return mediaRecorder;
  }
}
