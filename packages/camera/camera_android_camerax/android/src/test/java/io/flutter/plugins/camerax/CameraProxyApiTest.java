//// Copyright 2013 The Flutter Authors. All rights reserved.
//// Use of this source code is governed by a BSD-style license that can be
//// found in the LICENSE file.
//
//package io.flutter.plugins.camerax
//
//import androidx.camera.core.Camera
//import androidx.camera.core.CameraControl
//import androidx.camera.core.CameraInfo
//import org.junit.Test;
//import static org.junit.Assert.assertEquals;
//import static org.junit.Assert.assertTrue;
//import org.mockito.Mockito;
//import org.mockito.Mockito.any;
//import java.util.HashMap;
//import static org.mockito.Mockito.eq;
//import static org.mockito.Mockito.mock;
//import org.mockito.Mockito.verify;
//import static org.mockito.Mockito.when;
//
//public class CameraProxyApiTest {
//  @Test
//  public void cameraControl() {
//    final PigeonApiCamera api = new TestProxyApiRegistrar().getPigeonApiCamera();
//
//    final Camera instance = mock(Camera.class);
//    final androidx.camera.core.CameraControl value = mock(CameraControl.class);
//    when(instance.getCameraControl()).thenReturn(value);
//
//    assertEquals(value, api.cameraControl(instance));
//  }
//
//  @Test
//  public void getCameraInfo() {
//    final PigeonApiCamera api = new TestProxyApiRegistrar().getPigeonApiCamera();
//
//    final Camera instance = mock(Camera.class);
//    final androidx.camera.core.CameraInfo value = mock(CameraInfo.class);
//    when(instance.getCameraInfo()).thenReturn(value);
//
//    assertEquals(value, api.getCameraInfo(instance ));
//  }
//
//}
