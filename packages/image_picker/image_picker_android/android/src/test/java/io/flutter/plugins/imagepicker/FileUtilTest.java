// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static java.nio.charset.StandardCharsets.UTF_8;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
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
import android.os.Build;
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
import org.robolectric.shadows.ShadowMimeTypeMap;

@RunWith(RobolectricTestRunner.class)
public class FileUtilTest {

  private Context context;
  private FileUtils fileUtils;
  ShadowContentResolver shadowContentResolver;

  @Before
  @SuppressWarnings("deprecation") // shadowOf(MimeTypeMap)
  public void before() {
    context = ApplicationProvider.getApplicationContext();
    shadowContentResolver = shadowOf(context.getContentResolver());
    fileUtils = new FileUtils();
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
      // On S and higher robolectric does not need this setup because all the mappings are
      // present already.
      //noinspection deprecation
      ShadowMimeTypeMap mimeTypeMap = shadowOf(MimeTypeMap.getSingleton());
      mimeTypeMap.addExtensionMimeTypeMapping("jpg", "image/jpeg");
      mimeTypeMap.addExtensionMimeTypeMapping("png", "image/png");
      mimeTypeMap.addExtensionMimeTypeMapping("webp", "image/webp");
    }
  }

  @Test
  public void FileUtil_GetPathFromUri() throws IOException {
    Uri uri = Uri.parse("content://dummy/dummy.png");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    File file = new File(path);
    int size = (int) file.length();
    byte[] bytes = new byte[size];

    BufferedInputStream buf = new BufferedInputStream(new FileInputStream(file));
    buf.read(bytes, 0, bytes.length);
    buf.close();

    assertTrue(bytes.length > 0);
    String imageStream = new String(bytes, UTF_8);
    assertEquals("imageStream", imageStream);
  }

  @Test
  public void FileUtil_GetPathFromUri_securityException() throws IOException {
    Uri uri = Uri.parse("content://dummy/dummy.png");

    ContentResolver mockContentResolver = mock(ContentResolver.class);
    when(mockContentResolver.openInputStream(any(Uri.class))).thenThrow(SecurityException.class);

    Context mockContext = mock(Context.class);
    when(mockContext.getContentResolver()).thenReturn(mockContentResolver);

    String path = fileUtils.getPathFromUri(mockContext, uri);

    assertNull(path);
  }

  @Test
  public void FileUtil_getImageExtension() throws IOException {
    Uri uri = Uri.parse("content://dummy/dummy.png");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    assertTrue(path.endsWith(".jpg"));
  }

  @Test
  public void FileUtil_getImageName() throws IOException {
    Uri uri = MockContentProvider.PNG_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    assertTrue(path.endsWith("a.b.png"));
  }

  @Test
  public void FileUtil_getPathFromUri_noExtensionInBaseName() throws IOException {
    Uri uri = MockContentProvider.NO_EXTENSION_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    assertTrue(path.endsWith("abc.png"));
  }

  @Test
  public void FileUtil_getImageName_mismatchedType() throws IOException {
    Uri uri = MockContentProvider.WEBP_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    assertTrue(path.endsWith("c.d.webp"));
  }

  @Test
  public void getPathFromUri_sanitizesPathIndirection() {
    Uri uri = Uri.parse(MockMaliciousContentProvider.PNG_URI);
    Robolectric.buildContentProvider(MockMaliciousContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("fileStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    assertNotNull(path);
    assertTrue(path.endsWith("_bar.png"));
    assertFalse(path.contains(".."));
  }

  @Test
  public void FileUtil_getImageName_unknownType() throws IOException {
    Uri uri = MockContentProvider.UNKNOWN_URI;
    Robolectric.buildContentProvider(MockContentProvider.class).create("dummy");
    shadowContentResolver.registerInputStream(
        uri, new ByteArrayInputStream("imageStream".getBytes(UTF_8)));
    String path = fileUtils.getPathFromUri(context, uri);
    assertTrue(path.endsWith("e.f.g"));
  }

  private static class MockContentProvider extends ContentProvider {
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

  // Mocks a malicious content provider attempting to use path indirection to modify files outside
  // of the intended directory.
  // See https://developer.android.com/privacy-and-security/risks/untrustworthy-contentprovider-provided-filename#don%27t-trust-user-input.
  private static class MockMaliciousContentProvider extends ContentProvider {
    public static String PNG_URI = "content://dummy/a.png";

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
      cursor.addRow(new Object[] {"foo/../..bar.png"});
      return cursor;
    }

    @Nullable
    @Override
    public String getType(@NonNull Uri uri) {
      return "image/png";
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
