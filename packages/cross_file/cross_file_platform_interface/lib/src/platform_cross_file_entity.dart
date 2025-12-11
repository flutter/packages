// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// 
@immutable
abstract base class PlatformCrossFileEntityCreationParams {
  /// Constructs a [PlatformXFileCreationParams].
  const PlatformCrossFileEntityCreationParams({required this.uri});

  /// A string used to reference the resource's location.
  final String uri;
}


abstract base class PlatformCrossFileEntity {
  PlatformCrossFileEntity(this.params);

  /// The parameters used to initialize the [PlatformCrossFileEntity].
  final PlatformCrossFileEntityCreationParams params;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists();
}
