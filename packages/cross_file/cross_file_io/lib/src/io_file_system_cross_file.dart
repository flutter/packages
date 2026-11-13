// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:path/path.dart' as path;

/// Implementation of [PlatformFileSystemXFileCreationParams] for dart:io.
@immutable
base class IOFileSystemXFileCreationParams extends PlatformFileSystemXFileCreationParams {
  /// Constructs an [IOFileSystemXFileCreationParams].
  IOFileSystemXFileCreationParams(String path) : this.fromFile(File(path));

  /// Constructs an [IOFileSystemXFileCreationParams] from a [File].
  IOFileSystemXFileCreationParams.fromFile(this.file) : super(file.path);

  /// Constructs an [IOFileSystemXFileCreationParams] from a [PlatformFileSystemXFileCreationParams].
  factory IOFileSystemXFileCreationParams.fromCreationParams(
    PlatformFileSystemXFileCreationParams params,
  ) {
    return IOFileSystemXFileCreationParams(params.path);
  }

  /// The underlying [File] for [IOFileSystemXFile].
  final File file;
}

/// Implementation of [PlatformFileSystemXFile] for dart:io.
base class IOFileSystemXFile extends PlatformFileSystemXFile with IOFileSystemXFileExtension {
  /// Constructs an [IOFileSystemXFile].
  IOFileSystemXFile(super.params) : super.implementation();

  @override
  late final IOFileSystemXFileCreationParams params =
      super.params is IOFileSystemXFileCreationParams
      ? super.params as IOFileSystemXFileCreationParams
      : IOFileSystemXFileCreationParams.fromCreationParams(super.params);

  @override
  File get file => params.file;

  @override
  PlatformFileSystemXFileExtension? get extension => this;

  @override
  Future<DateTime?> lastModified() async {
    try {
      return file.lastModifiedSync();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<int?> length() async {
    try {
      return await file.length();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) => file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) => file.readAsString(encoding: encoding);

  @override
  Future<bool> exists() async => file.existsSync();

  @override
  Future<String?> name() async => path.basename(file.path);

  @override
  Future<PlatformFileSystemXFile> writeAsBytes(PlatformWriteAsBytesParams params) async {
    final File ioFile = await file.writeAsBytes(params.bytes);
    return IOFileSystemXFile(IOFileSystemXFileCreationParams.fromFile(ioFile));
  }
}

/// Provides platform-specific features for [IOFileSystemXFile].
mixin IOFileSystemXFileExtension implements PlatformFileSystemXFileExtension {
  /// The underlying file.
  File get file;
}
