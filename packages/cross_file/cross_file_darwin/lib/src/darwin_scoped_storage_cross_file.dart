// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'cross_file_darwin_apis.g.dart';
import 'security_scoped_resource.dart';

/// Implementation of [DarwinScopedStorageXFileCreationParams] for iOS and
/// macOS.
@immutable
base class DarwinScopedStorageXFileCreationParams
    extends PlatformScopedStorageXFileCreationParams {
  /// Constructs a [DarwinScopedStorageXFileCreationParams].
  DarwinScopedStorageXFileCreationParams({
    required super.uri,
    @visibleForTesting CrossFileDarwinApi? api,
  }) : api = api ?? CrossFileDarwinApi();

  /// Constructs an [DarwinScopedStorageXFileCreationParams] from a
  /// [PlatformScopedStorageXFileCreationParams].
  factory DarwinScopedStorageXFileCreationParams.fromCreationParams(
    PlatformXFileCreationParams params, {
    @visibleForTesting CrossFileDarwinApi? api,
  }) {
    return DarwinScopedStorageXFileCreationParams(uri: params.uri, api: api);
  }

  /// The API used to call to native code to interact with files.
  @visibleForTesting
  final CrossFileDarwinApi api;
}

/// Implementation of [PlatformScopedStorageXFile] for iOS and macOS.
base class DarwinScopedStorageXFile extends PlatformScopedStorageXFile
    with DarwinScopedStorageXFileExtension {
  /// Constructs a [DarwinScopedStorageXFile].
  DarwinScopedStorageXFile(super.params) : super.implementation();

  late final _file = File.fromUri(Uri.parse(params.uri));

  @override
  late final DarwinScopedStorageXFileCreationParams params =
      super.params is DarwinScopedStorageXFileCreationParams
      ? super.params as DarwinScopedStorageXFileCreationParams
      : DarwinScopedStorageXFileCreationParams.fromCreationParams(super.params);

  @override
  DarwinScopedStorageXFileExtension? get extension => this;

  @override
  Future<DateTime?> lastModified() async {
    try {
      return _file.lastModifiedSync();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<int?> length() async {
    try {
      return _file.length();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      _file.openRead(start, end).cast();

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _file.readAsString(encoding: encoding);

  @override
  Future<bool> canRead() => exists();

  @override
  Future<bool> exists() async => _file.existsSync();

  @override
  Future<String?> name() async => path.basename(_file.path);

  @override
  Future<bool> startAccessingSecurityScopedResource() {
    return params.api.startAccessingSecurityScopedResource(params.uri);
  }

  @override
  Future<void> stopAccessingSecurityScopedResource() {
    return params.api.stopAccessingSecurityScopedResource(params.uri);
  }

  @override
  Future<String?> toBookmarkedUri() async {
    return params.api.tryCreateBookmarkedUrl(params.uri);
  }
}

/// Provides platform specific features for [DarwinScopedStorageXFile].
mixin DarwinScopedStorageXFileExtension
    implements PlatformScopedStorageXFileExtension, SecurityScopedResource {}
