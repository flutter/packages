// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.FocusMeteringAction;
import androidx.camera.core.MeteringPoint;

/**
 * ProxyApi implementation for {@link FocusMeteringAction.Builder}. This class may handle
 * instantiating native object instances that are attached to a Dart instance or handle method calls
 * on the associated native class or an instance of that class.
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
  public FocusMeteringAction.Builder withMode(
      @NonNull MeteringPoint point, @NonNull MeteringMode mode) {
    return new FocusMeteringAction.Builder(point, getNativeMeteringMode(mode));
  }

  @Override
  public void addPoint(FocusMeteringAction.Builder pigeonInstance, @NonNull MeteringPoint point) {
    pigeonInstance.addPoint(point);
  }

  @Override
  public void addPointWithMode(
      FocusMeteringAction.Builder pigeonInstance,
      @NonNull MeteringPoint point,
      @NonNull MeteringMode mode) {
    pigeonInstance.addPoint(point, getNativeMeteringMode(mode));
  }

  @Override
  public void disableAutoCancel(FocusMeteringAction.Builder pigeonInstance) {
    pigeonInstance.disableAutoCancel();
  }

  @NonNull
  @Override
  public FocusMeteringAction build(FocusMeteringAction.Builder pigeonInstance) {
    return pigeonInstance.build();
  }

  int getNativeMeteringMode(@NonNull MeteringMode mode) {
    switch (mode) {
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
