// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax


import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.mockito.Mockito;
import org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class SystemServicesManagerProxyApiTest {
  @Test
  public void pigeon_defaultConstructor() {
    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar().getPigeonApiSystemServicesManager();

    assertTrue(api.pigeon_defaultConstructor() instanceof SystemServicesManagerProxyApi.SystemServicesManager);
  }

  @Test
  public void requestCameraPermissions() {
    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar().getPigeonApiSystemServicesManager();

    final SystemServicesManager instance = mock(SystemServicesManager.class);
    final Boolean enableAudio = true;
    api.requestCameraPermissions(instance, enableAudio);

    verify(instance).requestCameraPermissions(enableAudio);
  }

  @Test
  public void getTempFilePath() {
    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar().getPigeonApiSystemServicesManager();

    final SystemServicesManager instance = mock(SystemServicesManager.class);
    final String prefix = "myString";
    final String suffix = "myString";
    final String value = "myString";
    when(instance.getTempFilePath(prefix, suffix)).thenReturn(value);

    assertEquals(value, api.getTempFilePath(instance, prefix, suffix));
  }

  @Test
  public void isPreviewPreTransformed() {
    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar().getPigeonApiSystemServicesManager();

    final SystemServicesManager instance = mock(SystemServicesManager.class);
    final Boolean value = true;
    when(instance.isPreviewPreTransformed()).thenReturn(value);

    assertEquals(value, api.isPreviewPreTransformed(instance ));
  }

  @Test
  public void onCameraError() {
    final SystemServicesManagerProxyApi mockApi = mock(SystemServicesManagerProxyApi.class);
    when(mockApi.pigeonRegistrar).thenReturn(new TestProxyApiRegistrar());

    final SystemServicesManagerImpl instance = new SystemServicesManagerImpl(mockApi);
    final String errorDescription = "myString";
    instance.onCameraError(errorDescription);

    verify(mockApi).onCameraError(eq(instance), eq(errorDescription), any());
  }

}
