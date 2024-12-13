// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.shared_preferences_example

import androidx.preference.PreferenceManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val preferences =
            PreferenceManager.getDefaultSharedPreferences(applicationContext)

        // This call adds a preference for later testing in the Dart integration tests.
        preferences
            .edit()
            .putString("thisStringIsWrittenInTheExampleAppJavaCode", "testString")
            .commit()
    }
}
