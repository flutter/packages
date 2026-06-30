// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.video.FileOutputOptions;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.QualitySelector;
import androidx.camera.video.Recorder;
import java.io.File;

/**
 * ProxyApi implementation for {@link Recorder}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class RecorderProxyApi extends PigeonApiRecorder {
  RecorderProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public Recorder pigeon_defaultConstructor(
      @Nullable Long aspectRatio,
      @Nullable Long targetVideoEncodingBitRate,
      @Nullable QualitySelector qualitySelector) {
    final Recorder.Builder builder = new Recorder.Builder();
    if (aspectRatio != null) {
      builder.setAspectRatio(aspectRatio.intValue());
    }
    if (targetVideoEncodingBitRate != null) {
      builder.setTargetVideoEncodingBitRate(targetVideoEncodingBitRate.intValue());
    }
    if (qualitySelector != null) {
      builder.setQualitySelector(qualitySelector);
    }
    return builder.build();
  }

  @Override
  public long getAspectRatio(Recorder pigeonInstance) {
    return pigeonInstance.getAspectRatio();
  }

  @Override
  public long getTargetVideoEncodingBitRate(Recorder pigeonInstance) {
    return pigeonInstance.getTargetVideoEncodingBitRate();
  }

  @NonNull
  @Override
  public PendingRecording prepareRecording(Recorder pigeonInstance, @NonNull String path) {
    validateOutputPath(path);
    final File temporaryCaptureFile = openTempFile(path);
    final FileOutputOptions fileOutputOptions =
        new FileOutputOptions.Builder(temporaryCaptureFile).build();

    final PendingRecording pendingRecording =
        pigeonInstance.prepareRecording(getPigeonRegistrar().getContext(), fileOutputOptions);

    return pendingRecording;
  }

  private void validateOutputPath(@NonNull String path) {
    File file = new File(path);
    if (file.isDirectory()) {
      throw new GeneratedCameraXLibrary.FlutterError(
          "IOError", "The output path is a directory: " + path, null);
    }
    File parent = file.getParentFile();
    if (parent != null && !parent.exists()) {
      throw new GeneratedCameraXLibrary.FlutterError(
          "IOError", "The parent directory does not exist: " + parent.getAbsolutePath(), null);
    }

    String lowerPath = path.toLowerCase(Locale.ROOT);
    if (!lowerPath.endsWith(".mp4")) {
      throw new GeneratedCameraXLibrary.FlutterError(
          "IOError", "Invalid video extension. Supported: .mp4", null);
    }
  }

  @NonNull
  File openTempFile(@NonNull String path) {
    try {
      return new File(path);
    } catch (NullPointerException | SecurityException e) {
      throw new GeneratedCameraXLibrary.FlutterError("IOError", e.getMessage(), null);
    }
  }

  @NonNull
  @Override
  public QualitySelector getQualitySelector(@NonNull Recorder pigeonInstance) {
    return pigeonInstance.getQualitySelector();
  }
}
