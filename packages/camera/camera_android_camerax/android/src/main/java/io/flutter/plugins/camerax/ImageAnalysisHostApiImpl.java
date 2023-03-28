// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageProxy;
import androidx.core.content.ContextCompat;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ImageAnalysisHostApi;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

public class ImageAnalysisHostApiImpl implements ImageAnalysisHostApi {

  private InstanceManager instanceManager;
  private BinaryMessenger binaryMessenger;
  private Context context;

  @VisibleForTesting public CameraXProxy cameraXProxy = new CameraXProxy();

  public ImageAnalysisHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger, @NonNull InstanceManager instanceManager) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
  }

  public void setContext(Context context) {
    this.context = context;
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
    imageAnalysis.setAnalyzer(ContextCompat.getMainExecutor(context), analyzer);
  }

  private ImageAnalysis.Analyzer createImageAnalysisAnalyzer() {
    return new ImageAnalysis.Analyzer() {
      @Override
      public void analyze(@NonNull ImageProxy image) {
        ImageProxy.PlaneProxy[] planes = image.getPlanes();
        List<GeneratedCameraXLibrary.ImagePlaneInformation> imagePlanesInformation =
            new ArrayList<GeneratedCameraXLibrary.ImagePlaneInformation>();

        for (ImageProxy.PlaneProxy plane : planes) {
          ByteBuffer byteBuffer = plane.getBuffer();
          byte[] bytes = new byte[byteBuffer.remaining()];
          byteBuffer.get(bytes, 0, bytes.length);
          GeneratedCameraXLibrary.ImagePlaneInformation.Builder imagePlaneInfoBuilder =
              new GeneratedCameraXLibrary.ImagePlaneInformation.Builder();

          imagePlanesInformation.add(
              imagePlaneInfoBuilder
                  .setBytesPerRow(Long.valueOf(plane.getRowStride()))
                  .setBytesPerPixel(Long.valueOf(plane.getPixelStride()))
                  .setBytes(bytes)
                  .build());
        }

        // TODO (camsim99): Retrieve and send the following when made available by b/274791178: 
        // last lens aperture, last sensor exposure time, last sensor sensitivity.
        GeneratedCameraXLibrary.ImageInformation.Builder imageInfoBuilder =
            new GeneratedCameraXLibrary.ImageInformation.Builder();
        imageInfoBuilder.setWidth(Long.valueOf(image.getWidth()));
        imageInfoBuilder.setHeight(Long.valueOf(image.getHeight()));
        imageInfoBuilder.setFormat(Long.valueOf(image.getFormat()));
        imageInfoBuilder.setImagePlanesInformation(imagePlanesInformation);

        ImageAnalysisFlutterApiImpl imageAnalysisFlutterApiImpl =
          cameraXProxy.createImageAnalysisFlutterApiImpl(binaryMessenger);
        imageAnalysisFlutterApiImpl.sendOnImageAnalyzedEvent(imageInfoBuilder.build(), reply -> {});
        image.close();
      }
    };
  }

  @Override
  public void clearAnalyzer(@NonNull Long identifier) {
    ImageAnalysis imageAnalysis =
      (ImageAnalysis) Objects.requireNonNull(instanceManager.getInstance(identifier));
    imageAnalysis.clearAnalyzer();
  }

}
