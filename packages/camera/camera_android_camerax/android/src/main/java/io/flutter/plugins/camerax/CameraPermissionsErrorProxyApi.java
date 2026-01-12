// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;

/**
 * ProxyApi implementation for {@link CameraPermissionsError}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
public class CameraPermissionsErrorProxyApi extends PigeonApiCameraPermissionsError {
  public CameraPermissionsErrorProxyApi(
      @NonNull CameraXLibraryPigeonProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public String errorCode(@NonNull CameraPermissionsError pigeonInstance) {
    return pigeonInstance.getErrorCode();
  }

  @NonNull
  @Override
  public String description(@NonNull CameraPermissionsError pigeonInstance) {
    return pigeonInstance.getDescription();
  }
}
