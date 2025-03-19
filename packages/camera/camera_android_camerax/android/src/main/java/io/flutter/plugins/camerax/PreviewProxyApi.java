// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import io.flutter.view.TextureRegistry;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;

/**
 * ProxyApi implementation for {@link Preview}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class PreviewProxyApi extends PigeonApiPreview {
  // Stores the SurfaceProducer when it is used as a SurfaceProvider for a Preview.
  private final Map<Preview, TextureRegistry.SurfaceProducer> surfaceProducers = new HashMap<>();

  PreviewProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public Preview pigeon_defaultConstructor(
      @Nullable ResolutionSelector resolutionSelector, @Nullable Long targetRotation) {
    final Preview.Builder builder = new Preview.Builder();
    if (targetRotation != null) {
      builder.setTargetRotation(targetRotation.intValue());
    }
    if (resolutionSelector != null) {
      builder.setResolutionSelector(resolutionSelector);
    }
    return builder.build();
  }

  @Override
  public long setSurfaceProvider(
      @NonNull Preview pigeon_instance, @NonNull SystemServicesManager systemServicesManager) {
    final TextureRegistry.SurfaceProducer surfaceProducer =
        getPigeonRegistrar().getTextureRegistry().createSurfaceProducer();
    final Preview.SurfaceProvider surfaceProvider =
        createSurfaceProvider(surfaceProducer, systemServicesManager);

    pigeon_instance.setSurfaceProvider(surfaceProvider);
    surfaceProducers.put(pigeon_instance, surfaceProducer);

    return surfaceProducer.id();
  }

  @Override
  public void releaseSurfaceProvider(@NonNull Preview pigeon_instance) {
    final TextureRegistry.SurfaceProducer surfaceProducer =
        surfaceProducers.remove(pigeon_instance);
    if (surfaceProducer != null) {
      surfaceProducer.release();
      return;
    }
    throw new IllegalStateException("releaseFlutterSurfaceTexture() cannot be called if the flutterSurfaceProducer for the camera preview has not yet been initialized.");
  }

  @Override
  public boolean surfaceProducerHandlesCropAndRotation(@NonNull Preview pigeon_instance) {
    final TextureRegistry.SurfaceProducer surfaceProducer =
            surfaceProducers.remove(pigeon_instance);
    if (surfaceProducer != null) {
      return surfaceProducer.handlesCropAndRotation();
    }
    throw new IllegalStateException(
            "surfaceProducerHandlesCropAndRotation() cannot be called if the flutterSurfaceProducer for the camera preview has not yet been initialized.");
  }
  @Nullable
  @Override
  public androidx.camera.core.ResolutionInfo getResolutionInfo(Preview pigeon_instance) {
    return pigeon_instance.getResolutionInfo();
  }

  @Override
  public void setTargetRotation(Preview pigeon_instance, long rotation) {
    pigeon_instance.setTargetRotation((int) rotation);
  }

  @NonNull
  Preview.SurfaceProvider createSurfaceProvider(
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull SystemServicesManager systemServicesManager) {
    return request -> {
      // Set callback for surfaceProducer to invalidate Surfaces that it produces when they
      // get destroyed.
      surfaceProducer.setCallback(
          new TextureRegistry.SurfaceProducer.Callback() {
            public void onSurfaceAvailable() {
              // Do nothing. The Preview.SurfaceProvider will handle this whenever a new
              // Surface is needed.
            }

            @Override
            // TODO(bparrishMines): Replace with onSurfaceCleanup once available on stable. See
            // https://github.com/flutter/flutter/issues/161256.
            @SuppressWarnings({"deprecation", "removal"})
            public void onSurfaceDestroyed() {
              // Invalidate the SurfaceRequest so that CameraX knows to to make a new request
              // for a surface.
              request.invalidate();
            }
          });

      // Provide surface.
      surfaceProducer.setSize(
          request.getResolution().getWidth(), request.getResolution().getHeight());
      Surface flutterSurface = surfaceProducer.getSurface();
      request.provideSurface(
          flutterSurface,
          Executors.newSingleThreadExecutor(),
          (result) -> {
            // See
            // https://developer.android.com/reference/androidx/camera/core/SurfaceRequest.Result
            // for documentation.
            // Always attempt a release.
            flutterSurface.release();
            int resultCode = result.getResultCode();
            switch (resultCode) {
              case SurfaceRequest.Result.RESULT_REQUEST_CANCELLED:
              case SurfaceRequest.Result.RESULT_WILL_NOT_PROVIDE_SURFACE:
              case SurfaceRequest.Result.RESULT_SURFACE_ALREADY_PROVIDED:
              case SurfaceRequest.Result.RESULT_SURFACE_USED_SUCCESSFULLY:
                // Only need to release, do nothing.
                break;
              case SurfaceRequest.Result.RESULT_INVALID_SURFACE: // Intentional fall through.
              default:
                systemServicesManager.onCameraError(getProvideSurfaceErrorDescription(resultCode));
            }
          });
    };
  }

  /**
   * Returns an error description for each {@link SurfaceRequest.Result} that represents an error
   * with providing a surface.
   */
  String getProvideSurfaceErrorDescription(int resultCode) {
    if (resultCode == SurfaceRequest.Result.RESULT_INVALID_SURFACE) {
      return resultCode + ": Provided surface could not be used by the camera.";
    }
    return resultCode + ": Attempt to provide a surface resulted with unrecognizable code.";
  }

  @Nullable
  @Override
  public ResolutionSelector resolutionSelector(@NonNull Preview pigeon_instance) {
    return pigeon_instance.getResolutionSelector();
  }
}
