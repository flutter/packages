// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../cross_file_platform.dart';
import '../platform_cross_file.dart';

/// Object specifying creation parameters for creating a [PlatformFileSystemXFile].
///
/// Platform-specific implementations can add additional fields by extending
/// this class.
///
/// This example demonstrates how to extend the [PlatformFileSystemXFileCreationParams] to
/// provide additional platform-specific parameters.
///
/// When extending [PlatformFileSystemXFileCreationParams] additional parameters
/// should always accept `null` or have a default value to prevent breaking
/// changes.
///
/// ```dart
/// base class AndroidFileSystemXFileCreationParams
///     extends PlatformFileSystemXFileCreationParams {
///   AndroidFileSystemXFileCreationParams({required super.uri, this.platformValue});
///
///   factory AndroidFileSystemXFileCreationParams.fromCreationParams(
///     PlatformFileSystemXFileCreationParams params, {
///     Object? platformValue,
///   }) {
///     return AndroidFileSystemXFileCreationParams(
///       uri: params.uri,
///       platformValue: platformValue,
///     );
///   }
///
///   final Object? platformValue;
/// }
/// ```
@immutable
base class PlatformFileSystemXFileCreationParams extends PlatformXFileCreationParams {
  /// Constructs a [PlatformFileSystemXFileCreationParams].
  PlatformFileSystemXFileCreationParams(this.path) : super(uri: Uri.file(path).toString());

  /// The path of the file.
  final String path;
}

/// Base mixin used to provide platform-specific features for implementations of
/// [PlatformFileSystemXFile].
///
/// When providing platform specific features, platform implementations are
/// expected to declare a mixin that implements this mixin and return an
/// instance with [PlatformFileSystemXFile.extension].
///
/// ```dart
/// base class AndroidFileSystemXFile extends PlatformFileSystemXFile with AndroidFileSystemXFileExtension {
///   // ...
///   @override
///   PlatformFileSystemXFileExtension? get extension => this;
///
///   Future<void> platformMethod() {
///     // ...
///   }
/// }
///
/// mixin AndroidFileSystemXFileExtension implements PlatformFileSystemXFileExtension {
///   Future<void> platformMethod();
/// }
/// ```
mixin PlatformFileSystemXFileExtension implements PlatformXFileExtension {}

/// Interface for a reference to a local data resource on the file system.
abstract base class PlatformFileSystemXFile extends PlatformXFile {
  /// Creates a new [PlatformFileSystemXFile]
  factory PlatformFileSystemXFile(PlatformFileSystemXFileCreationParams params) {
    assert(
      CrossFilePlatform.instance != null,
      'A platform implementation for `cross_file` has not been set. Please '
      'ensure that an implementation of `CrossFilePlatform` has been set to '
      '`CrossFilePlatform.instance` before use. For unit testing, '
      '`CrossFilePlatform.instance` can be set with your own test implementation.',
    );
    return CrossFilePlatform.instance!.createPlatformFileSystemXFile(params);
  }

  /// Used by the platform implementation to create a new
  /// [PlatformFileSystemXFile].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformFileSystemXFile.implementation(PlatformFileSystemXFileCreationParams super.params);

  @override
  PlatformFileSystemXFileCreationParams get params =>
      super.params as PlatformFileSystemXFileCreationParams;

  /// Writes a list of bytes to a file.
  ///
  /// Platforms may throw an exception if there is an error opening or writing
  /// to the file.
  Future<PlatformFileSystemXFile> writeAsBytes(PlatformWriteAsBytesParams params);
}

/// Base class for parameters passed to [PlatformFileSystemXFile.writeAsBytes].
@immutable
base class PlatformWriteAsBytesParams {
  /// Constructs a [PlatformWriteAsBytesParams].
  const PlatformWriteAsBytesParams(this.bytes);

  /// List of bytes to write to the file.
  final Uint8List bytes;
}
