// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSource;
import com.google.android.exoplayer2.upstream.FileDataSource;
import com.google.android.exoplayer2.upstream.cache.CacheDataSink;
import com.google.android.exoplayer2.upstream.cache.CacheDataSource;
import com.google.android.exoplayer2.upstream.cache.SimpleCache;

/**
 * CacheDataSourceFactory is a DataSource.Factory implementation that creates a caching data source
 * for media content. It utilizes a combination of a local cache and an upstream data source to
 * provide efficient data retrieval with the ability to store and retrieve data from the cache.
 * The class is designed to be used with ExoPlayer or similar media frameworks to enable caching
 * of media content.
 *
 * Usage:
 * CacheDataSourceFactory cacheDataSourceFactory = new CacheDataSourceFactory(
 *      context,
 *      maxCacheSize,
 *      maxFileSize,
 *      upstreamDataSource
 * );
 * DataSource dataSource = cacheDataSourceFactory.createDataSource();
 *
 * Note: This class requires the use of ExoPlayer library or an equivalent media framework.
 */

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

/**
 * Setting the flags CacheDataSource.FLAG_BLOCK_ON_CACHE and
 * CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR in the CacheDataSource class affects the
 * caching behavior during data retrieval.
 *
 * 1. CacheDataSource.FLAG_BLOCK_ON_CACHE:
 *    - Impact: When set, the CacheDataSource will prioritize serving data
 *      from the cache, blocking (pausing) the data source from reading from the upstream
 *      (non-cache) source until the requested data is available in the cache. It reduces
 *      dependency on the upstream source for data, improving efficiency and reducing
 *      network usage for frequently accessed content.
 *
 * 2. CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR:
 *    - Impact: When set, the CacheDataSource will bypass the cache and read
 *      data directly from the upstream source if an error occurs while accessing the cache.
 *      It won't attempt to retrieve data from the cache even if it's available. This allows
 *      prioritizing real-time data from the upstream source in case of cache-related errors
 *      or corruptions, ensuring data integrity and preventing the usage of potentially
 *      compromised cached data.
 *
 */

    return new CacheDataSource(
        downloadCache,
        defaultDatasourceFactory.createDataSource(),
        new FileDataSource(),
        new CacheDataSink(downloadCache, maxFileSize),
        CacheDataSource.FLAG_BLOCK_ON_CACHE | CacheDataSource.FLAG_IGNORE_CACHE_ON_ERROR,
        null);
  }
}
