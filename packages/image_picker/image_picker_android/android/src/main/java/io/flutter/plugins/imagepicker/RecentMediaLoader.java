// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.util.Size;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

/** Loads OS-generated thumbnails of the most recent items in the device's media library. */
class RecentMediaLoader {
  private static final String TAG = "RecentMediaLoader";
  private static final int JPEG_QUALITY = 90;

  private final @NonNull Context context;

  RecentMediaLoader(@NonNull Context context) {
    this.context = context;
  }

  /**
   * Returns thumbnails of the most recent media items, newest first.
   *
   * <p>Items whose thumbnail cannot be generated are skipped. Thumbnails are written to the cache
   * directory with a name derived from the item and the requested size, so repeated calls reuse
   * existing files.
   */
  @NonNull
  List<RecentMediaItem> load(@NonNull RecentMediaRequest request) {
    List<RecentMediaItem> items = new ArrayList<>();
    try (Cursor cursor = query(request)) {
      if (cursor == null) {
        return items;
      }
      int idColumn = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns._ID);
      int mediaTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.MEDIA_TYPE);
      int modifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.Files.FileColumns.DATE_MODIFIED);
      while (cursor.moveToNext()) {
        long id = cursor.getLong(idColumn);
        RecentMediaKind kind =
            cursor.getInt(mediaTypeColumn) == MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
                ? RecentMediaKind.VIDEO
                : RecentMediaKind.IMAGE;
        String path =
            getThumbnailPath(
                id,
                kind,
                cursor.getLong(modifiedColumn),
                (int) request.getWidth(),
                (int) request.getHeight());
        if (path != null) {
          items.add(new RecentMediaItem(path, kind));
        }
      }
    }
    return items;
  }

  private @Nullable Cursor query(@NonNull RecentMediaRequest request) {
    Uri uri = MediaStore.Files.getContentUri("external");
    String[] projection = {
      MediaStore.Files.FileColumns._ID,
      MediaStore.Files.FileColumns.MEDIA_TYPE,
      MediaStore.Files.FileColumns.DATE_MODIFIED
    };
    List<String> mediaTypes = new ArrayList<>();
    if (request.getIncludeImages()) {
      mediaTypes.add(String.valueOf(MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE));
    }
    if (request.getIncludeVideos()) {
      mediaTypes.add(String.valueOf(MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO));
    }
    if (mediaTypes.isEmpty()) {
      return null;
    }
    String selection =
        MediaStore.Files.FileColumns.MEDIA_TYPE
            + " IN ("
            + TextUtils.join(",", Collections.nCopies(mediaTypes.size(), "?"))
            + ")";
    String[] selectionArgs = mediaTypes.toArray(new String[0]);
    String sortOrder =
        MediaStore.Files.FileColumns.DATE_ADDED
            + " DESC, "
            + MediaStore.Files.FileColumns._ID
            + " DESC";
    ContentResolver resolver = context.getContentResolver();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      Bundle queryArgs = new Bundle();
      queryArgs.putString(ContentResolver.QUERY_ARG_SQL_SELECTION, selection);
      queryArgs.putStringArray(ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS, selectionArgs);
      queryArgs.putString(ContentResolver.QUERY_ARG_SQL_SORT_ORDER, sortOrder);
      queryArgs.putInt(ContentResolver.QUERY_ARG_LIMIT, (int) request.getLimit());
      return resolver.query(uri, projection, queryArgs, null);
    }
    // Before API 30, MediaProvider accepts a LIMIT clause appended to the sort order.
    return resolver.query(
        uri, projection, selection, selectionArgs, sortOrder + " LIMIT " + request.getLimit());
  }

  private @Nullable String getThumbnailPath(
      long id, @NonNull RecentMediaKind kind, long dateModified, int width, int height) {
    File file =
        new File(
            context.getCacheDir(),
            String.format(
                Locale.US, "recent_media_%d_%dx%d_%d.jpg", id, width, height, dateModified));
    if (file.exists()) {
      return file.getAbsolutePath();
    }

    Bitmap bitmap;
    try {
      bitmap =
          Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
              ? loadThumbnail(id, kind, width, height)
              : loadThumbnailPreApi29(id, kind);
    } catch (IOException | RuntimeException e) {
      Log.w(TAG, "Unable to load thumbnail for media " + id, e);
      return null;
    }
    if (bitmap == null) {
      return null;
    }

    // Write to a temporary file first, so that an interrupted write is never reused.
    File tempFile = new File(file.getPath() + ".tmp");
    try (FileOutputStream outputStream = new FileOutputStream(tempFile)) {
      if (!bitmap.compress(Bitmap.CompressFormat.JPEG, JPEG_QUALITY, outputStream)) {
        throw new IOException("Bitmap compression failed");
      }
    } catch (IOException e) {
      Log.w(TAG, "Unable to write thumbnail for media " + id, e);
      // noinspection ResultOfMethodCallIgnored
      tempFile.delete();
      return null;
    } finally {
      bitmap.recycle();
    }
    if (!tempFile.renameTo(file)) {
      // noinspection ResultOfMethodCallIgnored
      tempFile.delete();
      return null;
    }
    return file.getAbsolutePath();
  }

  @RequiresApi(Build.VERSION_CODES.Q)
  private @NonNull Bitmap loadThumbnail(
      long id, @NonNull RecentMediaKind kind, int width, int height) throws IOException {
    Uri contentUri =
        kind == RecentMediaKind.VIDEO
            ? MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            : MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
    return context
        .getContentResolver()
        .loadThumbnail(ContentUris.withAppendedId(contentUri, id), new Size(width, height), null);
  }

  @SuppressWarnings("deprecation")
  private @Nullable Bitmap loadThumbnailPreApi29(long id, @NonNull RecentMediaKind kind) {
    ContentResolver resolver = context.getContentResolver();
    if (kind == RecentMediaKind.VIDEO) {
      return MediaStore.Video.Thumbnails.getThumbnail(
          resolver, id, MediaStore.Video.Thumbnails.MINI_KIND, null);
    }
    return MediaStore.Images.Thumbnails.getThumbnail(
        resolver, id, MediaStore.Images.Thumbnails.MINI_KIND, null);
  }
}
