// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.ImageProxy.PlaneProxy;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link PlaneProxyUtils}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class PlaneProxyUtilsProxyApi extends PigeonApiPlaneProxyUtils {
  PlaneProxyUtilsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public bytes[] getNv21Plane(@NonNull List<PlaneProxy> planeProxyList, long imageWidth, long imageHeight) {
    ByteBuffer nv21Bytes = PlaneProxyUtils.yuv420ThreePlanesToNV21(planeProxyList, (int) imageWidth, (int) imageHeight);
    return nv21Bytes.array();
  }
}
