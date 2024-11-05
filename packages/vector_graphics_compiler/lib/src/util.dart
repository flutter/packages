// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A utility method for comparing lists for equality.
///
/// This method assumes that [T] implements a meaningful equality operator.
/// Therefore, thi method should not be used to compare lists containing
/// nested lists.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) {
    return b == null;
  }
  if (b == null || a.length != b.length) {
    return false;
  }
  if (identical(a, b)) {
    return true;
  }
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) {
      return false;
    }
  }
  return true;
}

/// Linearly interpolates between two doubles by factor t.
@pragma('vm:prefer-inline')
double lerpDouble(double a, double b, double t) {
  assert(a.isFinite);
  assert(b.isFinite);
  assert(t <= 1.0);
  assert(t >= 0.0);
  return (1 - t) * a + t * b;
}
