// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform.dart';
import '../platform_cross_directory.dart';

/// Object specifying creation parameters for creating a [PlatformSharedStorageXDirectory].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformSharedStorageXDirectoryCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformSharedStorageXDirectoryCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidSharedStorageXDirectoryCreationParams
///     extends PlatformSharedStorageXDirectoryCreationParams {
///   AndroidSharedStorageXDirectoryCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidSharedStorageXDirectoryCreationParams.fromCreationParams(
///     PlatformSharedStorageXDirectoryCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidSharedStorageXDirectoryCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformSharedStorageXDirectoryCreationParams
    extends PlatformXDirectoryCreationParams {
  /// Constructs a [PlatformSharedStorageXDirectoryCreationParams].
  const PlatformSharedStorageXDirectoryCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformSharedStorageXDirectory].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformSharedStorageXDirectory.extension].
///
/// ```dart
/// base class AndroidSharedStorageXDirectory extends PlatformSharedStorageXDirectory with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformSharedStorageXDirectoryExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformSharedStorageXDirectoryExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin SharedStoragePlatformXDirectoryExtension
    implements PlatformXDirectoryExtension {}

/// A reference to a directory (or folder) on the file system within a devices
/// shared storage.
abstract base class PlatformSharedStorageXDirectory
    extends
        PlatformXDirectory<
          PlatformSharedStorageXDirectoryCreationParams,
          SharedStoragePlatformXDirectoryExtension
        > {
  /// Creates a new [PlatformSharedStorageXDirectory]
  factory PlatformSharedStorageXDirectory(
    PlatformSharedStorageXDirectoryCreationParams params,
  ) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformSharedStorageXDirectory(
      params,
    );
  }

  /// Used by the platform implementation to create a new
  /// [PlatformSharedStorageXDirectory].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  PlatformSharedStorageXDirectory.implementation(super.params)
    : super.implementation();
}
