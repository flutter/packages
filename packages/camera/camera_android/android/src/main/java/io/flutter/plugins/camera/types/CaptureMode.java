// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

// Mirrors camera.dart
public enum CaptureMode {
  photo("photo"),
  video("video");

  private final String strValue;

  CaptureMode(String strValue) {
    this.strValue = strValue;
  }

  @Nullable
  public static CaptureMode getValueForString(@NonNull String modeStr) {
    for (CaptureMode value : values()) {
      if (value.strValue.equals(modeStr)) return value;
    }
    return null;
  }

  @Override
  public String toString() {
    return strValue;
  }
}