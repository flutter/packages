// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.view.View;
import androidx.annotation.NonNull;

/**
 * Flutter API implementation for `View`.
 *
 * <p>This class may handle adding native instances that are attached to a Dart instance or passing
 * arguments of callbacks methods to a Dart instance.
 */
public class ViewProxyApi extends PigeonApiView {
  /** Constructs a {@link ViewProxyApi}. */
  public ViewProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void scrollTo(@NonNull View pigeon_instance, long x, long y) {
    pigeon_instance.scrollTo((int) x, (int) y);
  }

  @Override
  public void scrollBy(@NonNull View pigeon_instance, long x, long y) {
    pigeon_instance.scrollBy((int) x, (int) y);
  }

  @NonNull
  @Override
  public WebViewPoint getScrollPosition(@NonNull View pigeon_instance) {
    return new WebViewPoint(pigeon_instance.getScrollX(), pigeon_instance.getScrollY());
  }
}
