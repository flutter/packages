// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.webkit.PermissionRequest;
import androidx.annotation.NonNull;
import java.util.Arrays;
import java.util.List;

/**
 * Host API implementation for `PermissionRequest`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class PermissionRequestProxyApi extends PigeonApiPermissionRequest {
  /** Constructs a {@link PermissionRequestProxyApi}. */
  public PermissionRequestProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public List<String> resources(@NonNull PermissionRequest pigeon_instance) {
    return Arrays.asList(pigeon_instance.getResources());
  }

  @Override
  public void grant(@NonNull PermissionRequest pigeon_instance, @NonNull List<String> resources) {
    pigeon_instance.grant(resources.toArray(new String[0]));
  }

  @Override
  public void deny(@NonNull PermissionRequest pigeon_instance) {
    pigeon_instance.deny();
  }
}
