// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

// Mirrors flash_mode.dart
public enum FlashMode {
  off("off"),
  auto("auto"),
  always("always"),
  torch("torch");

  private final String strValue;

  FlashMode(String strValue) {
    this.strValue = strValue;
  }

  @Nullable
  public static FlashMode getValueForString(@NonNull String modeStr) {
    for (FlashMode value : values()) {
      if (value.strValue.equals(modeStr)) return value;
    }
    return null;
  }

  @Override
  public String toString() {
    return strValue;
  }
}
