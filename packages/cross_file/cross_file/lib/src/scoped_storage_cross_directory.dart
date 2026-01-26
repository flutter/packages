// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'cross_directory.dart';

/// A reference to a directory (or folder) on the file system within a devices
/// scoped storage.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.ScopedStorageXDirectory.fromCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the Android implementation of `cross_file`:
///
/// ```dart
/// final ScopedStorageXDirectory directory = XDirectory('my/dir');
///
/// final AndroidScopedStorageXDirectoryExtension? androidExtension =
///     file.maybeGetExtension<AndroidScopedStorageXDirectoryExtension>();
/// if (androidExtension != null) {
///   print(androidExtension.name());
/// }
/// ```
@immutable
class ScopedStorageXDirectory extends XDirectory {
  /// Constructs a [ScopedStorageXDirectory].
  ///
  /// See [ScopedStorageXDirectory.fromCreationParams] for setting parameters
  /// for a specific platform.
  ScopedStorageXDirectory(String uri)
    : this.fromCreationParams(
        PlatformScopedStorageXDirectoryCreationParams(uri: uri),
      );

  /// Constructs a [ScopedStorageXDirectory] from creation params for a specific
  /// platform.
  ///
  /// {@template cross_file.ScopedStorageXDirectory.fromCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the Android implementation of `cross_file`:
  ///
  /// ```dart
  /// var params = const PlatformXDirectoryCreationParams(uri: 'context://my/docs');
  ///
  /// if (CrossFilePlatform.instance is CrossFileAndroid) {
  ///   params = AndroidScopedStorageXDirectoryCreationParams.fromCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final file = ScopedStorageXDirectory.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  ScopedStorageXDirectory.fromCreationParams(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) : this.fromPlatform(PlatformScopedStorageXDirectory(params));

  /// Constructs a [ScopedStorageXDirectory] from a specific platform
  /// implementation.
  const ScopedStorageXDirectory.fromPlatform(
    PlatformScopedStorageXDirectory super.platform,
  ) : super.fromPlatform();

  @override
  PlatformScopedStorageXDirectory get platform =>
      super.platform as PlatformScopedStorageXDirectory;
}
