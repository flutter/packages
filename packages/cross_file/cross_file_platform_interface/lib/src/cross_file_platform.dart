// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:typed_data';

import 'platform_cross_directory.dart';
import 'platform_cross_file.dart';
import 'platform_cross_file_entity.dart';
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
  PlatformXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return _DefaultXFile(params);
  }

  /// Creates a new [PlatformXDirectory].
  PlatformXDirectory createPlatformXDirectory(
    PlatformXDirectoryCreationParams params,
  ) {
    return _DefaultXDirectory(params);
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

/// Implementation of [PlatformXFile} that represents a resource that does not
/// exist.
final class _DefaultXFile extends PlatformXFile {
  _DefaultXFile(super.params) : super.implementation();

  @override
  Future<bool> exists() async => false;

  @override
  Future<DateTime?> lastModified() async => null;

  @override
  Future<int?> length() async => null;

  @override
  Future<String?> name() async => null;

  @override
  Stream<Uint8List> openRead([int? start, int? end]) {
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
}

/// Implementation of [PlatformXDirectory} that represents a directory that does
/// not exist.
final class _DefaultXDirectory extends PlatformXDirectory {
  _DefaultXDirectory(super.params) : super.implementation();

  @override
  Future<bool> exists() async => false;

  @override
  Stream<PlatformXFileEntity> list(ListParams params) {
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
  Stream<Uint8List> openRead([int? start, int? end]) {
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
}

/// Implementation of [PlatformScopedStorageXDirectory} that represents a
/// directory that does not exist.
final class _DefaultScopedStorageXDirectory
    extends PlatformScopedStorageXDirectory {
  _DefaultScopedStorageXDirectory(super.params) : super.implementation();

  @override
  Future<bool> exists() async => false;

  @override
  Stream<PlatformXFileEntity> list(ListParams params) {
    throw UnsupportedError('This instance does not represent any directory.');
  }
}
