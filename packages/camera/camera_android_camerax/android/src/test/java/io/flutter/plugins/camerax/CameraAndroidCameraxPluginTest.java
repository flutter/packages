// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.withSettings;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugins.camerax.CameraPermissionsManager.PermissionsRegistry;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraAndroidCameraxPluginTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock ActivityPluginBinding activityPluginBinding;
  @Mock FlutterPluginBinding flutterPluginBinding;

  @Test
  public void onAttachedToActivity_setsLifecycleOwnerAsActivityIfLifecycleOwnerAsNeeded() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);

    doNothing().when(plugin).setUp(any(), any(), any());
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.liveDataHostApiImpl = mockLiveDataHostApiImpl;
    plugin.systemServicesHostApiImpl = mock(SystemServicesHostApiImpl.class);
    plugin.deviceOrientationManagerHostApiImpl = mock(DeviceOrientationManagerHostApiImpl.class);

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    verify(mockProcessCameraProviderHostApiImpl).setLifecycleOwner(any(LifecycleOwner.class));
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(any(LifecycleOwner.class));
  }

  @Test
  public void
      onAttachedToActivity_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwnerAsNeeded() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Activity mockActivity = mock(Activity.class);
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);

    doNothing().when(plugin).setUp(any(), any(), any());
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.liveDataHostApiImpl = mockLiveDataHostApiImpl;
    plugin.systemServicesHostApiImpl = mock(SystemServicesHostApiImpl.class);
    plugin.deviceOrientationManagerHostApiImpl = mock(DeviceOrientationManagerHostApiImpl.class);

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    verify(mockProcessCameraProviderHostApiImpl)
        .setLifecycleOwner(any(ProxyLifecycleProvider.class));
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(any(ProxyLifecycleProvider.class));
  }

  @Test
  public void onAttachedToActivity_setsActivityAsNeededAndPermissionsRegistry() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Activity mockActivity = mock(Activity.class);
    final SystemServicesHostApiImpl mockSystemServicesHostApiImpl =
        mock(SystemServicesHostApiImpl.class);
    final DeviceOrientationManagerHostApiImpl mockDeviceOrientationManagerHostApiImpl =
        mock(DeviceOrientationManagerHostApiImpl.class);
    final MeteringPointHostApiImpl mockMeteringPointHostApiImpl =
        mock(MeteringPointHostApiImpl.class);
    final ArgumentCaptor<PermissionsRegistry> permissionsRegistryCaptor =
        ArgumentCaptor.forClass(PermissionsRegistry.class);

    doNothing().when(plugin).setUp(any(), any(), any());
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    plugin.processCameraProviderHostApiImpl = mock(ProcessCameraProviderHostApiImpl.class);
    plugin.liveDataHostApiImpl = mock(LiveDataHostApiImpl.class);
    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.deviceOrientationManagerHostApiImpl = mockDeviceOrientationManagerHostApiImpl;
    plugin.meteringPointHostApiImpl = mockMeteringPointHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    // Check Activity references are set.
    verify(mockSystemServicesHostApiImpl).setActivity(mockActivity);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(mockActivity);
    verify(mockMeteringPointHostApiImpl).setActivity(mockActivity);

    // Check permissions registry reference is set.
    verify(mockSystemServicesHostApiImpl)
        .setPermissionsRegistry(permissionsRegistryCaptor.capture());
    assertNotNull(permissionsRegistryCaptor.getValue());
    assertTrue(permissionsRegistryCaptor.getValue() instanceof PermissionsRegistry);
  }

  @Test
  public void
      onDetachedFromActivityForConfigChanges_removesReferencesToActivityPluginBindingAndActivity() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);
    final SystemServicesHostApiImpl mockSystemServicesHostApiImpl =
        mock(SystemServicesHostApiImpl.class);
    final DeviceOrientationManagerHostApiImpl mockDeviceOrientationManagerHostApiImpl =
        mock(DeviceOrientationManagerHostApiImpl.class);
    final MeteringPointHostApiImpl mockMeteringPointHostApiImpl =
        mock(MeteringPointHostApiImpl.class);

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.liveDataHostApiImpl = mockLiveDataHostApiImpl;
    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.deviceOrientationManagerHostApiImpl = mockDeviceOrientationManagerHostApiImpl;
    plugin.meteringPointHostApiImpl = mockMeteringPointHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onDetachedFromActivityForConfigChanges();

    verify(mockProcessCameraProviderHostApiImpl).setLifecycleOwner(null);
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(null);
    verify(mockSystemServicesHostApiImpl).setActivity(null);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(null);
    verify(mockMeteringPointHostApiImpl).setActivity(null);
  }

  @Test
  public void
      onDetachedFromActivityForConfigChanges_setsContextReferencesBasedOnFlutterPluginBinding() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Context mockContext = mock(Context.class);
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final RecorderHostApiImpl mockRecorderHostApiImpl = mock(RecorderHostApiImpl.class);
    final PendingRecordingHostApiImpl mockPendingRecordingHostApiImpl =
        mock(PendingRecordingHostApiImpl.class);
    final SystemServicesHostApiImpl mockSystemServicesHostApiImpl =
        mock(SystemServicesHostApiImpl.class);
    final ImageCaptureHostApiImpl mockImageCaptureHostApiImpl = mock(ImageCaptureHostApiImpl.class);
    final ImageAnalysisHostApiImpl mockImageAnalysisHostApiImpl =
        mock(ImageAnalysisHostApiImpl.class);
    final CameraControlHostApiImpl mockCameraControlHostApiImpl =
        mock(CameraControlHostApiImpl.class);
    final Camera2CameraControlHostApiImpl mockCamera2CameraControlHostApiImpl =
        mock(Camera2CameraControlHostApiImpl.class);

    when(flutterPluginBinding.getApplicationContext()).thenReturn(mockContext);

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.recorderHostApiImpl = mockRecorderHostApiImpl;
    plugin.pendingRecordingHostApiImpl = mockPendingRecordingHostApiImpl;
    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.imageCaptureHostApiImpl = mockImageCaptureHostApiImpl;
    plugin.imageAnalysisHostApiImpl = mockImageAnalysisHostApiImpl;
    plugin.cameraControlHostApiImpl = mockCameraControlHostApiImpl;
    plugin.liveDataHostApiImpl = mock(LiveDataHostApiImpl.class);
    plugin.camera2CameraControlHostApiImpl = mockCamera2CameraControlHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onDetachedFromActivityForConfigChanges();

    verify(mockProcessCameraProviderHostApiImpl).setContext(mockContext);
    verify(mockRecorderHostApiImpl).setContext(mockContext);
    verify(mockPendingRecordingHostApiImpl).setContext(mockContext);
    verify(mockSystemServicesHostApiImpl).setContext(mockContext);
    verify(mockImageCaptureHostApiImpl).setContext(mockContext);
    verify(mockImageAnalysisHostApiImpl).setContext(mockContext);
    verify(mockCameraControlHostApiImpl).setContext(mockContext);
    verify(mockCamera2CameraControlHostApiImpl).setContext(mockContext);
  }

  @Test
  public void
      onReattachedToActivityForConfigChanges_setsLifecycleOwnerAsActivityIfLifecycleOwnerAsNeeded() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);

    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.liveDataHostApiImpl = mockLiveDataHostApiImpl;
    plugin.systemServicesHostApiImpl = mock(SystemServicesHostApiImpl.class);
    plugin.deviceOrientationManagerHostApiImpl = mock(DeviceOrientationManagerHostApiImpl.class);

    plugin.onReattachedToActivityForConfigChanges(activityPluginBinding);

    verify(mockProcessCameraProviderHostApiImpl).setLifecycleOwner(any(LifecycleOwner.class));
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(any(LifecycleOwner.class));
  }

  @Test
  public void
      onReattachedToActivityForConfigChanges_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwnerAsNeeded() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Activity mockActivity = mock(Activity.class);
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);

    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.liveDataHostApiImpl = mockLiveDataHostApiImpl;
    plugin.systemServicesHostApiImpl = mock(SystemServicesHostApiImpl.class);
    plugin.deviceOrientationManagerHostApiImpl = mock(DeviceOrientationManagerHostApiImpl.class);

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onReattachedToActivityForConfigChanges(activityPluginBinding);

    verify(mockProcessCameraProviderHostApiImpl)
        .setLifecycleOwner(any(ProxyLifecycleProvider.class));
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(any(ProxyLifecycleProvider.class));
  }

  @Test
  public void onReattachedToActivityForConfigChanges_setsActivityAndPermissionsRegistryAsNeeded() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Activity mockActivity = mock(Activity.class);
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final RecorderHostApiImpl mockRecorderHostApiImpl = mock(RecorderHostApiImpl.class);
    final PendingRecordingHostApiImpl mockPendingRecordingHostApiImpl =
        mock(PendingRecordingHostApiImpl.class);
    final SystemServicesHostApiImpl mockSystemServicesHostApiImpl =
        mock(SystemServicesHostApiImpl.class);
    final ImageAnalysisHostApiImpl mockImageAnalysisHostApiImpl =
        mock(ImageAnalysisHostApiImpl.class);
    final ImageCaptureHostApiImpl mockImageCaptureHostApiImpl = mock(ImageCaptureHostApiImpl.class);
    final CameraControlHostApiImpl mockCameraControlHostApiImpl =
        mock(CameraControlHostApiImpl.class);
    final DeviceOrientationManagerHostApiImpl mockDeviceOrientationManagerHostApiImpl =
        mock(DeviceOrientationManagerHostApiImpl.class);
    final Camera2CameraControlHostApiImpl mockCamera2CameraControlHostApiImpl =
        mock(Camera2CameraControlHostApiImpl.class);
    final MeteringPointHostApiImpl mockMeteringPointHostApiImpl =
        mock(MeteringPointHostApiImpl.class);
    final ArgumentCaptor<PermissionsRegistry> permissionsRegistryCaptor =
        ArgumentCaptor.forClass(PermissionsRegistry.class);

    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.recorderHostApiImpl = mockRecorderHostApiImpl;
    plugin.pendingRecordingHostApiImpl = mockPendingRecordingHostApiImpl;
    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.imageCaptureHostApiImpl = mockImageCaptureHostApiImpl;
    plugin.imageAnalysisHostApiImpl = mockImageAnalysisHostApiImpl;
    plugin.cameraControlHostApiImpl = mockCameraControlHostApiImpl;
    plugin.deviceOrientationManagerHostApiImpl = mockDeviceOrientationManagerHostApiImpl;
    plugin.meteringPointHostApiImpl = mockMeteringPointHostApiImpl;
    plugin.liveDataHostApiImpl = mock(LiveDataHostApiImpl.class);
    plugin.camera2CameraControlHostApiImpl = mockCamera2CameraControlHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onReattachedToActivityForConfigChanges(activityPluginBinding);

    // Check Activity references are set.
    verify(mockSystemServicesHostApiImpl).setActivity(mockActivity);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(mockActivity);
    verify(mockMeteringPointHostApiImpl).setActivity(mockActivity);

    // Check Activity as Context references are set.
    verify(mockProcessCameraProviderHostApiImpl).setContext(mockActivity);
    verify(mockRecorderHostApiImpl).setContext(mockActivity);
    verify(mockPendingRecordingHostApiImpl).setContext(mockActivity);
    verify(mockSystemServicesHostApiImpl).setContext(mockActivity);
    verify(mockImageCaptureHostApiImpl).setContext(mockActivity);
    verify(mockImageAnalysisHostApiImpl).setContext(mockActivity);
    verify(mockCameraControlHostApiImpl).setContext(mockActivity);
    verify(mockCamera2CameraControlHostApiImpl).setContext(mockActivity);

    // Check permissions registry reference is set.
    verify(mockSystemServicesHostApiImpl)
        .setPermissionsRegistry(permissionsRegistryCaptor.capture());
    assertNotNull(permissionsRegistryCaptor.getValue());
    assertTrue(permissionsRegistryCaptor.getValue() instanceof PermissionsRegistry);
  }

  @Test
  public void onDetachedFromActivity_removesReferencesToActivityPluginBindingAndActivity() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final SystemServicesHostApiImpl mockSystemServicesHostApiImpl =
        mock(SystemServicesHostApiImpl.class);
    final LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);
    final DeviceOrientationManagerHostApiImpl mockDeviceOrientationManagerHostApiImpl =
        mock(DeviceOrientationManagerHostApiImpl.class);
    final MeteringPointHostApiImpl mockMeteringPointHostApiImpl =
        mock(MeteringPointHostApiImpl.class);

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.liveDataHostApiImpl = mockLiveDataHostApiImpl;
    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.deviceOrientationManagerHostApiImpl = mockDeviceOrientationManagerHostApiImpl;
    plugin.meteringPointHostApiImpl = mockMeteringPointHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onDetachedFromActivityForConfigChanges();

    verify(mockProcessCameraProviderHostApiImpl).setLifecycleOwner(null);
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(null);
    verify(mockSystemServicesHostApiImpl).setActivity(null);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(null);
    verify(mockMeteringPointHostApiImpl).setActivity(null);
  }

  @Test
  public void onDetachedFromActivity_setsContextReferencesBasedOnFlutterPluginBinding() {
    final CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    final Context mockContext = mock(Context.class);
    final ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    final RecorderHostApiImpl mockRecorderHostApiImpl = mock(RecorderHostApiImpl.class);
    final PendingRecordingHostApiImpl mockPendingRecordingHostApiImpl =
        mock(PendingRecordingHostApiImpl.class);
    final SystemServicesHostApiImpl mockSystemServicesHostApiImpl =
        mock(SystemServicesHostApiImpl.class);
    final ImageAnalysisHostApiImpl mockImageAnalysisHostApiImpl =
        mock(ImageAnalysisHostApiImpl.class);
    final ImageCaptureHostApiImpl mockImageCaptureHostApiImpl = mock(ImageCaptureHostApiImpl.class);
    final CameraControlHostApiImpl mockCameraControlHostApiImpl =
        mock(CameraControlHostApiImpl.class);
    final Camera2CameraControlHostApiImpl mockCamera2CameraControlHostApiImpl =
        mock(Camera2CameraControlHostApiImpl.class);
    final ArgumentCaptor<PermissionsRegistry> permissionsRegistryCaptor =
        ArgumentCaptor.forClass(PermissionsRegistry.class);

    when(flutterPluginBinding.getApplicationContext()).thenReturn(mockContext);

    plugin.processCameraProviderHostApiImpl = mockProcessCameraProviderHostApiImpl;
    plugin.recorderHostApiImpl = mockRecorderHostApiImpl;
    plugin.pendingRecordingHostApiImpl = mockPendingRecordingHostApiImpl;
    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.imageCaptureHostApiImpl = mockImageCaptureHostApiImpl;
    plugin.imageAnalysisHostApiImpl = mockImageAnalysisHostApiImpl;
    plugin.cameraControlHostApiImpl = mockCameraControlHostApiImpl;
    plugin.liveDataHostApiImpl = mock(LiveDataHostApiImpl.class);
    plugin.camera2CameraControlHostApiImpl = mockCamera2CameraControlHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onDetachedFromActivity();

    verify(mockProcessCameraProviderHostApiImpl).setContext(mockContext);
    verify(mockRecorderHostApiImpl).setContext(mockContext);
    verify(mockPendingRecordingHostApiImpl).setContext(mockContext);
    verify(mockSystemServicesHostApiImpl).setContext(mockContext);
    verify(mockImageCaptureHostApiImpl).setContext(mockContext);
    verify(mockImageAnalysisHostApiImpl).setContext(mockContext);
    verify(mockCameraControlHostApiImpl).setContext(mockContext);
    verify(mockCamera2CameraControlHostApiImpl).setContext(mockContext);
  }
}
