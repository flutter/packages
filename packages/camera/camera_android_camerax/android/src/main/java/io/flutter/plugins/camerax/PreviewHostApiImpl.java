// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.util.Size;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import androidx.camera.core.resolutionselector.ResolutionSelector;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.PreviewHostApi;
import io.flutter.view.TextureRegistry;
import java.util.Objects;
import java.util.concurrent.Executors;

public class PreviewHostApiImpl implements PreviewHostApi {
  final BinaryMessenger binaryMessenger;
  private final InstanceManager instanceManager;
  private final TextureRegistry textureRegistry;

  @VisibleForTesting public @NonNull CameraXProxy cameraXProxy = new CameraXProxy();
  @VisibleForTesting public @Nullable TextureRegistry.SurfaceProducer flutterSurfaceProducer;

  public PreviewHostApiImpl(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull InstanceManager instanceManager,
      @NonNull TextureRegistry textureRegistry) {
    this.binaryMessenger = binaryMessenger;
    this.instanceManager = instanceManager;
    this.textureRegistry = textureRegistry;
  }

  /** Creates a {@link Preview} with the target rotation and resolution if specified. */
  @Override
  public void create(
      @NonNull Long identifier, @Nullable Long rotation, @Nullable Long resolutionSelectorId) {
    Preview.Builder previewBuilder = cameraXProxy.createPreviewBuilder();

    if (rotation != null) {
      previewBuilder.setTargetRotation(rotation.intValue());
    }
    if (resolutionSelectorId != null) {
      ResolutionSelector resolutionSelector =
          Objects.requireNonNull(instanceManager.getInstance(resolutionSelectorId));
      previewBuilder.setResolutionSelector(resolutionSelector);
    }

    Preview preview = previewBuilder.build();
    instanceManager.addDartCreatedInstance(preview, identifier);
  }

  /**
   * Sets the {@link Preview.SurfaceProvider} that will be used to provide a {@code Surface} backed
   * by a Flutter {@link TextureRegistry.SurfaceTextureEntry} used to build the {@link Preview}.
   */
  @Override
  public @NonNull Long setSurfaceProvider(@NonNull Long identifier) {
    Preview preview = getPreviewInstance(identifier);
    flutterSurfaceProducer = textureRegistry.createSurfaceProducer();
    Preview.SurfaceProvider surfaceProvider = createSurfaceProvider(flutterSurfaceProducer);
    preview.setSurfaceProvider(surfaceProvider);

    return flutterSurfaceProducer.id();
  }

  /**
   * Creates a {@link Preview.SurfaceProvider} that specifies how to provide a {@link Surface} to a
   * {@code Preview} that is backed by a Flutter {@link TextureRegistry.SurfaceTextureEntry}.
   */
  @VisibleForTesting
  public @NonNull Preview.SurfaceProvider createSurfaceProvider(
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer) {
    return new Preview.SurfaceProvider() {
      @Override
      public void onSurfaceRequested(@NonNull SurfaceRequest request) {
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
                  // Release and send error.
                  SystemServicesFlutterApiImpl systemServicesFlutterApi =
                      cameraXProxy.createSystemServicesFlutterApiImpl(binaryMessenger);
                  systemServicesFlutterApi.sendCameraError(
                      getProvideSurfaceErrorDescription(resultCode), reply -> {});
                  break;
              }
            });
      }
    };
  }

  /**
   * Returns an error description for each {@link SurfaceRequest.Result} that represents an error
   * with providing a surface.
   */
  String getProvideSurfaceErrorDescription(int resultCode) {
    switch (resultCode) {
      case SurfaceRequest.Result.RESULT_INVALID_SURFACE:
        return resultCode + ": Provided surface could not be used by the camera.";
      default:
        return resultCode + ": Attempt to provide a surface resulted with unrecognizable code.";
    }
  }

  /**
   * Releases the Flutter {@link TextureRegistry.SurfaceTextureEntry} if used to provide a surface
   * for a {@link Preview}.
   */
  @Override
  public void releaseFlutterSurfaceTexture() {
    if (flutterSurfaceProducer != null) {
      flutterSurfaceProducer.release();
    }
  }

  /** Returns the resolution information for the specified {@link Preview}. */
  @Override
  public @NonNull GeneratedCameraXLibrary.ResolutionInfo getResolutionInfo(
      @NonNull Long identifier) {
    Preview preview = getPreviewInstance(identifier);
    Size resolution = preview.getResolutionInfo().getResolution();

    GeneratedCameraXLibrary.ResolutionInfo.Builder resolutionInfo =
        new GeneratedCameraXLibrary.ResolutionInfo.Builder()
            .setWidth(Long.valueOf(resolution.getWidth()))
            .setHeight(Long.valueOf(resolution.getHeight()));
    return resolutionInfo.build();
  }

  /** Dynamically sets the target rotation of the {@link Preview}. */
  @Override
  public void setTargetRotation(@NonNull Long identifier, @NonNull Long rotation) {
    Preview preview = getPreviewInstance(identifier);
    preview.setTargetRotation(rotation.intValue());
  }

  /** Retrieves the {@link Preview} instance associated with the specified {@code identifier}. */
  private Preview getPreviewInstance(@NonNull Long identifier) {
    return Objects.requireNonNull(instanceManager.getInstance(identifier));
  }
}
