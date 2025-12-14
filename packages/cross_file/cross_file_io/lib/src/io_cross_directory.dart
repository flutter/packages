// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'io_cross_file.dart';

/// Implementation of [PlatformXDirectory] for dart:io.
base class IOXDirectory extends PlatformXDirectory with IOXDirectoryExtension {
  /// Constructs an [IOXDirectory].
  IOXDirectory(super.params) : super.implementation();

  @override
  late final directory = Directory(params.uri);

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
