// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';

export 'src/cross_directory.dart';
export 'src/cross_entity.dart';
export 'src/cross_file.dart';
export 'src/file_system/file_system_cross_directory.dart';
export 'src/file_system/file_system_cross_file.dart';
export 'src/scoped_storage/scoped_storage_cross_directory.dart';
export 'src/scoped_storage/scoped_storage_cross_file.dart';

/// Provides top level functions for the `cross_file` package.
final class CrossFile {
  /// The current platform implementation.
  ///
  /// The platform implementation is set automatically at runtime based on the
  /// target platform. Use this to check which platform is currently set when
  /// platform implementations are imported.
  ///
  /// Example:
  ///
  /// ```dart
  /// late final XFile file;
  ///
  /// switch (CrossFile.implementation) {
  ///   case CrossFileWeb():
  ///     final params = WebScopedStorageXFileCreationParams.fromObjectUrl(
  ///       objectUrl: 'blob:https://some/url:for/file',
  ///     );
  ///     file = ScopedStorageXFile.fromCreationParams(params);
  ///   case CrossFileDarwin():
  ///     file = ScopedStorageXFile.fromUri(Uri.file('private/my/file.txt'));
  ///   default:
  ///     file = XFile.fileSystem(path: '/my/file.txt'));
  /// }
  /// ```
  static CrossFilePlatform? get implementation => CrossFilePlatform.instance;
}
