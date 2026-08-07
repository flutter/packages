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
  IOFileSystemXFileCreationParams({required String uri})
    : this.fromFile(File.fromUri(Uri.parse(uri)));

  /// Constructs an [IOFileSystemXFileCreationParams] from a [File].
  IOFileSystemXFileCreationParams.fromFile(this.file) : super(uri: file.uri.toString());

  /// Constructs an [IOFileSystemXFileCreationParams] from a [PlatformXFileCreationParams].
  factory IOFileSystemXFileCreationParams.fromCreationParams(PlatformXFileCreationParams params) {
    return IOFileSystemXFileCreationParams(uri: params.uri);
  }

  /// The underlying [File] for [IOFileSystemXFile].
  final File file;
}

/// Implementation of [PlatformXFile] for dart:io.
base class IOFileSystemXFile extends PlatformXFile with IOFileSystemXFileExtension {
  /// Constructs an [IOFileSystemXFile].
  IOFileSystemXFile(super.params);

  @override
  late final IOFileSystemXFileCreationParams params =
      super.params is IOFileSystemXFileCreationParams
      ? super.params as IOFileSystemXFileCreationParams
      : IOFileSystemXFileCreationParams.fromCreationParams(super.params);

  @override
  File get file => params.file;

  @override
  PlatformXFileExtension? get extension => this;

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
}

/// Provides platform-specific features for [IOFileSystemXFile].
mixin IOFileSystemXFileExtension implements PlatformFileSystemXFileExtension {
  /// The underlying file.
  File get file;
}
