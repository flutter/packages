// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.PendingRecording;
import androidx.camera.video.Recording;
import androidx.core.content.ContextCompat;

/**
 * ProxyApi implementation for {@link PendingRecording}. This class may handle instantiating native
 * object instances that are attached to a Dart instance or handle method calls on the associated
 * native class or an instance of that class.
 */
class PendingRecordingProxyApi extends PigeonApiPendingRecording {
  PendingRecordingProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public Recording start(
      PendingRecording pigeon_instance, @NonNull VideoRecordEventListener listener) {
    return pigeon_instance.start(
        ContextCompat.getMainExecutor(getPigeonRegistrar().getContext()), listener::onEvent);
  }
}
