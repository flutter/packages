// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;

/** Platform implementation of the camera_plugin implemented with the CameraX library. */
public final class CameraAndroidCameraxPlugin implements FlutterPlugin, ActivityAware {
  private InstanceManager instanceManager;
  private FlutterPluginBinding pluginBinding;
  @VisibleForTesting @Nullable public PendingRecordingHostApiImpl pendingRecordingHostApiImpl;
  @VisibleForTesting @Nullable public RecorderHostApiImpl recorderHostApiImpl;
  @VisibleForTesting @Nullable public VideoCaptureHostApiImpl videoCaptureHostApiImpl;
  @VisibleForTesting @Nullable public ImageAnalysisHostApiImpl imageAnalysisHostApiImpl;
  @VisibleForTesting @Nullable public ImageCaptureHostApiImpl imageCaptureHostApiImpl;
  @VisibleForTesting @Nullable public CameraControlHostApiImpl cameraControlHostApiImpl;
  @VisibleForTesting @Nullable public SystemServicesHostApiImpl systemServicesHostApiImpl;
  @VisibleForTesting @Nullable public MeteringPointHostApiImpl meteringPointHostApiImpl;

  @VisibleForTesting @Nullable
  public Camera2CameraControlHostApiImpl camera2CameraControlHostApiImpl;

  @VisibleForTesting
  public @Nullable DeviceOrientationManagerHostApiImpl deviceOrientationManagerHostApiImpl;

  @VisibleForTesting
  public @Nullable ProcessCameraProviderHostApiImpl processCameraProviderHostApiImpl;

  @VisibleForTesting public @Nullable LiveDataHostApiImpl liveDataHostApiImpl;

  /**
   * Initialize this within the {@code #configureFlutterEngine} of a Flutter activity or fragment.
   *
   * <p>See {@code io.flutter.plugins.camera.MainActivity} for an example.
   */
  public CameraAndroidCameraxPlugin() {}

