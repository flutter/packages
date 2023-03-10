package io.flutter.plugins.imagepicker;

import androidx.annotation.Nullable;

/** Stores settings for video selection and output options. */
public class VideoOptions {
  @Nullable public final Integer maxDuration;

  public VideoOptions(@Nullable Integer maxDuration) {
    this.maxDuration = maxDuration;
  }
}
