// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.view.View;
import androidx.annotation.NonNull;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import java.util.List;

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

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
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

  @Override
  public void setVerticalScrollBarEnabled(@NonNull View pigeon_instance, boolean enabled) {
    pigeon_instance.setVerticalScrollBarEnabled(enabled);
  }

  @Override
  public void setHorizontalScrollBarEnabled(@NonNull View pigeon_instance, boolean enabled) {
    pigeon_instance.setHorizontalScrollBarEnabled(enabled);
  }

  @Override
  public void setOverScrollMode(@NonNull View pigeon_instance, @NonNull OverScrollMode mode) {
    switch (mode) {
      case ALWAYS:
        pigeon_instance.setOverScrollMode(View.OVER_SCROLL_ALWAYS);
        break;
      case IF_CONTENT_SCROLLS:
        pigeon_instance.setOverScrollMode(View.OVER_SCROLL_IF_CONTENT_SCROLLS);
        break;
      case NEVER:
        pigeon_instance.setOverScrollMode(View.OVER_SCROLL_NEVER);
        break;
      case UNKNOWN:
        throw getPigeonRegistrar().createUnknownEnumException(OverScrollMode.UNKNOWN);
    }
  }

  @Override
  public void setInsetListenerToSetInsetsToZero(@NonNull View pigeon_instance, @NonNull List<? extends WindowInsets> insets) {
    int insetsTypeMask = 0;
    for (WindowInsets inset : insets) {
      switch(inset) {
        case SYSTEM_BARS:
          insetsTypeMask |= WindowInsetsCompat.Type.systemBars();
          break;
        case DISPLAY_CUTOUT:
          insetsTypeMask |= WindowInsetsCompat.Type.displayCutout();
          break;
      }
    }

    final int finalTypeMask = insetsTypeMask;
    ViewCompat.setOnApplyWindowInsetsListener(pigeon_instance, (view, windowInsets) -> {
      if (finalTypeMask == 0) {
        return windowInsets;
      }

      final Insets allInsets = windowInsets.getInsets(finalTypeMask);
      pigeon_instance.setPadding(allInsets.left, allInsets.top, allInsets.right, allInsets.bottom);
      return new WindowInsetsCompat.Builder(windowInsets)
          .setInsets(finalTypeMask, Insets.NONE)
          .build();
    });
  }
}
