// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import androidx.annotation.Nullable;

/** Stores settings for image output options. */
public class ImageOutputOptions {
  /** The maximum width of the image, if the width should be constrained. */
  @Nullable public final Double maxWidth;
  /** The maximum height of the image, if the width should be constrained. */
  @Nullable public final Double maxHeight;
  /**
   * The output quality of the image, as a number from 0 to 100.
   *
   * <p>Defaults to 100.
   */
  final int quality;

  public ImageOutputOptions(
      @Nullable Double maxWidth, @Nullable Double maxHeight, @Nullable Integer quality) {
    this.maxWidth = maxWidth;
    this.maxHeight = maxHeight;
    // Treat any invalid value as full quality.
    this.quality = quality == null || quality < 0 || quality > 100 ? 100 : quality;
  }
}
