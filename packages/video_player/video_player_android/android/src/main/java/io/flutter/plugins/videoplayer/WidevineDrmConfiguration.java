// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * The Widevine DRM information needed to play a protected {@link HttpVideoAsset}.
 *
 * <p>This is the plugin-level equivalent of the Pigeon {@code PlatformWidevineDrmConfiguration}
 * message, so that {@link VideoAsset} doesn't depend on generated types.
 */
public final class WidevineDrmConfiguration {
  /** The license acquisition URL of the Widevine license server. */
  @NonNull public final String licenseUri;

  /** Headers to attach to each license request sent to {@link #licenseUri}. */
  @NonNull public final Map<String, String> licenseHeaders;

  public WidevineDrmConfiguration(
      @NonNull String licenseUri, @NonNull Map<String, String> licenseHeaders) {
    this.licenseUri = licenseUri;
    this.licenseHeaders = Collections.unmodifiableMap(new HashMap<>(licenseHeaders));
  }
}
