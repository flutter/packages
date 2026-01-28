// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.OptIn;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MimeTypes;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory;
import androidx.media3.exoplayer.source.MediaSource;
import java.util.Map;

final class HttpVideoAsset extends VideoAsset {
  @NonNull private final StreamingFormat streamingFormat;
  @NonNull private final Map<String, String> httpHeaders;
  @Nullable private final String userAgent;

  HttpVideoAsset(
      @Nullable String assetUrl,
      @NonNull StreamingFormat streamingFormat,
      @NonNull Map<String, String> httpHeaders,
      @Nullable String userAgent) {
    super(assetUrl);
    this.streamingFormat = streamingFormat;
    this.httpHeaders = httpHeaders;
    this.userAgent = userAgent;
  }

  @NonNull
  @Override
  public MediaItem getMediaItem() {
    MediaItem.Builder builder = new MediaItem.Builder().setUri(assetUrl);
    String mimeType = null;
    switch (streamingFormat) {
      case SMOOTH:
        mimeType = MimeTypes.APPLICATION_SS;
        break;
      case DYNAMIC_ADAPTIVE:
        mimeType = MimeTypes.APPLICATION_MPD;
        break;
      case HTTP_LIVE:
        mimeType = MimeTypes.APPLICATION_M3U8;
        break;
    }
    if (mimeType != null) {
      builder.setMimeType(mimeType);
    }
    return builder.build();
  }

  @NonNull
  @Override
  public MediaSource.Factory getMediaSourceFactory(@NonNull Context context) {
    return getMediaSourceFactory(context, new DefaultHttpDataSource.Factory());
  }

  @VisibleForTesting
  MediaSource.Factory getMediaSourceFactory(
      Context context, DefaultHttpDataSource.Factory initialFactory) {
    unstableUpdateDataSourceFactory(initialFactory, httpHeaders, userAgent, assetUrl, streamingFormat);
    DataSource.Factory dataSourceFactory = new DefaultDataSource.Factory(context, initialFactory);
    
    // Configure DefaultMediaSourceFactory - ExoPlayer handles ABR automatically
    DefaultMediaSourceFactory mediaSourceFactory = new DefaultMediaSourceFactory(context)
        .setDataSourceFactory(dataSourceFactory);
    
    // Log adaptive streaming readiness
    if (streamingFormat == StreamingFormat.HTTP_LIVE || streamingFormat == StreamingFormat.DYNAMIC_ADAPTIVE) {
      android.util.Log.i("HttpVideoAsset", 
          "✅ " + streamingFormat.name() + " stream configured - adaptive bitrate streaming READY");
    }
    
    return mediaSourceFactory;
  }

  // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
  @OptIn(markerClass = UnstableApi.class)
  private static void unstableUpdateDataSourceFactory(
      @NonNull DefaultHttpDataSource.Factory factory,
      @NonNull Map<String, String> httpHeaders,
      @Nullable String userAgent,
      @Nullable String assetUrl,
      @NonNull StreamingFormat streamingFormat) {
    
    factory.setUserAgent(userAgent).setAllowCrossProtocolRedirects(true);
    
    if (!httpHeaders.isEmpty()) {
      factory.setDefaultRequestProperties(httpHeaders);
    }
    
    // Enhanced logging for adaptive streaming
    android.util.Log.d("HttpVideoAsset", "========== VIDEO INITIALIZATION ==========");
    android.util.Log.d("HttpVideoAsset", "Video URL: " + assetUrl);
    android.util.Log.d("HttpVideoAsset", "Streaming Format: " + streamingFormat.name());
    android.util.Log.d("HttpVideoAsset", "User-Agent: " + userAgent);
    android.util.Log.d("HttpVideoAsset", "HTTP Headers count: " + httpHeaders.size());
    android.util.Log.d("HttpVideoAsset", "Allow Cross-Protocol Redirects: true");
    
    // Log streaming format specifics
    switch (streamingFormat) {
      case HTTP_LIVE:
        android.util.Log.i("HttpVideoAsset", "🎯 HLS ADAPTIVE STREAMING - ExoPlayer will automatically switch between quality variants (360p/480p/720p/1080p) based on network speed");
        break;
      case DYNAMIC_ADAPTIVE:
        android.util.Log.i("HttpVideoAsset", "🎯 DASH ADAPTIVE STREAMING - ExoPlayer will automatically switch between quality variants based on network speed");
        break;
      case SMOOTH:
        android.util.Log.i("HttpVideoAsset", "🎯 SMOOTH STREAMING - ExoPlayer will handle adaptive quality");
        break;
      case UNKNOWN:
        android.util.Log.d("HttpVideoAsset", "Format unknown - using default configuration (progressive download)");
        break;
    }
    
    android.util.Log.d("HttpVideoAsset", "========== END INITIALIZATION ==========");
  }
}