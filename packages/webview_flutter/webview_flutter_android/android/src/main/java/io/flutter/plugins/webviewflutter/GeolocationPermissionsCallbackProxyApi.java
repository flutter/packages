// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.GeolocationPermissions;
import androidx.annotation.NonNull;

/**
 * Host API implementation for `GeolocationPermissionsCallback`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class GeolocationPermissionsCallbackProxyApi
    extends PigeonApiGeolocationPermissionsCallback {
  /** Constructs a {@link GeolocationPermissionsCallbackProxyApi}. */
  public GeolocationPermissionsCallbackProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void invoke(
      @NonNull GeolocationPermissions.Callback pigeon_instance,
      @NonNull String origin,
      boolean allow,
      boolean retain) {
    pigeon_instance.invoke(origin, allow, retain);
  }
}
