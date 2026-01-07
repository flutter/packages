// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:meta/meta.dart';

/// The common superclass for [XFile] and [XDirectory].
@immutable
abstract class XFileEntity {
  /// Constructs a [XFileEntity].
  const XFileEntity(this.platform);

  /// Implementation of [XFileEntity] for the current platform.
  final PlatformXFileEntity platform;

  /// A string used to reference the resource's location.
  String get uri => platform.params.uri;

  /// Whether the resource represented by this reference exists.
  Future<bool> exists() => platform.exists();
}
