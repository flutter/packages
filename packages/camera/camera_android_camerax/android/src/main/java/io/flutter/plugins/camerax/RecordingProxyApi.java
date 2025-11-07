// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.video.Recording;

/**
 * ProxyApi implementation for {@link Recording}. This class may handle instantiating native object
 * instances that are attached to a Dart instance or handle method calls on the associated native
 * class or an instance of that class.
 */
class RecordingProxyApi extends PigeonApiRecording {
  RecordingProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public void close(Recording pigeonInstance) {
    pigeonInstance.close();
  }

  @Override
  public void pause(Recording pigeonInstance) {
    pigeonInstance.pause();
  }

  @Override
  public void resume(Recording pigeonInstance) {
    pigeonInstance.resume();
  }

  @Override
  public void stop(Recording pigeonInstance) {
    pigeonInstance.stop();
  }
}
