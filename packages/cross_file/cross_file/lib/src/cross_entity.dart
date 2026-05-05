// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, internal, protected;

/// The common superclass for [XFile] and [XDirectory].
@immutable
base class XEntity {
  /// Constructs a [XEntity].
  @protected
  @internal
  const XEntity(this.platform);

  /// Implementation of [XEntity] for the current platform.
  @internal
  final PlatformXEntity platform;

  /// A string used to reference the resource's location.
  String get uri => platform.params.uri;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists() => platform.exists();
}
