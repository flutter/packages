// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertThrows;
import static org.junit.Assert.assertTrue;
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

      final Boolean[] callbackCalled = new Boolean[1];
      fileSelectorApi.openFile(
          null,
          new FileTypes(Collections.emptyList(), Collections.emptyList()),
          ResultCompat.asCompatCallback(
              reply -> {
                callbackCalled[0] = true;
                FileResponse file = reply.getOrNull();
                assertNotNull(file);
                assertEquals(30, file.getBytes().length);
                assertEquals("text/plain", file.getMimeType());
                assertEquals("filename", file.getName());
                assertEquals(30L, file.getSize());
                assertEquals(mockUriPath, file.getPath());
                return null;
              }));
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE);

      verify(mockActivity).startActivityForResult(mockIntent, 221);

      final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
          ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

      final Intent resultMockIntent = mock(Intent.class);
      when(resultMockIntent.getData()).thenReturn(mockUri);
      listenerArgumentCaptor.getValue().onActivityResult(221, Activity.RESULT_OK, resultMockIntent);

      assertTrue(callbackCalled[0]);
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

      final Boolean[] callbackCalled = new Boolean[1];
      fileSelectorApi.openFiles(
          null,
          new FileTypes(Collections.emptyList(), Collections.emptyList()),
          ResultCompat.asCompatCallback(
              reply -> {
                callbackCalled[0] = true;
                List<FileResponse> fileList = reply.getOrNull();
                assertNotNull(fileList);
                FileResponse file1 = fileList.get(0);
                assertEquals(30, file1.getBytes().length);
                assertEquals("text/plain", file1.getMimeType());
                assertEquals("filename", file1.getName());
                assertEquals(30L, file1.getSize());
                assertEquals(mockUriPath, file1.getPath());

                FileResponse file2 = fileList.get(1);
                assertEquals(40, file2.getBytes().length);
                assertEquals("image/jpg", file2.getMimeType());
                assertEquals("filename2", file2.getName());
                assertEquals(40L, file2.getSize());
                assertEquals(mockUri2Path, file2.getPath());
                return null;
              }));
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

      assertTrue(callbackCalled[0]);
    }
  }

  // This test was created when error handling was moved from FileUtils.java to
  // FileSelectorApiImpl.java
  // in https://github.com/flutter/packages/pull/8184, so as to maintain the existing test.
  // The behavior is actually an error case and should be fixed,
  // see: https://github.com/flutter/flutter/issues/159568.
  // Remove when fixed!
  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void
      openFileThrowsNullPointerException_whenSecurityExceptionInGetPathFromCopyOfFileFromUri()
          throws FileNotFoundException {

    try (MockedStatic<FileUtils> mockedFileUtils = mockStatic(FileUtils.class)) {

      final ContentResolver mockContentResolver = mock(ContentResolver.class);

      final Uri mockUri = mock(Uri.class);
      final String mockUriPath = "some/path/";
      mockedFileUtils
          .when(() -> FileUtils.getPathFromCopyOfFileFromUri(any(Context.class), eq(mockUri)))
          .thenThrow(SecurityException.class);
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

      fileSelectorApi.openFiles(
          null,
          new FileTypes(Collections.emptyList(), Collections.emptyList()),
          ResultCompat.asCompatCallback(
              (reply) -> {
                return null;
              }));
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

      assertThrows(
          NullPointerException.class,
          () ->
              listenerArgumentCaptor
                  .getValue()
                  .onActivityResult(222, Activity.RESULT_OK, resultMockIntent));
    }
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void
      openFileReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri()
          throws FileNotFoundException {
    try (MockedStatic<FileUtils> mockedFileUtils = mockStatic(FileUtils.class)) {
      final ContentResolver mockContentResolver = mock(ContentResolver.class);

      final Uri mockUri = mock(Uri.class);
      mockedFileUtils
          .when(() -> FileUtils.getPathFromCopyOfFileFromUri(any(Context.class), eq(mockUri)))
          .thenThrow(IllegalArgumentException.class);
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

      final Boolean[] callbackCalled = new Boolean[1];
      fileSelectorApi.openFile(
          null,
          new FileTypes(Collections.emptyList(), Collections.emptyList()),
          ResultCompat.asCompatCallback(
              (reply) -> {
                callbackCalled[0] = true;
                final FileResponse file = reply.getOrNull();
                assertNotNull(file);
                assertNotNull(file.getFileSelectorNativeException());
                assertEquals(FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH, file.getPath());
                return null;
              }));
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE);

      verify(mockActivity).startActivityForResult(mockIntent, 221);

      final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
          ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

      final Intent resultMockIntent = mock(Intent.class);
      when(resultMockIntent.getData()).thenReturn(mockUri);
      listenerArgumentCaptor.getValue().onActivityResult(221, Activity.RESULT_OK, resultMockIntent);

      assertTrue(callbackCalled[0]);
    }
  }

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void
      openFilesReturnsNativeException_whenIllegalArgumentExceptionInGetPathFromCopyOfFileFromUri()
          throws FileNotFoundException {
    try (MockedStatic<FileUtils> mockedFileUtils = mockStatic(FileUtils.class)) {

      final ContentResolver mockContentResolver = mock(ContentResolver.class);

      final Uri mockUri = mock(Uri.class);
      final String mockUriPath = "some/path/";
      mockedFileUtils
          .when(() -> FileUtils.getPathFromCopyOfFileFromUri(any(Context.class), eq(mockUri)))
          .thenThrow(IllegalArgumentException.class);
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

      final Boolean[] callbackCalled = new Boolean[1];
      fileSelectorApi.openFiles(
          null,
          new FileTypes(Collections.emptyList(), Collections.emptyList()),
          ResultCompat.asCompatCallback(
              (reply) -> {
                callbackCalled[0] = true;
                final List<FileResponse> files = reply.getOrNull();
                assertNotNull(files);
                final FileResponse file = files.get(0);
                assertNotNull(file.getFileSelectorNativeException());
                assertEquals(FileUtils.FILE_SELECTOR_EXCEPTION_PLACEHOLDER_PATH, file.getPath());
                return null;
              }));
      verify(mockIntent).addCategory(Intent.CATEGORY_OPENABLE);
      verify(mockIntent).putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);

      verify(mockActivity).startActivityForResult(mockIntent, 222);

      final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
          ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
      verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

      final Intent resultMockIntent = mock(Intent.class);
      final ClipData mockClipData = mock(ClipData.class);
      when(mockClipData.getItemCount()).thenReturn(1);

      final ClipData.Item mockClipDataItem = mock(ClipData.Item.class);
      when(mockClipDataItem.getUri()).thenReturn(mockUri);
      when(mockClipData.getItemAt(0)).thenReturn(mockClipDataItem);

      when(resultMockIntent.getClipData()).thenReturn(mockClipData);

      listenerArgumentCaptor.getValue().onActivityResult(222, Activity.RESULT_OK, resultMockIntent);

      assertTrue(callbackCalled[0]);
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
                (version) -> Build.VERSION.SDK_INT >= version);

        final Boolean[] callbackCalled = new Boolean[1];
        fileSelectorApi.getDirectoryPath(
            null,
            ResultCompat.asCompatCallback(
                reply -> {
                  callbackCalled[0] = true;
                  assertEquals(mockUriPath, reply.getOrNull());
                  return null;
                }));

        verify(mockActivity).startActivityForResult(mockIntent, 223);

        final ArgumentCaptor<PluginRegistry.ActivityResultListener> listenerArgumentCaptor =
            ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
        verify(mockActivityBinding).addActivityResultListener(listenerArgumentCaptor.capture());

        final Intent resultMockIntent = mock(Intent.class);
        when(resultMockIntent.getData()).thenReturn(mockUri);
        listenerArgumentCaptor
            .getValue()
            .onActivityResult(223, Activity.RESULT_OK, resultMockIntent);

        assertTrue(callbackCalled[0]);
      }
    }
  }
}
