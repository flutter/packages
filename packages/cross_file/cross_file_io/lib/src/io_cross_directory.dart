// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'io_cross_file.dart';

/// Implementation of [PlatformXDirectoryCreationParams] for dart:io.
@immutable
base class IOXDirectoryCreationParams extends PlatformXDirectoryCreationParams {
  /// Constructs an [IOXDirectoryCreationParams].
  IOXDirectoryCreationParams({required String uri})
    : this.fromFile(Directory(uri));

  /// Constructs an [IOXDirectoryCreationParams] from a [Directory].
  IOXDirectoryCreationParams.fromFile(this.directory)
    : super(uri: directory.path);

  /// Constructs an [IOXDirectoryCreationParams] from a [PlatformXDirectoryCreationParams].
  factory IOXDirectoryCreationParams.fromCreationParams(
    PlatformXDirectoryCreationParams params,
  ) {
    return IOXDirectoryCreationParams(uri: params.uri);
  }

  /// The underlying [Directory] for [IOXDirectory].
  final Directory directory;
}

/// Implementation of [PlatformXDirectory] for dart:io.
base class IOXDirectory extends PlatformXDirectory with IOXDirectoryExtension {
  /// Constructs an [IOXDirectory].
  IOXDirectory(super.params) : super.implementation();

  @override
  late final IOXDirectoryCreationParams params =
      super.params is IOXDirectoryCreationParams
      ? super.params as IOXDirectoryCreationParams
      : IOXDirectoryCreationParams.fromCreationParams(super.params);

  @override
  Directory get directory => params.directory;

  @override
  IOXDirectoryExtension? get extension => this;

  @override
  Future<bool> exists() async => directory.existsSync();

  @override
  Stream<PlatformXFileEntity> list(ListParams params) async* {
    await for (final FileSystemEntity entity in directory.list()) {
      switch (entity) {
        case final Directory directory:
          yield IOXDirectory(
            PlatformXDirectoryCreationParams(uri: directory.path),
          );
        case final File file:
          yield IOXFile(PlatformXFileCreationParams(uri: file.path));
      }
    }
  }
}

/// Provides platform specific features for [IOXDirectory].
mixin IOXDirectoryExtension implements PlatformXDirectoryExtension {
  /// The underlying directory.
  Directory get directory;
}
