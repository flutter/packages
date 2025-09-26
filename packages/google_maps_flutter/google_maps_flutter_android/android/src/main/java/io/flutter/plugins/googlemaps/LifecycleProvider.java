// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.Nullable;
import androidx.lifecycle.Lifecycle;

interface LifecycleProvider {

  @Nullable
  Lifecycle getLifecycle();
}
