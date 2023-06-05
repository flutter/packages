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
  public void onAttachedToActivity_setsLifecycleOwnerAsActivityIfLifecycleOwner() {
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

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    verify(mockProcessCameraProviderHostApiImpl).setLifecycleOwner(any(LifecycleOwner.class));
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(any(LifecycleOwner.class));
  }

  @Test
  public void
      onAttachedToActivity_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwner() {
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

    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    verify(mockProcessCameraProviderHostApiImpl)
        .setLifecycleOwner(any(ProxyLifecycleProvider.class));
    verify(mockLiveDataHostApiImpl).setLifecycleOwner(any(ProxyLifecycleProvider.class));
  }
}
