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
  public void setInsetListenerToSetInsetsToZero(
      @NonNull View pigeon_instance, @NonNull List<? extends WindowInsetsType> types) {
    if (types.isEmpty()) {
      ViewCompat.setOnApplyWindowInsetsListener(
          pigeon_instance, (view, windowInsets) -> windowInsets);
      return;
    }

    int typeMaskAccumulator = 0;
    for (WindowInsetsType type : types) {
      switch (type) {
        case SYSTEM_BARS:
          typeMaskAccumulator |= WindowInsetsCompat.Type.systemBars();
          break;
        case DISPLAY_CUTOUT:
          typeMaskAccumulator |= WindowInsetsCompat.Type.displayCutout();
          break;
        case CAPTION_BAR:
          typeMaskAccumulator |= WindowInsetsCompat.Type.captionBar();
          break;
        case IME:
          typeMaskAccumulator |= WindowInsetsCompat.Type.ime();
          break;
        case MANDATORY_SYSTEM_GESTURES:
          typeMaskAccumulator |= WindowInsetsCompat.Type.mandatorySystemGestures();
          break;
        case NAVIGATION_BARS:
          typeMaskAccumulator |= WindowInsetsCompat.Type.navigationBars();
          break;
        case STATUS_BARS:
          typeMaskAccumulator |= WindowInsetsCompat.Type.statusBars();
          break;
        case SYSTEM_GESTURES:
          typeMaskAccumulator |= WindowInsetsCompat.Type.systemGestures();
          break;
        case TAPPABLE_ELEMENT:
          typeMaskAccumulator |= WindowInsetsCompat.Type.tappableElement();
          break;
      }
    }
    final int insetsTypeMask = typeMaskAccumulator;

    ViewCompat.setOnApplyWindowInsetsListener(
        pigeon_instance,
        (view, windowInsets) ->
            new WindowInsetsCompat.Builder(windowInsets)
                .setInsets(insetsTypeMask, Insets.NONE)
                .build());
  }
}
