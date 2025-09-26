// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.ByteBuffer;

/**
 * ProxyApi implementation for {@link PlaneProxy}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class PlaneProxyProxyApi extends PigeonApiPlaneProxy {
  PlaneProxyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public byte[] buffer(PlaneProxy pigeonInstance) {
    final ByteBuffer buffer = pigeonInstance.getBuffer();

    byte[] bytes = new byte[buffer.remaining()];
    buffer.get(bytes, 0, bytes.length);

    return bytes;
  }

  @Override
  public long pixelStride(PlaneProxy pigeonInstance) {
    return pigeonInstance.getPixelStride();
  }

  @Override
  public long rowStride(PlaneProxy pigeonInstance) {
    return pigeonInstance.getRowStride();
  }
}
