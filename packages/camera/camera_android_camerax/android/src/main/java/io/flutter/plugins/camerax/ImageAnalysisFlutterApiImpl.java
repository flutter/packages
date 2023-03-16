// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageAnalysisFlutterApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageInformation;

public class ImageAnalysisFlutterApiImpl extends ImageAnalysisFlutterApi {
  public ImageAnalysisFlutterApiImpl(@NonNull BinaryMessenger binaryMessenger) {
    super(binaryMessenger);
  }

  public void sendOnImageAnalyzedEvent(@NonNull ImageInformation imageInformation, Reply<Void> callback) {
    Log.v("FLUTTER", "sendOnImageAnalyzedEvent");
    onImageAnalyzed(imageInformation, callback);
  }
}
