// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Range;
import androidx.annotation.NonNull;
import androidx.camera.core.ExposureState;

/**
 * ProxyApi implementation for {@link ExposureState}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class ExposureStateProxyApi extends PigeonApiExposureState {
  ExposureStateProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public Range<?> exposureCompensationRange(ExposureState pigeonInstance) {
    return pigeonInstance.getExposureCompensationRange();
  }

  @Override
  public double exposureCompensationStep(ExposureState pigeonInstance) {
    return pigeonInstance.getExposureCompensationStep().doubleValue();
  }
}
