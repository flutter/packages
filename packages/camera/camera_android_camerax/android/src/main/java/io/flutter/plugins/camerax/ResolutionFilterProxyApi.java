// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;
import androidx.camera.core.resolutionselector.ResolutionFilter;
import java.util.List;

/**
 * ProxyApi implementation for {@link ResolutionFilter}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class ResolutionFilterProxyApi extends PigeonApiResolutionFilter {
  ResolutionFilterProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ResolutionFilter createWithOnePreferredSize(@NonNull Size preferredSize) {
    return new ResolutionFilter() {
      @Override
      @NonNull
      public List<Size> filter(@NonNull List<Size> supportedSizes, int rotationDegrees) {
        int preferredSizeIndex = supportedSizes.indexOf(preferredSize);

        if (preferredSizeIndex > -1) {
          supportedSizes.remove(preferredSizeIndex);
          supportedSizes.add(0, preferredSize);
        }

        return supportedSizes;
      }
    };
  }
}
