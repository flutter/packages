// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'file_system/platform_file_system_cross_directory.dart';
import 'file_system/platform_file_system_cross_file.dart';
import 'platform_cross_directory.dart';
import 'platform_cross_entity.dart';
import 'platform_cross_file.dart';
import 'scoped_storage/platform_scoped_storage_cross_directory.dart';
import 'scoped_storage/platform_scoped_storage_cross_file.dart';

/// Interface for a platform implementation of `cross_file`.
abstract base class CrossFilePlatform {
  /// The instance of [CrossFilePlatform] to be used.
  ///
  /// Platform implementations packages should set this with their own
  /// implementation of [CrossFilePlatform] when they register themselves.
  static CrossFilePlatform? instance;

  /// Creates a new [PlatformXFile].
  PlatformFileSystemXFile createPlatformFileSystemXFile(
    PlatformFileSystemXFileCreationParams params,
  ) {
    return _DefaultFileSystemXFile(params);
  }

  /// Creates a new [PlatformFileSystemXDirectory].
  PlatformFileSystemXDirectory createPlatformFileSystemXDirectory(
    PlatformFileSystemXDirectoryCreationParams params,
  ) {
    return _DefaultFileSystemXDirectory(params);
  }

  /// Creates a new [PlatformScopedStorageXDirectory].
  PlatformScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    return _DefaultScopedStorageXFile(params);
  }

  /// Creates a new [PlatformScopedStorageXDirectory].
  PlatformScopedStorageXDirectory createPlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    return _DefaultScopedStorageXDirectory(params);
  }
}

/// Implementation of [PlatformFileSystemXFile} that represents a resource that
/// does not exist.
final class _DefaultFileSystemXFile extends PlatformFileSystemXFile {
  _DefaultFileSystemXFile(super.params) : super.implementation();

  @override
  Future<bool> exists() async => false;

  @override
  Future<DateTime?> lastModified() async => null;

  @override
  Future<int?> length() async => null;

  @override
  Future<String?> name() async => null;

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    throw UnsupportedError('This instance does not represent any resource.');
  }

  @override
  Future<Uint8List> readAsBytes() {
    throw UnsupportedError('This instance does not represent any resource.');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    throw UnsupportedError('This instance does not represent any resource.');
  }

  @override
  Future<PlatformFileSystemXFile> writeAsBytes(PlatformWriteAsBytesParams params) {
    throw UnsupportedError('This instance does not represent any resource.');
  }
}

/// Implementation of [PlatformFileSystemXDirectory} that represents a directory
/// that does not exist.
final class _DefaultFileSystemXDirectory extends PlatformFileSystemXDirectory {
  _DefaultFileSystemXDirectory(super.params) : super.implementation();

  @override
  Future<bool> exists() async => false;

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) async* {
    throw UnsupportedError('This instance does not represent any directory.');
  }
}

/// Implementation of [PlatformScopedStorageXFile} that represents a resource
/// that does not exist.
final class _DefaultScopedStorageXFile extends PlatformScopedStorageXFile {
  _DefaultScopedStorageXFile(super.params) : super.implementation();

  @override
  Future<bool> canRead() async => false;

  @override
  Future<bool> exists() async => false;

  @override
  Future<DateTime?> lastModified() async => null;

  @override
  Future<int?> length() async => null;

  @override
  Future<String?> name() async => null;

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    throw UnsupportedError('This instance does not represent any resource.');
  }

  @override
  Future<Uint8List> readAsBytes() {
    throw UnsupportedError('This instance does not represent any resource.');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    throw UnsupportedError('This instance does not represent any resource.');
  }

  @override
  Future<void> dispose() async {}
}

/// Implementation of [PlatformScopedStorageXDirectory} that represents a
/// directory that does not exist.
final class _DefaultScopedStorageXDirectory extends PlatformScopedStorageXDirectory {
  _DefaultScopedStorageXDirectory(super.params) : super.implementation();

  @override
  Future<bool> exists() async => false;

  @override
  Future<bool> canRead() async => false;

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) async* {
    throw UnsupportedError('This instance does not represent any directory.');
  }

  @override
  Future<void> dispose() async {}
}
