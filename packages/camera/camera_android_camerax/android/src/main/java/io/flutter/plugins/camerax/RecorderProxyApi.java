// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.Manifest;
import android.content.pm.PackageManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.video.FileOutputOptions;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recorder;
import androidx.core.content.ContextCompat;
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
      @Nullable androidx.camera.video.QualitySelector qualitySelector) {
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
  public long getAspectRatio(Recorder pigeon_instance) {
    return pigeon_instance.getAspectRatio();
  }

  @Override
  public long getTargetVideoEncodingBitRate(Recorder pigeon_instance) {
    return pigeon_instance.getTargetVideoEncodingBitRate();
  }

  @NonNull
  @Override
  public PendingRecording prepareRecording(Recorder pigeon_instance, @NonNull String path) {
    final File temporaryCaptureFile = openTempFile(path);
    final FileOutputOptions fileOutputOptions =
        new FileOutputOptions.Builder(temporaryCaptureFile).build();

    final PendingRecording pendingRecording =
        pigeon_instance.prepareRecording(getPigeonRegistrar().getContext(), fileOutputOptions);
    if (ContextCompat.checkSelfPermission(
            getPigeonRegistrar().getContext(), Manifest.permission.RECORD_AUDIO)
        == PackageManager.PERMISSION_GRANTED) {
      pendingRecording.withAudioEnabled();
    }

    return pendingRecording;
  }

  @NonNull
  File openTempFile(@NonNull String path) throws RuntimeException {
    try {
      return new File(path);
    } catch (NullPointerException | SecurityException e) {
      throw new RuntimeException(e);
    }
  }
}
