package io.flutter.plugins.videoplayer;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.media3.common.AdPlaybackState;
import androidx.media3.common.Format;
import androidx.media3.common.MediaItem;
import androidx.media3.datasource.DefaultHttpDataSource;
import androidx.media3.exoplayer.drm.DrmSessionManagerProvider;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.upstream.LoadErrorHandlingPolicy;
import androidx.media3.test.utils.FakeMediaSource;
import androidx.media3.test.utils.FakeMediaSourceFactory;
import androidx.media3.test.utils.FakeTimeline;
import androidx.media3.test.utils.FakeTrackOutput;

import com.google.common.collect.Lists;

import java.time.Duration;
import java.util.Collections;

/**
 * A fake implementation of the {@link VideoAsset} class.
 */
final class FakeVideoAsset extends VideoAsset {
    @NonNull
    private final MediaSource.Factory mediaSourceFactory;

    FakeVideoAsset(String assetUrl) {
        this(assetUrl, new FakeMediaSourceFactory());
    }

    FakeVideoAsset(String assetUrl, @NonNull MediaSource.Factory mediaSourceFactory) {
        super(assetUrl);
        this.mediaSourceFactory = mediaSourceFactory;
    }

    @NonNull
    @Override
    MediaItem getMediaItem() {
        return new MediaItem.Builder().setUri(assetUrl).build();
    }

    @Override
    MediaSource.Factory getMediaSourceFactory(Context context) {
        return mediaSourceFactory;
    }

    @Override
    MediaSource.Factory getMediaSourceFactory(Context context, DefaultHttpDataSource.Factory initialFactory) {
        return getMediaSourceFactory(context);
    }
}
