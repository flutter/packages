// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

/**
 * Represents a position on a web page.
 *
 * <p>This is a custom class created for convenience of the wrapper.
 */
public class WebViewPoint {
  private final long x;
  private final long y;

  public WebViewPoint(long x, long y) {
    this.x = x;
    this.y = y;
  }

  public long getX() {
    return x;
  }

  public long getY() {
    return y;
  }
}
