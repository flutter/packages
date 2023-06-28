// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.video.Recorder;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.RecorderFlutterApi;

public class RecorderFlutterApiImpl extends RecorderFlutterApi {
  private final InstanceManager instanceManager;

  public RecorderFlutterApiImpl(
      @Nullable BinaryMessenger binaryMessenger, @Nullable InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(
      @NonNull Recorder recorder,
      @Nullable Long aspectRatio,
      @Nullable Long bitRate,
      @Nullable Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(recorder), aspectRatio, bitRate, reply);
  }
}
