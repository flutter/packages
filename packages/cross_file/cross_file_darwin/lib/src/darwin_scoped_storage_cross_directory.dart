// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';

import 'cross_file_darwin_apis.g.dart';
import 'darwin_scoped_storage_cross_file.dart';

/// Implementation of [PlatformScopedStorageXFileCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinScopedStorageXDirectoryCreationParams
    extends PlatformScopedStorageXDirectoryCreationParams {
  /// Constructs a [PlatformScopedStorageXDirectoryCreationParams].
  DarwinScopedStorageXDirectoryCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  /// The API used to call to native code to interact with files.
  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformScopedStorageXDirectory] for iOS and macOS.
base class DarwinScopedStorageXDirectory extends PlatformScopedStorageXDirectory
    with DarwinScopedStorageXDirectoryExtension {
  /// Constructs an [DarwinScopedStorageXDirectory].
  DarwinScopedStorageXDirectory(super.params) : super.implementation();

  @override
  late final DarwinScopedStorageXDirectoryCreationParams params =
      super.params is DarwinScopedStorageXDirectoryCreationParams
      ? super.params as DarwinScopedStorageXDirectoryCreationParams
      : DarwinScopedStorageXDirectoryCreationParams(uri: super.params.uri);

  @override
  PlatformXFileEntityExtension? get extension => this;

  @override
  Future<DarwinScopedStorageXDirectory?> toBookmarkedDirectory() async {
    final String? bookmarkedUrl = await params.api.tryCreateBookmarkedUrl(
      params.uri,
    );

    return bookmarkedUrl != null
        ? DarwinScopedStorageXDirectory(
            DarwinScopedStorageXDirectoryCreationParams(uri: bookmarkedUrl),
          )
        : null;
  }

  @override
  Future<bool> exists() async {
    final FileExistsResult result = await params.api.fileExists(params.uri);
    return result.exists && result.isDirectory;
  }

  @override
  Stream<PlatformXFileEntity> list(ListParams params) async* {
    for (final String url in await this.params.api.list(this.params.uri)) {
      final FileExistsResult existsResult = await this.params.api.fileExists(
        url,
      );
      if (existsResult.isDirectory) {
        yield DarwinScopedStorageXDirectory(
          PlatformScopedStorageXDirectoryCreationParams(uri: url),
        );
      } else {
        yield DarwinScopedStorageXFile(
          PlatformScopedStorageXFileCreationParams(uri: url),
        );
      }
    }
  }
}

/// Provides platform specific features for [DarwinScopedStorageXDirectory].
mixin DarwinScopedStorageXDirectoryExtension
    implements PlatformScopedStorageXDirectoryExtension {
  /// Attempt to create a bookmarked directory that serves as a persistent
  /// reference to the directory.
  ///
  /// Throws exception if the directory could not be bookmarked or null if the
  /// bookmark is stale.
  Future<DarwinScopedStorageXDirectory?> toBookmarkedDirectory();
}
