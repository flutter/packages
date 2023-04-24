// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.autofocus;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

// Mirrors focus_mode.dart
public enum FocusMode {
  auto("auto"),
  locked("locked");

  private final String strValue;

  FocusMode(String strValue) {
    this.strValue = strValue;
  }

  @Nullable
  public static FocusMode getValueForString(@NonNull String modeStr) {
    for (FocusMode value : values()) {
      if (value.strValue.equals(modeStr)) {
        return value;
      }
    }
    return null;
  }

  @Override
  public String toString() {
    return strValue;
  }
}
