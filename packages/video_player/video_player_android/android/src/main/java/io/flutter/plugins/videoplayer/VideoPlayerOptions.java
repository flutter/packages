// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

class VideoPlayerOptions {
  public boolean mixWithOthers;
  public VideoPlayerBuffer buffer;
}

class VideoPlayerBuffer {
  public int minBufferMs;
  public int maxBufferMs;
  public int bufferForPlaybackMs;
  public int bufferForPlaybackAfterRebufferMs;
}
