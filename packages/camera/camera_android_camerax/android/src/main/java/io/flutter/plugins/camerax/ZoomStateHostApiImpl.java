// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ZoomState;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureRange;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ZoomStateHostApi;
import java.util.Objects;


public class ZoomStateHostApiImpl implements ZoomStateHostApi {
    private final InstanceManager instanceManager;
  
    public ZoomStateHostApiImpl(InstanceManager instanceManager) {
      this.instanceManager = instanceManager;
    }

    /**
     * Gets the maximum and minimum exposure compensation values for the camera with the
     * {@link ZoomState} with the specified identifier.
     */ 
    @Override
    public Double getMaxZoomRatio(@NonNull Long identifier) {
        ZoomState zoomState =
            (ZoomState) Objects.requireNonNull(instanceManager.getInstance(identifier));
        return (Double) zoomState.getMaxZoomRatio();
    }
   
    /**
     * Gets the smallest step by which the exposure compensation can be changed
     * for the camera with the {@link ZoomState} with the specified identifier.
     */ 
    @Override
    public Double getMinZoomRatio(@NonNull Long identifier) {
        ZoomState zoomState =
            (ZoomState) Objects.requireNonNull(instanceManager.getInstance(identifier));
            return (Double) zoomState.getMinZoomRatio();
        }
}
