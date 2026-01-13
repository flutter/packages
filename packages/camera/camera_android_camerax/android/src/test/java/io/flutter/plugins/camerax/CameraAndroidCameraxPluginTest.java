// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.withSettings;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import androidx.lifecycle.LifecycleOwner;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.view.TextureRegistry;
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
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    assertNotNull(plugin.proxyApiRegistrar);
    assertEquals(plugin.proxyApiRegistrar.getActivity(), mockActivity);
    assertEquals(plugin.proxyApiRegistrar.getLifecycleOwner(), mockActivity);
  }

  @Test
  public void
      onAttachedToActivity_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwnerAsNeeded() {
    final Activity mockActivity = mock(Activity.class);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    assertNotNull(plugin.proxyApiRegistrar);
    assertTrue(plugin.proxyApiRegistrar.getLifecycleOwner() instanceof ProxyLifecycleProvider);
  }

  @Test
  public void onAttachedToActivity_setsActivityAsNeededAndPermissionsRegistry() {
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    assertNotNull(plugin.proxyApiRegistrar);
    assertEquals(plugin.proxyApiRegistrar.getActivity(), mockActivity);
    assertEquals(plugin.proxyApiRegistrar.getLifecycleOwner(), mockActivity);
    assertNotNull(plugin.proxyApiRegistrar.getPermissionsRegistry());
  }

  @Test
  public void
      onDetachedFromActivityForConfigChanges_removesReferencesToActivityPluginBindingAndActivity() {
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);
    plugin.onDetachedFromActivity();

    assertNotNull(plugin.proxyApiRegistrar);
    assertNull(plugin.proxyApiRegistrar.getActivity());
    assertNull(plugin.proxyApiRegistrar.getLifecycleOwner());
  }

  @Test
  public void
      onDetachedFromActivityForConfigChanges_setsContextReferencesBasedOnFlutterPluginBinding() {
    final Context mockContext = mock(Context.class);
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mockContext);
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);
    plugin.onDetachedFromActivityForConfigChanges();

    assertNotNull(plugin.proxyApiRegistrar);
    assertEquals(plugin.proxyApiRegistrar.getContext(), mockContext);
    assertNull(plugin.proxyApiRegistrar.getActivity());
    assertNull(plugin.proxyApiRegistrar.getLifecycleOwner());
  }

  @Test
  public void
      onReattachedToActivityForConfigChanges_setsLifecycleOwnerAsActivityIfLifecycleOwnerAsNeeded() {
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);

    assertNotNull(plugin.proxyApiRegistrar);
    assertEquals(plugin.proxyApiRegistrar.getActivity(), mockActivity);
    assertEquals(plugin.proxyApiRegistrar.getLifecycleOwner(), mockActivity);
  }

  @Test
  public void
      onReattachedToActivityForConfigChanges_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwnerAsNeeded() {
    final Activity mockActivity = mock(Activity.class);
    when(mockActivity.getApplication()).thenReturn(mock(Application.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onReattachedToActivityForConfigChanges(activityPluginBinding);

    assertNotNull(plugin.proxyApiRegistrar);
    assertTrue(plugin.proxyApiRegistrar.getLifecycleOwner() instanceof ProxyLifecycleProvider);
  }

  @Test
  public void onReattachedToActivityForConfigChanges_setsActivityAndPermissionsRegistryAsNeeded() {
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mock(Context.class));
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onReattachedToActivityForConfigChanges(activityPluginBinding);

    assertNotNull(plugin.proxyApiRegistrar);
    assertEquals(plugin.proxyApiRegistrar.getActivity(), mockActivity);
    assertEquals(plugin.proxyApiRegistrar.getLifecycleOwner(), mockActivity);
    assertNotNull(plugin.proxyApiRegistrar.getPermissionsRegistry());
  }

  @Test
  public void onDetachedFromActivity_setsContextReferencesBasedOnFlutterPluginBinding() {
    final Context mockContext = mock(Context.class);
    final Activity mockActivity =
        mock(Activity.class, withSettings().extraInterfaces(LifecycleOwner.class));

    when(flutterPluginBinding.getBinaryMessenger()).thenReturn(mock(BinaryMessenger.class));
    when(flutterPluginBinding.getApplicationContext()).thenReturn(mockContext);
    when(flutterPluginBinding.getTextureRegistry()).thenReturn(mock(TextureRegistry.class));
    when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

    final CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
    plugin.onAttachedToEngine(flutterPluginBinding);
    plugin.onAttachedToActivity(activityPluginBinding);
    plugin.onDetachedFromActivity();

    assertNotNull(plugin.proxyApiRegistrar);
    assertEquals(plugin.proxyApiRegistrar.getContext(), mockContext);
    assertNull(plugin.proxyApiRegistrar.getActivity());
    assertNull(plugin.proxyApiRegistrar.getLifecycleOwner());
  }
}
