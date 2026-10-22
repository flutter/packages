// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.MatrixCursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Size;
import java.io.File;
import java.io.IOException;
import java.util.List;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
public class RecentMediaLoaderTest {
  private static final RecentMediaRequest ALL_MEDIA_REQUEST =
      new RecentMediaRequest(
          /* limit */ 3L,
          /* includeImages */ true,
          /* includeVideos */ true,
          /* width */ 100L,
          /* height */ 200L);

  @Rule public TemporaryFolder temporaryFolder = new TemporaryFolder();

  ContentResolver mockResolver;
  File cacheDir;
  RecentMediaLoader loader;

  @Before
  public void setUp() throws IOException {
    Context mockContext = mock(Context.class);
    mockResolver = mock(ContentResolver.class);
    cacheDir = temporaryFolder.newFolder("cache");
    when(mockContext.getContentResolver()).thenReturn(mockResolver);
    when(mockContext.getCacheDir()).thenReturn(cacheDir);
    loader = new RecentMediaLoader(mockContext);
  }

  private static MatrixCursor createCursor(Object[]... rows) {
    MatrixCursor cursor =
        new MatrixCursor(
            new String[] {
              MediaStore.Files.FileColumns._ID,
              MediaStore.Files.FileColumns.MEDIA_TYPE,
              MediaStore.Files.FileColumns.DATE_MODIFIED
            });
    for (Object[] row : rows) {
      cursor.addRow(row);
    }
    return cursor;
  }

  private static Bitmap createBitmap() {
    return Bitmap.createBitmap(10, 10, Bitmap.Config.ARGB_8888);
  }

