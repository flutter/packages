// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import androidx.annotation.NonNull;

/**
 * A convenience class for results of a Pigeon Flutter API method call that perform no action.
 *
 * <p>Longer term, any call using this is likely a good candidate to migrate to event channels.
 */
public class NoOpVoidResult implements Messages.VoidResult {
  @Override
  public void success() {}

  @Override
  public void error(@NonNull Throwable error) {}
}
