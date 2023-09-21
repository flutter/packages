// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.exoplayer2.database.DatabaseProvider;
import com.google.android.exoplayer2.database.StandaloneDatabaseProvider;
import com.google.android.exoplayer2.upstream.cache.LeastRecentlyUsedCacheEvictor;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;
import java.io.File;

/**
 * The `VideoCache` class provides a simple interface for caching video content using the ExoPlayer
 * library. It utilizes a combination of a local cache and database with the ability to store and retrieve data from the cache.
 *  * Usage:
 * ```java
 * long maxCacheSize = 100 * 1024 * 1024; // 100MB
 * SimpleCache cache = VideoCache.getInstance(context, maxCacheSize);
 * ```
 * */

public class VideoCache {
  private static final String cacheFolder = "exoCache";
  private static SimpleCache sDownloadCache;

    /**
     * Returns a shared instance of the ExoPlayer `SimpleCache`. If the cache has not been created
     * yet, it initializes the cache with the provided `maxCacheSize`.
     *
     * @param context      The Android application context.
     * @param maxCacheSize The maximum size of the cache in bytes.
     * @return The shared instance of the ExoPlayer `SimpleCache`.
     */

  @NonNull
  public static SimpleCache getInstance(@NonNull Context context, long maxCacheSize) {
    DatabaseProvider databaseProvider = new StandaloneDatabaseProvider(context);

    if (sDownloadCache == null)
      sDownloadCache =
          new SimpleCache(
              new File(context.getCacheDir(), cacheFolder),
              new LeastRecentlyUsedCacheEvictor(maxCacheSize),
              databaseProvider);
    return sDownloadCache;
  }

      /**
     * Clears the video cache, including all cached video files. This function ensures that any
     * previously cached video files are deleted from the cache directory.
     *
     * @param context The Android application context.
     * @return `true` if the cache is cleared successfully, `false` otherwise.
     */

  public static boolean clearVideoCache(@NonNull Context context) {
    try {
      File dir = new File(context.getCacheDir(), cacheFolder);
      return deleteDir(dir);
    } catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }

  private static boolean deleteDir(@Nullable File dir) {
    if (dir != null && dir.isDirectory()) {
      String[] children = dir.list();
      assert children != null;
      for (String child : children) {
        boolean success = deleteDir(new File(dir, child));
        if (!success) {
          return false;
        }
      }
      return dir.delete();
    } else if (dir != null && dir.isFile()) {
      return dir.delete();
    } else {
      return false;
    }
  }
}
