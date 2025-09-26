// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.view.Display;
import androidx.annotation.NonNull;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.DisplayOrientedMeteringPointFactory;

/**
 * ProxyApi implementation for {@link DisplayOrientedMeteringPointFactory}. This class may handle
 * instantiating native object instances that are attached to a Dart instance or handle method calls
 * on the associated native class or an instance of that class.
 */
class DisplayOrientedMeteringPointFactoryProxyApi
    extends PigeonApiDisplayOrientedMeteringPointFactory {
  DisplayOrientedMeteringPointFactoryProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public DisplayOrientedMeteringPointFactory pigeon_defaultConstructor(
      @NonNull CameraInfo cameraInfo, double width, double height) {
    final Display display = getPigeonRegistrar().getDisplay();

    if (display != null) {
      return new DisplayOrientedMeteringPointFactory(
          display, cameraInfo, (float) width, (float) height);
    }

    throw new IllegalStateException("A Display could not be retrieved.");
  }
}
