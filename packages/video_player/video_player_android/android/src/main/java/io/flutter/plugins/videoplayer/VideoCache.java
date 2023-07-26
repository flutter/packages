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

public class VideoCache {
  private static final String cacheFolder = "exoCache";
  private static SimpleCache sDownloadCache;

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

  public static boolean clearVideoCache(@NonNull Context context) {
    try {
      File dir = new File(context.getCacheDir(), cacheFolder);
      return deleteDir(dir);
    } catch (Exception e) {
      return false;
      e.printStackTrace();
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
