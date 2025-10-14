// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.io.File;
import java.io.IOException;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class SystemServicesTest {
  @Test
  public void requestCameraPermissionsTest() {
    final Activity mockActivity = mock(Activity.class);
    final CameraPermissionsManager.PermissionsRegistry mockPermissionsRegistry =
        mock(CameraPermissionsManager.PermissionsRegistry.class);
    final CameraPermissionsManager mockCameraPermissionsManager =
        mock(CameraPermissionsManager.class);
    final TestProxyApiRegistrar proxyApiRegistrar =
        new TestProxyApiRegistrar() {
          @NonNull
          @Override
          public Context getContext() {
            return mockActivity;
          }

          @Nullable
          @Override
          CameraPermissionsManager.PermissionsRegistry getPermissionsRegistry() {
            return mockPermissionsRegistry;
          }

          @NonNull
          @Override
          public CameraPermissionsManager getCameraPermissionsManager() {
            return mockCameraPermissionsManager;
          }
        };
    final SystemServicesManagerProxyApi api = proxyApiRegistrar.getPigeonApiSystemServicesManager();

    final SystemServicesManager instance =
        new SystemServicesManagerProxyApi.SystemServicesManagerImpl(
            proxyApiRegistrar.getPigeonApiSystemServicesManager());
    final Boolean enableAudio = false;

    final CameraPermissionsError[] result = {null};
    api.requestCameraPermissions(
        instance,
        enableAudio,
        ResultCompat.asCompatCallback(
            reply -> {
              result[0] = reply.getOrNull();
              return null;
            }));

    final ArgumentCaptor<CameraPermissionsManager.ResultCallback> resultCallbackCaptor =
        ArgumentCaptor.forClass(CameraPermissionsManager.ResultCallback.class);

    // Test camera permissions are requested.
    verify(mockCameraPermissionsManager)
        .requestPermissions(
            eq(mockActivity),
            eq(mockPermissionsRegistry),
            eq(enableAudio),
            resultCallbackCaptor.capture());

    CameraPermissionsManager.ResultCallback resultCallback = resultCallbackCaptor.getValue();

    // Test no error data is sent upon permissions request success.
    resultCallback.onResult(null);
    assertNull(result[0]);

    // Test expected error data is sent upon permissions request failure.
    final String testErrorCode = "TestErrorCode";
    final String testErrorDescription = "Test error description.";

    final ArgumentCaptor<GeneratedCameraXLibrary.CameraPermissionsErrorData>
        cameraPermissionsErrorDataCaptor =
            ArgumentCaptor.forClass(GeneratedCameraXLibrary.CameraPermissionsErrorData.class);

    resultCallback.onResult(new CameraPermissionsError(testErrorCode, testErrorDescription));
    assertEquals(result[0], new CameraPermissionsError(testErrorCode, testErrorDescription));
  }

  @Test
  public void getTempFilePath_returnsCorrectPath() {
    final Context mockContext = mock(Context.class);
    final TestProxyApiRegistrar proxyApiRegistrar =
        new TestProxyApiRegistrar() {
          @NonNull
          @Override
          public Context getContext() {
            return mockContext;
          }
        };
    final SystemServicesManagerProxyApi api = proxyApiRegistrar.getPigeonApiSystemServicesManager();

    final SystemServicesManager instance =
        new SystemServicesManagerProxyApi.SystemServicesManagerImpl(api);
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
    assertEquals(api.getTempFilePath(instance, prefix, suffix), prefix + suffix);

    mockedStaticFile.close();
  }

  @Test
  public void getTempFilePath_throwsRuntimeExceptionOnIOException() {
    final Context mockContext = mock(Context.class);
    final TestProxyApiRegistrar proxyApiRegistrar =
        new TestProxyApiRegistrar() {
          @NonNull
          @Override
          public Context getContext() {
            return mockContext;
          }
        };
    final SystemServicesManagerProxyApi api = proxyApiRegistrar.getPigeonApiSystemServicesManager();

    final SystemServicesManager instance =
        new SystemServicesManagerProxyApi.SystemServicesManagerImpl(api);

    final String prefix = "prefix";
    final String suffix = ".suffix";
    final MockedStatic<File> mockedStaticFile = mockStatic(File.class);
    final File mockOutputDir = mock(File.class);
    when(mockContext.getCacheDir()).thenReturn(mockOutputDir);
    mockedStaticFile
        .when(() -> File.createTempFile(prefix, suffix, mockOutputDir))
        .thenThrow(IOException.class);
    assertThrows(RuntimeException.class, () -> api.getTempFilePath(instance, prefix, suffix));

    mockedStaticFile.close();
  }

  @Test
  public void onCameraError() {
    final SystemServicesManagerProxyApi mockApi = mock(SystemServicesManagerProxyApi.class);
    when(mockApi.getPigeonRegistrar()).thenReturn(new TestProxyApiRegistrar());

    final SystemServicesManager instance =
        new SystemServicesManagerProxyApi.SystemServicesManagerImpl(mockApi);
    final String errorDescription = "myString";
    instance.onCameraError(errorDescription);

    verify(mockApi).onCameraError(eq(instance), eq(errorDescription), any());
  }
}
