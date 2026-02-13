// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

final class TestCrossFilePlatform extends CrossFilePlatform {
  TestCrossFilePlatform({
    this.onCreatePlatformXFile,
    this.onCreatePlatformXDirectory,
    this.onCreatePlatformScopedStorageXFile,
    this.onCreatePlatformScopedStorageXDirectory,
  });

  PlatformXFile Function(PlatformXFileCreationParams params)?
  onCreatePlatformXFile;

  PlatformXDirectory Function(PlatformXDirectoryCreationParams params)?
  onCreatePlatformXDirectory;

  PlatformScopedStorageXFile Function(
    PlatformScopedStorageXFileCreationParams params,
  )?
  onCreatePlatformScopedStorageXFile;

  PlatformScopedStorageXDirectory Function(
    PlatformScopedStorageXDirectoryCreationParams params,
  )?
  onCreatePlatformScopedStorageXDirectory;

  @override
  PlatformXFile createPlatformXFile(PlatformXFileCreationParams params) {
    return onCreatePlatformXFile?.call(params) ?? TestXFile(params);
  }

  @override
  PlatformXDirectory createPlatformXDirectory(
    PlatformXDirectoryCreationParams params,
  ) {
    return onCreatePlatformXDirectory?.call(params) ?? TestXDirectory(params);
  }

  @override
  PlatformScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    return onCreatePlatformScopedStorageXFile?.call(params) ??
        TestScopedStorageXFile(params);
  }

  @override
  PlatformScopedStorageXDirectory createPlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    return onCreatePlatformScopedStorageXDirectory?.call(params) ??
        TestScopedStorageXDirectory(params);
  }
}

final class TestXFile extends PlatformXFile {
  TestXFile(
    super.params, {
    this.onCanRead,
    this.onExists,
    this.onLastModified,
    this.onLength,
    this.onName,
    this.onOpenRead,
    this.onReadAsBytes,
    this.onReadAsString,
  }) : super.implementation();

  Future<bool> Function()? onCanRead;
  Future<bool> Function()? onExists;
  Future<DateTime?> Function()? onLastModified;
  Future<int?> Function()? onLength;
  Future<String?> Function()? onName;
  Stream<Uint8List> Function()? onOpenRead;
  Future<Uint8List> Function()? onReadAsBytes;
  Future<String> Function({required Encoding encoding})? onReadAsString;

  @override
  Future<bool> canRead() async {
    return await onCanRead?.call() ?? false;
  }

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }

  @override
  Future<DateTime?> lastModified() async {
    return await onLastModified?.call();
  }

  @override
  Future<int?> length() async {
    return await onLength?.call();
  }

  @override
  Future<String?> name() async {
    return await onName?.call();
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    if (onOpenRead != null) {
      yield* onOpenRead!.call();
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return await onReadAsBytes?.call() ?? Uint8List(0);
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return await onReadAsString?.call(encoding: encoding) ?? '';
  }
}

final class TestXDirectory extends PlatformXDirectory {
  TestXDirectory(super.params, {this.onExists, this.onList})
    : super.implementation();

  Future<bool> Function()? onExists;
  Stream<PlatformXFileEntity> Function(ListParams params)? onList;

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }

  @override
  Stream<PlatformXFileEntity> list(ListParams params) async* {
    if (onList != null) {
      yield* onList!.call(params);
    }
  }
}

final class TestScopedStorageXFile extends PlatformScopedStorageXFile {
  TestScopedStorageXFile(
    super.params, {
    this.onCanRead,
    this.onExists,
    this.onLastModified,
    this.onLength,
    this.onName,
    this.onOpenRead,
    this.onReadAsBytes,
    this.onReadAsString,
  }) : super.implementation();

  Future<bool> Function()? onCanRead;
  Future<bool> Function()? onExists;
  Future<DateTime?> Function()? onLastModified;
  Future<int?> Function()? onLength;
  Future<String?> Function()? onName;
  Stream<Uint8List> Function()? onOpenRead;
  Future<Uint8List> Function()? onReadAsBytes;
  Future<String> Function({required Encoding encoding})? onReadAsString;

  @override
  Future<bool> canRead() async {
    return await onCanRead?.call() ?? false;
  }

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }

  @override
  Future<DateTime?> lastModified() async {
    return await onLastModified?.call();
  }

  @override
  Future<int?> length() async {
    return await onLength?.call();
  }

  @override
  Future<String?> name() async {
    return await onName?.call();
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    if (onOpenRead != null) {
      yield* onOpenRead!.call();
    }
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return await onReadAsBytes?.call() ?? Uint8List(0);
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return await onReadAsString?.call(encoding: encoding) ?? '';
  }
}

final class TestScopedStorageXDirectory
    extends PlatformScopedStorageXDirectory {
  TestScopedStorageXDirectory(super.params, {this.onExists, this.onList})
    : super.implementation();

  Future<bool> Function()? onExists;
  Stream<PlatformXFileEntity> Function(ListParams params)? onList;

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }

  @override
  Stream<PlatformXFileEntity> list(ListParams params) async* {
    if (onList != null) {
      yield* onList!.call(params);
    }
  }
}

final class TestXFileEntity extends PlatformXFileEntity {
  TestXFileEntity(super.params, {this.onExists});

  Future<bool> Function()? onExists;

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }
}
