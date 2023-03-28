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

  /**
   * Sets the context that will be used to run an {@link ImageAnalysis.Analyzer} on the main thread.
   */
  public void setContext(Context context) {
    this.context = context;
  }

  /** Creates an {@link ImageAnalysis} instance with the target resolution if specified. */
  @Override
  public void create(@NonNull Long identifier, @Nullable ResolutionInfo targetResolution) {
    ImageAnalysis.Builder imageAnalysisBuilder = cameraXProxy.createImageAnalysisBuilder();

    if (targetResolution != null) {
      imageAnalysisBuilder.setTargetResolution(CameraXProxy.sizeFromResolution(targetResolution));
    }

    ImageAnalysis imageAnalysis = imageAnalysisBuilder.build();
    instanceManager.addDartCreatedInstance(imageAnalysis, identifier);
  }

  /**
   * Sets an analyzer created by {@link ImageAnalysisHostApiImpl#createImageAnalysisAnalyzer()} on
   * an {@link ImageAnalysis} instance to receive and analyze images.
   */
  @Override
  public void setAnalyzer(@NonNull Long identifier) {
    ImageAnalysis imageAnalysis =
        (ImageAnalysis) Objects.requireNonNull(instanceManager.getInstance(identifier));
    ImageAnalysis.Analyzer analyzer = createImageAnalysisAnalyzer();
    imageAnalysis.setAnalyzer(ContextCompat.getMainExecutor(context), analyzer);
  }

  /**
   * Creates an {@link ImageAnalysis.Analyzer} instance to send image information to the Dart side
   * to support image streaming.
   *
   * <p>The image information collected and sent matches that of the (Dart) CameraImageData class,
   * which is required for image streaming in this plugin.
   */
  private ImageAnalysis.Analyzer createImageAnalysisAnalyzer() {
    return new ImageAnalysis.Analyzer() {
      @Override
      public void analyze(@NonNull ImageProxy image) {
        // Collect image plane information.
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

        // Collect general image information.
        // TODO(camsim99): Retrieve and send the following when made available by b/274791178:
        // last lens aperture, last sensor exposure time, last sensor sensitivity.
        GeneratedCameraXLibrary.ImageInformation.Builder imageInfoBuilder =
            new GeneratedCameraXLibrary.ImageInformation.Builder();
        imageInfoBuilder.setFormat(Long.valueOf(image.getFormat()));
        imageInfoBuilder.setImagePlanesInformation(imagePlanesInformation);
        imageInfoBuilder.setHeight(Long.valueOf(image.getHeight()));
        imageInfoBuilder.setWidth(Long.valueOf(image.getWidth()));

        // Send image frame to Dart side for image streaming and close ImageProxy, since we are done using it.
        ImageAnalysisFlutterApiImpl imageAnalysisFlutterApiImpl =
            cameraXProxy.createImageAnalysisFlutterApiImpl(binaryMessenger);
        imageAnalysisFlutterApiImpl.sendOnImageAnalyzedEvent(imageInfoBuilder.build(), reply -> {});
        image.close();
      }
    };
  }

  /** Clears any analyzer previously set on the specified {@link ImageAnalysis} instance. */
  @Override
  public void clearAnalyzer(@NonNull Long identifier) {
    ImageAnalysis imageAnalysis =
        (ImageAnalysis) Objects.requireNonNull(instanceManager.getInstance(identifier));
    imageAnalysis.clearAnalyzer();
  }
}
