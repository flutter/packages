// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.camera.video.Recording;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * ProxyApi implementation for {@link Recording}.
 * This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class RecordingProxyApi extends PigeonApiRecording {
  RecordingProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void close(Recording pigeon_instance) {
    pigeon_instance.close();
  }

  @Override
  public void pause(Recording pigeon_instance) {
    pigeon_instance.pause();
  }

  @Override
  public void resume(Recording pigeon_instance) {
    pigeon_instance.resume();
  }

  @Override
  public void stop(Recording pigeon_instance) {
    pigeon_instance.stop();
  }
}
