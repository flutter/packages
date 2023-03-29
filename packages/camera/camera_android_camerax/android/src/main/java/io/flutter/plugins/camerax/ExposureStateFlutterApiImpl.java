// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ExposureState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureStateFlutterApi;;

public class ExposureStateFlutterApiImpl extends ExposureStateFlutterApi {
  private final InstanceManager instanceManager;

  public ExposureStateFlutterApiImpl(
      BinaryMessenger binaryMessenger, InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  void create(@NonNull ExposureState exposureState, @NonNull Reply<Void> reply) {
    create(instanceManager.addHostCreatedInstance(exposureState), reply);
  }
}
