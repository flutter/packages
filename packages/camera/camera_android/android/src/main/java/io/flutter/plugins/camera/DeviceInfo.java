// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Build;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

/** Wraps BUILD device info, allowing for overriding it in unit tests. */
public class DeviceInfo {
  @VisibleForTesting public static @Nullable String BRAND = Build.BRAND;

  @VisibleForTesting public static @Nullable String MODEL = Build.MODEL;

  public static @Nullable String getBrand() {
    return BRAND;
  }

  public static @Nullable String getModel() {
    return MODEL;
  }
}
