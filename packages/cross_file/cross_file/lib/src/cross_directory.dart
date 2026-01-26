// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:meta/meta.dart';

import 'cross_file.dart';
import 'cross_file_entity.dart';
import 'scoped_storage_cross_directory.dart';
import 'scoped_storage_cross_file.dart';

/// A reference to a directory (or folder) on the file system.
///
/// Note: Not all platforms support directories.
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
/// final XDirectory dir = XFile('my/docs/');
///
/// final IOXDirectoryExtension? ioExtension = file.maybeGetExtension<IOXDirectoryExtension>();
/// if (ioExtension != null) {
///   print(ioExtension.directory.path);
/// }
/// ```
@immutable
class XDirectory extends XFileEntity {
  /// Constructs a [XDirectory].
  ///
  /// See [XDirectory.fromCreationParams] for setting parameters for a
  /// specific platform.
  XDirectory(String uri)
    : this.fromCreationParams(PlatformXDirectoryCreationParams(uri: uri));

  /// Constructs a [XDirectory] from creation params for a specific platform.
  ///
  /// {@template cross_file.XDirectory.fromCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the dart:io implementation of `cross_file`:
  ///
  /// ```dart
  /// var params = const PlatformXDirectoryCreationParams(uri: 'my/docs/');
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
  const XDirectory.fromPlatform(PlatformXDirectory super.platform);

  /// Implementation of [PlatformXDirectory] for the current platform.
  @override
  PlatformXDirectory get platform => super.platform as PlatformXDirectory;

  /// Provides a nonnull platform class extension.
  ///
  /// Will throw an exception if the specified platform extension can not be
  /// returned.
  S getExtension<S extends PlatformXDirectoryExtension>() {
    return platform.extension! as S;
  }

  /// Attempt to provide the platform class extension.
  ///
  /// Returns null if the specified platform extension cannot be retrieved.
  S? maybeGetExtension<S extends PlatformXDirectoryExtension>() {
    return platform.extension is S ? platform.extension! as S : null;
  }

  /// Lists the sub-directories and files of this directory.
  Stream<XFileEntity> list() {
    return platform.list(ListParams()).map<XFileEntity>((
      PlatformXFileEntity entity,
    ) {
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

      return XFileEntity(entity);
    });
  }
}
