// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.CameraState;
import androidx.lifecycle.LiveData;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.LiveCameraStateFlutterApi;

public class LiveCameraStateFlutterApiImpl extends LiveCameraStateFlutterApi {
  public LiveCameraStateFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  private final InstanceManager instanceManager;

  void create(LiveData<CameraState> liveCameraState, Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(liveCameraState), reply);
  }

  void sendCameraClosingEvent(Reply<Void> reply) {
    onCameraClosing(reply);
  }
}
