// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package android.util;

// Creates an implementation of Range that can be used with unittests and the JVM.
// Typically android.util.Size does nothing when not used with an Android environment.

public final class Size {
  private final int width;
  private final int height;

  public Size(int width, int height) {
    this.width = width;
    this.height = height;
  }

  public int getWidth() {
    return width;
  }

  public int getHeight() {
    return height;
  }

  public boolean equals(Object obj) {
    if (obj instanceof Size) {
      return ((Size) obj).width == width && ((Size) obj).height == height;
    }

    return false;
  }

  @Override
  public int hashCode() {
    return super.hashCode();
  }
}
