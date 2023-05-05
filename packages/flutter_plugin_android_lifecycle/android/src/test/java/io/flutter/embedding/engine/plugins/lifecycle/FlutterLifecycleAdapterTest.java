// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.embedding.engine.plugins.lifecycle;

import static org.junit.Assert.assertEquals;

import android.app.Activity;
import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import static org.mockito.Mockito.when;

public class FlutterLifecycleAdapterTest {
  @Mock Lifecycle lifecycle;
  @Mock ActivityPluginBinding mockActivityPluginBinding;

  AutoCloseable mockCloseable;

  @Before
  public void setUp() {
    mockCloseable = MockitoAnnotations.openMocks(this);
  }

  @After
  public void tearDown() throws Exception {
    mockCloseable.close();
  }

  @Test
  public void getActivityLifecycle() {
    when(mockActivityPluginBinding.getLifecycle())
        .thenReturn(new HiddenLifecycleReference(lifecycle));

    when(mockActivityPluginBinding.getActivity())
        .thenReturn(null);

    Lifecycle parsedLifecycle = FlutterLifecycleAdapter.getActivityLifecycle(mockActivityPluginBinding);

    assertEquals(lifecycle, parsedLifecycle);
  }
}
