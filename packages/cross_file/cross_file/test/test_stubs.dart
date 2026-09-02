// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

final class TestCrossFilePlatform extends CrossFilePlatform {
  TestCrossFilePlatform({
    this.onCreatePlatformFileSystemXFile,
    this.onCreatePlatformFileSystemXDirectory,
    this.onCreatePlatformScopedStorageXFile,
    this.onCreatePlatformScopedStorageXDirectory,
  });

  PlatformFileSystemXFile Function(PlatformFileSystemXFileCreationParams params)?
  onCreatePlatformFileSystemXFile;

  PlatformFileSystemXDirectory Function(PlatformFileSystemXDirectoryCreationParams params)?
  onCreatePlatformFileSystemXDirectory;

  PlatformScopedStorageXFile Function(PlatformScopedStorageXFileCreationParams params)?
  onCreatePlatformScopedStorageXFile;

  PlatformScopedStorageXDirectory Function(PlatformScopedStorageXDirectoryCreationParams params)?
  onCreatePlatformScopedStorageXDirectory;

  @override
  PlatformFileSystemXFile createPlatformFileSystemXFile(
    PlatformFileSystemXFileCreationParams params,
  ) {
    return onCreatePlatformFileSystemXFile?.call(params) ?? TestFileSystemXFile(params);
  }

  @override
  PlatformFileSystemXDirectory createPlatformFileSystemXDirectory(
    PlatformFileSystemXDirectoryCreationParams params,
  ) {
    return onCreatePlatformFileSystemXDirectory?.call(params) ?? TestFileSystemXDirectory(params);
  }

  @override
  PlatformScopedStorageXFile createPlatformScopedStorageXFile(
    PlatformScopedStorageXFileCreationParams params,
  ) {
    return onCreatePlatformScopedStorageXFile?.call(params) ?? TestScopedStorageXFile(params);
  }

  @override
  PlatformScopedStorageXDirectory createPlatformScopedStorageXDirectory(
    PlatformScopedStorageXDirectoryCreationParams params,
  ) {
    return onCreatePlatformScopedStorageXDirectory?.call(params) ??
        TestScopedStorageXDirectory(params);
  }
}

final class TestFileSystemXFile extends PlatformFileSystemXFile {
  TestFileSystemXFile(
    super.params, {
    this.onExists,
    this.onLastModified,
    this.onLength,
    this.onName,
    this.onOpenRead,
    this.onReadAsBytes,
    this.onReadAsString,
    this.onWriteAsBytes,
  }) : super.implementation();

  Future<bool> Function()? onExists;
  Future<DateTime?> Function()? onLastModified;
  Future<int?> Function()? onLength;
  Future<String?> Function()? onName;
  Stream<Uint8List> Function()? onOpenRead;
  Future<Uint8List> Function()? onReadAsBytes;
  Future<String> Function({required Encoding encoding})? onReadAsString;
  Future<TestFileSystemXFile> Function(Uint8List bytes)? onWriteAsBytes;

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

  @override
  Future<PlatformFileSystemXFile> writeAsBytes(PlatformWriteAsBytesParams params) async {
    if (onWriteAsBytes != null) {
      return onWriteAsBytes!.call(params.bytes);
    }

    throw UnimplementedError();
  }
}

final class TestFileSystemXDirectory extends PlatformFileSystemXDirectory {
  TestFileSystemXDirectory(super.params, {this.onExists, this.onList}) : super.implementation();

  Future<bool> Function()? onExists;
  Stream<PlatformXEntity> Function(PlatformListParams params)? onList;

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) async* {
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
    this.onDispose,
  }) : super.implementation();

  Future<bool> Function()? onCanRead;
  Future<bool> Function()? onExists;
  Future<DateTime?> Function()? onLastModified;
  Future<int?> Function()? onLength;
  Future<String?> Function()? onName;
  Stream<Uint8List> Function()? onOpenRead;
  Future<Uint8List> Function()? onReadAsBytes;
  Future<String> Function({required Encoding encoding})? onReadAsString;
  Future<void> Function()? onDispose;

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

  @override
  Future<void> dispose() async {
    return await onDispose?.call();
  }
}

final class TestScopedStorageXDirectory extends PlatformScopedStorageXDirectory {
  TestScopedStorageXDirectory(
    super.params, {
    this.onExists,
    this.onList,
    this.onCanRead,
    this.onDispose,
  }) : super.implementation();

  Future<bool> Function()? onExists;
  Stream<PlatformXEntity> Function(PlatformListParams params)? onList;
  Future<bool> Function()? onCanRead;
  Future<void> Function()? onDispose;

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }

  @override
  Future<bool> canRead() async {
    return await onCanRead?.call() ?? false;
  }

  @override
  Stream<PlatformXEntity> list(PlatformListParams params) async* {
    if (onList != null) {
      yield* onList!.call(params);
    }
  }

  @override
  Future<void> dispose() async {
    return await onDispose?.call();
  }
}

final class TestXEntity extends PlatformXEntity {
  TestXEntity(super.params, {this.onExists});

  Future<bool> Function()? onExists;

  @override
  Future<bool> exists() async {
    return await onExists?.call() ?? false;
  }
}
