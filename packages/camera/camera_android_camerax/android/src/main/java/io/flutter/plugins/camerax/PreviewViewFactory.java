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
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

/**
 * Platform view factory that shows a {@link PreviewView} created by the Dart side through {@link
 * PreviewViewProxyApi}.
 *
 * <p>The creation parameter is the {@code InstanceManager} identifier of that {@link PreviewView}.
 */
class PreviewViewFactory extends PlatformViewFactory {
  /** The view type registered with the platform view registry. */
  static final String VIEW_TYPE = "plugins.flutter.io/camera_android_camerax/preview_view";

  @NonNull private final CameraXLibraryPigeonInstanceManager instanceManager;

  PreviewViewFactory(@NonNull CameraXLibraryPigeonInstanceManager instanceManager) {
    super(StandardMessageCodec.INSTANCE);
    this.instanceManager = instanceManager;
  }

  @NonNull
  @Override
  public PlatformView create(@NonNull Context context, int viewId, @Nullable Object args) {
    if (!(args instanceof Number)) {
      throw new IllegalArgumentException(
          "PreviewView platform view requires the identifier of a PreviewView as creation"
              + " parameter.");
    }
    final PreviewView previewView = instanceManager.getInstance(((Number) args).longValue());
    if (previewView == null) {
      throw new IllegalStateException("No PreviewView exists for the requested identifier.");
    }

    // A previous platform view for the same PreviewView may not have been detached yet.
    if (previewView.getParent() instanceof ViewGroup) {
      ((ViewGroup) previewView.getParent()).removeView(previewView);
    }

    return new PlatformView() {
      @NonNull
      @Override
      public View getView() {
        return previewView;
      }

      @Override
      public void dispose() {}
    };
  }
}
