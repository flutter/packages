// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Arrays;
import java.util.List;

/**
 * ProxyApi implementation for {@link ImageProxy}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ImageProxyProxyApi extends PigeonApiImageProxy {
  ImageProxyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long format(ImageProxy pigeon_instance) {
    return pigeon_instance.getFormat();
  }

  @Override
  public long width(ImageProxy pigeon_instance) {
    return pigeon_instance.getWidth();
  }

  @Override
  public long height(ImageProxy pigeon_instance) {
    return pigeon_instance.getHeight();
  }

  @NonNull
  @Override
  public List<PlaneProxy> getPlanes(ImageProxy pigeon_instance) {
    return Arrays.asList(pigeon_instance.getPlanes());
  }

  @Override
  public void close(ImageProxy pigeon_instance) {
    pigeon_instance.close();
  }
}
