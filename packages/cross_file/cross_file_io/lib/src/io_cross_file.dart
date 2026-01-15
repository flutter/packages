// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Implementation of [PlatformXFileCreationParams] for dart:io.
@immutable
base class IOXFileCreationParams extends PlatformXFileCreationParams {
  /// Constructs an [IOXFileCreationParams].
  IOXFileCreationParams({required String uri}) : this.fromFile(File(uri));

  /// Constructs an [IOXFileCreationParams] from a [File].
  IOXFileCreationParams.fromFile(this.file) : super(uri: file.path);

  /// Constructs an [IOXFileCreationParams] from a [PlatformXFileCreationParams].
  factory IOXFileCreationParams.fromCreationParams(
    PlatformXFileCreationParams params,
  ) {
    return IOXFileCreationParams(uri: params.uri);
  }

  /// The underlying [File] for [IOXFile].
  final File file;
}

/// Implementation of [PlatformXFile] for dart:io.
base class IOXFile extends PlatformXFile with IOXFileExtension {
  /// Constructs an [IOXFile].
  IOXFile(super.params) : super.implementation();

  @override
  late final IOXFileCreationParams params =
      super.params is IOXFileCreationParams
      ? super.params as IOXFileCreationParams
      : IOXFileCreationParams.fromCreationParams(super.params);

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
      return file.length();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      file.readAsString(encoding: encoding);

  @override
  Future<bool> canRead() => exists();

  @override
  Future<bool> exists() async => file.existsSync();

  @override
  Future<String?> name() async => path.basename(file.path);
}

/// Provides platform specific features for [IOXFile].
mixin IOXFileExtension implements PlatformXFileExtension {
  /// The underlying file.
  File get file;
}
