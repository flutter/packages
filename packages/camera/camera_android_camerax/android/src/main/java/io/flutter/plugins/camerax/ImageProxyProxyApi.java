// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

/**
 * ProxyApi implementation for {@link ImageProxy}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class ImageProxyProxyApi extends PigeonApiImageProxy {
  ImageProxyProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public long format(ImageProxy pigeonInstance) {
    return pigeonInstance.getFormat();
  }

  @Override
  public long width(ImageProxy pigeonInstance) {
    return pigeonInstance.getWidth();
  }

  @Override
  public long height(ImageProxy pigeonInstance) {
    return pigeonInstance.getHeight();
  }

  @NonNull
  @Override
  public List<PlaneProxy> getPlanes(ImageProxy pigeonInstance) {
    PlaneProxy[] originalPlanes = pigeonInstance.getPlanes();
    List<PlaneProxy> planes = new ArrayList<>();
    int height = pigeonInstance.getHeight();

    for (int i = 0; i < originalPlanes.length; i++) {
      final PlaneProxy original = originalPlanes[i];
      final int planeHeight = (i == 0) ? height : height / 2;

      planes.add(
          new PlaneProxy() {
            @Override
            public int getRowStride() {
              return original.getRowStride();
            }

            @Override
            public int getPixelStride() {
              return original.getPixelStride();
            }

            @NonNull
            @Override
            public ByteBuffer getBuffer() {
              ByteBuffer sourceBuffer = original.getBuffer();
              // Create a duplicate so we don't modify the original's position/limit.
              ByteBuffer slicedBuffer = sourceBuffer.duplicate();
              // Limit the buffer to what's actually needed for this plane.
              int maxValidBytes = planeHeight * original.getRowStride();
              if (maxValidBytes < slicedBuffer.remaining()) {
                slicedBuffer.limit(slicedBuffer.position() + maxValidBytes);
              }
              return slicedBuffer;
            }
          });
    }
    return planes;
  }

  @Override
  public void close(ImageProxy pigeonInstance) {
    pigeonInstance.close();
  }
}