  private static Uri imageUri(long id) {
    return ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id);
  }

  private static Uri videoUri(long id) {
    return ContentUris.withAppendedId(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, id);
  }

  @Test
  @Config(sdk = 30)
  public void load_onApi30_queriesWithBundleLimitAndOrder() {
    when(mockResolver.query(any(Uri.class), any(String[].class), any(Bundle.class), any()))
        .thenReturn(createCursor());

    loader.load(ALL_MEDIA_REQUEST);

    ArgumentCaptor<Bundle> queryArgs = ArgumentCaptor.forClass(Bundle.class);
    verify(mockResolver)
        .query(
            eq(MediaStore.Files.getContentUri("external")),
            any(String[].class),
            queryArgs.capture(),
            any());
    Bundle args = queryArgs.getValue();
    assertEquals(3, args.getInt(ContentResolver.QUERY_ARG_LIMIT));
    assertEquals(
        "date_added DESC, _id DESC", args.getString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER));
    assertEquals("media_type IN (?,?)", args.getString(ContentResolver.QUERY_ARG_SQL_SELECTION));
    assertArrayEquals(
        new String[] {
          String.valueOf(MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE),
          String.valueOf(MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO)
        },
        args.getStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS));
  }

  @Test
  @Config(sdk = 30)
  public void load_withOnlyVideos_filtersByVideoMediaType() {
    when(mockResolver.query(any(Uri.class), any(String[].class), any(Bundle.class), any()))
        .thenReturn(createCursor());

    loader.load(new RecentMediaRequest(1L, false, true, 100L, 100L));

    ArgumentCaptor<Bundle> queryArgs = ArgumentCaptor.forClass(Bundle.class);
    verify(mockResolver).query(any(Uri.class), any(String[].class), queryArgs.capture(), any());
    assertEquals(
        "media_type IN (?)",
        queryArgs.getValue().getString(ContentResolver.QUERY_ARG_SQL_SELECTION));
    assertArrayEquals(
        new String[] {String.valueOf(MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO)},
        queryArgs.getValue().getStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS));
  }

  @Test
  @Config(sdk = 30)
  public void load_returnsThumbnailsInQueryOrder() throws IOException {
    when(mockResolver.query(any(Uri.class), any(String[].class), any(Bundle.class), any()))
        .thenReturn(
            createCursor(
                new Object[] {7L, MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO, 1000L},
                new Object[] {5L, MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE, 2000L}));
    when(mockResolver.loadThumbnail(any(Uri.class), any(Size.class), any()))
        .thenAnswer(invocation -> createBitmap());

    List<RecentMediaItem> items = loader.load(ALL_MEDIA_REQUEST);

    assertEquals(2, items.size());
    assertEquals(RecentMediaKind.VIDEO, items.get(0).getKind());
    assertEquals(
        new File(cacheDir, "recent_media_7_100x200_1000.jpg").getAbsolutePath(),
        items.get(0).getPath());
    assertEquals(RecentMediaKind.IMAGE, items.get(1).getKind());
    assertEquals(
        new File(cacheDir, "recent_media_5_100x200_2000.jpg").getAbsolutePath(),
        items.get(1).getPath());
    assertTrue(new File(items.get(0).getPath()).exists());
    assertTrue(new File(items.get(1).getPath()).exists());
    assertFalse(new File(items.get(0).getPath() + ".tmp").exists());
    verify(mockResolver).loadThumbnail(eq(videoUri(7L)), eq(new Size(100, 200)), any());
    verify(mockResolver).loadThumbnail(eq(imageUri(5L)), eq(new Size(100, 200)), any());
  }

  @Test
  @Config(sdk = 30)
  public void load_reusesExistingThumbnailFile() throws IOException {
    File existing = new File(cacheDir, "recent_media_5_100x200_2000.jpg");
    assertTrue(existing.createNewFile());
    when(mockResolver.query(any(Uri.class), any(String[].class), any(Bundle.class), any()))
        .thenReturn(
            createCursor(new Object[] {5L, MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE, 2000L}));

    List<RecentMediaItem> items = loader.load(ALL_MEDIA_REQUEST);

    assertEquals(1, items.size());
    assertEquals(existing.getAbsolutePath(), items.get(0).getPath());
    verify(mockResolver, never()).loadThumbnail(any(Uri.class), any(Size.class), any());
  }

  @Test
  @Config(sdk = 30)
  public void load_skipsItemsWhoseThumbnailFails() throws IOException {
    when(mockResolver.query(any(Uri.class), any(String[].class), any(Bundle.class), any()))
        .thenReturn(
            createCursor(
                new Object[] {7L, MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE, 1000L},
                new Object[] {5L, MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE, 2000L}));
    when(mockResolver.loadThumbnail(eq(imageUri(7L)), any(Size.class), any()))
        .thenThrow(new IOException("missing"));
    when(mockResolver.loadThumbnail(eq(imageUri(5L)), any(Size.class), any()))
        .thenAnswer(invocation -> createBitmap());

    List<RecentMediaItem> items = loader.load(ALL_MEDIA_REQUEST);

    assertEquals(1, items.size());
    assertEquals(
        new File(cacheDir, "recent_media_5_100x200_2000.jpg").getAbsolutePath(),
        items.get(0).getPath());
  }

  @Test
  @Config(sdk = 30)
  public void load_returnsEmptyListWhenQueryReturnsNull() {
    when(mockResolver.query(any(Uri.class), any(String[].class), any(Bundle.class), any()))
        .thenReturn(null);

    assertTrue(loader.load(ALL_MEDIA_REQUEST).isEmpty());
  }

  @Test
  @Config(sdk = 28)
  @SuppressWarnings("deprecation")
  public void load_onApi28_usesSortOrderLimitAndLegacyThumbnails() {
    when(mockResolver.query(
            any(Uri.class), any(String[].class), anyString(), any(String[].class), anyString()))
        .thenReturn(
            createCursor(
                new Object[] {7L, MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO, 1000L},
                new Object[] {5L, MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE, 2000L}));

    try (MockedStatic<MediaStore.Images.Thumbnails> imageThumbnails =
            Mockito.mockStatic(MediaStore.Images.Thumbnails.class);
        MockedStatic<MediaStore.Video.Thumbnails> videoThumbnails =
            Mockito.mockStatic(MediaStore.Video.Thumbnails.class)) {
      imageThumbnails
          .when(
              () ->
                  MediaStore.Images.Thumbnails.getThumbnail(
                      any(), anyLong(), eq(MediaStore.Images.Thumbnails.MINI_KIND), any()))
          .thenAnswer(invocation -> createBitmap());
      videoThumbnails
          .when(
              () ->
                  MediaStore.Video.Thumbnails.getThumbnail(
                      any(), anyLong(), eq(MediaStore.Video.Thumbnails.MINI_KIND), any()))
          .thenAnswer(invocation -> createBitmap());

      List<RecentMediaItem> items = loader.load(ALL_MEDIA_REQUEST);

      assertEquals(2, items.size());
      assertEquals(RecentMediaKind.VIDEO, items.get(0).getKind());
      assertEquals(RecentMediaKind.IMAGE, items.get(1).getKind());
      videoThumbnails.verify(
          () ->
              MediaStore.Video.Thumbnails.getThumbnail(
                  eq(mockResolver), eq(7L), eq(MediaStore.Video.Thumbnails.MINI_KIND), any()));
      imageThumbnails.verify(
          () ->
              MediaStore.Images.Thumbnails.getThumbnail(
                  eq(mockResolver), eq(5L), eq(MediaStore.Images.Thumbnails.MINI_KIND), any()));
    }

    ArgumentCaptor<String> sortOrder = ArgumentCaptor.forClass(String.class);
    verify(mockResolver)
        .query(
            eq(MediaStore.Files.getContentUri("external")),
            any(String[].class),
            eq("media_type IN (?,?)"),
            any(String[].class),
            sortOrder.capture());
    assertEquals("date_added DESC, _id DESC LIMIT 3", sortOrder.getValue());
  }
}
