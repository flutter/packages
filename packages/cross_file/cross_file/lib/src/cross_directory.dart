// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, internal;

import 'cross_entity.dart';
import 'cross_file.dart';
import 'scoped_storage_cross_directory.dart';
import 'scoped_storage_cross_file.dart';

/// A reference to a container of local data resources.
///
/// Note: Not all platforms support accessing directories.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.XDirectory.fromCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the dart:io implementation of `cross_file`:
///
/// ```dart
/// final XDirectory dir = XDirectory.fromUri(Uri.directory('/my/docs/.'));
///
/// final IOXDirectoryExtension? ioExtension = file.maybeGetExtension<IOXDirectoryExtension>();
/// if (ioExtension != null) {
///   print(ioExtension.directory.path);
/// }
/// ```
@immutable
base class XDirectory extends XEntity {
  /// Constructs a [XDirectory].
  ///
  /// See [XDirectory.fromCreationParams] for setting parameters for a specific
  /// platform.
  XDirectory({required String uri})
    : this.fromCreationParams(PlatformXDirectoryCreationParams(uri: uri));

  /// Constructs a [XDirectory].
  ///
  /// See [XDirectory.fromCreationParams] for setting parameters for a specific
  /// platform.
  XDirectory.fromUri(Uri uri) : this(uri: uri.toString());

  /// Constructs a [XDirectory] from a path.
  XDirectory.fromPath(String path) : this.fromUri(Uri.directory(path));

  /// Constructs a [XDirectory] from creation params for a specific platform.
  ///
  /// {@template cross_file.XDirectory.fromCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the dart:io implementation of `cross_file`:
  ///
  /// ```dart
  /// var params = const PlatformXDirectoryCreationParams(uri: 'file:///my/docs/');
  ///
  /// if (CrossFilePlatform.instance is CrossFileIO) {
  ///   params = IOXDirectoryCreationParams.fromCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final dir = XDirectory.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  XDirectory.fromCreationParams(PlatformXDirectoryCreationParams params)
    : this.fromPlatform(PlatformXDirectory(params));

  /// Constructs a [XDirectory] from a specific platform implementation.
  @internal
  const XDirectory.fromPlatform(PlatformXDirectory super.platform);

  /// Implementation of [PlatformXDirectory] for the current platform.
  @internal
  @override
  PlatformXDirectory get platform => super.platform as PlatformXDirectory;

  /// Lists the sub-directories and files of this directory.
  Stream<XEntity> list() {
    // Converts PlatformXEntities to XEntities.
    return platform.list(ListParams()).map<XEntity>((PlatformXEntity entity) {
      switch (entity) {
        case PlatformXFile():
          if (entity case PlatformScopedStorageXFile()) {
            return ScopedStorageXFile.fromPlatform(entity);
          }
          return XFile.fromPlatform(entity);
        case PlatformXDirectory():
          if (entity case PlatformScopedStorageXDirectory()) {
            return ScopedStorageXDirectory.fromPlatform(entity);
          }
          return XDirectory.fromPlatform(entity);
      }

      return XEntity(entity);
    });
  }
}
