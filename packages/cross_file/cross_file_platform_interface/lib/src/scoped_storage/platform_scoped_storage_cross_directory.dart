// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform.dart';
import '../platform_cross_directory.dart';

/// Object specifying creation parameters for creating a [PlatformScopedStorageXDirectory].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformScopedStorageXDirectoryCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformScopedStorageXDirectoryCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidScopedStorageXDirectoryCreationParams
///     extends PlatformScopedStorageXDirectoryCreationParams {
///   AndroidScopedStorageXDirectoryCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidScopedStorageXDirectoryCreationParams.fromCreationParams(
///     PlatformScopedStorageXDirectoryCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidScopedStorageXDirectoryCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformScopedStorageXDirectoryCreationParams
    extends PlatformXDirectoryCreationParams {
  /// Constructs a [PlatformScopedStorageXDirectoryCreationParams].
  const PlatformScopedStorageXDirectoryCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformScopedStorageXDirectory].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformScopedStorageXDirectory.extension].
///
/// ```dart
/// base class AndroidScopedStorageXDirectory extends PlatformScopedStorageXDirectory with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformScopedStorageXDirectoryExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformScopedStorageXDirectoryExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin ScopedStoragePlatformXDirectoryExtension
    implements PlatformXDirectoryExtension {}

/// A reference to a directory (or folder) on the file system within a devices
/// scoped storage.
abstract base class PlatformScopedStorageXDirectory extends PlatformXDirectory {
  /// Creates a new [PlatformScopedStorageXDirectory]
  factory PlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformScopedStorageXDirectory(
      params,
    );
  }

  /// Used by the platform implementation to create a new
  /// [PlatformScopedStorageXDirectory].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  PlatformScopedStorageXDirectory.implementation(
    PlatformScopedStorageXDirectoryCreationParams super.params,
  ) : super.implementation();

  @override
  PlatformScopedStorageXDirectoryCreationParams get params =>
      super.params as PlatformScopedStorageXDirectoryCreationParams;
}
