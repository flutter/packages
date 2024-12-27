// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import androidx.annotation.NonNull;
import androidx.camera.core.FocusMeteringResult;

/**
 * ProxyApi implementation for {@link FocusMeteringResult}. This class may handle instantiating
 * native object instances that are attached to a Dart instance or handle method calls on the
 * associated native class or an instance of that class.
 */
class FocusMeteringResultProxyApi extends PigeonApiFocusMeteringResult {
  FocusMeteringResultProxyApi(@NonNull ProxyApiRegistrar pigeonRegistrar) {
    super(pigeonRegistrar);
  }

  @Override
  public boolean isFocusSuccessful(FocusMeteringResult pigeon_instance) {
    return pigeon_instance.isFocusSuccessful();
  }
}
