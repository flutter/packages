// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.annotation.SuppressLint;
import android.os.Build;
import androidx.annotation.ChecksSdkIntAtLeast;
import androidx.annotation.VisibleForTesting;

/** Abstracts SDK version checks, and allows overriding them in unit tests. */
public class SdkCapabilityChecker {
  /** The current SDK version, overridable for testing. */
  @SuppressLint("AnnotateVersionCheck")
  @VisibleForTesting
  public static int SDK_VERSION = Build.VERSION.SDK_INT;

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.P)
  public static boolean supportsDistortionCorrection() {
    // See https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#DISTORTION_CORRECTION_AVAILABLE_MODES
    return SDK_VERSION >= Build.VERSION_CODES.P;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.O)
  public static boolean supportsEglRecordableAndroid() {
    // See https://developer.android.com/reference/android/opengl/EGLExt#EGL_RECORDABLE_ANDROID
    return SDK_VERSION >= Build.VERSION_CODES.O;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.S)
  public static boolean supportsEncoderProfiles() {
    // See https://developer.android.com/reference/android/media/EncoderProfiles
    return SDK_VERSION >= Build.VERSION_CODES.S;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.P)
  public static boolean supportsSessionConfiguration() {
    // See https://developer.android.com/reference/android/hardware/camera2/params/SessionConfiguration
    return SDK_VERSION >= Build.VERSION_CODES.P;
  }

  @ChecksSdkIntAtLeast(api = Build.VERSION_CODES.R)
  public static boolean supportsZoomRatio() {
    // See https://developer.android.com/reference/android/hardware/camera2/CaptureRequest#CONTROL_ZOOM_RATIO
    return SDK_VERSION >= Build.VERSION_CODES.R;
  }
}
