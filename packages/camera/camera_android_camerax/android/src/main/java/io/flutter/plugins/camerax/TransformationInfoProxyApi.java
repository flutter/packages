// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.SurfaceRequest.TransformationInfo;

/**
 * ProxyApi implementation for {@link TransformationInfo}.
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class TransformationInfoProxyApi extends PigeonApiTransformationInfo {
  TransformationInfoProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long rotationDegrees(@NonNull TransformationInfo pigeonInstance) {
    return pigeonInstance.getRotationDegrees();
  }

  @Override
  public boolean hasCameraTransform(@NonNull TransformationInfo pigeonInstance) {
    return pigeonInstance.hasCameraTransform();
  }

  @Override
  public boolean isMirroring(@NonNull TransformationInfo pigeonInstance) {
    return pigeonInstance.isMirroring();
  }
}
