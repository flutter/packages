// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;

/// Base implementation of [PlatformScopedStorageXFileCreationParams] for web.
@immutable
base class WebScopedStorageXFileCreationParams extends PlatformScopedStorageXFileCreationParams {
  /// Constructs a [WebScopedStorageXFileCreationParams].
  const WebScopedStorageXFileCreationParams({required super.uri});

  /// Constructs a [WebScopedStorageXFileCreationParams] by creating a [Blob]
  /// from [bytes].
  ///
  /// Creates an Object URL from the [Blob] created from the provided bytes.
  /// See [URL.createObjectURL].
  ///
  /// If a [fileName] is provided, the underlying [Blob] is created as a [File]
  /// with the [fileName] passed to it.
  ///
  /// `autoRevokeObjectUrl`: Whether the created object url should be revoked
  /// when this instance is garbage collected. See [URL.revokeObjectURL].
  const WebScopedStorageXFileCreationParams.fromBytes(
    // ignore: avoid_unused_constructor_parameters
    Uint8List bytes, {
    // ignore: avoid_unused_constructor_parameters
    String? fileName,
    // ignore: avoid_unused_constructor_parameters
    bool autoRevokeObjectUrl = true,
  }) : super(uri: '');
}

/// Implementation of [PlatformScopedStorageXFile] for web.
base class WebScopedStorageXFile extends PlatformScopedStorageXFile
    with WebScopedStorageXFileExtension {
  /// Constructs a [WebScopedStorageXFile].
  WebScopedStorageXFile(super.params) : super.implementation();

  @override
  PlatformScopedStorageXFileExtension? get extension => this;

  @override
  Future<bool> canRead() async => false;

  @override
  Future<bool> exists() async {
    return false;
  }

  @override
  Future<DateTime?> lastModified() async {
    return null;
  }

  @override
  Future<int?> length() async {
    return null;
  }

  @override
  Stream<Uint8List> openRead([int? start, int? end]) async* {
    throw UnimplementedError('openRead is not implemented on the current platform');
  }

  @override
  Future<Uint8List> readAsBytes() async {
    throw UnimplementedError('readAsBytes is not implemented on the current platform');
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    throw UnimplementedError('readAsString is not implemented on the current platform');
  }

  @override
  Future<void> download([String? suggestedName]) async {
    throw UnimplementedError('download is not implemented on the current platform');
  }

  @override
  Future<String?> name() async {
    return null;
  }

  @override
  Future<void> dispose() async {}
}

/// Provides platform-specific features for [WebScopedStorageXFile].
mixin WebScopedStorageXFileExtension implements PlatformScopedStorageXFileExtension {
  /// Attempts to download a [Blob], with [suggestedName] as the filename.
  Future<void> download([String? suggestedName]);
}
