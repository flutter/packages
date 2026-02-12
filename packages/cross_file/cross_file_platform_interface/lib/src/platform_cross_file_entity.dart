// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// The common superclass for [PlatformXFileCreationParams] and
/// [PlatformXDirectoryCreationParams].
@immutable
abstract base class PlatformXFileEntityCreationParams {
  /// Constructs a [PlatformXFileCreationParams].
  const PlatformXFileEntityCreationParams({required this.uri});

  /// A string used to reference the resource's location.
  final String uri;
}

/// The common superclass for [PlatformXFileExtension] and
/// [PlatformXDirectoryExtension].
mixin PlatformXFileEntityExtension {}

/// The common superclass for [PlatformXFile] and [PlatformXDirectory].
abstract base class PlatformXFileEntity {
  /// Constructs a [PlatformCrossFileEntity].
  PlatformXFileEntity(this.params);

  /// The parameters used to initialize the [PlatformXFileEntity].
  final PlatformXFileEntityCreationParams params;

  /// Extension for providing platform specific features.
  PlatformXFileEntityExtension? get extension => null;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists();
}
