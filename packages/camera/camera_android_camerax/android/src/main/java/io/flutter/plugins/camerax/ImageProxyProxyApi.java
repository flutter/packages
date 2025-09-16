// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.util.Arrays;
import java.util.List;

import java.nio.ByteBuffer;


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
    return Arrays.asList(pigeonInstance.getPlanes());
  }

  @Override
  public void close(ImageProxy pigeonInstance) {
    pigeonInstance.close();
  }

  // List<? extends PlaneProxy> can be considered the same as List<PlaneProxy>.
  @SuppressWarnings("unchecked")
  @NonNull
  @Override
  public byte[] getNv21Buffer(ImageProxy pigeonInstance, List<? extends PlaneProxy> planes) {
    System.out.println(":::::::::::::::::::::::::::::CAMILLE: GET NV21 BUFFER CALLED:::::::::::::::::::::::::::::");
    final ByteBuffer nv21Buffer = planesToNV21(
        planes.toArray(new PlaneProxy[0]), pigeonInstance.getWidth(), pigeonInstance.getHeight());

    byte[] bytes = new byte[nv21Buffer.remaining()];
    nv21Buffer.get(bytes, 0, bytes.length);

    return bytes;
  }

    /**
     * Converts ImageProxy.PlaneProxy[] in YUV_420_888 format (with VU planes in NV21 layout)
     * to a single NV21 ByteBuffer.
     */
    public ByteBuffer planesToNV21(
            ImageProxy.PlaneProxy[] planes, int width, int height) {
        int imageSize = width * height;
        int nv21Size = imageSize + 2 * (imageSize / 4);
        byte[] nv21 = new byte[nv21Size];

        // Copy Y plane
        ByteBuffer yBuffer = planes[0].getBuffer();
        yBuffer.rewind();
        yBuffer.get(nv21, 0, imageSize);

        // Copy interleaved VU plane (NV21 layout)
        ByteBuffer vBuffer = planes[2].getBuffer();
        ByteBuffer uBuffer = planes[1].getBuffer();

        // The first V value comes from the V buffer
        vBuffer.rewind();
        uBuffer.rewind();
        vBuffer.get(nv21, imageSize, 1);
        uBuffer.get(nv21, imageSize + 1, 2 * imageSize / 4 - 1);

        return ByteBuffer.wrap(nv21);
    }
}
