// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.WebChromeClient.CustomViewCallback;
import androidx.annotation.NonNull;

/**
 * Host API implementation for `CustomViewCallback`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class CustomViewCallbackProxyApi extends PigeonApiCustomViewCallback {
  /** Constructs a {@link CustomViewCallbackProxyApi}. */
  public CustomViewCallbackProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void onCustomViewHidden(@NonNull CustomViewCallback pigeon_instance) {
    pigeon_instance.onCustomViewHidden();
  }
}