  @VisibleForTesting
  public void setUp(
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull Context context,
      @NonNull TextureRegistry textureRegistry) {
    // Set up instance manager.
    instanceManager =
        InstanceManager.create(
            identifier -> {
              new GeneratedCameraXLibrary.JavaObjectFlutterApi(binaryMessenger)
                  .dispose(identifier, reply -> {});
            });

    // Set up Host APIs.
    GeneratedCameraXLibrary.InstanceManagerHostApi.setup(
        binaryMessenger, () -> instanceManager.clear());
    GeneratedCameraXLibrary.CameraHostApi.setup(
        binaryMessenger, new CameraHostApiImpl(binaryMessenger, instanceManager));
    GeneratedCameraXLibrary.CameraInfoHostApi.setup(
        binaryMessenger, new CameraInfoHostApiImpl(binaryMessenger, instanceManager));
    GeneratedCameraXLibrary.CameraSelectorHostApi.setup(
        binaryMessenger, new CameraSelectorHostApiImpl(binaryMessenger, instanceManager));
    GeneratedCameraXLibrary.JavaObjectHostApi.setup(
        binaryMessenger, new JavaObjectHostApiImpl(instanceManager));
    processCameraProviderHostApiImpl =
        new ProcessCameraProviderHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.ProcessCameraProviderHostApi.setup(
        binaryMessenger, processCameraProviderHostApiImpl);
    systemServicesHostApiImpl =
        new SystemServicesHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.SystemServicesHostApi.setup(binaryMessenger, systemServicesHostApiImpl);
    deviceOrientationManagerHostApiImpl =
        new DeviceOrientationManagerHostApiImpl(binaryMessenger, instanceManager);
    GeneratedCameraXLibrary.DeviceOrientationManagerHostApi.setup(
        binaryMessenger, deviceOrientationManagerHostApiImpl);
    GeneratedCameraXLibrary.PreviewHostApi.setup(
        binaryMessenger, new PreviewHostApiImpl(binaryMessenger, instanceManager, textureRegistry));
    imageCaptureHostApiImpl =
        new ImageCaptureHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.ImageCaptureHostApi.setup(binaryMessenger, imageCaptureHostApiImpl);
    GeneratedCameraXLibrary.CameraHostApi.setup(
        binaryMessenger, new CameraHostApiImpl(binaryMessenger, instanceManager));
    liveDataHostApiImpl = new LiveDataHostApiImpl(binaryMessenger, instanceManager);
    GeneratedCameraXLibrary.LiveDataHostApi.setup(binaryMessenger, liveDataHostApiImpl);
    GeneratedCameraXLibrary.ObserverHostApi.setup(
        binaryMessenger, new ObserverHostApiImpl(binaryMessenger, instanceManager));
    imageAnalysisHostApiImpl =
        new ImageAnalysisHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.ImageAnalysisHostApi.setup(binaryMessenger, imageAnalysisHostApiImpl);
    GeneratedCameraXLibrary.AnalyzerHostApi.setup(
        binaryMessenger, new AnalyzerHostApiImpl(binaryMessenger, instanceManager));
    GeneratedCameraXLibrary.ImageProxyHostApi.setup(
        binaryMessenger, new ImageProxyHostApiImpl(binaryMessenger, instanceManager));
    GeneratedCameraXLibrary.RecordingHostApi.setup(
        binaryMessenger, new RecordingHostApiImpl(binaryMessenger, instanceManager));
    recorderHostApiImpl = new RecorderHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.RecorderHostApi.setup(binaryMessenger, recorderHostApiImpl);
    pendingRecordingHostApiImpl =
        new PendingRecordingHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.PendingRecordingHostApi.setup(
        binaryMessenger, pendingRecordingHostApiImpl);
    videoCaptureHostApiImpl = new VideoCaptureHostApiImpl(binaryMessenger, instanceManager);
    GeneratedCameraXLibrary.VideoCaptureHostApi.setup(binaryMessenger, videoCaptureHostApiImpl);
    GeneratedCameraXLibrary.ResolutionSelectorHostApi.setup(
        binaryMessenger, new ResolutionSelectorHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.ResolutionStrategyHostApi.setup(
        binaryMessenger, new ResolutionStrategyHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.AspectRatioStrategyHostApi.setup(
        binaryMessenger, new AspectRatioStrategyHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.FallbackStrategyHostApi.setup(
        binaryMessenger, new FallbackStrategyHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.QualitySelectorHostApi.setup(
        binaryMessenger, new QualitySelectorHostApiImpl(instanceManager));
    cameraControlHostApiImpl =
        new CameraControlHostApiImpl(binaryMessenger, instanceManager, context);
    GeneratedCameraXLibrary.CameraControlHostApi.setup(binaryMessenger, cameraControlHostApiImpl);
    camera2CameraControlHostApiImpl = new Camera2CameraControlHostApiImpl(instanceManager, context);
    GeneratedCameraXLibrary.Camera2CameraControlHostApi.setup(
        binaryMessenger, camera2CameraControlHostApiImpl);
    GeneratedCameraXLibrary.CaptureRequestOptionsHostApi.setup(
        binaryMessenger, new CaptureRequestOptionsHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.FocusMeteringActionHostApi.setup(
        binaryMessenger, new FocusMeteringActionHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.FocusMeteringResultHostApi.setup(
        binaryMessenger, new FocusMeteringResultHostApiImpl(instanceManager));
    meteringPointHostApiImpl = new MeteringPointHostApiImpl(instanceManager);
    GeneratedCameraXLibrary.MeteringPointHostApi.setup(binaryMessenger, meteringPointHostApiImpl);
    GeneratedCameraXLibrary.ResolutionFilterHostApi.setup(
        binaryMessenger, new ResolutionFilterHostApiImpl(instanceManager));
    GeneratedCameraXLibrary.Camera2CameraInfoHostApi.setup(
        binaryMessenger, new Camera2CameraInfoHostApiImpl(binaryMessenger, instanceManager));
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    pluginBinding = flutterPluginBinding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (instanceManager != null) {
      instanceManager.stopFinalizationListener();
    }
  }

  // Activity Lifecycle methods:

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    Activity activity = activityPluginBinding.getActivity();

    // Set up Host API implementations based on the context that `activity` provides.
    setUp(pluginBinding.getBinaryMessenger(), activity, pluginBinding.getTextureRegistry());

    // Set any needed references to `activity` itself.
    updateLifecycleOwner(activity);
    updateActivity(activity);

    // Set permissions registry reference.
    systemServicesHostApiImpl.setPermissionsRegistry(
        activityPluginBinding::addRequestPermissionsResultListener);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    // Clear any references to previously attached `ActivityPluginBinding`/`Activity`.
    updateContext(pluginBinding.getApplicationContext());
    updateLifecycleOwner(null);
    updateActivity(null);
    systemServicesHostApiImpl.setPermissionsRegistry(null);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {
    Activity activity = activityPluginBinding.getActivity();

    // Set any needed references to `activity` itself or its context.
    updateContext(activity);
    updateLifecycleOwner(activity);
    updateActivity(activity);

    // Set permissions registry reference.
    systemServicesHostApiImpl.setPermissionsRegistry(
        activityPluginBinding::addRequestPermissionsResultListener);
  }

  @Override
  public void onDetachedFromActivity() {
    // Clear any references to previously attached `ActivityPluginBinding`/`Activity`.
    updateContext(pluginBinding.getApplicationContext());
    updateLifecycleOwner(null);
    updateActivity(null);
    systemServicesHostApiImpl.setPermissionsRegistry(null);
  }

  /**
   * Updates context that is used to fetch the corresponding instance of a {@code
   * ProcessCameraProvider} to each of the relevant camera controls.
   */
  public void updateContext(@NonNull Context context) {
    if (processCameraProviderHostApiImpl != null) {
      processCameraProviderHostApiImpl.setContext(context);
    }
    if (recorderHostApiImpl != null) {
      recorderHostApiImpl.setContext(context);
    }
    if (pendingRecordingHostApiImpl != null) {
      pendingRecordingHostApiImpl.setContext(context);
    }
    if (systemServicesHostApiImpl != null) {
      systemServicesHostApiImpl.setContext(context);
    }
    if (imageCaptureHostApiImpl != null) {
      imageCaptureHostApiImpl.setContext(context);
    }
    if (imageAnalysisHostApiImpl != null) {
      imageAnalysisHostApiImpl.setContext(context);
    }
    if (cameraControlHostApiImpl != null) {
      cameraControlHostApiImpl.setContext(context);
    }
    if (camera2CameraControlHostApiImpl != null) {
      camera2CameraControlHostApiImpl.setContext(context);
    }
  }

  /** Sets {@code LifecycleOwner} that is used to control the lifecycle of the camera by CameraX. */
  public void updateLifecycleOwner(@Nullable Activity activity) {
    if (activity == null) {
      processCameraProviderHostApiImpl.setLifecycleOwner(null);
      liveDataHostApiImpl.setLifecycleOwner(null);
    } else if (activity instanceof LifecycleOwner) {
      processCameraProviderHostApiImpl.setLifecycleOwner((LifecycleOwner) activity);
      liveDataHostApiImpl.setLifecycleOwner((LifecycleOwner) activity);
    } else {
      ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
      processCameraProviderHostApiImpl.setLifecycleOwner(proxyLifecycleProvider);
      liveDataHostApiImpl.setLifecycleOwner(proxyLifecycleProvider);
    }
  }

  /**
   * Updates {@code Activity} that is used for requesting camera permissions and tracking the
   * orientation of the device.
   */
  public void updateActivity(@Nullable Activity activity) {
    if (systemServicesHostApiImpl != null) {
      systemServicesHostApiImpl.setActivity(activity);
    }
    if (deviceOrientationManagerHostApiImpl != null) {
      deviceOrientationManagerHostApiImpl.setActivity(activity);
    }
    if (meteringPointHostApiImpl != null) {
      meteringPointHostApiImpl.setActivity(activity);
    }
  }
}
