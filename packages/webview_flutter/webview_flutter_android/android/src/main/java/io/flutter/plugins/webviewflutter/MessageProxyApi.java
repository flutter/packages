// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutter;

import android.os.Message;
import androidx.annotation.NonNull;

/**
 * Proxy API implementation for `Message`.
 *
 * <p>This class may handle instantiating and adding native object instances that are attached to a
 * Dart instance or handle method calls on the associated native class or an instance of the class.
 */
public class MessageProxyApi extends PigeonApiAndroidMessage {
  public MessageProxyApi(@NonNull AndroidWebkitLibraryPigeonProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void sendToTarget(@NonNull Message pigeon_instance) {
    pigeon_instance.sendToTarget();
  }
}
