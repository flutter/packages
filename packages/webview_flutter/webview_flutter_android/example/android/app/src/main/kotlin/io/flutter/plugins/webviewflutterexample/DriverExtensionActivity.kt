// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutterexample

import io.flutter.embedding.android.FlutterActivity

class DriverExtensionActivity : FlutterActivity() {
  override fun getDartEntrypointFunctionName(): String = "appMain"
}
