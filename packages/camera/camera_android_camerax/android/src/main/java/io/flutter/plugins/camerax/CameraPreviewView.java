// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import android.graphics.Matrix;
import android.util.Log;
import android.view.TextureView;
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
      PreviewView previewView) {
    this.previewView = previewView;

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
            int w = right - left;
            int h = bottom - top;
            Log.d("CAMILLE_DEBUG", "Native PreviewView bounds: " + w + "x" + h);
            refreshTransform();
            for (int i = 0; i < previewView.getChildCount(); i++) {
              View child = previewView.getChildAt(i);
              Matrix matrix = new Matrix();
              if (child instanceof TextureView) {
                ((TextureView) child).getTransform(matrix);
              }
              Log.d(
                  "CAMILLE_DEBUG",
                  "  PreviewView child["
                      + i
                      + "] ("
                      + child.getClass().getSimpleName()
                      + "): "
                      + child.getWidth()
                      + "x"
                      + child.getHeight()
                      + ", scale=("
                      + child.getScaleX()
                      + ", "
                      + child.getScaleY()
                      + "), trans=("
                      + child.getTranslationX()
                      + ", "
                      + child.getTranslationY()
                      + "), matrix="
                      + matrix);
            }
          }
        });

    this.previewView.setOnHierarchyChangeListener(
        new ViewGroup.OnHierarchyChangeListener() {
          @Override
          public void onChildViewAdded(View parent, View child) {
            Log.d(
                "CAMILLE_DEBUG",
                "PreviewView child view added: " + child.getClass().getSimpleName());
            previewView.post(
                new Runnable() {
                  @Override
                  public void run() {
                    refreshTransform();
                  }
                });
          }

          @Override
          public void onChildViewRemoved(View parent, View child) {
            Log.d(
                "CAMILLE_DEBUG",
                "PreviewView child view removed: " + child.getClass().getSimpleName());
          }
        });

    this.streamStateObserver =
        new Observer<PreviewView.StreamState>() {
          @Override
          public void onChanged(PreviewView.StreamState streamState) {
            Log.d("CAMILLE_DEBUG", "PreviewView streamState changed to: " + streamState);
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

  private void refreshTransform() {
    try {
      previewView.setScaleType(previewView.getScaleType());
    } catch (Exception e) {
      Log.w("CAMILLE_DEBUG", "Could not refresh PreviewView scaleType: " + e.getMessage());
    }
  }

  @NonNull
  @Override
  public View getView() {
    refreshTransform();
    previewView.requestLayout();
    previewView.post(
        new Runnable() {
          @Override
          public void run() {
            refreshTransform();
            previewView.requestLayout();
            previewView.invalidate();
          }
        });
    return previewView;
  }

  @Override
  public void dispose() {
    this.previewView.getPreviewStreamState().removeObserver(this.streamStateObserver);
    this.previewView.setOnHierarchyChangeListener(null);
    if (previewView.getParent() instanceof ViewGroup) {
      ((ViewGroup) previewView.getParent()).removeView(previewView);
    }
  }
}
