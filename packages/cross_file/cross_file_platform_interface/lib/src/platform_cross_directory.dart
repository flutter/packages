// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform_interface.dart';
import 'platform_cross_file_entity.dart';
import 'cross_file_platform.dart';

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
/// base class AndroidPlatformXDirectoryCreationParams
///     extends PlatformXDirectoryCreationParams {
///   AndroidPlatformXDirectoryCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidPlatformXDirectoryCreationParams.fromCreationParams(
///     PlatformXDirectoryCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidPlatformXDirectoryCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformXDirectoryCreationParams {
  /// Constructs a [PlatformXDirectoryCreationParams].
  const PlatformXDirectoryCreationParams({required this.uri});

  /// A string used to reference the resource's location.
  final String uri;
}

/// Base mixin used to provide platform specific features for implementations of
/// [PlatformXDirectory].
///
/// Platform implementations are expected to declare a mixin that implements
/// this mixin and return an instance with [PlatformXDirectory.extension].
///
/// ```dart
/// base class AndroidPlatformXDirectory extends PlatformXDirectory with AndroidXFileExtension {
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
mixin PlatformXDirectoryExtension {}

/// A reference to a directory (or folder) on the file system.
abstract base class PlatformXDirectory implements PlatformCrossFileEntity {
  /// Creates a new [PlatformXDirectory].
  factory PlatformXDirectory(PlatformXDirectoryCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    final PlatformXDirectory file = CrossFilePlatform.instance!
        .createPlatformXDirectory(params);
    return file;
  }

  /// Used by the platform implementation to create a new [PlatformXDirectory].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformXDirectory.implementation(this.params);

  /// The parameters used to initialize the [PlatformXDirectory].
  final PlatformXDirectoryCreationParams params;

  /// Extension for providing platform specific features.
  PlatformXDirectoryExtension? get extension => null;

  /// Lists the sub-directories and files of this Directory.
  Future<Stream<PlatformCrossFileEntity>> list(ListParams params);
}

class ListParams {

}
