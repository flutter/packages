// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.file_selector_android;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.net.Uri;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;
import java.io.FileNotFoundException;
import java.util.Collections;
import java.util.List;
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

  @Mock FileSelectorApiImpl.NativeObjectFactory mockObjectFactory;

  @Mock public ActivityPluginBinding mockActivityBinding;

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void openFileReturnsSuccessfully() {
    final Uri mockUri = mock(Uri.class);
    final String mockUriPath = "/some/path";
    when(mockUri.toString()).thenReturn(mockUriPath);

    when(mockObjectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT)).thenReturn(mockIntent);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    final FileSelectorApiImpl fileSelectorApi =
        new FileSelectorApiImpl(mockActivityBinding, mockObjectFactory);

    final Boolean[] callbackCalled = new Boolean[1];
    fileSelectorApi.openFile(
        null,
        new FileTypes(Collections.emptyList(), Collections.emptyList()),
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              assertEquals(mockUriPath, reply.getOrNull());
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

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void openFilesReturnsSuccessfully() throws FileNotFoundException {
    final Uri mockUri = mock(Uri.class);
    final String mockUriPath = "some/path/";
    when(mockUri.toString()).thenReturn(mockUriPath);

    final Uri mockUri2 = mock(Uri.class);
    final String mockUri2Path = "some/other/path/";
    when(mockUri2.toString()).thenReturn(mockUri2Path);

    when(mockObjectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT)).thenReturn(mockIntent);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    final FileSelectorApiImpl fileSelectorApi =
        new FileSelectorApiImpl(mockActivityBinding, mockObjectFactory);

    final Boolean[] callbackCalled = new Boolean[1];
    fileSelectorApi.openFiles(
        null,
        new FileTypes(Collections.emptyList(), Collections.emptyList()),
        ResultCompat.asCompatCallback(
            reply -> {
              callbackCalled[0] = true;
              List<String> fileList = reply.getOrNull();
              assertEquals(mockUriPath, fileList.get(0));
              assertEquals(mockUri2Path, fileList.get(1));
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

  @SuppressWarnings({"rawtypes", "unchecked"})
  @Test
  public void getDirectoryPathReturnsSuccessfully() {
    final Uri mockUri = mock(Uri.class);
    final String mockUriPath = "some/path/";
    when(mockUri.toString()).thenReturn(mockUriPath);

    when(mockObjectFactory.newIntent(Intent.ACTION_OPEN_DOCUMENT_TREE)).thenReturn(mockIntent);
    when(mockActivityBinding.getActivity()).thenReturn(mockActivity);
    final FileSelectorApiImpl fileSelectorApi =
        new FileSelectorApiImpl(mockActivityBinding, mockObjectFactory);

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
    listenerArgumentCaptor.getValue().onActivityResult(223, Activity.RESULT_OK, resultMockIntent);

    assertTrue(callbackCalled[0]);
  }
}
