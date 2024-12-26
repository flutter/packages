// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.FocusMeteringAction.Builder;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.FocusMeteringAction;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.List;

/**
 * ProxyApi implementation for {@link FocusMeteringAction.Builder}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class FocusMeteringActionBuilderProxyApi extends PigeonApiFocusMeteringActionBuilder {
  FocusMeteringActionBuilderProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public FocusMeteringAction.Builder pigeon_defaultConstructor(@NonNull MeteringPoint point) {
    return new FocusMeteringAction.Builder(point);
  }

  @NonNull
  @Override
  public FocusMeteringAction.Builder withMode(@NonNull MeteringPoint point, @NonNull MeteringMode mode) {
    return new FocusMeteringAction.Builder(point, getNativeMeteringMode(mode));
  }

  @Override
  public void addPoint(FocusMeteringAction.Builder pigeon_instance, @NonNull MeteringPoint point) {
    pigeon_instance.addPoint(point);
  }

  @Override
  public void addPointWithMode(FocusMeteringAction. Builder pigeon_instance, @NonNull MeteringPoint point, @NonNull MeteringMode mode) {
    pigeon_instance.addPoint(point, getNativeMeteringMode(mode));
  }

  @Override
  public void disableAutoCancel(FocusMeteringAction.Builder pigeon_instance) {
    pigeon_instance.disableAutoCancel();
  }

  @NonNull
  @Override
  public androidx.camera.core.FocusMeteringAction build(FocusMeteringAction.Builder pigeon_instance) {
    return pigeon_instance.build();
  }

  int getNativeMeteringMode(@NonNull MeteringMode mode) {
    switch(mode) {
      case AE:
        return FocusMeteringAction.FLAG_AE;
      case AF:
        return FocusMeteringAction.FLAG_AF;
      case AWB:
        return FocusMeteringAction.FLAG_AWB;
    }

    throw new IllegalArgumentException(
        "MeteringMode " + mode + " is unhandled by FocusMeteringActionBuilderProxyApi.");
  }
}
