// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.FocusMeteringAction.Builder;
import androidx.camera.core.MeteringPoint;
import androidx.camera.core.FocusMeteringAction;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link FocusMeteringActionBuilder}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class FocusMeteringActionBuilderProxyApi extends PigeonApiFocusMeteringActionBuilder {
  FocusMeteringActionBuilderProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public FocusMeteringActionBuilder pigeon_defaultConstructor(@NonNull androidx.camera.core.MeteringPoint point) {
    return FocusMeteringActionBuilder(point);
  }

  @NonNull
  @Override
  public FocusMeteringActionBuilder withMode(@NonNull androidx.camera.core.MeteringPoint point, @NonNull MeteringMode mode) {
    return FocusMeteringActionBuilder(point, mode);
  }

  @Override
  public Void addPoint(FocusMeteringActionBuilder, pigeon_instance@NonNull androidx.camera.core.MeteringPoint point) {
    pigeon_instance.addPoint(point);
  }

  @Override
  public Void addPointWithMode(FocusMeteringActionBuilder, pigeon_instance@NonNull androidx.camera.core.MeteringPoint point, @NonNull List<MeteringMode> modes) {
    pigeon_instance.addPointWithMode(point, modes);
  }

  @Override
  public Void disableAutoCancel(FocusMeteringActionBuilder pigeon_instance) {
    pigeon_instance.disableAutoCancel();
  }

  @NonNull
  @Override
  public androidx.camera.core.FocusMeteringAction build(FocusMeteringActionBuilder pigeon_instance) {
    return pigeon_instance.build();
  }

}
