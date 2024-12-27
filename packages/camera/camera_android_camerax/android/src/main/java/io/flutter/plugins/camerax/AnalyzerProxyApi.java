// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageAnalysis.Analyzer;

/**
 * ProxyApi implementation for {@link Analyzer}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class AnalyzerProxyApi extends PigeonApiAnalyzer {
  AnalyzerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  /** Implementation of {@link Analyzer} that passes arguments of callback methods to Dart. */
  static class AnalyzerImpl implements Analyzer {
    private final AnalyzerProxyApi api;

    AnalyzerImpl(@NonNull AnalyzerProxyApi api) {
      this.api = api;
    }

    @Override
    public void analyze(@NonNull androidx.camera.core.ImageProxy image) {
      api.getPigeonRegistrar().runOnMainThread(() -> api.analyze(this, image, reply -> null));
    }
  }

  @NonNull
  @Override
  public Analyzer pigeon_defaultConstructor() {
    return new AnalyzerImpl(this);
  }
}
