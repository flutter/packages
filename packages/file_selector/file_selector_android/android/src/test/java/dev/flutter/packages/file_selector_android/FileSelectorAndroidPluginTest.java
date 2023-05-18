// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import java.io.DataInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Collections;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class FileSelectorAndroidPluginTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Intent mockIntent;

  @Mock public Activity mockActivity;

  @Mock FileSelectorApiImpl.TestProxy mockTestProxy;

  @Mock public ActivityPluginBinding mockActivityBinding;

  @NonNull
  private ContentResolver mockContentResolver(
      Uri uri, String displayName, int size, String mimeType) throws FileNotFoundException {
    final Cursor mockCursor = mock(Cursor.class);
    when(mockCursor.moveToFirst()).thenReturn(true);

    when(mockCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)).thenReturn(0);
    when(mockCursor.getString(0)).thenReturn(displayName);

    when(mockCursor.getColumnIndex(OpenableColumns.SIZE)).thenReturn(1);
    when(mockCursor.isNull(1)).thenReturn(false);
    when(mockCursor.getInt(1)).thenReturn(size);

    final ContentResolver mockResolver = mock(ContentResolver.class);
    when(mockResolver.query(uri, null, null, null, null, null)).thenReturn(mockCursor);
    when(mockResolver.getType(uri)).thenReturn(mimeType);
    when(mockResolver.openInputStream(uri)).thenReturn(mock(InputStream.class));

    return mockResolver;
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void openFileReturnsSuccessfully() throws FileNotFoundException {
    final Uri mockUri = mock(Uri.class);
    when(mockUri.toString()).thenReturn("some/path/");

    final ContentResolver mockContentResolver =
        mockContentResolver(mockUri, "filename", 30, "text/plain");

    when(mockTestProxy.newIntent(Intent.ACTION_OPEN_DOCUMENT)).thenReturn(mockIntent);
    when(mockTestProxy.newDataInputStream(any())).thenReturn(mock(DataInputStream.class));
    when(mockActivity.getContentResolver()).thenReturn(mockContentResolver);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    final FileSelectorApiImpl fileSelectorApi =
        new FileSelectorApiImpl(mockActivityBinding, mockTestProxy);

    final GeneratedFileSelectorApi.Result mockResult = mock(GeneratedFileSelectorApi.Result.class);
    fileSelectorApi.openFile(null, Collections.emptyList(), Collections.emptyList(), mockResult);
    verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE);

    verify(mockActivity).startActivityForResult(mockIntent, 221);

    final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

    final Intent resultMockIntent = mock(Intent.class);
    when(resultMockIntent.getData()).thenReturn(mockUri);
    listenerArgumentCaptor.getValue().onActivityResult(221, Activity.RESULT_OK, resultMockIntent);

    final ArgumentCaptor<GeneratedFileSelectorApi.FileResponse> fileCaptor =
        ArgumentCaptor.forClass(GeneratedFileSelectorApi.FileResponse.class);
    verify(mockResult).success(fileCaptor.capture());

    final GeneratedFileSelectorApi.FileResponse file = fileCaptor.getValue();
    assertEquals(file.getBytes().length, 30);
    assertEquals(file.getMimeType(), "text/plain");
    assertEquals(file.getName(), "filename");
    assertEquals(file.getSize(), (Long) 30L);
    assertEquals(file.getPath(), "some/path/");
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void openFilesReturnsSuccessfully() throws FileNotFoundException {
    final Uri mockUri = mock(Uri.class);
    when(mockUri.toString()).thenReturn("some/path/");

    final Uri mockUri2 = mock(Uri.class);
    when(mockUri2.toString()).thenReturn("some/other/path/");

    final ContentResolver mockContentResolver =
        mockContentResolver(mockUri, "filename", 30, "text/plain");

    when(mockTestProxy.newIntent(Intent.ACTION_OPEN_DOCUMENT)).thenReturn(mockIntent);
    when(mockTestProxy.newDataInputStream(any())).thenReturn(mock(DataInputStream.class));
    when(mockActivity.getContentResolver()).thenReturn(mockContentResolver);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    final FileSelectorApiImpl fileSelectorApi =
        new FileSelectorApiImpl(mockActivityBinding, mockTestProxy);

    final GeneratedFileSelectorApi.Result mockResult = mock(GeneratedFileSelectorApi.Result.class);
    fileSelectorApi.openFile(null, Collections.emptyList(), Collections.emptyList(), mockResult);
    verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE);

    verify(mockActivity).startActivityForResult(mockIntent, 221);

    final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

    final Intent resultMockIntent = mock(Intent.class);
    when(resultMockIntent.getData()).thenReturn(mockUri);
    listenerArgumentCaptor.getValue().onActivityResult(221, Activity.RESULT_OK, resultMockIntent);

    final ArgumentCaptor<GeneratedFileSelectorApi.FileResponse> fileCaptor =
        ArgumentCaptor.forClass(GeneratedFileSelectorApi.FileResponse.class);
    verify(mockResult).success(fileCaptor.capture());

    final GeneratedFileSelectorApi.FileResponse file = fileCaptor.getValue();
    assertEquals(file.getBytes().length, 30);
    assertEquals(file.getMimeType(), "text/plain");
    assertEquals(file.getName(), "filename");
    assertEquals(file.getSize(), (Long) 30L);
    assertEquals(file.getPath(), "some/path/");
  }
}
