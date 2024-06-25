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

import java.util.HashMap;
import java.util.Map;

/**
 * A video to be played by {@link VideoPlayer}.
 */
abstract class VideoAsset {
    /**
     * Returns an asset from a local {@code asset:///} URL, i.e. an on-device asset.
     *
     * @param assetUrl local asset, beginning in {@code asset:///}.
     *
     * @return the asset.
     */
    @NonNull
    static VideoAsset fromAssetUrl(@NonNull String assetUrl) {
        if (!assetUrl.startsWith("asset:///")) {
            throw new IllegalArgumentException("assetUrl must start with 'asset:///'");
        }
        return new LocalVideoAsset(assetUrl);
    }

    /**
     * Returns an asset from a remote URL.
     *
     * @param remoteUrl remote asset, i.e. typically beginning with {@code https://} or similar.
     * @param streamingFormat which streaming format, provided as a hint if able.
     * @param httpHeaders HTTP headers to set for a request.
     *
     * @return the asset.
     */
    @NonNull
    static VideoAsset fromRemoteUrl(
            @Nullable String remoteUrl,
            @NonNull StreamingFormat streamingFormat,
            @NonNull Map<String, String> httpHeaders) {
        return new RemoteVideoAsset(remoteUrl, streamingFormat, new HashMap<>(httpHeaders));
    }

    @Nullable
    protected final String assetUrl;

    protected VideoAsset(@Nullable String assetUrl) {
        this.assetUrl = assetUrl;
    }

    /**
     * Returns the configured media item to be played.
     *
     * @return media item.
     */
    @NonNull
    abstract MediaItem getMediaItem();

    /**
     * Returns a configured media source factory, starting at the provided factory.
     *
     * <p>This method is provided for ease of testing without making real HTTP calls.
     *
     * @param context application context.
     * @param initialFactory initial factory, to be configured.
     *
     * @return configured factory, or {@code null} if not needed for this asset type.
     */
    @VisibleForTesting
    abstract MediaSource.Factory getMediaSourceFactory(Context context, DefaultHttpDataSource.Factory initialFactory);

    /**
     * Returns the configured media source factory, if needed for this asset type.
     *
     * @param context application context.
     *
     * @return configured factory, or {@code null} if not needed for this asset type.
     */
    abstract MediaSource.Factory getMediaSourceFactory(Context context);

    private static final class LocalVideoAsset extends VideoAsset {
        private LocalVideoAsset(@NonNull String assetUrl) {
            super(assetUrl);
        }

        @NonNull
        @Override
        MediaItem getMediaItem() {
            return new MediaItem.Builder().setUri(assetUrl).build();
        }

        @Override
        MediaSource.Factory getMediaSourceFactory(Context context) {
            return new DefaultMediaSourceFactory(context);
        }

        @Override
        MediaSource.Factory getMediaSourceFactory(Context context, DefaultHttpDataSource.Factory initialFactory) {
            return new DefaultMediaSourceFactory(context);
        }
    }

    private static final class RemoteVideoAsset extends VideoAsset {
        private static final String DEFAULT_USER_AGENT = "ExoPlayer";
        private static final String HEADER_USER_AGENT = "User-Agent";

        @NonNull
        private final StreamingFormat streamingFormat;
        @NonNull
        private final Map<String, String> httpHeaders;

        private RemoteVideoAsset(
                @Nullable String assetUrl,
                @NonNull StreamingFormat streamingFormat,
                @NonNull Map<String, String> httpHeaders) {
            super(assetUrl);
            this.streamingFormat = streamingFormat;
            this.httpHeaders = httpHeaders;
        }

        @NonNull
        @Override
        MediaItem getMediaItem() {
            MediaItem.Builder builder = new MediaItem.Builder().setUri(assetUrl);
            String mimeType = null;
            switch (streamingFormat) {
                case Smooth:
                    mimeType = MimeTypes.APPLICATION_SS;
                    break;
                case DynamicAdaptive:
                    mimeType = MimeTypes.APPLICATION_MPD;
                    break;
                case HttpLive:
                    mimeType = MimeTypes.APPLICATION_M3U8;
                    break;
            }
            if (mimeType != null) {
                builder.setMimeType(mimeType);
            }
            return builder.build();
        }

        @Override
        MediaSource.Factory getMediaSourceFactory(Context context) {
            return getMediaSourceFactory(context, new DefaultHttpDataSource.Factory());
        }

        @Override
        MediaSource.Factory getMediaSourceFactory(Context context, DefaultHttpDataSource.Factory factory) {
            String userAgent = DEFAULT_USER_AGENT;
            if (!httpHeaders.isEmpty() && httpHeaders.containsKey(HEADER_USER_AGENT)) {
                userAgent = httpHeaders.get(HEADER_USER_AGENT);
            }
            unstableUpdateDataSourceFactory(factory, httpHeaders, userAgent);

            DataSource.Factory dataSoruceFactory = new DefaultDataSource.Factory(context, factory);
            return new DefaultMediaSourceFactory(context).setDataSourceFactory(dataSoruceFactory);
        }

        // TODO: Migrate to stable API, see https://github.com/flutter/flutter/issues/147039.
        @OptIn(markerClass = UnstableApi.class)
        private static void unstableUpdateDataSourceFactory(
                @NonNull DefaultHttpDataSource.Factory factory,
                @NonNull Map<String, String> httpHeaders,
                @Nullable String userAgent) {
            factory.setUserAgent(userAgent).setAllowCrossProtocolRedirects(true);
            if (!httpHeaders.isEmpty()) {
                factory.setDefaultRequestProperties(httpHeaders);
            }
        }
    }

    /**
     * Streaming formats that can be provided to the video player as a hint.
     */
    enum StreamingFormat {
        /**
         * Default, if the format is either not known or not another valid format.
         */
        Unknown,

        /**
         * Smooth Streaming.
         */
        Smooth,

        /**
         * MPEG-DASH (Dynamic Adaptive over HTTP).
         */
        DynamicAdaptive,

        /**
         * HTTP Live Streaming (HLS).
         */
        HttpLive
    }
}
