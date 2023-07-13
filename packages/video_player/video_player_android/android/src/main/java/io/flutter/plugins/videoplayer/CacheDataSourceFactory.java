package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSource;
import com.google.android.exoplayer2.upstream.FileDataSource;
import com.google.android.exoplayer2.upstream.cache.CacheDataSink;
import com.google.android.exoplayer2.upstream.cache.CacheDataSource;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;

public class CacheDataSourceFactory implements DataSource.Factory {
  private final Context context;
  private final DefaultDataSource.Factory defaultDatasourceFactory;
  private final long maxFileSize, maxCacheSize;
  private static SimpleCache downloadCache;

  CacheDataSourceFactory(
      Context context, long maxCacheSize, long maxFileSize, DataSource.Factory upstreamDataSource) {
    super();
    this.context = context;
    this.maxCacheSize = maxCacheSize;
    this.maxFileSize = maxFileSize;
    defaultDatasourceFactory = new DefaultDataSource.Factory(this.context, upstreamDataSource);
  }

  @Override
  public @NonNull DataSource createDataSource() {

    if (downloadCache == null) {
      downloadCache = VideoCache.getInstance(context, maxCacheSize);
    }

    return new CacheDataSource(
        downloadCache,
        defaultDatasourceFactory.createDataSource(),
        new FileDataSource(),
        new CacheDataSink(downloadCache, maxFileSize),
        CacheDataSource.FLAG_BLOCK_ON_CACHE | CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR,
        null);
  }
}
