// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.CameraPermissionsManager.PermissionsRegistry;
import io.flutter.plugins.camerax.CameraPermissionsManager.ResultCallback;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.CameraPermissionsErrorData;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.Result;
import java.io.File;
import java.io.IOException;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class SystemServicesTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public InstanceManager mockInstanceManager;
  @Mock public Context mockContext;

  @Test
  public void requestCameraPermissionsTest() {
    final SystemServicesHostApiImpl systemServicesHostApi =
        new SystemServicesHostApiImpl(mockBinaryMessenger, mockInstanceManager, mockContext);
    final CameraXProxy mockCameraXProxy = mock(CameraXProxy.class);
    final CameraPermissionsManager mockCameraPermissionsManager =
        mock(CameraPermissionsManager.class);
    final Activity mockActivity = mock(Activity.class);
    final PermissionsRegistry mockPermissionsRegistry = mock(PermissionsRegistry.class);
    @SuppressWarnings("unchecked")
    final Result<CameraPermissionsErrorData> mockResult = mock(Result.class);
    final Boolean enableAudio = false;

    systemServicesHostApi.cameraXProxy = mockCameraXProxy;
    systemServicesHostApi.setActivity(mockActivity);
    systemServicesHostApi.setPermissionsRegistry(mockPermissionsRegistry);
    when(mockCameraXProxy.createCameraPermissionsManager())
        .thenReturn(mockCameraPermissionsManager);

    final ArgumentCaptor<ResultCallback> resultCallbackCaptor =
        ArgumentCaptor.forClass(ResultCallback.class);

    systemServicesHostApi.requestCameraPermissions(enableAudio, mockResult);

    // Test camera permissions are requested.
    verify(mockCameraPermissionsManager)
        .requestPermissions(
            eq(mockActivity),
            eq(mockPermissionsRegistry),
            eq(enableAudio),
            resultCallbackCaptor.capture());

    ResultCallback resultCallback = resultCallbackCaptor.getValue();

    // Test no error data is sent upon permissions request success.
    resultCallback.onResult(null, null);
    verify(mockResult).success(null);

    // Test expected error data is sent upon permissions request failure.
    final String testErrorCode = "TestErrorCode";
    final String testErrorDescription = "Test error description.";

    final ArgumentCaptor<CameraPermissionsErrorData> cameraPermissionsErrorDataCaptor =
        ArgumentCaptor.forClass(CameraPermissionsErrorData.class);

    resultCallback.onResult(testErrorCode, testErrorDescription);
    verify(mockResult, times(2)).success(cameraPermissionsErrorDataCaptor.capture());

    CameraPermissionsErrorData cameraPermissionsErrorData =
        cameraPermissionsErrorDataCaptor.getValue();
    assertEquals(cameraPermissionsErrorData.getErrorCode(), testErrorCode);
    assertEquals(cameraPermissionsErrorData.getDescription(), testErrorDescription);
  }

  @Test
  public void getTempFilePath_returnsCorrectPath() {
    final SystemServicesHostApiImpl systemServicesHostApi =
        new SystemServicesHostApiImpl(mockBinaryMessenger, mockInstanceManager, mockContext);

    final String prefix = "prefix";
    final String suffix = ".suffix";
    final MockedStatic<File> mockedStaticFile = mockStatic(File.class);
    final File mockOutputDir = mock(File.class);
    final File mockFile = mock(File.class);
    when(mockContext.getCacheDir()).thenReturn(mockOutputDir);
    mockedStaticFile
        .when(() -> File.createTempFile(prefix, suffix, mockOutputDir))
        .thenReturn(mockFile);
    when(mockFile.toString()).thenReturn(prefix + suffix);
    assertEquals(systemServicesHostApi.getTempFilePath(prefix, suffix), prefix + suffix);

    mockedStaticFile.close();
  }

  @Test
  public void getTempFilePath_throwsRuntimeExceptionOnIOException() {
    final SystemServicesHostApiImpl systemServicesHostApi =
        new SystemServicesHostApiImpl(mockBinaryMessenger, mockInstanceManager, mockContext);

    final String prefix = "prefix";
    final String suffix = ".suffix";
    final MockedStatic<File> mockedStaticFile = mockStatic(File.class);
    final File mockOutputDir = mock(File.class);
    when(mockContext.getCacheDir()).thenReturn(mockOutputDir);
    mockedStaticFile
        .when(() -> File.createTempFile(prefix, suffix, mockOutputDir))
        .thenThrow(IOException.class);
    assertThrows(
        GeneratedCameraXLibrary.FlutterError.class,
        () -> systemServicesHostApi.getTempFilePath(prefix, suffix));

    mockedStaticFile.close();
  }

  @Test
  @Config(sdk = 28)
  public void isPreviewPreTransformed_returnsTrueWhenRunningBelowSdk29() {
    final SystemServicesHostApiImpl systemServicesHostApi =
        new SystemServicesHostApiImpl(mockBinaryMessenger, mockInstanceManager, mockContext);
    assertTrue(systemServicesHostApi.isPreviewPreTransformed());
  }

  @Test
  @Config(sdk = 28)
  public void isPreviewPreTransformed_returnsTrueWhenRunningSdk28() {
    final SystemServicesHostApiImpl systemServicesHostApi =
        new SystemServicesHostApiImpl(mockBinaryMessenger, mockInstanceManager, mockContext);
    assertTrue(systemServicesHostApi.isPreviewPreTransformed());
  }

  @Test
  @Config(sdk = 29)
  public void isPreviewPreTransformed_returnsFalseWhenRunningAboveSdk28() {
    final SystemServicesHostApiImpl systemServicesHostApi =
        new SystemServicesHostApiImpl(mockBinaryMessenger, mockInstanceManager, mockContext);
    assertFalse(systemServicesHostApi.isPreviewPreTransformed());
  }
}
