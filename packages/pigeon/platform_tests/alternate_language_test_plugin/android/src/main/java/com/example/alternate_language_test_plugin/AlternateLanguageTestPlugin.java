// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.alternate_language_test_plugin;

import androidx.annotation.NonNull;
import com.example.alternate_language_test_plugin.AllDatatypes.Everything;
import com.example.alternate_language_test_plugin.AllDatatypes.HostEverything;
import com.example.alternate_language_test_plugin.AllVoid.AllVoidHostApi;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/** This plugin handles the native side of the integration tests in example/integration_test/. */
public class AlternateLanguageTestPlugin implements FlutterPlugin, AllVoidHostApi, HostEverything {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
    AllVoidHostApi.setup(binding.getBinaryMessenger(), this);
    HostEverything.setup(binding.getBinaryMessenger(), this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  // AllVoidHostApi

  @Override
  public void doit() {
    // No-op.
  }

  // HostEverything

  @Override
  public @NonNull Everything giveMeEverything() {
    // Currently unused in integration tests, so just return an empty object.
    return new Everything();
  }

  @Override
  public @NonNull Everything echo(@NonNull Everything everything) {
    return everything;
  }
}
