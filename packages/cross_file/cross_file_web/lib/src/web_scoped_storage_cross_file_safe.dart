// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable, visibleForTesting;

/// Base implementation of [PlatformScopedStorageXFileCreationParams] for web.
///
/// This implementation exists to provide access to platform-specific features
/// that are safe to use when compiling on multiple platforms without a stub.
///
/// This class is a stub for the implementation in
/// `web_scoped_storage_cross_file.dart`.
@immutable
base class WebScopedStorageXFileCreationParams extends PlatformScopedStorageXFileCreationParams {
  /// Constructs a [WebScopedStorageXFileCreationParams].
  const WebScopedStorageXFileCreationParams._({required super.uri});

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
  ///
  /// This is a stub for the method in `web_scoped_storage_cross_file.dart`.
  factory WebScopedStorageXFileCreationParams.fromBytes(
    // ignore: avoid_unused_constructor_parameters
    Uint8List bytes, {
    // ignore: avoid_unused_constructor_parameters
    String? fileName,
    // ignore: avoid_unused_constructor_parameters
    bool autoRevokeObjectUrl = true,
    // The type should be a `XFileTestOverrides`. It can't be imported in this
    // stub without breaking other platforms.
    // ignore: avoid_unused_constructor_parameters
    @visibleForTesting dynamic testOverrides,
  }) => const WebScopedStorageXFileCreationParams._(uri: '');
}

/// Provides platform-specific features for [WebScopedStorageXFile].
mixin WebScopedStorageXFileExtension implements PlatformScopedStorageXFileExtension {
  /// Attempts to download a [Blob], with [suggestedName] as the filename.
  Future<void> download([String? suggestedName]);
}
