// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraAndroidCameraxPluginTest {

    @Mock ActivityPluginBinding activityPluginBinding;
    @Mock FlutterPluginBinding flutterPluginBinding;
    
    @Test
    public void onAttachedToActivity_setsLifecycleOwnerAsActivityIfLifecycleOwner() {
        CameraAndroidCameraxPlugin plugin = new CameraAndroidCameraxPlugin();
        Activity mockActivity = mock(Activity.class);

        when(activityPluginBinding.getActivity()).thenReturn(mockActivity);

        // Set plugin's pluginBinding.
        plugin.onAttachedToEngine(flutterPluginBinding);

        plugin.onAttachedToActivity(activityPluginBinding);
    }

    @Test
    public void onAttachedToActivity_setsLifecycleOwnerAsProxyLifecycleProviderIfActivityNotLifecycleOwner() {

    }
}
