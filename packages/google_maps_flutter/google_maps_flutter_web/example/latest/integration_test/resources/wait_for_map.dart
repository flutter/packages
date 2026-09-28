// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

/// Waits for a map-creation [future] (e.g. the value passed to `onMapCreated`).
///
/// Integration tests have no default timeout, so a map that never becomes
/// ready would otherwise hang until the driver gives up, reporting an opaque
/// `DriverError` with no test output.
/// See https://github.com/flutter/flutter/issues/193452.
Future<T> waitForMap<T>(Future<T> future) {
  return future.timeout(
    const Duration(seconds: 30),
    onTimeout: () => throw TimeoutException('The map never reported being ready.'),
  );
}
