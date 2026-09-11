// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'io_file_system_cross_file.dart';

/// Implementation of [PlatformFileSystemXDirectoryCreationParams] for dart:io.
@immutable
base class IOFileSystemXDirectoryCreationParams extends PlatformFileSystemXDirectoryCreationParams {
  /// Constructs an [IOFileSystemXDirectoryCreationParams].
  IOFileSystemXDirectoryCreationParams(String path) : this.fromDirectory(Directory(path));

  /// Constructs an [IOFileSystemXDirectoryCreationParams] from a [Directory].
  IOFileSystemXDirectoryCreationParams.fromDirectory(this.directory) : super(directory.path);

  /// Constructs an [IOFileSystemXDirectoryCreationParams] from a
  /// [PlatformFileSystemXDirectoryCreationParams].
  factory IOFileSystemXDirectoryCreationParams.fromCreationParams(
    PlatformFileSystemXDirectoryCreationParams params,
  ) {
    return IOFileSystemXDirectoryCreationParams(params.path);
  }

  /// The underlying [Directory] for [IOFileSystemXDirectory].
  final Directory directory;
}

/// Implementation of [PlatformFileSystemXDirectory] for dart:io.
base class IOFileSystemXDirectory extends PlatformFileSystemXDirectory
    with IOFileSystemXDirectoryExtension {
  /// Constructs an [IOFileSystemXDirectory].
  IOFileSystemXDirectory(super.params) : super.implementation();

  @override
  late final IOFileSystemXDirectoryCreationParams params =
      super.params is IOFileSystemXDirectoryCreationParams
      ? super.params as IOFileSystemXDirectoryCreationParams
      : IOFileSystemXDirectoryCreationParams.fromCreationParams(super.params);

  @override
  Directory get directory => params.directory;

  @override
  IOFileSystemXDirectoryExtension? get extension => this;

  @override
  Future<bool> exists() async => directory.existsSync();

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) async* {
    await for (final FileSystemEntity entity in directory.list()) {
      switch (entity) {
        case final Directory directory:
          yield IOFileSystemXDirectory(
            IOFileSystemXDirectoryCreationParams.fromDirectory(directory),
          );
        case final File file:
          yield IOFileSystemXFile(IOFileSystemXFileCreationParams.fromFile(file));
      }
    }
  }
}

/// Provides platform-specific features for [IOFileSystemXDirectory].
mixin IOFileSystemXDirectoryExtension implements PlatformFileSystemXDirectoryExtension {
  /// The underlying directory.
  Directory get directory;
}
