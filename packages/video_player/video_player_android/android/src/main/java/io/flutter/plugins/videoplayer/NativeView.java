// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import android.view.SurfaceView;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;

class NativeView implements PlatformView {
  @NonNull private final SurfaceView surfaceView;

  NativeView(@NonNull Context context, @NonNull ExoPlayer exoPlayer) {
    surfaceView = new SurfaceView(context);
    // The line below is needed to display the video correctly on older Android versions (blank
    // space instead of a video).
    surfaceView.setZOrderMediaOverlay(true);
    exoPlayer.setVideoSurfaceView(surfaceView);
  }

  @NonNull
  @Override
  public View getView() {
    return surfaceView;
  }

  @Override
  public void dispose() {
    surfaceView.getHolder().getSurface().release();
  }
}
