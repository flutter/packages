// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

import 'android_library.g.dart';
import 'android_scoped_storage_cross_file.dart';

/// Implementation of [PlatformScopedStorageXDirectory] for Android.
base class AndroidScopedStorageXDirectory extends PlatformScopedStorageXDirectory {
  /// Constructs an [AndroidScopedStorageXDirectory].
  AndroidScopedStorageXDirectory(super.params) : super.implementation();

  late final DocumentFile _documentFile = DocumentFile.fromTreeUri(treeUri: params.uri);

  @override
  Future<bool> canRead() => _documentFile.canRead();

  @override
  Future<bool> exists() async {
    return await _documentFile.exists() && await _documentFile.isDirectory();
  }

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) async* {
    for (final DocumentFile documentFile in await _documentFile.listFiles()) {
      final String uri = await documentFile.getUri();
      if (await documentFile.isFile()) {
        yield AndroidScopedStorageXFile(PlatformScopedStorageXFileCreationParams(uri: uri));
      } else if (await documentFile.isDirectory()) {
        yield AndroidScopedStorageXDirectory(
          PlatformScopedStorageXDirectoryCreationParams(uri: uri),
        );
      }
    }
  }

  @override
  Future<bool> canWrite() => _documentFile.canWrite();

  @override
  Future<PlatformXFile> createFile(PlatformCreateParams params) async {
    final DocumentFile? file = await _documentFile.createFile(params.name);
    if (file != null) {
      final String uri = await file.getUri();
      return AndroidScopedStorageXFile(PlatformScopedStorageXFileCreationParams(uri: uri));
    }

    throw Exception('Failed to create file in directory with uri: ${this.params.uri}');
  }

  @override
  Future<PlatformXDirectory> createDirectory(PlatformCreateParams params) async {
    final DocumentFile? file = await _documentFile.createDirectory(params.name);
    if (file != null) {
      final String uri = await file.getUri();
      return AndroidScopedStorageXDirectory(
        PlatformScopedStorageXDirectoryCreationParams(uri: uri),
      );
    }

    throw Exception('Failed to create directory in directory with uri: ${this.params.uri}');
  }

  @override
  Future<bool> delete(PlatformDirectoryDeleteParams params) => _documentFile.delete();

  @override
  Future<void> dispose() async {
    // Reference to the resource does not need to be released.
  }
}
