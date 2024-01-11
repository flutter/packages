// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.Recorder;
import androidx.camera.video.VideoCapture;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.VideoCaptureFlutterApi;

public class VideoCaptureFlutterApiImpl extends VideoCaptureFlutterApi {
  public VideoCaptureFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  private final InstanceManager instanceManager;

  void create(@NonNull VideoCapture<Recorder> videoCapture, Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(videoCapture), reply);
  }
}
