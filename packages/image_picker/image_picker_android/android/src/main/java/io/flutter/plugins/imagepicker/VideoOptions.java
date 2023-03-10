// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import androidx.annotation.Nullable;

/** Stores settings for video selection and output options. */
public class VideoOptions {
  @Nullable public final Integer maxDuration;

  public VideoOptions(@Nullable Integer maxDuration) {
    this.maxDuration = maxDuration;
  }
}
