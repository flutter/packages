// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../../cross_file_platform_interface.dart';

/// Object specifying creation parameters for creating a [PlatformXFile].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformXFileCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformXFileCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidPlatformXFileCreationParams
///     extends PlatformXFileCreationParams {
///   AndroidPlatformXFileCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidPlatformXFileCreationParams.fromCreationParams(
///     PlatformXFileCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidPlatformXFileCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformSharedStorageXFileCreationParams
    extends PlatformXFileCreationParams {
  /// Constructs a [PlatformXFileCreationParams].
  const PlatformSharedStorageXFileCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformXFile].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformXFile.extension].
///
/// ```dart
/// base class AndroidPlatformXFile extends PlatformXFile with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformXFileExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformXFileExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin SharedStoragePlatformXFileExtension implements PlatformXFileExtension {}

abstract base class PlatformSharedStorageXFile extends PlatformXFile {
  /// Creates a new [PlatformSharedStorageXFile]
  factory PlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `XFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    final PlatformSharedStorageXFile file = CrossFilePlatform.instance!
        .createPlatformSharedStorageXFile(params);
    return file;
  }

  /// Used by the platform implementation to create a new [PlatformXFile].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformSharedStorageXFile.implementation(super.params)
    : super.implementation();

  /// The parameters used to initialize the [PlatformXFile].
  @override
  PlatformSharedStorageXFileCreationParams get params =>
      super.params as PlatformSharedStorageXFileCreationParams;

  /// Extension for providing platform specific features.
  @override
  SharedStoragePlatformXFileExtension? get extension =>
      super.extension as SharedStoragePlatformXFileExtension?;
}
