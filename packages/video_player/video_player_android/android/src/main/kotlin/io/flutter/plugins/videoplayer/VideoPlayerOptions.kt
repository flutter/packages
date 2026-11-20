// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

internal class VideoPlayerOptions(
    @JvmField var mixWithOthers: Boolean = false,
    /**
     * The duration of the back buffer in milliseconds, used to configure ExoPlayer's load control.
     */
    @JvmField var backBufferDurationMs: Long? = null
) {

  /** Copy constructor to ensure all options are reliably copied. */
  constructor(other: VideoPlayerOptions) : this(other.mixWithOthers, other.backBufferDurationMs)
}
