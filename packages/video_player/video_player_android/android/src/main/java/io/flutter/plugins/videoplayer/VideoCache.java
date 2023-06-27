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

  public @NonNull static SimpleCache getInstance(Context context, long maxCacheSize) {
    DatabaseProvider databaseProvider = new StandaloneDatabaseProvider(context);

    if (sDownloadCache == null)
      sDownloadCache =
          new SimpleCache(
              new File(context.getCacheDir(), cacheFolder),
              new LeastRecentlyUsedCacheEvictor(maxCacheSize),
              databaseProvider);
    return sDownloadCache;
  }

  public @Nullable
  static void clearVideoCache(Context context) {
    try {
      File dir = new File(context.getCacheDir(), cacheFolder);
      deleteDir(dir);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  @NonNull
  private static boolean deleteDir(File dir) {
    if (dir != null && dir.isDirectory()) {
      String[] children = dir.list();
      for (int i = 0; i < children.length; i++) {
        boolean success = deleteDir(new File(dir, children[i]));
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
