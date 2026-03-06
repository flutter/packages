// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.view.View;
import androidx.core.graphics.Insets;
import androidx.core.view.OnApplyWindowInsetsListener;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import java.util.Collections;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;

public class ViewTest {
  @Test
  public void scrollTo() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final long x = 0L;
    final long y = 1L;
    api.scrollTo(instance, x, y);

    verify(instance).scrollTo((int) x, (int) y);
  }

  @Test
  public void scrollBy() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final long x = 0L;
    final long y = 1L;
    api.scrollBy(instance, x, y);

    verify(instance).scrollBy((int) x, (int) y);
  }

  @Test
  public void getScrollPosition() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final WebViewPoint value = new WebViewPoint(0L, 1L);
    when(instance.getScrollX()).thenReturn((int) value.getX());
    when(instance.getScrollY()).thenReturn((int) value.getY());

    assertEquals(value.getX(), api.getScrollPosition(instance).getX());
    assertEquals(value.getY(), api.getScrollPosition(instance).getY());
  }

  @Test
  public void setVerticalScrollBarEnabled() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final boolean enabled = true;
    api.setVerticalScrollBarEnabled(instance, enabled);

    verify(instance).setVerticalScrollBarEnabled(enabled);
  }

  @Test
  public void setHorizontalScrollBarEnabled() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final boolean enabled = false;
    api.setHorizontalScrollBarEnabled(instance, enabled);

    verify(instance).setHorizontalScrollBarEnabled(enabled);
  }

  @Test
  public void setOverScrollMode() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final OverScrollMode mode = io.flutter.plugins.webviewflutter.OverScrollMode.ALWAYS;
    api.setOverScrollMode(instance, mode);

    verify(instance).setOverScrollMode(View.OVER_SCROLL_ALWAYS);
  }

  @Test
  public void setInsetListenerToSetInsetsToZero() {
    final PigeonApiView api = new TestProxyApiRegistrar().getPigeonApiView();

    final View instance = mock(View.class);
    final WindowInsetsCompat windowInsets = mock(WindowInsetsCompat.class);
    final Insets insets = Insets.of(1, 2, 3, 4);

    when(windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())).thenReturn(insets);

    try (MockedStatic<ViewCompat> viewCompatMockedStatic = mockStatic(ViewCompat.class)) {
      api.setInsetListenerToSetInsetsToZero(
          instance, Collections.singletonList(WindowInsets.SYSTEM_BARS));

      final ArgumentCaptor<OnApplyWindowInsetsListener> listenerCaptor =
          ArgumentCaptor.forClass(OnApplyWindowInsetsListener.class);
      viewCompatMockedStatic.verify(
          () -> ViewCompat.setOnApplyWindowInsetsListener(eq(instance), listenerCaptor.capture()));

      listenerCaptor.getValue().onApplyWindowInsets(instance, windowInsets);

      verify(instance).setPadding(insets.left, insets.top, insets.right, insets.bottom);
    }
  }
}
