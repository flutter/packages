// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.MeteringPoint;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.List;

/**
 * ProxyApi implementation for {@link FocusMeteringAction}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class FocusMeteringActionProxyApi extends PigeonApiFocusMeteringAction {
  FocusMeteringActionProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public List<MeteringPoint> meteringPointsAe(FocusMeteringAction pigeon_instance) {
    return pigeon_instance.getMeteringPointsAe();
  }

  @NonNull
  @Override
  public List<androidx.camera.core.MeteringPoint> meteringPointsAf(FocusMeteringAction pigeon_instance) {
    return pigeon_instance.getMeteringPointsAf();
  }

  @NonNull
  @Override
  public List<androidx.camera.core.MeteringPoint> meteringPointsAwb(FocusMeteringAction pigeon_instance) {
    return pigeon_instance.getMeteringPointsAwb();
  }

  @Override
  public boolean isAutoCancelEnabled(FocusMeteringAction pigeon_instance) {
    return pigeon_instance.isAutoCancelEnabled();
  }
}
