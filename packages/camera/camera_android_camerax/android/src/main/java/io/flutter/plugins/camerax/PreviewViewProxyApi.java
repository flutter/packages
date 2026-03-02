// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.view.PreviewView;
import androidx.camera.core.Preview;
import java.util.Objects;


class PreviewViewProxyApi extends PigeonApiPreviewView {
  // Cached previewView.
  PreviewView previewView;

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
    PreviewView previewView = new PreviewView(getPigeonRegistrar().getContext());
    previewView.setImplementationMode(PreviewView.ImplementationMode.COMPATIBLE);

    return previewView;
  }

  @NonNull
  @Override
  public void registerPreviewView(PreviewView pigeon_instance) {
    getPigeonRegistrar().registerPlatformView(pigeon_instance);
  }

  @NonNull
  @Override
  public Preview.SurfaceProvider getSurfaceProvider(PreviewView pigeon_instance) {
    return pigeon_instance.getSurfaceProvider();
  }
}
