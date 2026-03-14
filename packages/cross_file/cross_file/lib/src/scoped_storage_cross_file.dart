// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'cross_file.dart';

/// A reference to a local data resource within a devices scoped storage.
///
/// Scoped storage limits app access to external storage and apps may lose
/// access to a resource at some point depending on the platform.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.ScopedStorageXFile.fromCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the Android implementation of `cross_file`:
///
/// ```dart
/// final ScopedStorageXFile file = ScopedStorageXFile(uri: 'content://my/file.txt');
///
/// final AndroidScopedStorageXFileExtension? androidExtension =
///     file.maybeGetExtension<AndroidScopedStorageXFileExtension>();
/// if (androidExtension != null) {
///   print(androidExtension.name());
/// }
/// ```
@immutable
class ScopedStorageXFile extends XFile {
  /// Constructs a [ScopedStorageXFile].
  ///
  /// See [ScopedStorageXFile.fromCreationParams] for setting parameters
  /// for a specific platform.
  ScopedStorageXFile({required String uri})
    : this.fromCreationParams(
        PlatformScopedStorageXFileCreationParams(uri: uri),
      );

  /// Constructs a [ScopedStorageXFile].
  ///
  /// See [ScopedStorageXFile.fromCreationParams] for setting parameters for a
  /// specific platform.
  ScopedStorageXFile.fromUri(Uri uri) : this(uri: uri.toString());

  /// Constructs a [ScopedStorageXFile] from creation params for a specific
  /// platform.
  ///
  /// {@template cross_file.ScopedStorageXFile.fromCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the Android implementation of `cross_file`:
  ///
  /// ```dart
  /// var params = const PlatformScopedStorageXFileCreationParams(uri: 'content://my/file.txt');
  ///
  /// if (CrossFilePlatform.instance is CrossFileAndroid) {
  ///   params = AndroidScopedStorageXFileCreationParams.fromCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final file = ScopedStorageXFile.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  ScopedStorageXFile.fromCreationParams(
    PlatformScopedStorageXFileCreationParams params,
  ) : this.fromPlatform(PlatformScopedStorageXFile(params));

  /// Constructs a [ScopedStorageXFile] from a specific platform implementation.
  const ScopedStorageXFile.fromPlatform(
    PlatformScopedStorageXFile super.platform,
  ) : super.fromPlatform();

  @override
  PlatformScopedStorageXFile get platform =>
      super.platform as PlatformScopedStorageXFile;

  /// Whether the resource represented by this reference can be read.
  Future<bool> canRead() => platform.canRead();
}
