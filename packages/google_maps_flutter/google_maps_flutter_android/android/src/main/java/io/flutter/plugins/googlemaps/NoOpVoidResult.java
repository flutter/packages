// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import androidx.annotation.NonNull;

/**
 * Response handler for calls to Dart that don't require any error handling, such as event
 * notifications where if the Dart side has been torn down, silently dropping the message is the
 * desired behavior.
 *
 * <p>Longer term, any call using this is likely a good candidate to migrate to event channels.
 */
public class NoOpVoidResult implements Messages.VoidResult {
  @Override
  public void success() {}

  @Override
  public void error(@NonNull Throwable error) {}
}
