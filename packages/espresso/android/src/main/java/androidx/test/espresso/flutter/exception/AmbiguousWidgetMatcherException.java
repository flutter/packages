// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.exception;

import androidx.test.espresso.EspressoException;

/**
 * Indicates that a {@code WidgetMatcher} matched multiple widgets in the Flutter UI hierarchy when
 * only one widget was expected.
 */
public final class AmbiguousWidgetMatcherException extends RuntimeException
    implements EspressoException {

  private static final long serialVersionUID = 0L;

  public AmbiguousWidgetMatcherException(String message) {
    super(message);
  }
}
