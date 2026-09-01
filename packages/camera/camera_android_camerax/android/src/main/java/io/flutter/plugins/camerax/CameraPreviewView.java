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
            refreshTransform();
          }
        });

    this.previewView.setOnHierarchyChangeListener(
        new ViewGroup.OnHierarchyChangeListener() {
          @Override
          public void onChildViewAdded(View parent, View child) {
            previewView.post(
                new Runnable() {
                  @Override
                  public void run() {
                    refreshTransform();
                  }
                });
          }

          @Override
          public void onChildViewRemoved(View parent, View child) {}
        });

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

  private void refreshTransform() {
    try {
      previewView.setScaleType(previewView.getScaleType());
    } catch (Exception e) {
      // Ignored if view is not ready yet.
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
