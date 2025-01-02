// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A representation of a Java IllegalArgumentException in dart.
class NativeIllegalArgumentException implements Exception {
  /// Creates a [NativeIllegalArgumentException].
  NativeIllegalArgumentException(this.message);

  /// The message provided by the native error.
  final String message;

  @override
  String toString() {
    return 'NativeIllegalArgumentException($message)';
  }
}
