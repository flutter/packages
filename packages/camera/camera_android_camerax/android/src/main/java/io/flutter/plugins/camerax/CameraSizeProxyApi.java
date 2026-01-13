// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link Size}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class CameraSizeProxyApi extends PigeonApiCameraSize {
  CameraSizeProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public Size pigeon_defaultConstructor(long width, long height) {
    return new Size((int) width, (int) height);
  }

  @Override
  public long width(@NonNull Size pigeonInstance) {
    return pigeonInstance.getWidth();
  }

  @Override
  public long height(Size pigeonInstance) {
    return pigeonInstance.getHeight();
  }
}
