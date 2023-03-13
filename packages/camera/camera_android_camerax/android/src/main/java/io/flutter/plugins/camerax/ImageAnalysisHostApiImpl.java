// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Log;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageAnalysisHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import java.util.Objects;
import java.util.concurrent.Executors;

public class ImageAnalysisHostApiImpl implements ImageAnalysisHostApi {

  private InstanceManager instanceManager;
  private BinaryMessenger binaryMessenger;

  @VisibleForTesting CameraXProxy cameraXProxy = new CameraXProxy();

  public ImageAnalysisHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  @Override
  public void create(@NonNull Long identifier, @Nullable ResolutionInfo targetResolution) {
    ImageAnalysis.Builder imageAnalysisBuilder = cameraXProxy.createImageAnalysisBuilder();

    if (targetResolution != null) {
      imageAnalysisBuilder.setTargetResolution(CameraXProxy.sizeFromResolution(targetResolution));
    }

    ImageAnalysis imageAnalysis = imageAnalysisBuilder.build();
    instanceManager.addDartCreatedInstance(imageAnalysis, identifier);
  }

  @Override
  public void setAnalyzer(@NonNull Long identifier) {
    ImageAnalysis imageAnalysis =
        (ImageAnalysis) Objects.requireNonNull(instanceManager.getInstance(identifier));
    ImageAnalysis.Analyzer analyzer = createImageAnalysisAnalyzer();
    imageAnalysis.setAnalyzer(Executors.newSingleThreadExecutor(), analyzer);
  }

  private ImageAnalysis.Analyzer createImageAnalysisAnalyzer() {
    return new ImageAnalysis.Analyzer() {
      @Override
      public void analyze(@NonNull ImageProxy image) {
        ImageProxy.PlaneProxy[] planes = image.getPlanes();

        List<GeneratedCameraXLibrary.ImagePlaneInformation> imagePlanesInformation = new ArrayList<GeneratedCameraXLibrary.ImagePlaneInformation>();
        for(ImageProxy.PlaneProxy plane : planes) {
          ByteBuffer byteBuffer = plane.getBuffer();
          byte[] bytes = new byte[byteBuffer.remaining()];
          buffer.get(bytes, 0, bytes.length);
          GeneratedCameraXLibrary.ImagePlaneInformation.Builder imagePlaneInfoBuilder = new GeneratedCameraXLibrary.ImagePlaneInformation.Builder();

          imagePlanesInformation.add(
            imagePlaneInfoBuilder
            .setBytesPerRow(plane.getRowStride())
            .setBytesPerPixel(plane.getPixelStride())
            .setBytes(bytes)
            .build());
        }

        GeneratedCameraXLibrary.ImageInformation.Builder imageInfoBuilder = new GeneratedCameraXLibrary.ImageInformation.Builder();
        imageInfoBuilder.setWidth(image.getWidth());
        imageInfoBuilder.setHeight(image.getHeight());
        imageInfoBuilder.setFormat(image.getFormat());
        imageInfoBuilder.setPlanes(imagePlanesInformation);
        // last lens aperture
        // last sensor exposure time
        // last sensor sensitivity

        image.close();
      }
    };
  }
}
