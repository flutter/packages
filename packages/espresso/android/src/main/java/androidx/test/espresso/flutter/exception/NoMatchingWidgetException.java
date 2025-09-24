// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.exception;

import androidx.test.espresso.EspressoException;

/**
 * Indicates that a given {@code WidgetMatcher} did not match any widgets in the Flutter UI
 * hierarchy.
 */
public final class NoMatchingWidgetException extends RuntimeException implements EspressoException {
  private static final long serialVersionUID = 0L;

  public NoMatchingWidgetException(String message) {
    super(message);
  }
}
