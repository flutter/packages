// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.Preview;
import androidx.camera.view.PreviewView;

/**
 * ProxyApi implementation for {@link PreviewView}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class PreviewViewProxyApi extends PigeonApiPreviewView {
  PreviewViewProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public PreviewView pigeon_defaultConstructor() {
    return new PreviewView(getPigeonRegistrar().getContext());
  }

  @Override
  public void setImplementationMode(
      @NonNull PreviewView pigeonInstance, @NonNull PreviewViewImplementationMode mode) {
    switch (mode) {
      case PERFORMANCE:
        pigeonInstance.setImplementationMode(PreviewView.ImplementationMode.PERFORMANCE);
        break;
      case COMPATIBLE:
        pigeonInstance.setImplementationMode(PreviewView.ImplementationMode.COMPATIBLE);
        break;
    }
  }

  @Override
  public void setScaleType(
      @NonNull PreviewView pigeonInstance, @NonNull PreviewViewScaleType scaleType) {
    switch (scaleType) {
      case FILL_CENTER:
        pigeonInstance.setScaleType(PreviewView.ScaleType.FILL_CENTER);
        break;
      case FIT_CENTER:
        pigeonInstance.setScaleType(PreviewView.ScaleType.FIT_CENTER);
        break;
    }
  }

  @NonNull
  @Override
  public Preview.SurfaceProvider getSurfaceProvider(@NonNull PreviewView pigeonInstance) {
    return pigeonInstance.getSurfaceProvider();
  }
}
