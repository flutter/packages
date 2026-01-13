// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.util;

// Creates an implementation of Range that can be used with unittests and the JVM.
// Typically android.util.Range does nothing when not used with an Android environment.
public final class Range<T extends Comparable<? super T>> {
  private final T lower;
  private final T upper;

  public Range(T lower, T upper) {
    this.lower = lower;
    this.upper = upper;
  }

  public T getLower() {
    return lower;
  }

  public T getUpper() {
    return upper;
  }
}
