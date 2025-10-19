// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link DeviceOrientationManager}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
public class DeviceOrientationManagerProxyApi extends PigeonApiDeviceOrientationManager {
  DeviceOrientationManagerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public DeviceOrientationManager pigeon_defaultConstructor() {
    return new DeviceOrientationManager(this);
  }

  @Override
  public void startListeningForDeviceOrientationChange(
      @NonNull DeviceOrientationManager pigeonInstance) {
    pigeonInstance.start();
  }

  @Override
  public void stopListeningForDeviceOrientationChange(
      @NonNull DeviceOrientationManager pigeonInstance) {
    pigeonInstance.stop();
  }

  @Override
  public long getDefaultDisplayRotation(@NonNull DeviceOrientationManager pigeonInstance) {
    return pigeonInstance.getDefaultRotation();
  }

  @NonNull
  @Override
  public String getUiOrientation(@NonNull DeviceOrientationManager pigeonInstance) {
    return pigeonInstance.getUiOrientation().toString();
  }
}
