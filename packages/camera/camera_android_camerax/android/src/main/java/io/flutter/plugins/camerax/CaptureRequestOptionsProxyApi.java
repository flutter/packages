// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.camera2.interop.CaptureRequestOptions;
import android.hardware.camera2.CaptureRequest.Key<*>;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link CaptureRequestOptions}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class CaptureRequestOptionsProxyApi extends PigeonApiCaptureRequestOptions {
  CaptureRequestOptionsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public CaptureRequestOptions pigeon_defaultConstructor(@NonNull Map<android.hardware.camera2.CaptureRequest.Key<*>, Any?> options) {
    return CaptureRequestOptions(options);
  }

}
