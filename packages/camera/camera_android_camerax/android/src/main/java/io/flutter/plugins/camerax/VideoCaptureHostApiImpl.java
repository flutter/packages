// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.camera.video.Recorder;
import androidx.camera.video.VideoCapture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoCaptureHostApi;
import java.util.Objects;

public class VideoCaptureHostApiImpl implements VideoCaptureHostApi {
  private final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;

  public VideoCaptureHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  @NonNull
  public Long withOutput(@NonNull Long videoOutputId) {
    Recorder recorder =
        (Recorder) Objects.requireNonNull(instanceManager.getInstance(videoOutputId));
    VideoCapture<Recorder> videoCapture = VideoCapture.withOutput(recorder);
    final VideoCaptureFlutterApiImpl videoCaptureFlutterApi =
        getVideoCaptureFlutterApiImpl(binaryMessenger, instanceManager);
    videoCaptureFlutterApi.create(videoCapture, result -> {});
    return Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(videoCapture));
  }

  @Override
  @NonNull
  public Long getOutput(@NonNull Long identifier) {
    VideoCapture<Recorder> videoCapture =
        Objects.requireNonNull(instanceManager.getInstance(identifier));
    Recorder recorder = videoCapture.getOutput();
    return Objects.requireNonNull(instanceManager.getIdentifierForStrongReference(recorder));
  }

  @VisibleForTesting
  @NonNull
  public VideoCaptureFlutterApiImpl getVideoCaptureFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    return new VideoCaptureFlutterApiImpl(binaryMessenger, instanceManager);
  }
}
