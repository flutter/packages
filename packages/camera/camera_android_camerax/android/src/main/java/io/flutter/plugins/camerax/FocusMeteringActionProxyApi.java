// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.MeteringPoint;
import java.util.List;

/**
 * ProxyApi implementation for {@link FocusMeteringAction}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class FocusMeteringActionProxyApi extends PigeonApiFocusMeteringAction {
  FocusMeteringActionProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public List<MeteringPoint> meteringPointsAe(FocusMeteringAction pigeonInstance) {
    return pigeonInstance.getMeteringPointsAe();
  }

  @NonNull
  @Override
  public List<MeteringPoint> meteringPointsAf(FocusMeteringAction pigeonInstance) {
    return pigeonInstance.getMeteringPointsAf();
  }

  @NonNull
  @Override
  public List<MeteringPoint> meteringPointsAwb(FocusMeteringAction pigeonInstance) {
    return pigeonInstance.getMeteringPointsAwb();
  }

  @Override
  public boolean isAutoCancelEnabled(FocusMeteringAction pigeonInstance) {
    return pigeonInstance.isAutoCancelEnabled();
  }
}
