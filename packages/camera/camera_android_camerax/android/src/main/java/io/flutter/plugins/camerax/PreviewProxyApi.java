// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.view.Surface;

import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import androidx.camera.core.ResolutionInfo;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.Executors;

import io.flutter.view.TextureRegistry;

/**
 * ProxyApi implementation for {@link Preview}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
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
  public Preview pigeon_defaultConstructor(@Nullable Long targetRotation, @Nullable ResolutionSelector resolutionSelector) {
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
  public long setSurfaceProvider(@NonNull Preview pigeon_instance, @NonNull SystemServicesManager systemServicesManager) {
    final TextureRegistry.SurfaceProducer surfaceProducer = getPigeonRegistrar().getTextureRegistry().createSurfaceProducer();
    final Preview.SurfaceProvider surfaceProvider = createSurfaceProvider(surfaceProducer, systemServicesManager);

    pigeon_instance.setSurfaceProvider(surfaceProvider);
    surfaceProducers.put(pigeon_instance, surfaceProducer);

    return surfaceProducer.id();
  }

  @Override
  public void releaseSurfaceProvider(@NonNull Preview pigeon_instance) {
    final TextureRegistry.SurfaceProducer surfaceProducer = surfaceProducers.remove(pigeon_instance);
    if (surfaceProducer != null) {
      surfaceProducer.release();
    }
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

  @NonNull Preview.SurfaceProvider createSurfaceProvider(
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer, @NonNull SystemServicesManager systemServicesManager) {
    return request -> {
      // Set callback for surfaceProducer to invalidate Surfaces that it produces when they
      // get destroyed.
      surfaceProducer.setCallback(
          new TextureRegistry.SurfaceProducer.Callback() {
            @Override
            // TODO(matanlurey): Replace with onSurfaceAvailable once available on stable;
            // https://github.com/flutter/flutter/issues/155131.
            @SuppressWarnings({"deprecation", "removal"})
            public void onSurfaceCreated() {
              // Do nothing. The Preview.SurfaceProvider will handle this whenever a new
              // Surface is needed.
            }

            @Override
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
}
