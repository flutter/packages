// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.shared_preferences_example;

import android.content.SharedPreferences;
import androidx.annotation.NonNull;
import androidx.preference.PreferenceManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);
    SharedPreferences preferences =
        PreferenceManager.getDefaultSharedPreferences(getApplicationContext());

    // These calls add preferences for later testing in the Dart integration tests.
    preferences
        .edit()
        .putInt("thisIntIsWrittenInTheExampleAppJavaCode", 5)
        .putString("thisStringIsWrittenInTheExampleAppJavaCode", "testString")
        .commit();
  }
}
