// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recording;
import androidx.camera.video.VideoRecordEvent;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PendingRecordingHostApi;
import java.util.Objects;
import java.util.concurrent.Executor;

public class PendingRecordingHostApiImpl implements PendingRecordingHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  @Nullable private Context context;

  @VisibleForTesting @NonNull public CameraXProxy cameraXProxy = new CameraXProxy();

  @VisibleForTesting PendingRecordingFlutterApiImpl pendingRecordingFlutterApi;

  @VisibleForTesting SystemServicesFlutterApiImpl systemServicesFlutterApi;

  @VisibleForTesting RecordingFlutterApiImpl recordingFlutterApi;

  public PendingRecordingHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @Nullable Context context) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.context = context;
    systemServicesFlutterApi = cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
    recordingFlutterApi = new RecordingFlutterApiImpl(binaryMessenger, instanceManager);
    pendingRecordingFlutterApi =
        new PendingRecordingFlutterApiImpl(binaryMessenger, instanceManager);
  }

  /** Sets the context, which is used to get the {@link Executor} needed to start the recording. */
  public void setContext(@Nullable Context context) {
    this.context = context;
  }

  /**
   * Starts the given {@link PendingRecording}, creating a new {@link Recording}. The recording is
   * then added to the instance manager and we return the corresponding identifier.
   *
   * @param identifier An identifier corresponding to a PendingRecording.
   */
  @NonNull
  @Override
  public Long start(@NonNull Long identifier) {
    PendingRecording pendingRecording = getPendingRecordingFromInstanceId(identifier);
    Recording recording =
        pendingRecording.start(this.getExecutor(), event -> handleVideoRecordEvent(event));
    recordingFlutterApi.create(recording, reply -> {});
    return Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(recording));
  }

  @Nullable
  @VisibleForTesting
  public Executor getExecutor() {
    if (context == null) {
      throw new IllegalStateException("Context must be set to get an executor to start recording.");
    }

    return ContextCompat.getMainExecutor(context);
  }

  /**
   * Handles {@link VideoRecordEvent}s that come in during video recording. Sends any errors
   * encountered using {@link SystemServicesFlutterApiImpl}.
   *
   * <p>Currently only sends {@link VideoRecordEvent.Start} and {@link VideoRecordEvent.Finalize}
   * events to the Dart side.
   */
  @VisibleForTesting
  public void handleVideoRecordEvent(@NonNull VideoRecordEvent event) {
    if (event instanceof VideoRecordEvent.Start) {
      pendingRecordingFlutterApi.sendVideoRecordingStartedEvent(reply -> {});
    } else if (event instanceof VideoRecordEvent.Finalize) {
      pendingRecordingFlutterApi.sendVideoRecordingFinalizedEvent(reply -> {});
      VideoRecordEvent.Finalize castedEvent = (VideoRecordEvent.Finalize) event;
      if (castedEvent.hasError()) {
        String cameraErrorMessage;
        if (castedEvent.getCause() != null) {
          cameraErrorMessage = castedEvent.getCause().toString();
        } else {
          cameraErrorMessage =
              "Error code " + castedEvent.getError() + ": An error occurred while recording video.";
        }
        systemServicesFlutterApi.sendCameraError(cameraErrorMessage, reply -> {});
      }
    }
  }

  private PendingRecording getPendingRecordingFromInstanceId(Long instanceId) {
    return (PendingRecording) Objects.requireNonNull(instanceManager.getInstance(instanceId));
  }
}
