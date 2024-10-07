// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ClipData;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;
import android.provider.OpenableColumns;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import java.io.DataInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Collections;
import java.util.List;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;

public class FileSelectorAndroidPluginTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Intent mockIntent;

  @Mock public Activity mockActivity;

  @Mock FileSelectorApiImpl.NativeObjectFactory mockObjectFactory;

  @Mock public ActivityPluginBinding mockActivityBinding;

  private void mockContentResolver(
      @NonNull ContentResolver mockResolver,
      @NonNull Uri uri,
      @NonNull String displayName,
      int size,
      @NonNull String mimeType)
      throws FileNotFoundException {
    final Cursor mockCursor = mock(Cursor.class);
    when(mockCursor.moveToFirst()).thenReturn(true);

    when(mockCursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)).thenReturn(0);
    when(mockCursor.getString(0)).thenReturn(displayName);

    when(mockCursor.getColumnIndex(OpenableColumns.SIZE)).thenReturn(1);
    when(mockCursor.isNull(1)).thenReturn(false);
    when(mockCursor.getInt(1)).thenReturn(size);

    when(mockResolver.query(uri, null, null, null, null, null)).thenReturn(mockCursor);
    when(mockResolver.getType(uri)).thenReturn(mimeType);
    when(mockResolver.openInputStream(uri)).thenReturn(mock(InputStream.class));
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void openFileReturnsSuccessfully() throws FileNotFoundException {
    try (MockedStatic<FileUtils> mockedFileUtils = mockStatic(FileUtils.class)) {
      final ContentResolver mockContentResolver = mock(ContentResolver.class);

      final Uri mockUri = mock(Uri.class);
      final String mockUriPath = "/some/path";
      mockedFileUtils
          .when(() -> FileUtils.getPathFromCopyOfFileFromUri(any(Context.class), eq(mockUri)))
          .thenAnswer((Answer<String>) invocation -> mockUriPath);
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain");

      when(mockObjectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT)).thenReturn(mockIntent);
      when(mockObjectFactory.newDataInputStream(any())).thenReturn(mock(DataInputStream.class));
      when(mockActivity.getContentResolver()).thenReturn(mockContentResolver);
      when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
      final FileSelectorApiImpl fileSelectorApi =
          new FileSelectorApiImpl(
              mockActivityBinding,
              mockObjectFactory,
              (version) -> Build.VERSION.SDK_INT >= version);

      final GeneratedFileSelectorApi.NullableResult mockResult =
          mock(GeneratedFileSelectorApi.NullableResult.class);
      fileSelectorApi.openFile(
          null,
          new GeneratedFileSelectorApi.FileTypes.Builder()
              .setMimeTypes(Collections.emptyList())
              .setExtensions(Collections.emptyList())
              .build(),
          mockResult);
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
      assertEquals(file.getPath(), mockUriPath);
    }
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void openFilesReturnsSuccessfully() throws FileNotFoundException {
    try (MockedStatic<FileUtils> mockedFileUtils = mockStatic(FileUtils.class)) {

      final ContentResolver mockContentResolver = mock(ContentResolver.class);

      final Uri mockUri = mock(Uri.class);
      final String mockUriPath = "some/path/";
      mockedFileUtils
          .when(() -> FileUtils.getPathFromCopyOfFileFromUri(any(Context.class), eq(mockUri)))
          .thenAnswer((Answer<String>) invocation -> mockUriPath);
      mockContentResolver(mockContentResolver, mockUri, "filename", 30, "text/plain");

      final Uri mockUri2 = mock(Uri.class);
      final String mockUri2Path = "some/other/path/";
      mockedFileUtils
          .when(() -> FileUtils.getPathFromCopyOfFileFromUri(any(Context.class), eq(mockUri2)))
          .thenAnswer((Answer<String>) invocation -> mockUri2Path);
      mockContentResolver(mockContentResolver, mockUri2, "filename2", 40, "image/jpg");

      when(mockObjectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT)).thenReturn(mockIntent);
      when(mockObjectFactory.newDataInputStream(any())).thenReturn(mock(DataInputStream.class));
      when(mockActivity.getContentResolver()).thenReturn(mockContentResolver);
      when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
      final FileSelectorApiImpl fileSelectorApi =
          new FileSelectorApiImpl(
              mockActivityBinding,
              mockObjectFactory,
              (version) -> Build.VERSION.SDK_INT >= version);

      final GeneratedFileSelectorApi.Result mockResult =
          mock(GeneratedFileSelectorApi.Result.class);
      fileSelectorApi.openFiles(
          null,
          new GeneratedFileSelectorApi.FileTypes.Builder()
              .setMimeTypes(Collections.emptyList())
              .setExtensions(Collections.emptyList())
              .build(),
          mockResult);
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE);
      verify(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);

      verify(mockActivity).startActivityForResult(mockIntent, 222);

      final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
          ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

      final Intent resultMockIntent = mock(Intent.class);
      final ClipData mockClipData = mock(ClipData.class);
      when(mockClipData.getItemCount()).thenReturn(2);

      final ClipData.Item mockClipDataItem = mock(ClipData.Item.class);
      when(mockClipDataItem.getUri()).thenReturn(mockUri);
      when(mockClipData.getItemAt(0)).thenReturn(mockClipDataItem);

      final ClipData.Item mockClipDataItem2 = mock(ClipData.Item.class);
      when(mockClipDataItem2.getUri()).thenReturn(mockUri2);
      when(mockClipData.getItemAt(1)).thenReturn(mockClipDataItem2);

      when(resultMockIntent.getClipData()).thenReturn(mockClipData);

      listenerArgumentCaptor.getValue().onActivityResult(222, Activity.RESULT_OK, resultMockIntent);

      final ArgumentCaptor<List> fileListCaptor = ArgumentCaptor.forClass(List.class);
      verify(mockResult).success(fileListCaptor.capture());

      final List<GeneratedFileSelectorApi.FileResponse> fileList = fileListCaptor.getValue();
      assertEquals(fileList.get(0).getBytes().length, 30);
      assertEquals(fileList.get(0).getMimeType(), "text/plain");
      assertEquals(fileList.get(0).getName(), "filename");
      assertEquals(fileList.get(0).getSize(), (Long) 30L);
      assertEquals(fileList.get(0).getPath(), mockUriPath);

      assertEquals(fileList.get(1).getBytes().length, 40);
      assertEquals(fileList.get(1).getMimeType(), "image/jpg");
      assertEquals(fileList.get(1).getName(), "filename2");
      assertEquals(fileList.get(1).getSize(), (Long) 40L);
      assertEquals(fileList.get(1).getPath(), mockUri2Path);
    }
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void getDirectoryPathReturnsSuccessfully() {
    try (MockedStatic<FileUtils> mockedFileUtils = mockStatic(FileUtils.class)) {
      final Uri mockUri = mock(Uri.class);
      final String mockUriPath = "some/path/";
      final String mockUriId = "someId";
      final Uri mockUriUsingTree = mock(Uri.class);

      mockedFileUtils
          .when(() -> FileUtils.getPathFromUri(any(Context.class), eq(mockUriUsingTree)))
          .thenAnswer((Answer<String>) invocation -> mockUriPath);

      try (MockedStatic<DocumentsContract> mockedDocumentsContract =
          mockStatic(DocumentsContract.class)) {

        mockedDocumentsContract
            .when(() -> DocumentsContract.getTreeDocumentId(mockUri))
            .thenAnswer((Answer<String>) invocation -> mockUriId);
        mockedDocumentsContract
            .when(() -> DocumentsContract.buildDocumentUriUsingTree(mockUri, mockUriId))
            .thenAnswer((Answer<Uri>) invocation -> mockUriUsingTree);

        when(mockObjectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE)).thenReturn(mockIntent);
        when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
        final FileSelectorApiImpl fileSelectorApi =
            new FileSelectorApiImpl(
                mockActivityBinding,
                mockObjectFactory,
                (version) -> Build.VERSION_CODES.LOLLIPOP >= version);

        final GeneratedFileSelectorApi.NullableResult mockResult =
            mock(GeneratedFileSelectorApi.NullableResult.class);
        fileSelectorApi.getDirectoryPath(null, mockResult);

        verify(mockActivity).startActivityForResult(mockIntent, 223);

        final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
            ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
        verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

        final Intent resultMockIntent = mock(Intent.class);
        when(resultMockIntent.getData()).thenReturn(mockUri);
        listenerArgumentCaptor
            .getValue()
            .onActivityResult(223, Activity.RESULT_OK, resultMockIntent);

        verify(mockResult).success(mockUriPath);
      }
    }
  }

  @Test
  public void getDirectoryPath_errorsForUnsupportedVersion() {
    final FileSelectorApiImpl fileSelectorApi =
        new FileSelectorApiImpl(
            mockActivityBinding,
            mockObjectFactory,
            (version) -> Build.VERSION_CODES.KITKAT >= version);

    @SuppressWarnings("unchecked")
    final GeneratedFileSelectorApi.NullableResult<String> mockResult =
        mock(GeneratedFileSelectorApi.NullableResult.class);
    fileSelectorApi.getDirectoryPath(null, mockResult);

    verify(mockResult).error(any());
  }
}
