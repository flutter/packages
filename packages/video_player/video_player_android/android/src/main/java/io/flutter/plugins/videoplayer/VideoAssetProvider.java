// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Supplies a {@link VideoAsset} for a URI, overriding this plugin's default handling.
 *
 * <p>This is the extension point for playback that the plugin cannot express on its own, such as
 * reading from a download or HTTP cache, applying a custom {@code DataSource.Factory}, or resolving
 * a scheme this plugin does not know about. Because {@link VideoAsset} already exposes the media
 * item and media source factory, an implementation has full control over how a URI is played
 * without this plugin needing to know why.
 *
 * <p>Register with {@link VideoPlayerPlugin#setVideoAssetProvider}. At most one provider is active
 * at a time; the last one registered wins.
 */
public interface VideoAssetProvider {
  /**
   * Returns the asset to play for {@code uri}, or null to use this plugin's default handling.
   *
   * <p>Called on the main thread each time a player is created, before the URI is inspected for a
   * known scheme, so a provider may override any URI including {@code asset:} and {@code rtsp:}
   * ones.
   *
   * @param context application context.
   * @param uri the URI the player was created with.
   * @return the asset to play, or null to fall through to the default.
   */
  @Nullable
  VideoAsset getAsset(@NonNull Context context, @NonNull String uri);
}
