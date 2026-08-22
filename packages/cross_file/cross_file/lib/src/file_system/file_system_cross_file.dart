// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, immutable, internal;

import '../cross_file.dart';

/// A reference to a local data resource on the file system.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.FileSystemXFile.fromCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the IO implementation of `cross_file`:
///
/// ```dart
/// final FileSystemXFile file = FileSystemXDirectory('my/file.txt');
///
/// final IOFileSystemXFileExtension? ioExtension =
///     file.getExtension<IOFileSystemXFileExtension>();
/// if (ioExtension != null) {
///   print(ioExtension.file.lastAccessedSync());
/// }
/// ```
@immutable
base class FileSystemXFile extends XFile {
  /// Constructs a [FileSystemXFile].
  ///
  /// See [FileSystemXFile.fromCreationParams] for setting parameters
  /// for a specific platform.
  FileSystemXFile(String path)
    : this.fromCreationParams(PlatformFileSystemXFileCreationParams(path));

  /// Constructs a [FileSystemXFile].
  ///
  /// See [FileSystemXFile.fromCreationParams] for setting parameters for a
  /// specific platform.
  FileSystemXFile.fromUri(Uri uri)
    : this(uri.toFilePath(windows: defaultTargetPlatform == TargetPlatform.windows));

  /// Constructs a [FileSystemXFile] from creation params for a specific
  /// platform.
  ///
  /// {@template cross_file.FileSystemXFile.fromCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the Android implementation of `cross_file`:
  ///
  /// ```dart
  /// late final PlatformFileSystemCreationParams params;
  ///
  /// switch(CrossFile.implementation) {
  ///   case CrossFileIO():
  ///     params = IOFileSystemXFileCreationParams.fromFile(
  ///       File('my/file.txt'),
  ///     );
  ///   default:
  ///     params = PlatformFileSystemXFileCreationParams('my/file.txt');
  /// }
  ///
  /// final file = FileSystemXFile.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  FileSystemXFile.fromCreationParams(PlatformFileSystemXFileCreationParams params)
    : this.fromPlatform(PlatformFileSystemXFile(params));

  /// Constructs a [FileSystemXFile] from a specific platform implementation.
  @internal
  const FileSystemXFile.fromPlatform(PlatformFileSystemXFile super.platform);

  @internal
  @override
  PlatformFileSystemXFile get platform => super.platform as PlatformFileSystemXFile;

  /// The path of the file.
  String get path => platform.params.path;

  /// Writes a list of bytes to a file.
  ///
  /// Platforms may throw an exception if there is an error opening or writing
  /// to the file.
  Future<XFile> writeAsBytes(Uint8List bytes) async {
    final PlatformFileSystemXFile platformFile = await platform.writeAsBytes(
      PlatformWriteAsBytesParams(bytes),
    );
    return FileSystemXFile.fromPlatform(platformFile);
  }
}
