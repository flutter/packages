// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.annotation.SuppressLint;
import android.os.Build;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.VisibleForTesting;

public class SdkCapabilityChecker {
  /** The current SDK version, overridable for testing. */
  @SuppressLint("AnnotateVersionCheck")
  @VisibleForTesting
  public static int SDK_VERSION = Build.VERSION.SDK_INT;

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.P)
  public static boolean supportsDistortionCorrection() {
    return SDK_VERSION >= Build.VERSION_CODES.P;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.O)
  public static boolean supportsEglRecordableAndroid() {
    return SDK_VERSION >= Build.VERSION_CODES.O;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.S)
  public static boolean supportsEncoderProfiles() {
    return SDK_VERSION >= Build.VERSION_CODES.S;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.M)
  public static boolean supportsMarshmallowNoiseReductionModes() {
    return SDK_VERSION >= Build.VERSION_CODES.M;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.P)
  public static boolean supportsSessionConfiguration() {
    return SDK_VERSION >= Build.VERSION_CODES.P;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.N)
  public static boolean supportsVideoPause() {
    return SDK_VERSION >= Build.VERSION_CODES.N;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.R)
  public static boolean supportsZoomRatio() {
    return SDK_VERSION >= Build.VERSION_CODES.R;
  }
}
