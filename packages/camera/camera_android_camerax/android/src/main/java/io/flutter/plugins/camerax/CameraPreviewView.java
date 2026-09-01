// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.view.PreviewView;
import androidx.lifecycle.Observer;
import io.flutter.plugin.platform.PlatformView;
import java.util.Map;

class CameraPreviewView implements PlatformView {
  @NonNull private final PreviewView previewView;
  @NonNull private final Observer<PreviewView.StreamState> streamStateObserver;

  CameraPreviewView(
      @NonNull Context context,
      int id,
      @Nullable Map<String, Object> creationParams,
      @NonNull PreviewView previewView) {
    this.previewView = previewView;

    // CameraX's PreviewView internally updates the child transform matrix and scale factors
    // on layout change, but only when (width != oldWidth || height != oldHeight). On 180-degree
    // device rotations or layout passes where dimensions do not change, CameraX skips updating
    // the transform. Listening to layout changes ensures the transform is always refreshed.
    this.previewView.addOnLayoutChangeListener(
        new View.OnLayoutChangeListener() {
          @Override
          public void onLayoutChange(
              View v,
              int left,
              int top,
              int right,
              int bottom,
              int oldLeft,
              int oldTop,
              int oldRight,
              int oldBottom) {
            refreshTransform();
          }
        });

    // When switching cameras (e.g. front to back) while remaining in the same device orientation,
    // PreviewView's outer dimensions do not change, so no layout pass occurs on PreviewView.
    // CameraX recreates the internal preview surface child (e.g. TextureView) initialized to the
    // raw stream resolution (e.g. 320x240) with scale (1.0, 1.0). Observing STREAMING ensures
    // that as soon as frames begin flowing from the new camera, refreshTransform() is called to
    // scale the child view to fill the container, preventing the "tiny preview" bug.
    this.streamStateObserver =
        new Observer<PreviewView.StreamState>() {
          @Override
          public void onChanged(PreviewView.StreamState streamState) {
            if (streamState == PreviewView.StreamState.STREAMING) {
              previewView.post(
                  new Runnable() {
                    @Override
                    public void run() {
                      refreshTransform();
                    }
                  });
            }
          }
        };
    this.previewView.getPreviewStreamState().observeForever(this.streamStateObserver);
  }

  /**
   * Forces CameraX to recalculate and apply scale and rotation transformations to the internal
   * preview child view (TextureView/SurfaceView).
   *
   * <p>Setting the scale type triggers CameraX's internal redrawPreview() and transformView() logic
   * without requiring access to package-private APIs.
   */
  private void refreshTransform() {
    try {
      previewView.setScaleType(previewView.getScaleType());
    } catch (Exception e) {
      // Ignored if the view or camera stream is not ready yet.
    }
  }

  @NonNull
  @Override
  public View getView() {
    refreshTransform();
    return previewView;
  }

  @Override
  public void dispose() {
    previewView.getPreviewStreamState().removeObserver(streamStateObserver);
    // Detach the shared PreviewView from its parent container when this platform
    // view is disposed to prevent holding onto old view hierarchy references.
    if (previewView.getParent() instanceof ViewGroup) {
      ((ViewGroup) previewView.getParent()).removeView(previewView);
    }
  }
}
