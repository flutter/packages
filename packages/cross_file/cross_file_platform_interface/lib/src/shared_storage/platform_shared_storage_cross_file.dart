// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform.dart';
import '../platform_cross_file.dart';


/// Object specifying creation parameters for creating a [PlatformSharedStorageXFile].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformSharedStorageXFileCreationParams] to
/// provide additional platform specific parameters.
///
/// When extending [PlatformSharedStorageXFileCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidSharedStorageXFileCreationParams
///     extends PlatformSharedStorageXFileCreationParams {
///   AndroidSharedStorageXFileCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidSharedStorageXFileCreationParams.fromCreationParams(
///     PlatformSharedStorageXFileCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidSharedStorageXFileCreationParams(
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
  /// Constructs a [PlatformSharedStorageXFileCreationParams].
  const PlatformSharedStorageXFileCreationParams({required super.uri});
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformSharedStorageXFile].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformSharedStorageXFile.extension].
///
/// ```dart
/// base class AndroidSharedStorageXFile extends PlatformSharedStorageXFile with AndroidXFileExtension {
///   // ...
///   @override
///   PlatformSharedStorageXFileExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidXFileExtension implements PlatformSharedStorageXFileExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformSharedStorageXFileExtension implements PlatformXFileExtension {}

/// Interface for a reference to a local data resource within a devices
/// shared storage.
abstract base class PlatformSharedStorageXFile
    extends
        PlatformXFile<
          PlatformSharedStorageXFileCreationParams,
          PlatformSharedStorageXFileExtension
        > {
  /// Creates a new [PlatformSharedStorageXFile]
  factory PlatformSharedStorageXFile(
    PlatformSharedStorageXFileCreationParams params,
  ) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformSharedStorageXFile(params);
  }

  /// Used by the platform implementation to create a new
  /// [PlatformSharedStorageXFile].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformSharedStorageXFile.implementation(super.params)
    : super.implementation();
}
