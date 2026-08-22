// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform.dart';
import '../platform_cross_directory.dart';

/// Object specifying creation parameters for creating a [PlatformFileSystemXDirectory].
///
/// Platform-specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformFileSystemXDirectoryCreationParams] to
/// provide additional platform-specific parameters.
///
/// When extending [PlatformFileSystemXDirectoryCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidFileSystemXDirectoryCreationParams
///     extends PlatformFileSystemXDirectoryCreationParams {
///   AndroidFileSystemXDirectoryCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidFileSystemXDirectoryCreationParams.fromCreationParams(
///     PlatformFileSystemXDirectoryCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidFileSystemXDirectoryCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformFileSystemXDirectoryCreationParams extends PlatformXDirectoryCreationParams {
  /// Constructs a [PlatformFileSystemXDirectoryCreationParams].
  PlatformFileSystemXDirectoryCreationParams(this.path) : super(uri: Uri.file(path).toString());

  /// The path of the directory.
  final String path;
}

/// Base mixin used to provide platform-specific features for implementations of
/// [PlatformFileSystemXDirectory].
///
/// When providing platform specific features, platform implementations are
/// expected to declare a mixin that implements this mixin and return an
/// instance with [PlatformFileSystemXDirectory.extension].
///
/// ```dart
/// base class AndroidFileSystemXDirectory extends PlatformFileSystemXDirectory with AndroidFileSystemXDirectoryExtension {
///   // ...
///   @override
///   PlatformFileSystemXDirectoryExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidFileSystemXDirectoryExtension implements PlatformFileSystemXDirectoryExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformFileSystemXDirectoryExtension implements PlatformXDirectoryExtension {}

/// Interface for a reference to a directory (or folder) on the file system.
abstract base class PlatformFileSystemXDirectory extends PlatformXDirectory {
  /// Creates a new [PlatformFileSystemXDirectory]
  factory PlatformFileSystemXDirectory(PlatformFileSystemXDirectoryCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformFileSystemXDirectory(params);
  }

  /// Used by the platform implementation to create a new
  /// [PlatformFileSystemXDirectory].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  PlatformFileSystemXDirectory.implementation(
    PlatformFileSystemXDirectoryCreationParams super.params,
  );

  @override
  PlatformFileSystemXDirectoryCreationParams get params =>
      super.params as PlatformFileSystemXDirectoryCreationParams;
}
