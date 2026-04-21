// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart' show immutable;

/// The common superclass for [PlatformXFileCreationParams] and
/// [PlatformXDirectoryCreationParams].
@immutable
abstract base class PlatformXEntityCreationParams {
  /// Constructs a [PlatformXEntityCreationParams].
  const PlatformXEntityCreationParams({required this.uri});

  /// A string used to reference the resource's location.
  final String uri;
}

/// The common superclass for [PlatformXFileExtension] and
/// [PlatformXDirectoryExtension].
mixin PlatformXEntityExtension {}

/// The common superclass for [PlatformXFile] and [PlatformXDirectory].
abstract base class PlatformXEntity {
  /// Constructs a [PlatformCrossFileEntity].
  PlatformXEntity(this.params);

  /// The parameters used to initialize the [PlatformXEntity].
  final PlatformXEntityCreationParams params;

  /// Extension for providing platform specific features.
  PlatformXEntityExtension? get extension => null;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists();
}
