// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.media.MediaRecorder;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.SdkCapabilityChecker;
import java.io.IOException;

public class MediaRecorderBuilder {
  @SuppressWarnings("deprecation")
  static class MediaRecorderFactory {
    MediaRecorder makeMediaRecorder() {
      return new MediaRecorder();
    }
  }

  private final String outputFilePath;
  private final CamcorderProfile camcorderProfile;
  private final EncoderProfiles encoderProfiles;
  private final MediaRecorderFactory recorderFactory;
  private final Integer fps;
  private final Integer videoBitrate;
  private final Integer audioBitrate;

  private boolean enableAudio;
  private int mediaOrientation;

  public MediaRecorderBuilder(
      @NonNull CamcorderProfile camcorderProfile,
      @NonNull String outputFilePath,
      @NonNull Integer fps,
      @NonNull Integer videoBitrate,
      @NonNull Integer audioBitrate) {
    this(
        camcorderProfile,
        outputFilePath,
        new MediaRecorderFactory(),
        fps,
        videoBitrate,
        audioBitrate);
  }

  public MediaRecorderBuilder(
      @NonNull EncoderProfiles encoderProfiles,
      @NonNull String outputFilePath,
      @NonNull Integer fps,
      @NonNull Integer videoBitrate,
      @NonNull Integer audioBitrate) {
    this(
        encoderProfiles,
        outputFilePath,
        new MediaRecorderFactory(),
        fps,
        videoBitrate,
        audioBitrate);
  }

  MediaRecorderBuilder(
      @NonNull CamcorderProfile camcorderProfile,
      @NonNull String outputFilePath,
      MediaRecorderFactory helper,
      @NonNull Integer fps,
      @NonNull Integer videoBitrate,
      @NonNull Integer audioBitrate) {
    this.outputFilePath = outputFilePath;
    this.camcorderProfile = camcorderProfile;
    this.encoderProfiles = null;
    this.recorderFactory = helper;
    this.fps = fps;
    this.videoBitrate = videoBitrate;
    this.audioBitrate = audioBitrate;
  }

  MediaRecorderBuilder(
      @NonNull EncoderProfiles encoderProfiles,
      @NonNull String outputFilePath,
      MediaRecorderFactory helper,
      @NonNull Integer fps,
      @NonNull Integer videoBitrate,
      @NonNull Integer audioBitrate) {
    this.outputFilePath = outputFilePath;
    this.encoderProfiles = encoderProfiles;
    this.camcorderProfile = null;
    this.recorderFactory = helper;
    this.fps = fps;
    this.videoBitrate = videoBitrate;
    this.audioBitrate = audioBitrate;
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
      EncoderProfiles.VideoProfile videoProfile = encoderProfiles.getVideoProfiles().get(0);
      EncoderProfiles.AudioProfile audioProfile = encoderProfiles.getAudioProfiles().get(0);

      mediaRecorder.setOutputFormat(encoderProfiles.getRecommendedFileFormat());
      if (enableAudio) {
        mediaRecorder.setAudioEncoder(audioProfile.getCodec());
        mediaRecorder.setAudioEncodingBitRate(
            (audioBitrate != null && audioBitrate.intValue() > 0)
                ? audioBitrate
                : audioProfile.getBitrate());
        mediaRecorder.setAudioSamplingRate(audioProfile.getSampleRate());
      }
      mediaRecorder.setVideoEncoder(videoProfile.getCodec());
      mediaRecorder.setVideoEncodingBitRate(
          (videoBitrate != null && videoBitrate.intValue() > 0)
              ? videoBitrate
              : videoProfile.getBitrate());
      mediaRecorder.setVideoFrameRate(
          (fps != null && fps.intValue() > 0) ? fps : videoProfile.getFrameRate());
      mediaRecorder.setVideoSize(videoProfile.getWidth(), videoProfile.getHeight());
    } else if (camcorderProfile != null) {
      mediaRecorder.setOutputFormat(camcorderProfile.fileFormat);
      if (enableAudio) {
        mediaRecorder.setAudioEncoder(camcorderProfile.audioCodec);
        mediaRecorder.setAudioEncodingBitRate(
            (audioBitrate != null && audioBitrate.intValue() > 0)
                ? audioBitrate
                : camcorderProfile.audioBitRate);
        mediaRecorder.setAudioSamplingRate(camcorderProfile.audioSampleRate);
      }
      mediaRecorder.setVideoEncoder(camcorderProfile.videoCodec);
      mediaRecorder.setVideoEncodingBitRate(
          (videoBitrate != null && videoBitrate.intValue() > 0)
              ? videoBitrate
              : camcorderProfile.videoBitRate);
      mediaRecorder.setVideoFrameRate(
          (fps != null && fps.intValue() > 0) ? fps : camcorderProfile.videoFrameRate);
      mediaRecorder.setVideoSize(
          camcorderProfile.videoFrameWidth, camcorderProfile.videoFrameHeight);
    }

    mediaRecorder.setOutputFile(outputFilePath);
    mediaRecorder.setOrientationHint(this.mediaOrientation);

    mediaRecorder.prepare();

    return mediaRecorder;
  }
}
