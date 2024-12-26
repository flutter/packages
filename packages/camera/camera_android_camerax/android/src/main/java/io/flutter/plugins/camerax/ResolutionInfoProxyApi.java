// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.core.ResolutionInfo;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link ResolutionInfo}.
 *
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ResolutionInfoProxyApi extends PigeonApiResolutionInfo {
  ResolutionInfoProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public android.util.Size resolution(ResolutionInfo pigeon_instance) {
    return pigeon_instance.getResolution();
  }
}
