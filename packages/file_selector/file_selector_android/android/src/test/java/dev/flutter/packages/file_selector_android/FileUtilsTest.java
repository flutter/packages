// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.file_selector_android;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.robolectric.Shadows.shadowOf;

import android.content.ContentProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.MatrixCursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.webkit.MimeTypeMap;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.test.core.app.ApplicationProvider;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.shadows.ShadowContentResolver;
import org.robolectric.shadows.ShadowEnvironment;
import org.robolectric.shadows.ShadowMimeTypeMap;

@RunWith(RobolectricTestRunner.class)
public class FileUtilTest {

  private Context context;
  final private String externalStorageDirectoryPath = ShadowEnvironment.getExternalStorageDirectory();
  ShadowContentResolver shadowContentResolver;

  @Before
  public void before() {
    context = ApplicationProvider.getApplicationContext();
    shadowContentResolver = shadowOf(context.getContentResolver());
    ShadowMimeTypeMap mimeTypeMap = shadowOf(MimeTypeMap.getSingleton());
    mimeTypeMap.addExtensionMimeTypMapping("txt", "document/txt");
    mimeTypeMap.addExtensionMimeTypMapping("jpg", "image/jpeg");
    mimeTypeMap.addExtensionMimeTypMapping("png", "image/png");
    mimeTypeMap.addExtensionMimeTypMapping("webp", "image/webp");
  }

  @Test
  public void getPathFromUri_returnsExpectedPathForExternalDocumentUri() {
    Uri uri = Uri.parse("content://com.android.externalstorage.documents/tree/primary%3ADocuments%2Ftest");
    String path = FileUtils.getPathFromUri(context, uri);
    String expectedPath = externalStorageDirectoryPath + "document.txt";
    assertEquals(path, expectedPath);
  }

 @Test
  public void getPathFromUri_returnsExpectedPathForMediaDocumentUri() {
    Uri uri = Uri.parse("content://com.android.providers.media.documents/document/image:1");
    String path = FileUtils.getPathFromUri(context, uri);
    String expectedPath = ""; // TODO
    assertEquals(path, expectedPath);
  }

  @Test
  public void getPathFromUri_throwExceptionForExternalDocumentUriWithNonPrimaryStorageVolume() {
    Uri uri = Uri.parse("content://com.android.externalstorage.documents/tree/emulated%3ADocuments%2Ftest");
    assertThrows(UnsupportedOperationException.class, () -> FileUtils.getPathFromUri(context, uri));
  }

  @Test
  public void getPathFromUri_throwExceptionForUriWithUnhandledAuthority() {
    Uri uri = Uri.parse("content://com.unsupported.authority/tree/primary%3ADocuments%2Ftest");
    assertThrows(UnsupportedOperationException.class, () -> FileUtils.getPathFromUri(context, uri));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsPathWithContent() throws IOException {
    Uri uri = Uri.parse("content://dummy/dummy.png");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = FileUtils.getPathFromCopyOfFileFromUri(context, uri);
    File file = new File(path);
    int size = (int) file.length();
    byte[] bytes = new byte[size];

    BufferedInputStream buf = new BufferedInputStream(new FileInputStream(file));
    buf.read(bytes, 0, bytes.length);
    buf.close();

    assertTrue(bytes.length > 0);
    String fileStream = new String(bytes, UTF_8);
    assertEquals("fileStream", fileStream);
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsNullPathWhenSecurityExceptionThrown() throws IOException {
    Uri uri = Uri.parse("content://dummy/dummy.png");

    ContentResolver mockContentResolver = mock(ContentResolver.class);
    when(mockContentResolver.openInputStream(any(Uri.class))).thenThrow(SecurityException.class);

    Context mockContext = mock(Context.class);
    when(mockContext.getContentResolver()).thenReturn(mockContentResolver);

    String path = fileUtils.getPathFromCopyOfFileFromUri(mockContext, uri);

    assertNull(path);
  }

  @Test
  public void getFileExtension_returnsExpectedTextFileExtension() throws IOException {
    Uri uri = Uri.parse("content://document/dummy.txt");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith(".txt"));
  }

  @Test
  public void getFileExtension_returnsExpectedImageExtension() throws IOException {
    Uri uri = Uri.parse("content://dummy/dummy.png");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith(".jpg"));
  }

  @Test
  public void getFileName_returnsExpectedName() throws IOException {
    Uri uri = MockContentProvider.PNG_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("a.b.png"));
  }

  @Test
  public void  getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithNoExtensionInBaseName() throws IOException {
    Uri uri = MockContentProvider.NO_EXTENSION_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("abc.png"));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithMismatchedTypeToFile() throws IOException {
    Uri uri = MockContentProvider.WEBP_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("c.d.webp"));
  }

  @Test
  public void getPathFromCopyOfFileFromUri_returnsExpectedPathForUriWithUnknownType() throws IOException {
    Uri uri = MockContentProvider.UNKNOWN_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromCopyOfFileFromUri(context, uri);
    assertTrue(path.endsWith("e.f.g"));
  }

  private static class MockContentProvider extends ContentProvider {
    public static final Uri TXT_URI = Uri.parse("content://document/dummy.txt");
    public static final Uri PNG_URI = Uri.parse("content://dummy/a.b.png");
    public static final Uri WEBP_URI = Uri.parse("content://dummy/c.d.png");
    public static final Uri UNKNOWN_URI = Uri.parse("content://dummy/e.f.g");
    public static final Uri NO_EXTENSION_URI = Uri.parse("content://dummy/abc");

    @Override
    public boolean onCreate() {
      return true;
    }

    @Nullable
    @Override
    public Cursor query(
        @NonNull Uri uri,
        @Nullable String[] projection,
        @Nullable String selection,
        @Nullable String[] selectionArgs,
        @Nullable String sortOrder) {
      MatrixCursor cursor = new MatrixCursor(new String[] {MediaStore.MediaColumns.DISPLAY_NAME});
      cursor.addRow(new Object[] {uri.getLastPathSegment()});
      return cursor;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
      if (uri.equals(TXT_URI)) return "document/txt";
      if (uri.equals(PNG_URI)) return "image/png";
      if (uri.equals(WEBP_URI)) return "image/webp";
      if (uri.equals(NO_EXTENSION_URI)) return "image/png";
      return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull Uri uri, @Nullable ContentValues values) {
      return null;
    }

    @Override
    public int delete(
        @NonNull Uri uri, @Nullable String selection, @Nullable String[] selectionArgs) {
      return 0;
    }

    @Override
    public int update(
        @NonNull Uri uri,
        @Nullable ContentValues values,
        @Nullable String selection,
        @Nullable String[] selectionArgs) {
      return 0;
    }
  }
}
