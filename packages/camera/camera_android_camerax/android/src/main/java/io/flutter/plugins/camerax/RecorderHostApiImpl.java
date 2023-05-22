// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.video.FileOutputOptions;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recorder;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.RecorderHostApi;
import java.io.File;
import java.util.Objects;
import java.util.concurrent.Executor;

public class RecorderHostApiImpl implements RecorderHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private Context context;

  @NonNull @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  @NonNull @VisibleForTesting public PendingRecordingFlutterApiImpl pendingRecordingFlutterApi;

  public RecorderHostApiImpl(
      @Nullable BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @Nullable Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
    this.pendingRecordingFlutterApi =
        new PendingRecordingFlutterApiImpl(binaryMessenger, instanceManager);
  }

  @Override
  public void create(@NonNull Long instanceId, @Nullable Long aspectRatio, @Nullable Long bitRate) {
    Recorder.Builder recorderBuilder = cameraXProxy.createRecorderBuilder();
    if (aspectRatio != null) {
      recorderBuilder.setAspectRatio(aspectRatio.intValue());
    }
    if (bitRate != null) {
      recorderBuilder.setTargetVideoEncodingBitRate(bitRate.intValue());
    }
    Recorder recorder = recorderBuilder.setExecutor(ContextCompat.getMainExecutor(context)).build();
    instanceManager.addDartCreatedInstance(recorder, instanceId);
  }

  /** Sets the context, which is used to get the {@link Executor} passed to the Recorder builder. */
  public void setContext(@Nullable Context context) {
    this.context = context;
  }

  /** Gets the aspect ratio of the given {@link Recorder}. */
  @NonNull
  @Override
  public Long getAspectRatio(@NonNull Long identifier) {
    Recorder recorder = getRecorderFromInstanceId(identifier);
    return Long.valueOf(recorder.getAspectRatio());
  }

  /** Gets the target video encoding bitrate of the given {@link Recorder}. */
  @NonNull
  @Override
  public Long getTargetVideoEncodingBitRate(@NonNull Long identifier) {
    Recorder recorder = getRecorderFromInstanceId(identifier);
    return Long.valueOf(recorder.getTargetVideoEncodingBitRate());
  }

  /**
   * Uses the provided {@link Recorder} to prepare a recording that will be saved to a file at the
   * provided path.
   */
  @NonNull
  @Override
  public Long prepareRecording(@NonNull Long identifier, @NonNull String path) {
    Recorder recorder = getRecorderFromInstanceId(identifier);
    File temporaryCaptureFile = openTempFile(path);
    FileOutputOptions fileOutputOptions =
        new FileOutputOptions.Builder(temporaryCaptureFile).build();
    PendingRecording pendingRecording = recorder.prepareRecording(context, fileOutputOptions);
    if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO)
        == PackageManager.PERMISSION_GRANTED) {
      pendingRecording.withAudioEnabled();
    }
    pendingRecordingFlutterApi.create(pendingRecording, reply -> {});
    return Objects.requireNonNull(
        instanceManager.getIdentifierForStrongReference(pendingRecording));
  }

  @Nullable
  @VisibleForTesting
  public File openTempFile(@NonNull String path) {
    File file = null;
    try {
      file = new File(path);
    } catch (NullPointerException | SecurityException e) {
      throw new RuntimeException(e);
    }
    return file;
  }

  private Recorder getRecorderFromInstanceId(Long instanceId) {
    return (Recorder) Objects.requireNonNull(instanceManager.getInstance(instanceId));
  }
}
