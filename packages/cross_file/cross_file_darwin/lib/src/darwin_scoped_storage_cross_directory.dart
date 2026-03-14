// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'cross_file_darwin_apis.g.dart';
import 'darwin_scoped_storage_cross_file.dart';
import 'security_scoped_resource.dart';

/// Implementation of [PlatformXDirectoryCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinScopedStorageXDirectoryCreationParams
    extends PlatformScopedStorageXDirectoryCreationParams {
  /// Constructs a [DarwinScopedStorageXDirectoryCreationParams].
  DarwinScopedStorageXDirectoryCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  /// Constructs an [DarwinScopedStorageXDirectoryCreationParams] from a
  /// [PlatformScopedStorageXDirectoryCreationParams].
  factory DarwinScopedStorageXDirectoryCreationParams.fromCreationParams(
    PlatformScopedStorageXDirectoryCreationParams params, {
    @visibleForTesting CrossFileDarwinApi? api,
  }) {
    return DarwinScopedStorageXDirectoryCreationParams(
      uri: params.uri,
      api: api,
    );
  }

  /// The API used to call to native code to interact with files.
  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformScopedStorageXDirectory] for iOS and macOS.
base class DarwinScopedStorageXDirectory extends PlatformScopedStorageXDirectory
    with DarwinScopedStorageXDirectoryExtension {
  /// Constructs a [DarwinScopedStorageXDirectory].
  DarwinScopedStorageXDirectory(super.params) : super.implementation();

  late final _directory = Directory.fromUri(Uri.parse(params.uri));

  @override
  late final DarwinScopedStorageXDirectoryCreationParams params =
      super.params is DarwinScopedStorageXDirectoryCreationParams
      ? super.params as DarwinScopedStorageXDirectoryCreationParams
      : DarwinScopedStorageXDirectoryCreationParams.fromCreationParams(
          super.params,
        );

  @override
  DarwinScopedStorageXDirectoryExtension? get extension => this;

  @override
  Future<bool> exists() async => _directory.existsSync();

  @override
  Stream<PlatformXFileEntity> list(ListParams params) async* {
    await for (final FileSystemEntity entity in _directory.list()) {
      switch (entity) {
        case final Directory directory:
          yield DarwinScopedStorageXDirectory(
            DarwinScopedStorageXDirectoryCreationParams(
              uri: directory.uri.toString(),
            ),
          );
        case final File file:
          yield DarwinScopedStorageXFile(
            DarwinScopedStorageXFileCreationParams(uri: file.uri.toString()),
          );
      }
    }
  }

  @override
  Future<bool> startAccessingSecurityScopedResource() {
    return params.api.startAccessingSecurityScopedResource(params.uri);
  }

  @override
  Future<void> stopAccessingSecurityScopedResource() {
    return params.api.stopAccessingSecurityScopedResource(params.uri);
  }
}

/// Provides platform specific features for [DarwinScopedStorageXDirectory].
mixin DarwinScopedStorageXDirectoryExtension
    implements
        PlatformScopedStorageXDirectoryExtension,
        SecurityScopedResource {}
