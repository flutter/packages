// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, internal, protected;

/// The common superclass for [XFile] and [XDirectory].
@immutable
base class XEntity {
  /// Constructs a [XEntity].
  @internal
  @protected
  const XEntity(this.platform);

  /// Implementation of [XEntity] for the current platform.
  @internal
  final PlatformXEntity platform;

  /// Attempt to provide the platform class extension.
  ///
  /// Returns null if the specified platform extension cannot be retrieved.
  S? getExtension<S extends PlatformXEntityExtension>() {
    return platform.extension is S ? platform.extension! as S : null;
  }

  /// A unique string used to identify the resource.
  String get uri => platform.params.uri;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists() => platform.exists();

  @override
  String toString() => platform.params.uri;
}
