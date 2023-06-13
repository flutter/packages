// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android_example;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;

/** Test Activity that sets the name of the Dart method entrypoint. */
public class DriverExtensionActivity extends FlutterActivity {
  @NonNull
  @Override
  public String getDartEntrypointFunctionName() {
    // Name of method in `lib/main.dart` that enables driver extension.
    return "integrationTestMain";
  }
}
