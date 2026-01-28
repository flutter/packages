// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'cross_file_platform.dart';
import 'platform_cross_file_entity.dart';

/// Object specifying creation parameters for creating a [PlatformXDirectory].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformXDirectoryCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformXDirectoryCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidXDirectoryCreationParams
///     extends PlatformXDirectoryCreationParams {
///   AndroidXDirectoryCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidXDirectoryCreationParams.fromCreationParams(
///     PlatformXDirectoryCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidXDirectoryCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformXDirectoryCreationParams
    extends PlatformXFileEntityCreationParams {
  /// Constructs a [PlatformXDirectoryCreationParams].
  const PlatformXDirectoryCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformXDirectory].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformXDirectory.extension].
///
/// ```dart
/// base class AndroidXDirectory extends PlatformXDirectory with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformXDirectoryExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformXDirectoryExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformXDirectoryExtension implements PlatformXFileEntityExtension {}

/// A reference to a directory (or folder) on the file system.
abstract base class PlatformXDirectory extends PlatformXFileEntity {
  /// Creates a new [PlatformXDirectory].
  factory PlatformXDirectory(PlatformXDirectoryCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformXDirectory(params);
  }

  /// Used by the platform implementation to create a new [PlatformXDirectory].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformXDirectory.implementation(
    PlatformXDirectoryCreationParams super.params,
  );

  @override
  PlatformXDirectoryCreationParams get params =>
      super.params as PlatformXDirectoryCreationParams;

  /// Lists the sub-directories and files of this Directory.
  ///
  /// Platforms may throw an exception if there is an error listing entities in
  /// the directory
  Stream<PlatformXFileEntity> list(ListParams params);
}

/// Base class for parameters passed to [PlatformXDirectory.list].
@immutable
base class ListParams {}
