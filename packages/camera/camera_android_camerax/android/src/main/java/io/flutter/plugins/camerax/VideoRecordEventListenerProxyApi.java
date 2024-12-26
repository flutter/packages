// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.video.VideoRecordEvent;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link VideoRecordEventListener}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VideoRecordEventListenerProxyApi extends PigeonApiVideoRecordEventListener {
  VideoRecordEventListenerProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }
  /** Implementation of {@link VideoRecordEventListener} that passes arguments of callback methods to Dart. */
  static class VideoRecordEventListenerImpl implements VideoRecordEventListener {
    private final VideoRecordEventListenerProxyApi api;

    VideoRecordEventListenerImpl(@NonNull VideoRecordEventListenerProxyApi api) {
      this.api = api;
    }

    @Override
    public void onEvent(@NonNull VideoRecordEvent event) {
      api.getPigeonRegistrar().runOnMainThread(() -> api.onEvent(this, event, reply -> null));
    }
  }

  @NonNull
  @Override
  public ProxyApiRegistrar getPigeonRegistrar() {
    return (ProxyApiRegistrar) super.getPigeonRegistrar();
  }

  @NonNull
  @Override
  public VideoRecordEventListener pigeon_defaultConstructor() {
    return new VideoRecordEventListenerImpl(this);
  }
}
