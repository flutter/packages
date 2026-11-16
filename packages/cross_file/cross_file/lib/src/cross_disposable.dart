// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show internal;

/// Handles setting and checking whether an instance is disposed.
@internal
mixin XDisposable {
  bool _isDisposed = false;

  @internal
  void markDisposed() {
    _isDisposed = true;
  }

  @internal
  bool assertNotDisposed() {
    assert(() {
      if (_isDisposed) {
        throw StateError(
          'A $runtimeType was used after being disposed.\n'
          'Once you have called dispose() on a $runtimeType, it can no longer be used.',
        );
      }
      return true;
    }());
    return true;
  }
}
