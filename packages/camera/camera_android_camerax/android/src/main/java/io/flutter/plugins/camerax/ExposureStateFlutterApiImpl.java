// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Range;
import androidx.annotation.NonNull;
import androidx.camera.core.ExposureState;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureCompensationRange;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ExposureStateFlutterApi;

public class ExposureStateFlutterApiImpl extends ExposureStateFlutterApi {
  private final InstanceManager instanceManager;

  public ExposureStateFlutterApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    super(binaryMessenger);
    this.instanceManager = instanceManager;
  }

  /**
   * Creates a {@link ExposureState} on the Dart side with its exposure compensation range that can
   * be used to set the exposure compensation index and its exposure compensation step, the smallest
   * step by which the exposure compensation can be changed.
   */
  void create(@NonNull ExposureState exposureState, @NonNull Reply<Void> reply) {
    if (instanceManager.containsInstance(exposureState)) {
      return;
    }

    final Range<Integer> exposureCompensationRangeFromState =
        exposureState.getExposureCompensationRange();
    ExposureCompensationRange exposureCompensationRange =
        new ExposureCompensationRange.Builder()
            .setMinCompensation(exposureCompensationRangeFromState.getLower().longValue())
            .setMaxCompensation(exposureCompensationRangeFromState.getUpper().longValue())
            .build();
    final Double exposureCompensationStep =
        exposureState.getExposureCompensationStep().doubleValue();

    create(
        instanceManager.addHostCreatedInstance(exposureState),
        exposureCompensationRange,
        exposureCompensationStep,
        reply);
  }
}
