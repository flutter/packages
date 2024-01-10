// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.withSettings;

import android.app.Activity;
import android.app.Application;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraAndroidCameraxPluginTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock ActivityPluginBinding activityPluginBinding;
  @Mock FlutterPluginBinding flutterPluginBinding;

  @Test
  public void onAttachedToActivity_setsLifecycleOwnerAsActivityIfLifecycleOwnerAsNeeded() {
    CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));
    ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);

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
    CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    Activity mockActivity = mock(Activity.class);
    ProcessCameraProviderHostApiImpl mockProcessCameraProviderHostApiImpl =
        mock(ProcessCameraProviderHostApiImpl.class);
    LiveDataHostApiImpl mockLiveDataHostApiImpl = mock(LiveDataHostApiImpl.class);

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
  public void onAttachedToActivity_setsActivityAsNeeded() {
    CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    Activity mockActivity = mock(Activity.class);
    SystemServicesHostApiImpl mockSystemServicesHostApiImpl = mock(SystemServicesHostApiImpl.class);
    DeviceOrientationManagerHostApiImpl mockDeviceOrientationManagerHostApiImpl = mock(DeviceOrientationManagerHostApiImpl.class);

    doNothing().when(plugin).setUp(any(), any(), any());
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.deviceOrientationManagerHostApiImpl = mockDeviceOrientationManagerHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    verify(mockSystemServicesHostApiImpl).setActivity(mockActivity);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(mockActivity);
  }

  @Test
  public void onDetachedFromActivityForConfigChanges_removesReferencesToActivityPluginBindingAndActivity() {


    verify(mockProcessCameraProviderHostApiImpl)
        .setLifecycleOwner(null);
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(null);
    verify(mockSystemServicesHostApiImpl).setActivity(null);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(null);
  }

  @Test
  public void onReattachedToActivityForConfigChanges_setsLifecycleOwnerAsActivityIfLifecycleOwnerAsNeeded() {

  }

    @Test
  public void onReattachedToActivityForConfigChanges_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwnerAsNeeded() {
    
  }

  @Test
  public void onReattachedToActivityForConfigChanges_setsActivityAndPermissionsRegistryAsNeeded() {
    CameraAndroidCameraxPlugin plugin = spy(new CameraAndroidCameraxPlugin());
    Activity mockActivity = mock(Activity.class);
    SystemServicesHostApiImpl mockSystemServicesHostApiImpl = mock(SystemServicesHostApiImpl.class);
    DeviceOrientationManagerHostApiImpl mockDeviceOrientationManagerHostApiImpl = mock(DeviceOrientationManagerHostApiImpl.class);
    ??? mockPermissionsRegistry = mock(???.class);

    doNothing().when(plugin).setUp(any(), any(), any());
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    plugin.systemServicesHostApiImpl = mockSystemServicesHostApiImpl;
    plugin.deviceOrientationManagerHostApiImpl = mockDeviceOrientationManagerHostApiImpl;

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onReattachedToActivityForConfigChanges(activityPluginBinding);

    // Check Activity references are set.
    verify(mockSystemServicesHostApiImpl).setActivity(mockActivity);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(mockActivity);

    // Check Activity as Context references are set.

    // Check permissions registry reference is set.
    verify(mockSystemServicesHostApiImpl).setPermissionsRegistry(mockPermissionsRegistry);

  }

  @Test
  public void onDetachedFromActivity_removesReferencesToActivityPluginBindingAndActivity() {

    verify(mockProcessCameraProviderHostApiImpl)
        .setLifecycleOwner(null);
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(null);
    verify(mockSystemServicesHostApiImpl).setActivity(null);
    verify(mockDeviceOrientationManagerHostApiImpl).setActivity(null);
  }
}
