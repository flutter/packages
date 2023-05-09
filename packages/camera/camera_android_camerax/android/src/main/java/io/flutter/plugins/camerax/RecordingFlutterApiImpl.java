// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.Recording;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.RecordingFlutterApi;

public class RecordingFlutterApiImpl extends RecordingFlutterApi {
  private final InstanceManager instanceManager;

  public RecordingFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(@NonNull Recording recording, Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(recording), reply);
  }
}
