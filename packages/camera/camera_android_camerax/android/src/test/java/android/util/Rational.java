// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.util;

// Creates an implementation of Rational that can be used with unittests and the JVM.
// Typically android.util.Rational does nothing when not used with an Android environment.

public final class Rational {
  private final int numerator;
  private final int denominator;

  public Rational(int numerator, int denominator) {
    this.numerator = numerator;
    this.denominator = denominator;
  }

  public double doubleValue() {
    return (double) numerator / denominator;
  }
}
