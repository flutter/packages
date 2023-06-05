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
  private PendingRecordingHostApiImpl pendingRecordingHostApiImpl;
  private RecorderHostApiImpl recorderHostApiImpl;
  private VideoCaptureHostApiImpl videoCaptureHostApiImpl;
  private ImageAnalysisHostApiImpl imageAnalysisHostApiImpl;
  private ImageCaptureHostApiImpl imageCaptureHostApiImpl;
  public @Nullable SystemServicesHostApiImpl systemServicesHostApiImpl;

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
    imageAnalysisHostApiImpl = new ImageAnalysisHostApiImpl(binaryMessenger, instanceManager);
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

    setUp(pluginBinding.getBinaryMessenger(), activity, pluginBinding.getTextureRegistry());
    updateContext(activity);

    if (activity instanceof LifecycleOwner) {
      processCameraProviderHostApiImpl.setLifecycleOwner((LifecycleOwner) activity);
      liveDataHostApiImpl.setLifecycleOwner((LifecycleOwner) activity);
    } else {
      ProxyLifecycleProvider proxyLifecycleProvider = new ProxyLifecycleProvider(activity);
      processCameraProviderHostApiImpl.setLifecycleOwner(proxyLifecycleProvider);
      liveDataHostApiImpl.setLifecycleOwner(proxyLifecycleProvider);
    }

    systemServicesHostApiImpl.setActivity(activity);
    systemServicesHostApiImpl.setPermissionsRegistry(
        activityPluginBinding::addRequestPermissionsResultListener);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    updateContext(pluginBinding.getApplicationContext());
  }

  @Override
  public void onReattachedToActivityForConfigChanges(
      @NonNull ActivityPluginBinding activityPluginBinding) {
    updateContext(activityPluginBinding.getActivity());
  }

  @Override
  public void onDetachedFromActivity() {
    updateContext(pluginBinding.getApplicationContext());
  }

  /**
   * Updates context that is used to fetch the corresponding instance of a {@code
   * ProcessCameraProvider}.
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
  }
}
