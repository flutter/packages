// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.video.PendingRecording;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PendingRecordingFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoRecordEvent;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoRecordEventData;

public class PendingRecordingFlutterApiImpl extends PendingRecordingFlutterApi {
  private final InstanceManager instanceManager;

  public PendingRecordingFlutterApiImpl(
      @Nullable BinaryMessenger binaryMessenger, @Nullable InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(@NonNull PendingRecording pendingRecording, @Nullable Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(pendingRecording), reply);
  }

  void sendVideoRecordingFinalizedEvent(@NonNull Reply<Void> reply) {
    super.onVideoRecordingEvent(
        new VideoRecordEventData.Builder().setValue(VideoRecordEvent.FINALIZE).build(), reply);
  }

  void sendVideoRecordingStartedEvent(@NonNull Reply<Void> reply) {
    super.onVideoRecordingEvent(
        new VideoRecordEventData.Builder().setValue(VideoRecordEvent.START).build(), reply);
  }
}
