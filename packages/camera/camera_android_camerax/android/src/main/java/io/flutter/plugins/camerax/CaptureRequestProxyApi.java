// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link CaptureRequest}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class CaptureRequestProxyApi extends PigeonApiCaptureRequest {
  CaptureRequestProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public CaptureRequest.Key<?> controlAELock() {
    return CaptureRequest.CONTROL_AE_LOCK;
  }
}
