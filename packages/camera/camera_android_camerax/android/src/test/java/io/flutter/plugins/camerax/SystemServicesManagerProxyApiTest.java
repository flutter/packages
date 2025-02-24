// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;


import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import static org.mockito.Mockito.any;
import java.util.HashMap;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class SystemServicesManagerProxyApiTest {
//  @Test
//  public void requestCameraPermissionsTest() {
//    final Activity mockActivity = mock(Activity.class);
//    final CameraPermissionsManager.PermissionsRegistry mockPermissionsRegistry = mock(CameraPermissionsManager.PermissionsRegistry.class);
//    final CameraPermissionsManager mockCameraPermissionsManager =
//        mock(CameraPermissionsManager.class);
//    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar() {
//      @Nullable
//      @Override
//      public Activity getActivity() {
//        return mockActivity;
//      }
//
//      @Nullable
//      @Override
//      CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry() {
//        return mockPermissionsRegistry;
//      }
//
//      @NonNull
//      @Override
//      public CameraPermissionsManager getCameraPermissionsManager() {
//        return mockCameraPermissionsManager;
//      }
//    }.getPigeonApiSystemServicesManager();
//
//    final SystemServicesManager instance = mock(SystemServicesManager.class);
//    final Boolean enableAudio = false;
//
//    final boolean[] isSuccess = {false};
//    api.requestCameraPermissions(instance, enableAudio, ResultCompat.asCompatCallback(
//        reply -> {
//          isSuccess[0] = reply.isSuccess();
//          return null;
//        }));
//
//        final ArgumentCaptor<CameraPermissionsManager.ResultCallback> resultCallbackCaptor =
//        ArgumentCaptor.forClass(CameraPermissionsManager.ResultCallback.class);
//
//    // Test camera permissions are requested.
//    verify(mockCameraPermissionsManager)
//        .requestPermissions(
//            eq(mockActivity),
//            eq(mockPermissionsRegistry),
//            eq(enableAudio),
//            resultCallbackCaptor.capture());
//
//    CameraPermissionsManager.ResultCallback resultCallback = resultCallbackCaptor.getValue();
//
//    // Test no error data is sent upon permissions request success.
//    resultCallback.onResult(null, null);
//    assertTrue(isSuccess[0]);
//
//    // Test expected error data is sent upon permissions request failure.
//    final String testErrorCode = "TestErrorCode";
//    final String testErrorDescription = "Test error description.";
//
//    final ArgumentCaptor<GeneratedCameraXLibrary.CameraPermissionsErrorData> cameraPermissionsErrorDataCaptor =
//        ArgumentCaptor.forClass(GeneratedCameraXLibrary.CameraPermissionsErrorData.class);
//
//    resultCallback.onResult(testErrorCode, testErrorDescription);
//    verify(mockResult, times(2)).success(cameraPermissionsErrorDataCaptor.capture());
//
//    CameraPermissionsErrorData cameraPermissionsErrorData =
//        cameraPermissionsErrorDataCaptor.getValue();
//    assertEquals(cameraPermissionsErrorData.getErrorCode(), testErrorCode);
//    assertEquals(cameraPermissionsErrorData.getDescription(), testErrorDescription);
//  }
//
//  @Test
//  public void getTempFilePath() {
//    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar().getPigeonApiSystemServicesManager();
//
//    final SystemServicesManager instance = mock(SystemServicesManager.class);
//    final String prefix = "myString";
//    final String suffix = "myString";
//    final String value = "myString";
//    when(instance.getTempFilePath(prefix, suffix)).thenReturn(value);
//
//    assertEquals(value, api.getTempFilePath(instance, prefix, suffix));
//  }
//
//  @Test
//  public void isPreviewPreTransformed() {
//    final PigeonApiSystemServicesManager api = new TestProxyApiRegistrar().getPigeonApiSystemServicesManager();
//
//    final SystemServicesManager instance = mock(SystemServicesManager.class);
//    final Boolean value = true;
//    when(instance.isPreviewPreTransformed()).thenReturn(value);
//
//    assertEquals(value, api.isPreviewPreTransformed(instance ));
//  }
//
//  @Test
//  public void onCameraError() {
//    final SystemServicesManagerProxyApi mockApi = mock(SystemServicesManagerProxyApi.class);
//    when(mockApi.pigeonRegistrar).thenReturn(new TestProxyApiRegistrar());
//
//    final SystemServicesManagerImpl instance = new SystemServicesManagerImpl(mockApi);
//    final String errorDescription = "myString";
//    instance.onCameraError(errorDescription);
//
//    verify(mockApi).onCameraError(eq(instance), eq(errorDescription), any());
//  }
}
