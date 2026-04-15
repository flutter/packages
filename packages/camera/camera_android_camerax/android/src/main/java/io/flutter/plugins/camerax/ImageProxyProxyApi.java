// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.ImageProxy.PlaneProxy;
import java.util.Arrays;
import java.util.List;

/**
 * ProxyApi implementation for {@link ImageProxy}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class ImageProxyProxyApi extends PigeonApiImageProxy {
  private static final String TAG = "ImageProxyProxyApi";

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
    try {
      // Add a small delay to allow any pending operations to complete
      // This helps prevent BufferQueue abandoned errors
      Thread.sleep(5);
    } catch (InterruptedException e) {
      // Ignore
    }
    
    try {
      pigeonInstance.close();
    } catch (Exception e) {
      // Ignore
    }
  }
}
