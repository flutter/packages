// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.pigeon_example_app

import ExampleHostApi
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

// #docregion kotlin-class
private class PigeonApiImplementation: ExampleHostApi {
    override fun getHostLanguage(): String {
        return "Kotlin"
    }

    fun add(a: Long, b: Long): Long {
        return a + b
    }

    fun sendMessage(message: CreateMessage, callback: (Result<Boolean>) -> Unit) {
        callback(Result.success(true))
    }
}
// #enddocregion kotlin-class

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val api = PigeonApiImplementation()
        ExampleHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, api);
    }
}
