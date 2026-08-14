// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable, internal;

import '../cross_directory.dart';

/// A reference to a directory (or folder) on the file system.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.FileSystemXDirectory.fromCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the IO implementation of `cross_file`:
///
/// ```dart
/// final FileSystemXDirectory dir = FileSystemXDirectory(uri: 'my/dir/');
///
/// final IOFileSystemXDirectoryExtension? ioExtension =
///     file.getExtension<IOFileSystemXDirectoryExtension>();
/// if (ioExtension != null) {
///   print(ioExtension.directory.statSync().accessed);
/// }
/// ```
@immutable
base class FileSystemXDirectory extends XDirectory {
  /// Constructs a [FileSystemXDirectory].
  ///
  /// See [FileSystemXDirectory.fromCreationParams] for setting parameters
  /// for a specific platform.
  FileSystemXDirectory(String path)
    : this.fromCreationParams(PlatformFileSystemXDirectoryCreationParams(path));

  /// Constructs a [FileSystemXDirectory].
  ///
  /// See [FileSystemXDirectory.fromCreationParams] for setting parameters
  /// for a specific platform.
  FileSystemXDirectory.fromUri(Uri uri)
    : this(uri.toFilePath(windows: defaultTargetPlatform == TargetPlatform.windows));

  /// Constructs a [FileSystemXDirectory] from creation params for a specific
  /// platform.
  ///
  /// {@template cross_file.FileSystemXDirectory.fromCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the IO implementation of `cross_file`:
  ///
  /// ```dart
  /// late final PlatformFileSystemXDirectoryCreationParams params;
  ///
  /// switch(CrossFile.implementation) {
  ///   case CrossFileIO():
  ///     params = IOFileSystemXDirectoryCreationParams.fromDirectory(
  ///       Directory('my/dir/'),
  ///     );
  ///   default:
  ///     params = PlatformFileSystemXDirectoryCreationParams('my/dir/');
  /// }
  ///
  /// final dir = FileSystemXDirectory.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  FileSystemXDirectory.fromCreationParams(PlatformFileSystemXDirectoryCreationParams params)
    : this.fromPlatform(PlatformFileSystemXDirectory(params));

  /// Constructs a [FileSystemXDirectory] from a specific platform
  /// implementation.
  @internal
  const FileSystemXDirectory.fromPlatform(PlatformFileSystemXDirectory super.platform);

  /// The path of the directory.
  String get path => platform.params.path;

  @internal
  @override
  PlatformFileSystemXDirectory get platform => super.platform as PlatformFileSystemXDirectory;
}
