// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file_platform_interface/cross_file_platform_interface.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'cross_file.dart';

/// A reference to a local data resource within a devices scoped storage.
///
/// ## Platform-Specific Features
/// This class contains an underlying implementation provided by the current
/// platform. Once a platform implementation is imported, the examples below
/// can be followed to use features provided by a platform's implementation.
///
/// {@macro cross_file.XFile.fromPlatformCreationParams}
///
/// Below is an example of accessing the platform-specific extension for
/// the Android implementation of `cross_file`:
///
/// ```dart
/// final SharedStorageXFile file = XFile('my/file.txt');
///
/// final AndroidSharedStorageXFileExtension? androidExtension =
///     file.maybeGetPlatformExtension<AndroidSharedStorageXFileExtension>();
/// if (androidExtension != null) {
///   print(androidExtension.file.path);
/// }
/// ```
@immutable
class SharedStorageXFile extends XFile {
  /// Constructs a [SharedStorageXFile].
  ///
  /// See [SharedStorageXFile.fromPlatformCreationParams] for setting parameters
  /// for a specific platform.
  SharedStorageXFile(String uri)
    : this.fromPlatformCreationParams(
        PlatformSharedStorageXFileCreationParams(uri: uri),
      );

  /// Constructs a [SharedStorageXFile] from creation params for a specific
  /// platform.
  ///
  /// {@template cross_file.SharedStorageXFile.fromPlatformCreationParams}
  /// Below is an example of setting platform-specific creation parameters for
  /// the Android implementation of `cross_file`:
  ///
  /// ```dart
  /// var params = const PlatformXFileCreationParams(uri: 'my/file.txt');
  ///
  /// if (CrossFilePlatform.instance is CrossFileAndroid) {
  ///   params = AndroidSharedStorageXFileCreationParams.fromCreationParams(
  ///     params,
  ///   );
  /// }
  ///
  /// final file = SharedStorageXFile.fromCreationParams(params);
  /// ```
  /// {@endtemplate}
  SharedStorageXFile.fromPlatformCreationParams(
    PlatformSharedStorageXFileCreationParams params,
  ) : this.fromPlatform(PlatformSharedStorageXFile(params));

  /// Constructs a [SharedStorageXFile] from a specific platform implementation.
  const SharedStorageXFile.fromPlatform(PlatformSharedStorageXFile super.platform)
    : super.fromPlatform();

  @override
  PlatformSharedStorageXFile get platform =>
      super.platform as PlatformSharedStorageXFile;
}
