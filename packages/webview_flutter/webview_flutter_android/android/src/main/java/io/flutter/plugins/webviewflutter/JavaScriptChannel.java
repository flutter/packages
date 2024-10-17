// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.JavascriptInterface;
import androidx.annotation.NonNull;

/**
 * Added as a JavaScript interface to the WebView for any JavaScript channel that the Dart code sets
 * up.
 *
 * <p>Exposes a single method named `postMessage` to JavaScript, which sends a message to the Dart
 * code.
 */
public class JavaScriptChannel {
  final String javaScriptChannelName;
  private final JavaScriptChannelProxyApi api;

  /** Creates a {@link JavaScriptChannel} that passes arguments of callback methods to Dart. */
  public JavaScriptChannel(@NonNull String channelName, @NonNull JavaScriptChannelProxyApi api) {
    this.javaScriptChannelName = channelName;
    this.api = api;
  }

  // Suppressing unused warning as this is invoked from JavaScript.
  @SuppressWarnings("unused")
  @JavascriptInterface
  public void postMessage(@NonNull final String message) {
    api.getPigeonRegistrar()
        .runOnMainThread(
            () -> {
              api.postMessage(JavaScriptChannel.this, message, reply -> null);
            });
  }
}
