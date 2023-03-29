// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ExposureState;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureRange;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureStateHostApi;
import java.util.Objects;


public class ExposureStateHostApiImpl implements ExposureStateHostApi {
    private final InstanceManager instanceManager;
  
    public ExposureStateHostApiImpl(InstanceManager instanceManager) {
      this.instanceManager = instanceManager;
    }

    /**
     * Gets the maximum and minimum exposure compensation values for the camera with the
     * {@link ExposureState} with the specified identifier.
     */ 
    @Override
    public ExposureRange getExposureCompensationRange(@NonNull Long identifier) {
        ExposureState exposureState =
            (ExposureState) Objects.requireNonNull(instanceManager.getInstance(identifier));
        Range<Integer> exposureCompensationRange = exposureState.getExposureCompensationRange();

        return ExposureRange.Builder().setMinCompensation(exposureCompensationRange.getLower()).setMaxCompensation(exposureCompensationRange.getUpper()).build();
    }
   
    /**
     * Gets the smallest step by which the exposure compensation can be changed
     * for the camera with the {@link ExposureState} with the specified identifier.
     */ 
    @Override
    public Double getExposureCompensationStep(@NonNull Long identifier) {
        ExposureState exposureState =
            (ExposureState) Objects.requireNonNull(instanceManager.getInstance(identifier));
        return exposureState.getExposureCompensationStep.getValue();
    }
}
