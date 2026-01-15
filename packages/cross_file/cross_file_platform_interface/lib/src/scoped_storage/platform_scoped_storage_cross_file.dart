// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform.dart';
import '../platform_cross_file.dart';

/// Object specifying creation parameters for creating a [PlatformScopedStorageXFile].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformScopedStorageXFileCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformScopedStorageXFileCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidScopedStorageXFileCreationParams
///     extends PlatformScopedStorageXFileCreationParams {
///   AndroidScopedStorageXFileCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidScopedStorageXFileCreationParams.fromCreationParams(
///     PlatformScopedStorageXFileCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidScopedStorageXFileCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformScopedStorageXFileCreationParams
    extends PlatformXFileCreationParams {
  /// Constructs a [PlatformScopedStorageXFileCreationParams].
  const PlatformScopedStorageXFileCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformScopedStorageXFile].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformScopedStorageXFile.extension].
///
/// ```dart
/// base class AndroidScopedStorageXFile extends PlatformScopedStorageXFile with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformScopedStorageXFileExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformScopedStorageXFileExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformScopedStorageXFileExtension implements PlatformXFileExtension {}

/// Interface for a reference to a local data resource within a devices
/// scoped storage.
abstract base class PlatformScopedStorageXFile extends PlatformXFile {
  /// Creates a new [PlatformScopedStorageXFile]
  factory PlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformScopedStorageXFile(params);
  }

  /// Used by the platform implementation to create a new
  /// [PlatformScopedStorageXFile].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformScopedStorageXFile.implementation(
    PlatformScopedStorageXFileCreationParams super.params,
  ) : super.implementation();

  @override
  PlatformScopedStorageXFileCreationParams get params =>
      super.params as PlatformScopedStorageXFileCreationParams;
}
