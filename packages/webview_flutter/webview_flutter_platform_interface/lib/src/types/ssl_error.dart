// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Provides the details for an SSl certificate error.
@immutable
class SslError {
  /// Creates an [SslError].
  const SslError({required this.description});

  /// A human-presentable description for a given error.
  final String description;
}
