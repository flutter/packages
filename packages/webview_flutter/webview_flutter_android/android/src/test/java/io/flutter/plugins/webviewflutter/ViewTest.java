// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.view.View;
import org.junit.Test;

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
}
