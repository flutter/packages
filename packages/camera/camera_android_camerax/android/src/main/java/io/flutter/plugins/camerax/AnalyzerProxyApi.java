// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageAnalysis.Analyzer;
import androidx.camera.core.ImageProxy;
import java.nio.ByteBuffer;
import java.util.Objects;

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
    final AnalyzerProxyApi api;

    AnalyzerImpl(@NonNull AnalyzerProxyApi api) {
      this.api = api;
    }

    @Override
    public void analyze(@NonNull ImageProxy image) {
      api.getPigeonRegistrar()
          .runOnMainThread(
              new ProxyApiRegistrar.FlutterMethodRunnable() {
                @Override
                public void run() {
                  api.analyze(
                      AnalyzerImpl.this,
                      image,
                      ResultCompat.asCompatCallback(
                          result -> {
                            if (result.isFailure()) {
                              onFailure(
                                  "Analyzer.analyze",
                                  Objects.requireNonNull(result.exceptionOrNull()));
                            }
                            return null;
                          }));
                }
              });
    }
  }

  @NonNull
  @Override
  public Analyzer pigeon_defaultConstructor() {
    return new AnalyzerImpl(this);
  }

  ///// OTHER METHODS FOR NV21 TESTING //////
  /**
   * Checks if the UV plane buffers of a YUV_420_888 image are in the NV21 format.
   *
   * <p>https://github.com/googlesamples/mlkit/blob/master/android/vision-quickstart/app/src/main/java/com/google/mlkit/vision/demo/BitmapUtils.java
   */
  private static boolean areUVPlanesNV21(
      ByteBuffer uBuffer, ByteBuffer vBuffer, int width, int height) {
    int imageSize = width * height;

    // ByteBuffer uBuffer = planes[1].getBuffer();
    // ByteBuffer vBuffer = planes[2].getBuffer();

    // Backup buffer properties.
    int vBufferPosition = vBuffer.position();
    int uBufferLimit = uBuffer.limit();

    // Advance the V buffer by 1 byte, since the U buffer will not contain the first V value.
    vBuffer.position(vBufferPosition + 1);
    // Chop off the last byte of the U buffer, since the V buffer will not contain the last U value.
    uBuffer.limit(uBufferLimit - 1);

    // Check that the buffers are equal and have the expected number of elements.
    boolean areNV21 =
        (vBuffer.remaining() == (2 * imageSize / 4 - 2)) && (vBuffer.compareTo(uBuffer) == 0);

    // Restore buffers to their initial state.
    vBuffer.position(vBufferPosition);
    uBuffer.limit(uBufferLimit);

    return areNV21;
  }
}
