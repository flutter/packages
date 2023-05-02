// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ZoomState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ZoomStateFlutterApi;

public class ZoomStateFlutterApiImpl extends ZoomStateFlutterApi {
  private final InstanceManager instanceManager;

  public ZoomStateFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /**
   * Creates a {@link ZoomState} on the Dart side with its minimum zoom ratio and maximum zoom
   * ratio.
   */
  void create(@NonNull ZoomState zoomState, @NonNull Reply<Void> reply) {
    if (instanceManager.containsInstance(zoomState)) {
      return;
    }

    final Float minZoomRatio = zoomState.getMinZoomRatio();
    final Float maxZoomRatio = zoomState.getMaxZoomRatio();
    create(
        instanceManager.addHostCreatedInstance(zoomState),
        minZoomRatio.doubleValue(),
        maxZoomRatio.doubleValue(),
        reply);
  }
}
