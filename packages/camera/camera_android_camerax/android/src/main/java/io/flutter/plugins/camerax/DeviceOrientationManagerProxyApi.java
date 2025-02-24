// Copyright 2013 The Flutter Authors. All rights reserved.
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
      DeviceOrientationManager pigeon_instance, boolean isFrontFacing, long sensorOrientation) {
    pigeon_instance.start();
  }

  @Override
  public void stopListeningForDeviceOrientationChange(DeviceOrientationManager pigeon_instance) {
    pigeon_instance.stop();
  }

  @Override
  public long getDefaultDisplayRotation(DeviceOrientationManager pigeon_instance) {
    return pigeon_instance.getDefaultRotation();
  }

  @NonNull
  @Override
  public String getUiOrientation(DeviceOrientationManager pigeon_instance) {
    return pigeon_instance.getUIOrientation().toString();
  }
}
