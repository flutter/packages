// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.camera2.interop.CaptureRequestOptions;
import androidx.camera.camera2.interop.ExperimentalCamera2Interop;
import java.util.Map;

/**
 * ProxyApi implementation for {@link CaptureRequestOptions}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class CaptureRequestOptionsProxyApi extends PigeonApiCaptureRequestOptions {
  CaptureRequestOptionsProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @ExperimentalCamera2Interop
  CaptureRequestOptions.Builder createBuilder() {
    return new CaptureRequestOptions.Builder();
  }

  @SuppressWarnings("unchecked")
  @ExperimentalCamera2Interop
  @NonNull
  @Override
  public CaptureRequestOptions pigeon_defaultConstructor(
      @NonNull Map<CaptureRequest.Key<?>, ?> options) {
    final CaptureRequestOptions.Builder builder = createBuilder();

    for (final Map.Entry<CaptureRequest.Key<?>, ?> option : options.entrySet()) {
      Object optionValue = option.getValue();

      if (optionValue == null) {
        builder.clearCaptureRequestOption(option.getKey());
        continue;
      }

      builder.setCaptureRequestOption(
          (CaptureRequest.Key<Object>) option.getKey(), option.getValue());
    }

    return builder.build();
  }

  @ExperimentalCamera2Interop
  @Nullable
  @Override
  public Object getCaptureRequestOption(
      @NonNull CaptureRequestOptions pigeonInstance, @NonNull CaptureRequest.Key<?> key) {
    return pigeonInstance.getCaptureRequestOption(key);
  }
}
